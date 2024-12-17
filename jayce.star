jayce_package = import_module("./lib/jayce.star")


def run(plan, args, suffix):
    jayce_package.start(
        plan,
        args,
        suffix,
    )
