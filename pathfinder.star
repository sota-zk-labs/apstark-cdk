pathfinder_package = import_module("./lib/pathfinder.star")


def run(plan, args, suffix):
    pathfinder_package.start(plan, args, suffix)
