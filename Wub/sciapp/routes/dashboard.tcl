auth /dashboard { r args } {
    set page [<div> id "main-title" class "jumbotron" \
                  [<h1> Scope]]

    set qlist [lmap { id q } [user questions $name] {
        box inputgroup [box get /question?qid=$id text $q] \
            [box button del-$id class "rm-item" text -]
    }]

    lappend page [box container questions \
                  title Questions \
                  pos { my center at center of #varwindow } \
                  width 400 {
                      {box dynamic-list question-list \
                          addroute /api/question/new \
                          rmroute /api/question/rm \
                          existing $qlist}
                  }]

    set r [Html style $r css]
    return [Http Ok $r $page]
}
