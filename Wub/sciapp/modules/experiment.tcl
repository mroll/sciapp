namespace eval ::experiment {
    proc create { } {
        db eval {insert into experiment default values}
        db eval {select last_insert_rowid()}
    }

    proc procedure { id } {
        set res [db eval {select procedure from experiment where id = $id}]
        if { [llength $res] } {
            set res [lindex $res 0]
        }
        return $res
    }

    proc resources { id } {
        set res [db eval {select resources from experiment where id = $id}]
        if { [llength $res] } {
            set res [lindex $res 0]
        }
        return $res
    }

    proc update { id field value } {
        set query "update experiment set $field = \$value where id = \$id"
        db eval $query
    }

    namespace export -clear *
    namespace ensemble create -subcommands { create update procedure resources }
}
