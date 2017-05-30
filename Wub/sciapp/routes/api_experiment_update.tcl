auth /api/experiment/update { r args } {
    Query::with $r {}

    experiment update ${data[eid]} ${data[field]} $value

    Http Ok $r [::json::write object message [json::write string success]] application/json
}
