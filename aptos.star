aptos_package = import_module("./lib/aptos.star")

def run(plan, args, suffix):
    aptos_package.start(
        plan,
        args,
        suffix,
    )
