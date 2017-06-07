namespace eval ::var {
    proc create { name } {
        db eval {insert into var (name) values ($name)}
        db eval {select last_insert_rowid()}
    }

    namespace export -clear *
    namespace ensemble create -subcommands { create }
}
