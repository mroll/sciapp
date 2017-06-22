package require json::write
package require sqlite3

foreach f [glob ${::apphome}/modules/*] { source $f }

namespace eval ::Sciapp {
    variable headers [box::siblings \
                          [box::jquery] \
                          [box::jqueryui] \
                          [box::jqueryui-css] \
                          [box::bootstrap] \
                          [box::simplemde] \
                          [<link> href "https://fonts.googleapis.com/css?family=Inconsolata" rel "stylesheet"]]
                          # [<link> href https://fonts.googleapis.com/css?family=Slabo+27px rel stylesheet]]

    proc init { file } {
        sqlite3 db $file
        puts here
        puts [info procs]

        # not sure if this is a great place for these definitions, but
        # it's better than the util file.
        jointable_namespace user uid question qid
        jointable_namespace question qid hypothesis hid
        jointable_namespace hypothesis hid experiment eid
        jointable_namespace experiment eid var vid
    }

    proc setup { rname } {
        set sitetitle ./_

        set script [subst -nocommands {
            variable headers
            dict set $rname -headers \$headers
            dict set $rname -title $sitetitle

            set name [::cookie name \$$rname]

            set page [<div> id "main-title" class "jumbotron" \
                          [<h1> $sitetitle]]
        }]

        uplevel $script
    }

    proc auth { name args body } {
        proc $name $args [subst -nocommands {
            # if there is no cookie, or if the session cookie does not equal
            # the one stored in the db for the given name, redirect to login.
            puts "cookie: [::cookie get \$r]"
            if { [::cookie get \$r] eq {} || [::cookie get \$r] eq "nil" } {
                return [Http Redirect \$r /login]
            }
            if { [user getsession [::cookie name \$r]] ne [::cookie val \$r] } {
                return [Http Redirect \$r /login]
            }

            setup r

            $body
        }]
    }

    set css [fread fool/fool.css]
    proc /css { r args } [string map [mapvars css] { return [Http Ok $r "@css" text/css] }]

    # set the landing page
    proc / { r args } {
        Http Redirect $r /login
    }

    # load routes
    foreach f [glob ${::apphome}/routes/*] { source $f }

    namespace export -clear *
    namespace ensemble create -subcommands {}
}


Sciapp init ${::apphome}/db/sciapp.sqlite3
