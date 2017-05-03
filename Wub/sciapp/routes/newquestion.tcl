auth /new-question { r args } {
    Query::with $r {}
    
    set id [question add $question [::cookie name $r]]

    Http Ok $r [::json::write string [subst {{"message": "success", "id": "$id"}}]] application/json
}
