def apply_default(args):
    return {
        "image": "hduoc2003/jayce:latest",
        "name": "jayce"
    } | args


def start(plan, args, suffix):
    args = apply_default(args)

    name = args["name"] + suffix

    # mount files
    config_file_artifact = plan.upload_files(
        src=args["config_file"],
    )
    mounted_files = {
        "/app": config_file_artifact
    }

    output_file_path = "/app/" + args["output_file_name"]
    command = "jayce deploy --config-path /app/" + last_file_or_dir(args["config_file"]) + " --output-json " + output_file_path
    if len(args["contracts"]) > 0:
        command += " --modules-path "
    for (i, contract_path) in enumerate(args["contracts"]):
        contract_artifact = plan.upload_files(
            src=contract_path,
        )
        container_contract_path = "/app/contracts/" + last_file_or_dir(contract_path) + "-" + str(i)
        mounted_files[container_contract_path] = contract_artifact
        command += container_contract_path + ","
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
        )
    )
    plan.exec(
        service_name=name,
        recipe=ExecRecipe(
            command=["touch", output_file_path]
        )
    )
    plan.wait(
        service_name=name,
        recipe = ExecRecipe(
            command=command
        ),
        field="code",
        assertion="==",
        target_value=0,
        timeout="1h",
        description="Deploying contracts by Jayce"
    )
    output = plan.exec(
        service_name=name,
        recipe=ExecRecipe(
            command=["cat", output_file_path],
        )
    )
    plan.print("Deploy output file: " + output_file_path)

def last_file_or_dir(path):
    return path.split("/")[-1]
