auth /api/question/new { r args } {
    Query::with $r {}

    set qid [question add $value]
    set uid [user id $name]
    dblink user $uid question $qid

    set res [json::write object message [json::write string success] qid $qid]

    Http Ok $r $res application/json
}
