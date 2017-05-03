auth /rm-question { r args } {
    Query::with $r {}
    question rm $id

    Http Ok $r [::json::write string {"message": "success"}] application/json
}
