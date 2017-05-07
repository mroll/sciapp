auth /api/preview { r args } {
    Query::with $r {}

    set dir [regsub -all _ $dir .]

    set res [_html::preview $cwd $dir $dialog]

    Http Ok $r [::json::write object html [json::write string $res]] application/json
}
