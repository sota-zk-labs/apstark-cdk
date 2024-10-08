constants = import_module("./src/package_io/constants.star")

DEFAULT_ARGS = {
    "deployment_suffix": "-001",
    "global_log_level": "info",
}

# A list of fork identifiers currently supported by Kurtosis CDK.
SUPPORTED_FORK_IDS = [9, 11, 12]

def parse_args(args):
    args = DEFAULT_ARGS | args
    validate_global_log_level(args["global_log_level"])
    return args

def validate_global_log_level(global_log_level):
    if global_log_level not in (
        constants.GLOBAL_LOG_LEVEL.error,
        constants.GLOBAL_LOG_LEVEL.warn,
        constants.GLOBAL_LOG_LEVEL.info,
        constants.GLOBAL_LOG_LEVEL.debug,
        constants.GLOBAL_LOG_LEVEL.trace,
    ):
        fail(
            "Unsupported global log level: '{}', please use '{}', '{}', '{}', '{}' or '{}'".format(
                global_log_level,
                constants.GLOBAL_LOG_LEVEL.error,
                constants.GLOBAL_LOG_LEVEL.warn,
                constants.GLOBAL_LOG_LEVEL.info,
                constants.GLOBAL_LOG_LEVEL.debug,
                constants.GLOBAL_LOG_LEVEL.trace,
            )
        )
