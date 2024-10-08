databases_package = "./databases.star"
aptos_package = "./aptos.star"
input_parser = "./input_parser.star"

# Additional services packages.
grafana_package = "./src/additional_services/grafana.star"
prometheus_package = "./src/additional_services/prometheus.star"

def run(
    plan,
    deploy_aptos=True,
    deploy_databases=True,
    args={},
):
    args = import_module(input_parser).parse_args(args)
    args = args | {"deploy_aptos": deploy_aptos}  # hacky but works fine for now.
    plan.print("Deploying with parameters: " + str(args))

    # Deploy a local Aptos.
    if args["deploy_aptos"]:
        plan.print("Deploying a local Aptos")
        import_module(aptos_package).run(
            plan, 
            args["aptos"],
            suffix=args["deployment_suffix"],
        )
    else:
        plan.print("Skipping the deployment of a local Aptos")

    # Deploy databases.
    if deploy_databases:
        plan.print("Deploying databases")
        import_module(databases_package).run(
            plan,
            suffix=args["deployment_suffix"],
        )
    else:
        plan.print("Skipping the deployment of databases")

    # Launching additional services.
    additional_services = args["additional_services"]

    for index, additional_service in enumerate(additional_services):
        if additional_service == "prometheus_grafana":
            deploy_additional_service(plan, "prometheus", prometheus_package, args)
            deploy_additional_service(plan, "grafana", grafana_package, args)
        else:
            fail("Invalid additional service: %s" % (additional_service))

def deploy_additional_service(plan, name, package, args):
    plan.print("Launching %s" % name)
    service_args = dict(args)
    import_module(package).run(plan, service_args)
    plan.print("Successfully launched %s" % name)
