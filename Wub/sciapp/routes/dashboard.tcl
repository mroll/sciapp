auth /dashboard { r args } {
    set page [<div> id "main-title" class "jumbotron" \
                  [<h1> Scope]]

    set qlist [lmap { id q } [user questions $name] {
        box inputgroup [box get /question?qid=$id text $q] \
            [box button del-$id class "rm-item" text -]
    }]

    lappend page [box container questions \
                  pos { my "center top" at "center bottom+100" of "#main-title" } \
                  width 400 {
                      {box dynamic-list question-list \
                          addroute /api/question/new \
                          rmroute /api/question/rm \
                          existing $qlist}
                  }]

    lappend page [box container logout \
                  pos { my "left top" at "left-1 bottom+10" of "#questions" } \
                  width 400 {
                      {box nav /logout {text Logout}}
                  }]

    set r [Html style $r css]
    return [Http Ok $r $page]
}
