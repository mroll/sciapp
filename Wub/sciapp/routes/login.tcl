proc /login { r args } {
    if { [user loggedin $r] } {
        return [Http Redirect $r /dashboard]
    }

    switch [dict get $r -method] {
        GET {
            return [login_get $r $args]
        }
        POST {
            return [login_post $r $args]
        }
    }
}


proc login_get { r args } {
    variable headers

    dict set r -headers $headers
    dict set r -title Sciapp
    
    set page [<div> id "main-title" class "jumbotron" \
                  [<h1> Questions]]
    
    append page [<div> class row \
                     [<div> class "offset-md-4 col-md-4" \
                          [<usercreds> /login Login]]]

    set r [Html style $r css]
    return [Http Ok $r $page]
}

proc login_post { r args } {
    Query::with $r {}

    if { [user auth $name $password] } {
        user newsession $name
        dict set r set-cookie "questions=$name [user getsession $name]"

        return [Http Redirect $r /dashboard]
    }
    
    return [Http Redirect $r /login]
}
