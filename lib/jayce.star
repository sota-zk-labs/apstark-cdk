def apply_default(args):
    return {"image": "hduoc2003/jayce:latest", "name": "jayce"} | args


def start(plan, args, suffix):
    args = apply_default(args)
    name = args["name"] + suffix
    output_file_name = "deploy-report.json"
    output_file_path = "/app/" + output_file_name

    # mount config files
    config_file_artifact = plan.upload_files(
        src=args["config_file"], name=last_file_or_dir(args["config_file"])
    )
    mounted_files = {"/app": config_file_artifact}

    # mount contract files
    command = (
        "jayce deploy --config-path /app/"
        + last_file_or_dir(args["config_file"])
        + " --output-json "
        + output_file_path
    )
    if len(args["contracts"]) > 0:
        command += " --modules-path "
    for i, contract_path in enumerate(args["contracts"]):
        contract_artifact = plan.upload_files(src=contract_path, name=contract_path)
        container_contract_path = "/app/contracts/" + last_file_or_dir(contract_path)
        mounted_files[container_contract_path] = contract_artifact
        command += container_contract_path + ","

    # split command by space and remove the last comma
    if command[-1] == ",":
        command = command[:-1]
    command = command.split(" ")
    plan.print("Deploy contracts with command: " + str(command))

    plan.add_service(
        name=name,
        config=ServiceConfig(
            image=args["image"],
            files=mounted_files,
            entrypoint=["sleep", "infinity"],
        ),
    )
    plan.exec(
        service_name=name,
        recipe=ExecRecipe(command=command),
        skip_code_check=True,
        description="Deploying contracts by Jayce",
    )
    plan.exec(
        service_name=name,
        recipe=ExecRecipe(
            command=["cat", output_file_path],
        ),
        description="Jayce deploy output",
    )

    # create output file, and mount to container for downloading
    output_file_artifact = plan.store_service_files(
        service_name=name,
        src=output_file_path,
        name=output_file_name,
    )
    # plan.add_service(
    #     name="jayce-output",
    #     config=ServiceConfig(image="alpine", files={"/app": output_file_artifact}),
    # )

    # stop jayce
    plan.stop_service(name=name)
    # plan.stop_service(name="jayce-output")


def last_file_or_dir(path):
    return path.split("/")[-1]
