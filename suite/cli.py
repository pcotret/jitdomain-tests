"""
Module that contains the command line app.

Why does this file exist, and why not put this in __main__?

You might be tempted to import things from __main__ later, but that will cause
problems: the code will get executed twice:

- When you run `python -m gigue` python will execute
``__main__.py`` as a script. That means there won't be any
``gigue.__main__`` in ``sys.modules``.
- When you import __main__ it will get executed again (as a module) because
there's no ``runner.__main__`` in ``sys.modules``.

Also see (1) from http://click.pocoo.org/5/setuptools/#setuptools-integration
"""


import argparse
import sys
from typing import List, Optional

from suite.runner import RES_DIR, Runner, default_run_file


class Parser(argparse.ArgumentParser):
    def __init__(self):
        super(Parser, self).__init__(description="JITDomain test suite runner")
        self.add_parse_arguments()

    def add_parse_arguments(self):
        # Setup subparsers
        subparsers = self.add_subparsers(
            dest="command", parser_class=argparse.ArgumentParser
        )

        # Collect subparser
        collect_parser = subparsers.add_parser(
            name="collect",
            help=(
                "Collects the tests expected results for a given group. A group"
                " corresponds to a word in the directory path of the tests. For"
                " example, using group 'domain-change' will select all tests within"
                " that subdirectory, and 'mem-access' all tests in the subdirectories"
                " 'base'/'duplicated'/'shadow-stack'."
            ),
        )
        collect_parser.add_argument(
            "-g",
            "--group",
            type=str,
            default="tests",
            help="Name of the group to collect.",
        )

        # Launch subparser
        launch_parser = subparsers.add_parser(
            name="launch",
            help=(
                "Launches all tests that have been collected in the corresponding"
                " collect.json file."
            ),
        )
        launch_parser.add_argument(
            "-f",
            "--collectfile",
            type=str,
            default=f"{RES_DIR}/collect.json",
            help="Collect results file to run.",
        )

        # Report subparser
        report_subparser = subparsers.add_parser(
            name="report",
            help=(
                "Reports the results of a test suite run based on a 'run-results.json'"
                " file."
            ),
        )
        report_subparser.add_argument(
            "-f",
            "--runfile",
            type=str,
            default=default_run_file(),
            help="Results file to report on.",
        )

        # All subparser
        all_subparser = subparsers.add_parser(
            name="all",
            help="Performs the three steps of collect/launch/report on an input group.",
        )
        all_subparser.add_argument(
            "-g",
            "--group",
            type=str,
            default="tests",
            help="Name of the group to collect.",
        )

    def parse(self, args):
        return self.parse_args(args)


def main(argv: Optional[List[str]] = None) -> int:
    if argv is None:
        argv = sys.argv[1:]

    parser = Parser()
    args = parser.parse(argv)

    if not argv:
        parser.print_help()
        return 0

    runner = Runner()

    if args.command == "collect":
        runner.collect(args.group)
    elif args.command == "launch":
        runner.launch(args.collectfile)
    elif args.command == "report":
        runner.report(args.runfile)
    elif args.command == "all":
        runner.collect(args.group)
        runner.launch()
        runner.report()
    else:
        parser.print_help()
        return 1

    return 0
