namespace eval ::experiment {
    proc create { } {
        db eval {insert into experiment default values}
        set eid [db eval {select last_insert_rowid()}]

        set query [string map [mapvars eid] {
            create table e@eid_data (id integer primary key autoincrement, runid int)
        }]
        db eval $query

        return $eid
    }

    proc data { id data } {
        set cols [join [car $data] ", "]
        set vals [join [lmap row [cdr $data] { id ([join [lmap x $row { json::write string $x }] ", "]) }] ", "]

        set query [string map [mapvars id cols vals] {
            insert into e@id_data (@cols) values @vals
        }]

        db eval $query
    }

    proc addvar { id var } {
        set query [string map [mapvars id var] {
            alter table e@id_data add column @var text
        }]
        db eval $query
    }

    # sqlite doesn't have easy handling of removing a column. so this
    # will be slightly complicated.
    proc rmvar { id var } { }

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

    make_joinquery_proc experiment_vars experiment eid var vid \
        var.name
    proc vars { id } {
        experiment_vars $id
    }

    namespace export -clear *
    namespace ensemble create -subcommands { create update procedure resources vars data addvar }
}
