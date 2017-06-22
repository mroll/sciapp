auth /dashboard { r args } {
    Query::with $r {}

    set qlist [lmap { id q } [user questions $name] {
        box inputgroup [box get /question?qid=$id text $q] \
            [box button del-$id class "rm-item" text -]
    }]

    lappend page [box container questions \
                      pos { my "center top" at "center bottom+100" of "#main-title" } \
                      width 600 {
                          {box dynamic-list question-list \
                               addroute /api/question/new \
                               rmroute /api/question/rm \
                               existing $qlist \
                               listtype nav \
                               placeholder "Ask anything..."}
                      }]

    lappend page [box container nav \
                      pos { my "left top" at "right+20 top" of "#questions" } \
                      width 250 {
                          {box litem welcomemsg text $name class sciapp}
                          {box get /logout text logout}
                      }]

    set r [Html style $r css]
    return [Http Ok $r [box siblings {*}$page]]
}
