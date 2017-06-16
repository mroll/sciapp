# takes a starbase file for now. the idea is to expand this function
# to support many kinds of files. but really depends on what turns out
# to be useful.
proc parsedata { data } {
    lmap vec [transpose [rows_from_csv $data]] { lreplace $vec 1 1 }
}

auth /api/upload { r args } {
    Query::with $r {}
    
    puts $payload
    set eid    [dict get [json::json2dict $payload] eid]
    experiment data $eid [rows_from_csv $file]

    Http Ok $r [::json::write object message [::json::write string success]] application/json
}
