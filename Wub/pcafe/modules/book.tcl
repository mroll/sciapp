package require base64

namespace eval ::book {
    proc add { name author pub comment } {
        db eval {insert into book (name, author, pub, comment)
            values ($name, $author, $pub, $comment)}
        db eval {select last_insert_rowid()}
    }

    proc rm { id } {
        db eval {delete from book where id = $id}
        db eval {delete from userbook where bid = $id}
    }

    proc columns { } {
        lmap { 0 1 2 3 4 5 } [db eval "pragma table_info(book)"] { id $1 }
    }

    proc title { id } {
        set res [db eval {select name from book where id = $id}]
        if { [llength $res] == 1 } {
            set res [lindex $res 0]
        }
        return $res
    }

    proc author { id } {
        set res [db eval {select author from book where id = $id}]
        if { [llength $res] == 1 } {
            set res [lindex $res 0]
        }
        return $res
    }

    proc img { id } {
        db eval {select img from book where id = $id}
    }

    proc update { id field value } {
        set query "update book set $field = \$value where id = \$id"
        db eval $query
    }

    namespace export -clear *
    namespace ensemble create -subcommands { add rm columns title img update author }
}
