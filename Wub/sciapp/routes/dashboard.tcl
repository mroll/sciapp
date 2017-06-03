auth /dashboard { r args } {
    set page [<div> id "main-title" class "jumbotron" \
                  [<h1> Scope]]

    set qlist [lmap { id q } [user questions $name] { _html::qlistitem $id $q }]

    append page [_html::siblings \
                     [_html::box mainmenu \
                          -title {Main Menu} \
                          -pos { my "left+15 top+15" at "left bottom" of ".jumbotron" } \
                          -width 400 \
                          [_html::nav \
                               /hypothesis {-text Hypothesis} \
                               /design {-text {Experiment Design}} \
                               /measurements {-text Measurements} \
                               /analysis {-text Analysis} \
                               /conclusions {-text Conclusions}]] \
                     [_html::dynamic-list questions \
                          -add "route /api/question/new data {}" \
                          -rm "route /api/question/rm" \
                          -existing $qlist \
                          -pos { my "left top+15" at "left bottom" of "#mainmenu" } \
                          -width 400 \
                          -hidetitle 1] \
                     [_html::box logout \
                          -pos { my "left top+15" at "left bottom" of "#questions" } \
                          -width 400 \
                          -hidetitle 1 \
                          [<div> [_html::nav /logout {-text Logout}]]]]

    set r [Html style $r css]
    return [Http Ok $r $page]
}
