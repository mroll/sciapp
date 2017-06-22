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

    lappend page [box container register \
                    pos { my "center" at "center" of #varwindow } \
                    width 500 {
                        {box usercreds /register Register}
                    }]

    lappend page [box container login \
                      width 500 \
                      pos { my "left top" at "left bottom+5" of "#register" } {
                        {box get /login text Login class sciapp}
                      }]
    
    set r [Html style $r css]
    return [Http Ok $r [box siblings {*}$page]]
}
