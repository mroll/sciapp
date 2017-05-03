namespace eval ::cookie {
    proc get { r } {
        dict get [Cookies Fetch $r {-name questions}] -value
    }

    proc name { r } {
        lindex [::cookie get $r] 0
    }

    proc val { r }  {
        lindex [::cookie get $r] 1
    }

    proc exists { r } {
        expr { [dict get? $r -cookies] ne {} }
    }

    namespace export -clear *
    namespace ensemble create -subcommands { get name val exists }
}
