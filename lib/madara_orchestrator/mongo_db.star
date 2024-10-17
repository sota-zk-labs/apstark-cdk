USE_REMOTE_MONGODB = False

MONGODB_HOSTNAME = "127.0.0.1"

MONGODB_IMAGE = "mongo:latest"
MONGODB_SERVICE_NAME = "mongodb"
MONGODB_PORT = "27017"

MONGO_ROOT_USERNAME = "root"
MONGO_ROOT_PASSWORD = "rootpasswd"

MADARA_ENV_DBS = {
    "madara_orchestrator_db": {
        "name": "madara_orchestrator_db",
        "user": "madara_orchestrator_user",
        "password": "redacted",
    }
}

DATABASES = MADARA_ENV_DBS


def run(plan, suffix):
    db_configs = get_db_configs(suffix)
    create_mongodb_service(plan, db_configs, suffix)


def get_db_configs(suffix):
    dbs = DATABASES

    configs = {
        k: v
        | {
            "hostname": MONGODB_HOSTNAME
            if USE_REMOTE_MONGODB
            else _service_name(suffix),
            "port": MONGODB_PORT,
        }
        for k, v in dbs.items()
    }
    return configs


def _service_name(suffix):
    return MONGODB_SERVICE_NAME + suffix


def create_mongodb_service(plan, db_configs, suffix):
    init_mongo_script_tpl = read_file(src="../../templates/database/init-mongo.js")
    init_script = plan.render_templates(
        name="init-mongo.js" + suffix,
        config={
            "init-mongo.js": struct(
                template=init_mongo_script_tpl,
                data={
                    "dbs": db_configs,
                    "root_db": MONGO_INITDB_ROOT_USERNAME,
                    "root_user": MONGO_INITDB_ROOT_PASSWORD,
                },
            )
        },
    )

    mongodb_service_config = ServiceConfig(
        image=MONGODB_IMAGE,
        ports={
            "mongodb": PortSpec(
                MONGODB_PORT, application_protocol="mongodb", wait=None
            ),
        },
        env_vars={
            "MONGO_INITDB_ROOT_USER": MONGO_ROOT_USERNAME,
            "MONGO_INTIDB_ROOT_PASSWORD": MONGO_ROOT_PASSWORD,
        },
        file={"/docker-entrypoint-initdb.d/": init_script},
        cmd=["-N 1000"],
    )

    plan.add_service(
        name=_service_name(suffix),
        config=mongodb_service_config,
        description="Starting MongoDB Service",
    )
