madara_explorer_package = import_module("./lib/madara_explorer.star")


def run(plan, args, suffix):
    madara_explorer_package.run(plan, args, suffix)
