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
    
    set page [<div> id "main-title" class "jumbotron" \
                  [<h1> Scope]]
    
    append page [_html::box credentials \
                     -padded 1 -width 650 -hidetitle 1 \
                     [_html::siblings \
                        [_html::usercreds /login Login] \
                        [_html::nav /register {-text Register \
                            -class sciapp \
                            -style "color: white; margin-top: 3px;"}]]]

    set r [Html style $r css]
    return [Http Ok $r $page]
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
