def apply_default(args):
    return {
        "name": "sqs-admin-ui",
        "image": "akilamaxi/sqs-admin-ui:v1",
        "port": 8081,
    } | args


def run(plan, args, suffix):
    args = apply_default(args)
    ports = {}
    ports["http"] = PortSpec(
        number=args["number"], application_protocol="http", wait=None
    )

    name = args["name"] + suffix

    localstack_service = plan.get_service(name="localstack" + suffix)
    localstack_url = "http://{}:{}".format(
        localstack_service.ip_address, localstack_service.ports["http"].number
    )

    config = ServiceConfig(
        image=args["image"],
        ports=ports,
        env_vars={
            "DEFAULT_REGION": localstack_service.config.env_vars["DEFAULT_REGION"],
            "AWS_ACCESS_KEY_ID": localstack_service.config.env_vars[
                "AWS_ACCESS_KEY_ID"
            ],
            "AWS_SECRET_ACCESS_KEY": localstack_service.config.env_vars[
                "AWS_SECRET_ACCESS_KEY"
            ],
            "SQS_ENDPOINT_URL": localstack_url,
        },
    )

    plan.add_service(name=name, config=config, description="Start SQS Admin UI Service")
