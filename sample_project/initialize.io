// TODO: This won't work if you're not in the project directory.
// We only want to define the absolute path to the project once, in settings.io
// and I'm not sure how to make this work with that in mind.
Lobby doFile("settings.io")

// Bring in the URLs file.
Lobby doFile("#{Project absolute_path}/urls.io" interpolate)

// Load appropriate applications.
Project applications foreach(application,
    doFile("#{Project absolute_path}/applications/#{application}.io" interpolate)
)

urlrouter := method(destination,
    destination := destination split("/")
    called_application := destination at(0)
    if(Project applications contains(called_application) not,
        "Routing failed: No application #{called_application} is included in settings.io." interpolate println
        return
    )
    called_method := destination at(1)
    if(Project debug, "Routing to #{called_application}.#{called_method}" interpolate println)
    Lobby getSlot(called_application) views perform(called_method asString)
)

HTTPRedirect := method(sock, newlocation,
    sock write("HTTP/1.1 301 Moved Permanently\n")
    sock write("Location: #{newlocation}\n" interpolate)
    sock close
    return 301
)

if(Project devel enable,

    WebRequest := Object clone do (
        handleSocket := method(sock,
            sock streamReadNextChunk
            request_path := sock readBuffer betweenSeq("GET ", " HTTP")
            "Request for: #{request_path}" interpolate println
            
            // Does the request end with /? Should it?
            if(Project devel force_ending_slash and request_path endsWithSeq("/") not,
                "Slashes forced, and request does not end with a slash. Redirecting." println
                HTTPRedirect(sock, "#{request_path}/" interpolate)
                return // Because HTTP* will close the socket.
            )

            // Pass it off to the router.
            response := urlrouter(Project urls at(request_path))
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

urlrouter("TestApp/index") println