auth /api/variable/new { r args } {
    Query::with $r {}

    set eid ${data[eid]}
    set vid [var create $value]

    dblink experiment $eid var $vid
    experiment addvar $eid $value

    Http Ok $r [json::write object message [json::write string success]] application/json
}
