proc getpage { url } {
    set i [interp create]
    interp eval $i [string map [mapvars url] {
        package require http
        proc K { x y } { set x }
        K [http::data [set tok [http::geturl @url]]] \
            [http::cleanup $tok]
    }]
}

auth /book { r args } {
    Query::with $r {}

    set title [book title $id]
    set author [book author $id]

    lappend page [box container sitenav \
                    width 200 \
                    pos { my "right top" at "right-15 bottom+15" of ".jumbotron" } {
                        {box get /dashboard text dashboard}
                        {box get /logout text logout}
                    }]

    set results [json::json2dict [getpage http://openlibrary.org/search.json?q=[join $title +]+[join $author +]]]

    set src {""}
    if { [dict get $results num_found] } {
        set key [dict get [lindex [dict get $results docs] 0] cover_i]
        set src [string map [mapvars key] {http://covers.openlibrary.org/b/id/@key-L.jpg}]
    }

    lappend page [box container coverimg \
                      pos { my "left top" at "left+15 bottom+15" of ".jumbotron" } {
                          {<img> src $src width 300 height 500}
                      }]
                      
    lappend page [box container title \
                      pos { my "left top" at "right+15 top" of "#coverimg" } {
                          {<div> [<h1> $title]}
                      }
                 ]

    lappend page [box container rmbook \
                      pos { my "left top" at "left bottom+5" of "#title" } \
                      width 200 {
                          {box litem _rmbook \
                               text "delete this book" \
                               class "sciapp-inverse btn-sciapp" \
                               cb [string map [mapvars id] {
                                   $.post('/api/book/rm', { id: @id }, data => {
                                       window.location = '/dashboard';
                                   });
                               }]}
                      }]

    set r [Html style $r css]
    return [Http Ok $r [box siblings {*}$page]]
}
