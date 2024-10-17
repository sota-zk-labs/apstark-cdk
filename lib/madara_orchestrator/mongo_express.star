def apply_default(args):
    return {"image": "mongo-express", "name": "mongo-express", "port": 8080} | args


def run(plan, args, suffix):
    args = apply_default(args)
    ports = {}
    ports["http"] = PortSpec(
        number=args["port"], application_protocol="http", wait=None
    )

    name = args["name"] + suffix

    mongo_service = plan.get_service(name="mongodb" + suffix)
    mongo_port = mongo_service.ports["mongodb"].number

    config = ServiceConfig(
        image=args["image"],
        ports=ports,
        env_vars={
            "ME_CONFIG_MONGODB_SERVER": mongo_service.name,
            "ME_CONFIG_MONGODB_PORT": "{}".format(mongo_port),
            "ME_CONFIG_MONGODB_ENABLE_ADMIN": "True",
            "ME_CONFIG_MONGODB_AUTH_DATABASE": "admin",
            "ME_CONFIG_MONGODB_AUTH_USERNAME": "root",
            "ME_CONFIG_MONGODB_AUTH_PASSWORD": "rootpasswd",
            "ME_CONFIG_BASICAUTH_USERNAME": "express_user",
            "ME_CONFIG_BASICAUTH_PASSWORD": "express_pwd",
        },
    )

    plan.add_service(name=name, config=config, description="Starting Mongo Express")
