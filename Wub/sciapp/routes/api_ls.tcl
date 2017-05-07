auth /api/ls { r args } {
    Query::with $r {}

    set dir [regsub -all _ $dir /]
    if { $dir eq "UPDIR" } {
        set dir ..
    }

    # escape newlines and quotes
    set files [regsub -all \n [_html::ls $cwd/$dir $dir $dialog] \\n]
    set files [regsub -all \" $files \\"]

    Http Ok $r [::json::write string [subst {{"html": "$files"}}]] application/json
}
