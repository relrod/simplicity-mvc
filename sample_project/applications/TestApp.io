TestApp := Object clone do (
    models := Object clone // TODO
    views := Object clone do (
        happy := method(request,
            return ":D"
        )
        index := method(request,
            variables := Map clone do (
                atPut("version", "0.1")
            )
            return Project render("index.html", variables)
        )
    )
)
