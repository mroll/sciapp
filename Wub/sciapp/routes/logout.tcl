    proc /logout { r args } {
        set name [::cookie name $r]

        dict set r set-cookie questions=nil
        user rmsession $name

        Http Redirect $r /login
    }

