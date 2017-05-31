auth /api/variable/new { r args } {
    Query::with $r {}

    set vid [var create $value]
    dblink experiment ${data[eid]} var $vid

    Http Ok $r [::json::write object message [json::write string success]] application/json
}
