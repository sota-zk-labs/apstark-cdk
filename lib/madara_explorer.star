database_package = import_module("../databases.star")


def apply_default(args):
    return {
        "image": "sotazklabs/stark_compass_explorer:v0.2.38",
        "name": "madara-explorer",
        "port": 4000,
    } | args


def run(plan, args, suffix):
    args = apply_default(args)
    ports = {}
    ports["http"] = PortSpec(
        number=args["port"], application_protocol="http", wait=None
    )

    name = args["name"] + suffix

    madara_service = plan.get_service(name="madara" + suffix)
    madara_url = "http://{}:{}".format(
        madara_service.ip_address, madara_service.ports["rpc"].number
    )

    postgres_service = plan.get_service(name="postgres" + suffix)
    postgres_config = database_package.get_db_configs(suffix)
    postgres_url = "postgresql://{}:{}@{}:{}/{}".format(
        postgres_config["madara_explorer_db"]["user"],
        postgres_config["madara_explorer_db"]["password"],
        postgres_service.ip_address,
        postgres_service.ports["postgres"].number,
        postgres_config["madara_explorer_db"]["name"],
    )

    plan.add_service(
        name=name,
        config=ServiceConfig(
            image=args["image"],
            ports=ports,
            env_vars={
                "DB_TYPE": "postgresql",
                "DISABLE_MAINNET_SYNC": "True",
                "DISABLE_SEPOLIA_SYNC": "False",
                "RPC_API_HOST": madara_url,
                "SEPOLIA_RPC_API_HOST": madara_url,
                "SECRET_KEY_BASE": "JyULoT5cLBifW+XNEuCTVoAb+SaFgQt9j227RN0cKpR3wTsrApGd1HNcgeopemyl",
                "DATABASE_URL": postgres_url,
                "PHX_HOST": "*",
                "PORT": "{}".format(args["port"]),
            },
        ),
        description="Starting Madara Explorer Service",
    )
