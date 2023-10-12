class ExpectedTestResultNotFound(Exception):
    """
    Raised when no test result is found by the parser, in a comment like:
    # Should:  <test_result>
    """

    pass


class UnknownTestResult(Exception):
    """
    Raised when the parsed test results is unknown, not 'fail' or 'pass'.
    """

    pass


class EnvironmentException(Exception):
    """
    Raised when env vars are not found.
    """

    pass
