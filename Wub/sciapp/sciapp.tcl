package require json::write
package require sqlite3

# load modules
foreach f [glob ${::sciapp_home}/modules/*] { source $f }


namespace eval ::Sciapp {
    proc init { file } {
        sqlite3 db $file
    }

    proc auth { name args body } {
        proc $name $args [subst -nocommands {
            if { [::cookie get \$r] eq "nil" } {
                return [Http Redirect \$r /login]
            }
            if { [user getsession [::cookie name \$r]] ne [::cookie val \$r] } {
                return [Http Redirect \$r /login]
            }
            set name [::cookie name \$r]
            
            $body
        }]
    }

    variable headers [<siblings> [<jquery>] \
                          [<bootstrap>] \
                          [<link> href https://fonts.googleapis.com/css?family=Slabo+27px rel stylesheet]]
                          

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
