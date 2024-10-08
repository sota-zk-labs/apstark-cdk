def apply_default(args):
    return {
        "image": "sotazklabs/madara:latest",
        "name": "madara",
        "rpc_port": 9944,
    } | args


def start(plan, args, suffix):
    args = apply_default(args)
    ports = {}
    ports["rpc"] = PortSpec(
        number=args["rpc_port"],
        application_protocol="http",
        wait=None,
    )

    name = args["name"] + suffix

    service = plan.add_service(
        name=name,
        config=ServiceConfig(
            image=args["image"],
            ports=ports,
            cmd=[
                "--devnet",
                "--name=madara",
                "--base-path=../madara_db",
                "--rpc-port={}".format(args["rpc_port"]),
                "--rpc-methods=unsafe",
                "--rpc-cors=all",
                "--rpc-external",
                "--no-l1-sync",
                "--telemetry-disabled",
            ],
        ),
    )
