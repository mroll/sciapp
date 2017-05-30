auth /question { r args } {
    Query::with $r {}

    set page [<div> id "main-title" class "jumbotron" \
                  [<h1> Scope]]

    set data [json::write object field [json::write string hypothesis] qid $qid]

    set initval [question hypothesis $qid]

    append page [_html::siblings \
                     [_html::editor hypothesis \
                          -initval $initval \
                          -title Hypothesis \
                          -width 400 \
                          -save "route /api/question/update data $data" \
                          -pos { my "left+15 top+15" at "left bottom" of ".jumbotron" }] \
                     [_html::editor procedure \
                          -initval $initval \
                          -title Procedure \
                          -width 400 \
                          -save "route /api/question/update data $data" \
                          -pos { my "left+15 top-47" at "right top" of "#hypothesis" }] \
                     [_html::editor resources \
                          -initval $initval \
                          -title Resources \
                          -width 400 \
                          -save "route /api/question/update data $data" \
                          -pos { my "left+15 top-45" at "right top" of "#procedure" }] \
                     [_html::dynamic-list variables \
                          -addroute /api/variable/new \
                          -rmroute /api/variable/rm \
                          -title Variables \
                          -width 350 \
                          -pos { my "left+15 top-45" at "right top" of "#resources" }]]

    set r [Html style $r css]
    return [Http Ok $r $page]
}
