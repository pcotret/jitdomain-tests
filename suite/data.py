from enum import Enum
from typing import TypedDict


class SuiteData(TypedDict):
    pass


# Inherits from int to make json happy
class RunResult(int, Enum):
    INIT = 0
    SUCCESS = 1  # Run succeeded
    FAILURE = 2  # Run failed
    ERROR = 3  # Error (I/O, timer, ..)


class TestResult(int, Enum):
    INIT = 0
    EXP_SUCCESS = 1  # Success and expected success
    EXP_FAILURE = 2  # Failure and expected failure
    FAILURE = 3  # Mismatch between expected and result
    ERROR = 4  # Error in the run


class TestData(SuiteData):
    name: str
    group: str
    expected: RunResult
    run: RunResult
    result: TestResult


def default_test_data() -> TestData:
    return {
        "name": "",
        "group": "tests",
        "expected": RunResult.INIT,
        "run": RunResult.INIT,
        "result": TestResult.INIT,
    }
