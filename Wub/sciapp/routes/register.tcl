proc /register { r args } {
    switch [dict get $r -method] {
        GET {
            return [register_get $r $args]
        }
        POST {
            return [register_post $r $args]
        }
    }
}

proc register_post { r args } {
    Query::with $r {}

    # figure out how to pass a message here
    if { [user exists $name] } {
        return [Http Redirect $r /register]
    }

    user add $name $password
    user newsession $name
    dict set r set-cookie "questions=$name [user getsession $name]"
    
    return [Http Redirect $r /dashboard?name=$name]
}


proc register_get { r args } {
    variable headers

    dict set r -headers $headers
    dict set r -title Sciapp

    set page [<div> id "main-title" class "jumbotron" \
                  [<h1> Questions]]

    append page [<div> class row \
                     [<div> class "offset-md-4 col-md-4" \
                          [<usercreds> /register Register]]]
    
    set r [Html style $r css]
    return [Http Ok $r $page]
}
