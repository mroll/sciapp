package require math::statistics 1

auth /api/operator { r args } {
    Query::with $r {}

    set path [regsub -all ___ $path .]

    # now we need to read the file and do the operation.
    # will eventually use starbase.

    set data [fread $path]
    puts $data

    set res [_html::showdata $windowid [::math::statistics::$operator $data]]
    
    Http Ok $r [::json::write object html [json::write string $res]] application/json
}
