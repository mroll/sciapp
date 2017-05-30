auth /api/question/update { r args } {
    Query::with $r {}

    set field ${data[field]}
    set qid   ${data[qid]}

    question update $qid $field $value

    Http Ok $r [::json::write object html [json::write string hello]] application/json
}
