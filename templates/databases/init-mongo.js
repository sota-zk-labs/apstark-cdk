for (let db of {{.dbs}}) {
    db.getSiblingDB('admin').auth(
        {{$.root_db}},
        {{$.root_user}}
    );

    db.createUser({
        user: {{.user}},
        pwd: {{.password}},
        roles: [
            {
                role: "readWrite",
                db: {{.name}}
            }
        ],
    });
}