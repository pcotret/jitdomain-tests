import glob
import json
import os
import re
import shutil
import subprocess
from datetime import datetime
from typing import Dict, List, Optional, Union

from suite.data import RunResult, TestData, TestResult, default_test_data
from suite.exceptions import (
    EnvironmentException,
    ExpectedTestResultNotFound,
    MissingRunResultsFile,
    UnknownTestResult,
)

# Info on test source files
TEST_DIR: str = "tests"
RES_DIR: str = "results"
BASE_MEM_ACCESS_TESTS: str = f"{TEST_DIR}/mem-access/base/"
DUP_MEM_ACCESS_TESTS: str = f"{TEST_DIR}/mem-access/duplicated/"
SS_MEM_ACCESS_TESTS: str = f"{TEST_DIR}/mem-access/shadow-stack/"
DOMAIN_CHANGE_TESTS: str = f"{TEST_DIR}/domain-change/"
CSR_TESTS: str = f"{TEST_DIR}/csr/"

ALL_TESTS: List[str] = [
    BASE_MEM_ACCESS_TESTS,
    DUP_MEM_ACCESS_TESTS,
    SS_MEM_ACCESS_TESTS,
    DOMAIN_CHANGE_TESTS,
    CSR_TESTS,
]

# ANSI escape codes for text colors
GREEN = "\033[92m"
ORANGE = "\033[93m"
RED = "\033[91m"
RESET = "\033[0m"  # Reset the color

# Test results helpers
TEST_RESULT_NAMES: Dict[TestResult, str] = {
    TestResult.EXP_FAILURE: f"{GREEN}Expected failure{RESET}",
    TestResult.EXP_SUCCESS: f"{GREEN}Expected success{RESET}",
    TestResult.FAILURE: f"{ORANGE}Failure{RESET}",
    TestResult.ERROR: f"{RED}Error{RESET}",
}

# Helpers
# \________


# Source file name extractor
def glob_s_files(paths: List[str]) -> List[str]:
    s_files = []
    for path in paths:
        s_files.extend(glob.glob(f"{path}/*.S"))
    return s_files


def default_run_file() -> str:
    runs: List[str] = glob.glob(f"{RES_DIR}/*-run/run-results.json")
    runs.sort(reverse=True)
    if runs:
        return runs[0]
    raise MissingRunResultsFile(
        "No run results found, expecting one as results/*-run/run-results.json."
    )


def check_envs() -> None:
    if "RISCV" not in os.environ:
        raise EnvironmentException(
            "RISCV environment variable is not set. Please define it "
            "to point to your installed toolchain location "
            "(i.e. export RISCV=path/to/your/toolchain)"
        )
    if "CORE" not in os.environ:
        raise EnvironmentException(
            "CORE environment variable is not set. Please define it "
            "to point to the root of the used processor "
            "(i.e. export CORE=path/to/cva6)"
        )


def cleanup_build() -> None:
    try:
        subprocess.run(
            ["make", "clean"],
            timeout=10,
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        subprocess.run(
            ["make", "alldump"],
            timeout=10,
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except (
        FileNotFoundError,
        subprocess.CalledProcessError,
        subprocess.TimeoutExpired,
    ):
        # TODO: Log error instead of stopping
        raise


def define_test_res(expected: RunResult, actual: RunResult) -> TestResult:
    if actual == RunResult.ERROR:
        return TestResult.ERROR
    if expected != actual:
        return TestResult.FAILURE
    if expected == RunResult.SUCCESS:
        return TestResult.EXP_SUCCESS
    return TestResult.EXP_FAILURE


class Runner:
    # Collection
    # \___________

    def collect(
        self, group: str = "tests", out: str = f"{RES_DIR}/collect.json"
    ) -> List[TestData]:
        test_structs: List[TestData] = []
        # 1. Collect targetted .S files
        # TODO: LOGGER
        print("[C] Collecting expected test suite results...")
        paths: List[str] = [path for path in ALL_TESTS if group in path]
        s_files: List[str] = glob_s_files(paths=paths)
        # 2. For each file
        for s_file in s_files:
            test_struct: TestData = default_test_data()
            # 2.1 Parse for the expected status
            with open(s_file, "r") as file:
                expected_com: str = ""
                for line in file:
                    match = re.search(r"# Should:\s*(\w+)", line)
                    if match:
                        expected_com = match.group(1).lower()
                        break
                if not expected_com:
                    raise ExpectedTestResultNotFound(
                        f"{s_file.split('/')[-1]}: No match with comment # Should:"
                        " <test result>."
                    )

            # 2.2. Fill the corresponding structure
            expected: RunResult
            if "fail" in expected_com:
                expected = RunResult.FAILURE
            elif "pass" in expected_com:
                expected = RunResult.SUCCESS
            else:
                raise UnknownTestResult("Expected 'pass' or 'fail' as a run result.")

            name: str = s_file.split("/")[-1][:-2]
            group_name: str = s_file.split("tests/")[1].split(name)[0]
            test_struct["group"] = group_name
            test_struct["name"] = name
            test_struct["expected"] = expected
            test_structs.append(test_struct)
        # 3. Output the json
        # TODO: LOGGER
        print(f"[C] Writing expected test suite results to {out}...")
        with open(out, "w") as outfile:
            json.dump(test_structs, outfile, indent=2, separators=(",", ": "))

        return test_structs

    # Test runs
    # \__________

    def launch(self, conf_file: str = f"{RES_DIR}/collect.json") -> List[TestData]:
        # 1. Environment check
        # TODO: LOGGER
        print("[R] Checking environment variables...")
        check_envs()
        # 2. Environment cleanup and build
        # TODO: LOGGER
        print("[R] Cleaning up and building test binaries...")
        cleanup_build()
        # 3. Directory setup
        run_dir_name: str = (
            f"{RES_DIR}/{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}-run"
        )
        os.mkdir(run_dir_name)
        # 4. Load collection
        # TODO: LOGGER
        print("[R] Loading collected data...")
        with open(conf_file, "r") as collect_data:
            test_structs: List[TestData] = json.load(collect_data)
        # 4. For each test
        print("[R] Running tests...")
        test_structs = sorted(test_structs, key=lambda x: (x["group"], x["name"]))
        for test_struct in test_structs:
            run_completed: bool = False
            command_output: str = ""
            print(f"[R] - Running {test_struct['group']} - {test_struct['name']}...")
            try:
                core_path: Optional[str] = os.environ.get("CORE")
                command_result = subprocess.run(
                    [
                        f"{core_path}/work-ver/Variane_testharness",
                        f"bin/{test_struct['name']}.elf",
                    ],
                    timeout=200,
                    check=True,
                    text=True,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                )
                run_completed = True
                command_output = f"{command_result.stdout} {command_result.stderr}"
            # 4.1 Run test and capture output
            except subprocess.CalledProcessError as command_result:
                run_completed = True
                command_output = f"{command_result.stdout} {command_result.stderr}"
            except (
                FileNotFoundError,
                subprocess.TimeoutExpired,
            ) as err:
                print(err)
                run_completed = False
            # 4.2 Parse output and setup run result accordingly
            run_result: RunResult = RunResult.INIT
            if run_completed:
                if "FAILED" in command_output:
                    run_result = RunResult.FAILURE
                elif "SUCCESS" in command_output:
                    run_result = RunResult.SUCCESS
                else:
                    raise UnknownTestResult(
                        "Expected 'SUCCESS' or 'FAILED' in the run result output."
                    )
            else:
                run_result = RunResult.ERROR
            test_struct["run"] = run_result

            # 4.3 Define the result of the test itself
            test_result: TestResult = define_test_res(
                expected=test_struct["expected"], actual=test_struct["run"]
            )
            print(f"[R] - Test run complete: {TEST_RESULT_NAMES[test_result]}...")
            test_struct["result"] = test_result

            # 4.4 Copy the logfile
            shutil.copy(
                src="trace_hart_00.dasm",
                dst=f"{run_dir_name}/{test_struct['name']}.corelog",
            )

        # 5. Output the json
        # TODO: Logger
        print("[R] - Writing test suite result...")
        with open(f"{run_dir_name}/run-results.json", "w") as outfile:
            json.dump(test_structs, outfile, indent=2, separators=(",", ": "))

        return test_structs

    def report(
        self, run_file: Optional[str] = None
    ) -> Dict[str, Dict[Union[str, TestResult], int]]:
        # 0. Take the most recent run by default
        if run_file is None:
            run_file = default_run_file()
        with open(run_file, "r") as collect_data:
            test_structs: List[TestData] = json.load(collect_data)

        suite_counter: Dict[str, Dict[Union[str, TestResult], int]] = {}
        default_val: Dict[Union[str, TestResult], int] = {
            "total": 0,
            TestResult.EXP_SUCCESS: 0,
            TestResult.EXP_FAILURE: 0,
            TestResult.FAILURE: 0,
            TestResult.ERROR: 0,
        }

        # 1. For each group
        for test_struct in test_structs:
            # 1.1 Check if the group already exists
            group = test_struct["group"]
            test_result = test_struct["result"]
            if suite_counter.get(group) is None:
                suite_counter[group] = default_val.copy()
            suite_counter[group][test_result] += 1
            suite_counter[group]["total"] += 1

        # 2. Display results
        for group, stats in suite_counter.items():
            passed: int = stats[TestResult.EXP_FAILURE] + stats[TestResult.EXP_SUCCESS]
            total: int = stats["total"]
            colored_output: str
            if passed == total:
                colored_output = GREEN
            elif passed == 0:
                colored_output = RED
            else:
                colored_output = ORANGE
            print(
                f"{group}: {colored_output}{passed}/{total}{RESET}\n"
                f"{GREEN}   {stats[TestResult.EXP_SUCCESS]} expected successes{RESET}\n"
                f"{GREEN}   {stats[TestResult.EXP_FAILURE]} expected failures{RESET}\n"
                f"{ORANGE}   {stats[TestResult.FAILURE]} failures{RESET}\n"
                f"{RED}   {stats[TestResult.ERROR]} errors{RESET}\n"
            )

        return suite_counter


if __name__ == "__main__":
    runner = Runner()
    runner.collect("domain")
    runner.launch()
    runner.report()
