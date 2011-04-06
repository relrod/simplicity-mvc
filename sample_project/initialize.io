// Bring in some addons.
Regex

// TODO: This won't work if you're not in the project directory.
// We only want to define the absolute path to the project once, in settings.io
// and I'm not sure how to make this work with that in mind.
Lobby doRelativeFile("settings.io")

// Bring in the URLs file.
Lobby doFile("#{Project absolute_path}/urls.io" interpolate)

// Load appropriate applications.
Project applications foreach(application,
    doFile("#{Project absolute_path}/applications/#{application}.io" interpolate)
)

urlrouter := method(sock, request_path,
    if(Project urls hasKey(request_path) not, return HTTPNotFound(sock))
    destination := Project urls at(request_path)
    destination := destination split("/")
    called_application := destination at(0)
    if(Project applications contains(called_application) not,
        "Routing failed: No application #{called_application} is included in settings.io." interpolate println
        return
    )
    called_method := destination at(1)
    if(Project debug, "Routing to #{called_application}.#{called_method}" interpolate println)
    // TODO: Error checking for method existence.
    Lobby getSlot(called_application) views perform(called_method asString)
)

HTTPRedirect := method(sock, newlocation,
    if(Project debug, "Redirecting client to #{newlocation}" interpolate println)
    sock write("HTTP/1.1 301 Moved Permanently\n")
    sock write("Location: #{newlocation}\n" interpolate)
    sock close
    return 301
)

HTTPNotFound := method(sock,
    if(Project debug, "404: Not Found." println)
    sock write("HTTP/1.1 404 Not Found\n")
    sock close
    return 301
)

Project render := method(template, variables,
    // Load the contents of the template into memory.
    template_path := "#{Project absolute_path}/templates/#{template}" interpolate
    template := File with(template_path) contents asMutable
    
    // Scan for all template blocks, things in {{ and }}.
    blocks := template allMatchesOfRegex("\{\{(.+?)\}\}")
    
    // In each block, see if we're dealing with a variable...
    blocks foreach(codeblock,
        // Get rid of the surrounding junk.
        codeblock := codeblock string
        workable_codeblock := codeblock asMutable replaceSeq(" ", "") betweenSeq("{{", "}}")
        if(workable_codeblock beginsWithSeq("$"),
            // Bingo!
            workable_codeblock := workable_codeblock strip("$")
            if(variables hasKey(workable_codeblock)) then (
                template = template replaceSeq(codeblock, variables at(workable_codeblock))
            ) else (
                "The variable `#{workable_codeblock}`, found in #{template_path}, is undefined." interpolate println
            )
        )
    )
    template
)
        

if(Project devel enable,

    WebRequest := Object clone do (
        handleSocket := method(sock,
            sock streamReadNextChunk
            request_path := sock readBuffer betweenSeq("GET ", " HTTP")
            "#{sock ipAddress}: #{request_path}" interpolate println
            
            // Does the request end with /? Should it?
            if(Project devel force_ending_slash and request_path endsWithSeq("/") not,
                "Slashes forced, and request does not end with a slash. Redirecting." println
                return HTTPRedirect(sock, "#{request_path}/" interpolate)
            )

            // Pass it off to the router.
            response := urlrouter(sock, request_path)
            sock write(response)
            sock close
        )
    )

    WebServer := Server clone do (
        setPort(Project devel port)
        handleSocket := method (sock,
            WebRequest clone @handleSocket(sock)
        )
    )
    
    WebServer start

)

