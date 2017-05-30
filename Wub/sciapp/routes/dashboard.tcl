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
                          -addroute /api/question/new \
                          -rmroute /api/question/rm \
                          -existing $qlist \
                          -pos { my "left top+15" at "left bottom" of "#mainmenu" } \
                          -width 400 \
                          -hidetitle 1] \
                     [_html::box logout \
                          -pos { my "left top+15" at "left bottom" of "#questions" } \
                          -width 400 \
                          -hidetitle 1 \
                          [<div> [_html::nav /logout {-text Logout}]]] \
                     [_html::filenav file-nav ${::sciapp_home}/users/[cookie name $r] \
                          -title {File Navigator} \
                          -pos { my "left top-47" at "right+10 top" of "#mainmenu" } \
                          -width 350 \
                          -maxheight 600] \
                     [_html::box tools \
                          -title Tools \
                          -pos { my "left-1 top+10" at "left bottom" of "#file-nav" } \
                          -width 350 \
                          [_html::siblings \
                               [_html::tool mean {$('#file-preview').data("filename")} results] \
                               [_html::tool min {$('#file-preview').data("filename")} results] \
                               [_html::tool max {$('#file-preview').data("filename")} results] \
                               [_html::tool stdev {$('#file-preview').data("filename")} results]]] \
                     [_html::box results \
                          -title Results \
                          -pos { my "left-1 top+10" at "left bottom" of "#tools" } \
                          -width 350 \
                          [_html::showdata results {}]] \
                     [_html::fileviewer file-preview \
                          -hidetitle 1 \
                          -width 800 \
                          -height 600 \
                          -pos { my "left top-45" at "right+10 top" of "#file-nav" }]]

    set r [Html style $r css]
    return [Http Ok $r $page]
}
