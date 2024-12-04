def apply_default(args):
    return {
        "image": "sotazklabs/madara:latest",
        "name": "madara",
        "rpc_port": 9944,
        "gateway_port": 8080,
    } | args


def start(plan, args, suffix):
    args = apply_default(args)
    ports = {}
    ports["rpc"] = PortSpec(
        number=args["rpc_port"],
        application_protocol="http",
        wait=None,
    )

    ports["gateway"] = PortSpec(
        number=args["gateway_port"],
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
                "--chain-config-path=configs/presets/devnet.yaml",
                "--rpc-port={}".format(args["rpc_port"]),
                "--rpc-methods=unsafe",
                "--rpc-cors='*'",
                "--rpc-external",
                "--no-l1-sync",
                "--feeder-gateway-enable",
                "--gateway-enable",
                "--gateway-external",
                "--telemetry-disabled",
            ],
        ),
    )
