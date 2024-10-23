madara_orchestrator_package = import_module(
    "./lib/madara_orchestrator/madara_orchestrator.star"
)


def run(plan, args, suffix):
    madara_orchestrator_package.start(plan, args, suffix)
