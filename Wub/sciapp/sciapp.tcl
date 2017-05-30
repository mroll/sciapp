package require json::write
package require sqlite3

# load modules
foreach f [glob ${::sciapp_home}/modules/*] { source $f }


namespace eval ::Sciapp {
    variable headers [_html::siblings \
                          [_html::jquery] \
                          [_html::jqueryui] \
                          [_html::jqueryui-css] \
                          [_html::bootstrap] \
                          [_html::simplemde] \
                          [<link> href https://fonts.googleapis.com/css?family=Slabo+27px rel stylesheet]]

    proc init { file } {
        sqlite3 db $file
    }

    proc setup { rname } {
        set script [subst -nocommands {
            variable headers
            dict set $rname -headers \$headers
            dict set $rname -title Scope

            set name [::cookie name \$$rname]
        }]

        uplevel $script
    }

    proc auth { name args body } {
        proc $name $args [subst -nocommands {
            # if there is no cookie, or if the session cookie does not equal
            # the one stored in the db for the given name, redirect to login.
            if { [::cookie get \$r] eq "nil" } {
                return [Http Redirect \$r /login]
            }
            if { [user getsession [::cookie name \$r]] ne [::cookie val \$r] } {
                return [Http Redirect \$r /login]
            }

            setup r

            $body
        }]
    }

    # set the landing page
    proc / { r args } {
        Http Redirect $r /login
    }

    # load routes
    foreach f [glob ${::sciapp_home}/routes/*] { source $f }

    namespace export -clear *
    namespace ensemble create -subcommands {}
}

Sciapp init ${::sciapp_home}/db/sciapp.sqlite3
