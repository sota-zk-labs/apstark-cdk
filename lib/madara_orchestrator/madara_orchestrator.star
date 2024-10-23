mongo_db_service = "./mongo_db.star"
mongo_express_service = "./mongo_express.star"
localstack_service = "./localstack.star"
sqs_admin_ui_service = "./sqs_admin_ui.star"


def apply_default(args):
    return {
        "name": "madara-orchestrator",
        "image": "sotazklabs/madara-orchestrator:latest",
        "port": 3000,
        "enable_mongo_express": True,
        "enable_sqs_admin_ui": True,
    } | args


def start(plan, args, suffix):
    args = apply_default(args)
    ports = {}
    ports["http"] = PortSpec(
        number=args["number"],
        application_protocol="http",
        wait=None,
    )

    name = args["name"] + suffix

    mongo_db_service = import_module(mongo_db_service).run(plan, args, suffix)

    if args["enable_mongo_express"]:
        mongo_express_service = import_module(mongo_express_service).run(
            plan, args, suffix
        )
    else:
        plan.print("Skipping Deployment Mongo Express")

    localstack_service = import_module(localstack_service).run(plan, args, suffix)

    if args["enable_sqs_admin_ui"]:
        sqs_admin_ui_service = import_module(sqs_admin_ui_service).run(
            plan, args, suffix
        )
    else:
        plan.print("Skipping Deployment Sqs Admin UI")

    aws_endpoint = "http://{}.{}:{}".format(
        localstack_service.config.env_vars["DEFAULT_REGION"],
        localstack_service.ip_address,
        localstack_service.ports["http"].number,
    )

    mongodb_url = "mongodb://{}:{}".format(
        mongo_db_service.ip_address, mongo_db_service.ports["mongodb"].number
    )

    madara_service = plan.get_service(name="madara" + suffix)
    madara_url = "http://{}:{}".format(
        madara_service.ip_address, madara_service.ports["rpc"].number
    )

    config = ServiceConfig(
        image=args["image"],
        ports=ports,
        env_vars={
            "HOST": "127.0.0.1",
            "PORT": "{}".format(args["port"]),
            "AWS_ACCESS_KEY_ID": localstack_service.config.env_vars[
                "AWS_ACCESS_KEY_ID"
            ],
            "AWS_SECRET_ACCESS_KEY": localstack_service.config.env_vars[
                "AWS_SECRET_ACCESS_KEY"
            ],
            "AWS_REGION": localstack_service.config.env_vars["DEFAULT_REGION"],
            "AWS_DEFAULT_REGION": "localhost",
            "DATA_STORAGE": "s3",
            "AWS_S3_BUCKET_NAME": "madara-orchestrator-test-bucket",
            "QUEUE_PROVIDER": "sqs",
            "SQS_SNOS_JOB_PROCESSING_QUEUE_URL": "http://sqs.{}/000000000000/madara_orchestrator_snos_job_processing_queue".format(
                aws_endpoint
            ),
            "SQS_SNOS_JOB_VERIFICATION_QUEUE_URL": "http://sqs.{}/000000000000/madara_orchestrator_snos_job_verification_queue".format(
                aws_endpoint
            ),
            "SQS_PROVING_JOB_PROCESSING_QUEUE_URL": "http://sqs.{}/000000000000/madara_orchestrator_proving_job_processing_queue".format(
                aws_endpoint
            ),
            "SQS_PROVING_JOB_VERIFICATION_QUEUE_URL": "http://sqs.{}/000000000000/madara_orchestrator_proving_job_verification_queue".format(
                aws_endpoint
            ),
            "SQS_DATA_SUBMISSION_JOB_PROCESSING_QUEUE_URL": "http://sqs.{}/000000000000/madara_orchestrator_data_submission_job_processing_queue".format(
                aws_endpoint
            ),
            "SQS_DATA_SUBMISSION_JOB_VERIFICATION_QUEUE_URL": "http://sqs.{}/000000000000/madara_orchestrator_data_submission_job_verification_queue".format(
                aws_endpoint
            ),
            "SQS_UPDATE_STATE_JOB_PROCESSING_QUEUE_URL": "http://sqs.{}/000000000000/madara_orchestrator_update_state_job_processing_queue".format(
                aws_endpoint
            ),
            "SQS_UPDATE_STATE_JOB_VERIFICATION_QUEUE_URL": "http://sqs.{}/000000000000/madara_orchestrator_update_state_job_verification_queue".format(
                aws_endpoint
            ),
            "SQS_JOB_HANDLE_FAILURE_QUEUE_URL": "http://sqs.{}/000000000000/madara_orchestrator_job_handle_failure_queue".format(
                aws_endpoint
            ),
            "SQS_WORKER_TRIGGER_QUEUE_URL": "http://sqs.{}/000000000000/madara_orchestrator_worker_trigger_queue".format(
                aws_endpoint
            ),
            "ALERTS": "sns",
            "AWS_SNS_ARN": "arn:aws:sns:us-east-1:000000000000:madara-orchestrator-arn",
            "DATABASE": "mongodb",
            "MONGODB_CONNECTION_STRING": mongodb_url,
            "DATABASE_NAME": "orchestrator",
            "PROVER_SERVICE": "sharp",
            "DA_LAYER": "",
            "SETTLEMENT_LAYER": "",
            "MADARA_RPC_URL": madara_url,
            "RPC_FOR_SNOS": "",
        },
    )

    service = plan.add_service(
        name=name, config=config, description="Starting Madara Orchestrator Service"
    )
