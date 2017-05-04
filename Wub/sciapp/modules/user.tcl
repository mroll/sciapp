namespace eval ::user {
    proc hash { string } { return [base64::encode [md5::md5 $string]] }

    proc exists { name } {
        return [db exists {select 1 from user where name = $name}]
    }

    proc add { name password } {
        set passhash [hash $password]
        db eval {insert into user (name, password) values ($name, $passhash)}
    }

    proc rmsession { name } {
        db eval {update user set session = NULL where name = $name}
    }

    proc setsession { name session } {
        db eval {update user set session = $session where name = $name}
    }

    proc getsession { name } {
        db eval {select session from user where name = $name}
    }

    proc newsession { name } {
        setsession $name [hash [::padfront [::randint 1e6] 64]]
    }

    proc hassession { name } {
        expr { [getsession $name] ne "" }
    }

    proc id { name } {
        db eval {select id from user where name = $name}
    }

    proc _password { name } {
        db eval {select password from user where name = $name}
    }

    proc auth { name password } {
        expr { [_password $name] eq [hash $password] }
    }

    proc questions { name } {
        set uid [id $name]
        db eval {select id, question from question inner join userquestions on
            userquestions.uid = $uid and
            userquestions.qid = question.id order by question.id desc}
    }

    proc loggedin { r } {
        if { [::cookie get $r] eq "nil" } {
            return 0
        }
        if { [user getsession [::cookie name $r]] ne [::cookie val $r] } {
            return 0
        }
        return 1
    }

    namespace export -clear *
    namespace ensemble create -subcommands { loggedin id questions rmsession auth exists add setsession getsession newsession }
}

