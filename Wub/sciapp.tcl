package require json::write
package require sqlite3

# load modules
foreach f [glob modules/*] { source $f }

namespace eval ::Sciapp {
    proc init { file } {
        sqlite3 db $file
    }

    # set the landing page
    proc / { r args } {
        Http Redirect $r /login
    }

    # load routes
    foreach f [glob routes/*] { source $f }

    # [/css] is created by loading the contents of ./custom.css
    proc /css { r args } [subst {
        set css {[::fread custom.css]};
        return \[Http Ok \$r \$css text/css\]
    }]

    namespace export -clear *
    namespace ensemble create -subcommands {}
}

Sciapp init db/sciapp.sqlite3
