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
    
    return [Http Redirect $r /dashboard]
}


proc register_get { r args } {
    setup r

    set page [_html::siblings \
                  [<div> id "main-title" class "jumbotron" [<h1> Scope]] \
                  [_html::box credentials -width 650 [_html::usercreds /register Register]]]
    
    set r [Html style $r css]
    return [Http Ok $r $page]
}
