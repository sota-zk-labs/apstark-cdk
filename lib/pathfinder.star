def apply_default(args):
    return {
        "image": "sotazklabs/pathfinder:latest",
        "name": "pathfinder",
        "rpc_port": 9545,
    } | args


def start(plan, args, suffix):
    args = apply_default(args)
    ports = {}
    port["rpc"] = PortSpec(
        number=args["rpc_port"], application_protocol="http", wait=None
    )

    name = args["name"] + suffix

    madara_service = plan.get_service(name="madara" + suffix)
    madara_gateway_url = "http://{}:{}/gateway".format(
        madara_service.ip_address, madara_service.ports["gateway"].number
    )

    madara_feeder_gateway_url = "http://{}:{}/feeder_gateway".format(
        madara_service.ip_address, madara_service.ports["gateway"].number
    )

    service = plan.add_service(
        name=name,
        config=ServiceConfig(
            image=args["image"],
            ports=ports,
            env_vars={},
            cmd=[
                "--network",
                "custom",
                "--chain-id",
                "{}".format("MADARA_DEVNET"),
                "--feeder-gateway-url",
                "{}".format(madara_feeder_gateway_url),
                "--gateway-url",
                "{}".format(madara_gateway_url),
                "--storage.state-tries",
                "archive",
                "--data-directory",
                "../pathfinder-db",
            ],
        ),
    )
