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
    setup r

    lappend page [box container login \
                    pos { my "center" at "center" of #varwindow } \
                    width 500 {
                        {box usercreds /login Login}
                    }]

    lappend page [box container register \
                      width 500 \
                      pos { my "left top" at "left bottom+5" of "#login" } {
                          {box get /register text Register class sciapp}
                      }]

    set r [Html style $r css]
    return [Http Ok $r [box siblings {*}$page]]
}

proc login_post { r args } {
    Query::with $r {}

    if { [user auth $name $password] } {
        user newsession $name
        ::cookie set r "$name [user getsession $name]"

        return [Http Redirect $r /dashboard]
    }
    
    return [Http Redirect $r /login]
}
