auth /measurements { r args } {
    set page [<div> id "main-title" class "jumbotron" \
                  [<h1> Scope]]

    append page [_html::box file-upload \
                     -title {File Upload} \
                     -width 300 \
                     [_html::ls . . file-upload]]

    set r [Html style $r css]
    Http Ok $r $page
}
