namespace eval ::cookie {
    proc get { r } {
        if { [Cookies Match $r {-name questions}] ne "" } {
            dict get [Cookies Fetch $r {-name questions}] -value
        }
    }

    proc set { rname val } {
        upvar $rname r
        dict set r set-cookie "questions=$val"
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
    namespace ensemble create -subcommands { get set name val exists }
}
