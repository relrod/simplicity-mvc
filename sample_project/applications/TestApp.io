TestApp := Object clone do (
    models := Object clone // TODO
    views := Object clone do (
        index := method(request,
            return "This is just a string for now."
        )
        happy := method(request,
            return ":D"
        )
        temp := method(request,
            variables := Map clone do (
                atPut("version", "0.1")
            )
            return Project render("template.html", variables)
        )
    )
)
