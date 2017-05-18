auth /api/ls { r args } {
    Query::with $r {}

    set dir [regsub -all ___ $dir /]
    if { $dir eq "UPDIR" } {
        set dir ..
    }
    if { $dir eq "DOTDIR" } {
        set dir .
    }

    # escape newlines and quotes
    set files [regsub -all \n [_html::ls $windowid $cwd/$dir $dialog] \\n]
    set files [regsub -all \" $files \\"]

    Http Ok $r [::json::write string [subst {{"html": "$files"}}]] application/json
}
