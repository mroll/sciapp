namespace eval ::question {
    proc text { id } {
        db eval {select question from question where id = $id}
    }

    proc rm { id } {
        db eval {delete from question where id = $id; delete from userquestions where qid = $id}
    }

    proc add { question user } {
        db eval {insert into question (question) values ($question)}

        set uid [user id $user]
        set qid [db eval {select last_insert_rowid()}]
        db eval {insert into userquestions (uid, qid) values ($uid, $qid)}

        return $qid
    }

    namespace export -clear *
    namespace ensemble create -subcommands { text rm add }
}

