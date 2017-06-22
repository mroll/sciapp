auth /api/book/new { r args } {
    Query::with $r {}


    set bid [book add $name $author $pub $comment]
    set uid [user id $username]
    dblink user $uid book $bid

    set res [json::write object id $bid {*}[concat {*}[lmap colname [lrange [book columns] 1 end] {
        list $colname [json::write string [set $colname]]
    }]]]

    Http Ok $r $res application/json
}

auth /api/book/rm { r args } {
    Query::with $r {}

    book rm $id

    set res [json::write object message [json::write string success]]

    Http Ok $r $res application/json
}

auth /api/book/update { r args } {
    Query::with $r {}

    set b64file [base64::encode $file]
    set bid [dict get [json::json2dict $payload] bid]

    book update $bid img $b64file

    set res [json::write object \
                 message [json::write string success] \
                 img [json::write string $b64file]]

    Http Ok $r $res application/json
}
