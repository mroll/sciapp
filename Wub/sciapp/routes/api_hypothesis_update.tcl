auth /api/hypothesis/update { r args } {
    Query::with $r {}

    hypothesis update ${data[hid]} $value

    Http Ok $r [::json::write object message [json::write string success]] application/json
}
