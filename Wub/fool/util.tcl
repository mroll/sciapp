package require csv
package require json::write
package require json

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

proc ::make_joinquery_proc { name t1name t1idname t2name t2idname args } {
    set fields ${t2name}.id
    if { $args ne {} } {
        append fields ", [join $args ,]"
    }

    set tblname $t1name$t2name
    set querystring [string map [mapvars tblname fields t1name t1idname t2name t2idname] {
        select @fields from @t2name inner join @tblname on
        @tblname.@t1idname = $id and
        @tblname.@t2idname = @t2name.id order by @t2name.id desc}]

    proc $name { id } [string map [mapvars querystring] {
        db eval {@querystring}
    }]
}

proc ::id { x } { set x }

# write [mapcan]

proc ::zip { args } {
    for {set i 0} {$i < [llength $args]} {incr i} {
        lappend vars x$i
    }
    set script  [concat list {*}[lmap v $vars { id $$v }]]
    set mapargs [concat {*}[lmap v $vars arg $args { list $v $arg }]]

    lmap {*}$mapargs $script
}

proc ::transpose { m } { zip {*}$m }

proc ::rows_from_csv { s } {
    set rows [lmap line [split $s \n] { csv::split $line \t }]
    list [lindex $rows 0] {*}[lrange $rows 2 end]
}

proc ::len  list { llength $list }
proc ::atom x    { expr { [len $x] == 1 } }

proc ::car { list } {
    if { [atom $list] } { return $list }
    lindex $list 0
}

proc ::cdr { list } {
    if { [atom $list] } { return {} }
    lrange $list 1 end
}

proc ::cadr { list } { car [cdr $list] }

proc ::tuples { l {n 2} } {
    if { $l eq {} } { return }
    for {set i 0} {$i < [llength $l]} {incr i $n} {
        lappend tups [lrange $l $i [expr {$i+$n-1}]]
    }
    return $tups
}
