Project := Object clone do (
    name := "sample_project"
    absolute_path := "/home/ricky/sources/simplicity-mvc/sample_project/"
    debug := true // This is NOT related to the Development Environment below.
    applications := list(
        "TestApp"
    )
    database := Object clone do (
        backend := "mysql"
        name := "mydatabase"
        user := "testuser"
        password := "Fo0b4R!"
        host := "127.0.0.1"
        port := 3306
    )
    
    // Development Environment
    devel := Object clone do (
        enable := true
        port := 8123
        force_ending_slash := true
    )
)
