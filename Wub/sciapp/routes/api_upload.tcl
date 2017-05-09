auth /api/upload { r args } {

    puts $r

    Http Ok $r [::json::write object message [::json::write string success]] application/json
}
