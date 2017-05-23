auth /api/upload { r args } {

    # there should be a better way to get the filename from the request.
    set filename [dict get [lindex [dict get $r -Query file] 1] filename]
    set data [Query::value [Query::parse $r] file]

    fwrite ${::sciapp_home}/users/[cookie name $r]/$filename $data

    Http Ok $r [::json::write object message [::json::write string success]] application/json
}
