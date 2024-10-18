def apply_default(args):
    return {
        "name": "localstack",
        "image": "localstack/localstack:latest",
        "port": 4566,
        "default_region": "us-east-1",
        "aws_access_key_id": "test",
        "aws_secret_access_key": "test",
    } | args


def run(plan, args, suffix):
    args = apply_default(args)
    ports = {}
    ports["http"] = PortSpec(
        number=args["port"], application_protocol="http", wait=None
    )

    name = args["name"] + suffix

    config = ServiceConfig(
        image=args["image"],
        ports=ports,
        env_vars={
            "DEFAULT_REGION": args["default_region"],
            "AWS_ACCESS_KEY_ID": args["aws_access_key_id"],
            "AWS_SECRET_ACCESS_KEY": args["aws_secret_access_key"],
        },
    )

    plan.add_service(name=name, config=config, description="Start Localstack Service")
