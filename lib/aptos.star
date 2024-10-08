def apply_default(args):
    return {
        "image": "sotazklabs/aptos-tools:mainnet",
        "name": "aptos",
        "rpc_port": 8080,
        "faucet_port": 8081,
        "faucet": True,
        "transaction_port": 50051,
    } | args


# raw start function with no default values
def start(plan, args, suffix):
    args = apply_default(args)
    ports = {}
    ports["rpc"] = PortSpec(
        number=args["rpc_port"],
        application_protocol="http",
        wait=None,
    )
    ports["transaction"] = PortSpec(
        number=args["transaction_port"],
        application_protocol="http",
        wait=None,
    )

    command = "aptos node run-localnet --performance"

    if args["faucet"]:
        command = "aptos node run-localnet --performance"
        ports["faucet"] = PortSpec(
            number=args["faucet_port"],
            application_protocol="http",
            wait=None,
        )
    else:
        command = command + " --no-faucet"

    name = args["name"] + suffix
    proc_runner_file_artifact = plan.upload_files(
        src="../templates/proc-runner.sh",
        # leaving the name out for now. This might cause some idempotency issues, but we're not currently relying on that for now
    )
    service = plan.add_service(
        name=name,
        config=ServiceConfig(
            image=args["image"],
            ports=ports,
            files={
                "/usr/local/share/proc-runner": proc_runner_file_artifact,
            },
            entrypoint=["/usr/local/share/proc-runner/proc-runner.sh"],
            cmd=[
                command,
            ],
        ),
    )
    if args["faucet"]:
        faucet_service_url = "http://%s:%d" % (service.ip_address, args["faucet_port"])
        plan.print("Faucet running with url: %s" % faucet_service_url)
