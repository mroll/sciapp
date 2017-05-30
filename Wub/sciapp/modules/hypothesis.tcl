namespace eval ::hypothesis {
    proc create { _hypothesis } {
        db eval {insert into hypothesis (hypothesis) values ($_hypothesis)}
        db eval {select last_insert_rowid()}
    }

    proc get { id } {
        set res [db eval {select hypothesis from hypothesis where id = $id}]
        if { [llength $res] } {
            set res [lindex $res 0]
        }
        return $res
    }

    proc update { id value } {
        db eval {update hypothesis set hypothesis = $value where id = $id}
    }

    make_joinquery_proc hypothesis_experiments hypothesis hid experiment eid
    proc experiment { id } {
        hypothesis_experiments $id
    }

    namespace export -clear *
    namespace ensemble create -subcommands { create get update experiment }
}



