proc ::mapvars { args } {
    foreach v $args { lappend res @$v; lappend res [uplevel [list set $v]] }
    set res
}

proc ::K { x y } { set x }
proc ::fread { fname } { ::K [read [set fp [open $fname]]] [close $fp] }

proc ::tcl::dict::get? {args} {
    try {
        ::set x [dict get {*}$args]
    } on error message {
        ::set x {}
    }

    return $x
 }

namespace ensemble configure dict -map [dict merge [namespace ensemble configure dict -map] {get? ::tcl::dict::get?}]

proc ::randint limit {
    expr {int(rand() * $limit +1)}
}

proc ::padfront { s n } {
    concat [string repeat 0 [expr { $n - [string length $s] }]] $s
}

proc ::fwrite { fname data } {
    K [puts [set fd [open $fname w]] $data] [close $fd]
}

proc ::dblink { t1 t1id t2 t2id } {
    $t1$t2 insert $t1id $t2id
}

proc ::jointable_namespace { t1 t1idname t2 t2idname } {
    set tblname $t1$t2
    set context [mapvars tblname t1idname t2idname]
    namespace eval ::$tblname [string map $context {
        proc insert { t1id t2id } {
            db eval {insert into @tblname (@t1idname, @t2idname)
                values ($t1id, $t2id)}
        }

        namespace export -clear *
        namespace ensemble create -subcommands { insert }
    }]
}

# this should go somewhere else since it's specific to the
# application.
jointable_namespace user uid question qid
