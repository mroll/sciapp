proc ::K { x y } { set x }
proc ::fread { fname } { ::K [read [set fp [open $fname]]] [close $fp] }

proc ::tcl::dict::get? {args} {

    try {                ::set x [dict get {*}$args]
    } on error message { ::set x {} }

    return $x
 }

namespace ensemble configure dict -map [dict merge [namespace ensemble configure dict -map] {get? ::tcl::dict::get?}]

proc ::randint limit {
    expr {int(rand() * $limit +1)}
}

proc ::padfront { s n } {
    concat [string repeat 0 [expr { $n - [string length $s] }]] $s
}

proc authproc { name args body } {
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
