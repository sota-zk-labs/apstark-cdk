madara_package = import_module("./lib/madara.star")


def run(plan, args, suffix):
    madara_package.start(plan, args, suffix)
