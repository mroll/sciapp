namespace eval ::question {
    proc text { id } {
        lindex [db eval {select question from question where id = $id}] 0
    }

    proc rm { id } {
        db eval {delete from question where id = $id; delete from userquestion where qid = $id}
    }

    proc add { question } {
        db eval {insert into question (question) values ($question)}
        db eval {select last_insert_rowid()}
    }

    proc update { id field value } {
        set query "update question set $field = \$value where id = \$id"
        db eval $query
    }

    proc hypothesis { id } {
        set res [db eval {select hypothesis from question where id = $id}]

        if { [llength $res] } {
            set res [lindex $res 0]
        }

        return $res
    }

    namespace export -clear *
    namespace ensemble create -subcommands { text rm add update hypothesis }
}

