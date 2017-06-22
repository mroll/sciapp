package require math::statistics 1

auth /api/operator { r args } {
    Query::with $r {}

    set colnames [lmap { 0 1 2 3 4 5 } [db eval "pragma table_info(e${eid}_data)"] { id $1 }]
    # for {set i 0} {$i < [llength $colnames]} {incr i} {
    #     proc [lindex $colnames $i] { row } [string map [mapvars i] {
    #         lindex $row @i
    #     }]
    # }

    set rows [db eval "select [join $colnames ,] from e${eid}_data"]
    set res  [eval $script]

    foreach name $colnames { rename $name {} }

    Http Ok $r [::json::write object result [json::write string $res]] application/json
}
