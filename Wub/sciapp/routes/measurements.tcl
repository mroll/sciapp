auth /measurements { r args } {
    set page [<div> id "main-title" class "jumbotron" \
                  [<h1> Scope]]

    append page [_html::box file-nav \
                     -title {File Navigator} \
                     -width 300 \
                     -height 500 \
                     [_html::ls . . file-nav]]

    set r [Html style $r css]
    Http Ok $r $page
}
