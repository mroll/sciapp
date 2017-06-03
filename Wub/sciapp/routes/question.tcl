auth /question { r args } {
    Query::with $r {}

    set page [<div> id "main-title" class "jumbotron" \
                  [<h1> Scope]]

    set hypotheses [question hypothesis $qid]
    if { $hypotheses eq {} } {
        set hid [hypothesis create {}]
        dblink question $qid hypothesis $hid

        set eid [experiment create]
        dblink hypothesis $hid experiment $eid
    } else {
        set hid [lindex $hypotheses 0]
        set eid [lindex [hypothesis experiment $hid] 0]
    }

    set hypothesis [hypothesis get $hid]
    set procedure  [experiment procedure $eid]
    set resources  [experiment resources $eid]

    set proceduredata [json::write object field [json::write string procedure] eid $eid]
    set resourcesdata [json::write object field [json::write string resources] eid $eid]

    set varlist [lmap { id name } [experiment vars $eid] { _html::qlistitem $id $name }]



    append page [_html::siblings \
                     [_html::uploader upload [json::write string [json::write object eid $eid]] \
                          -pos { my "left+15 top+55" at "left bottom" of ".jumbotron" }]]

    append page [_html::siblings \
                     [_html::editor hypothesis \
                          -initval $hypothesis \
                          -title Hypothesis \
                          -width 400 \
                          -save "route /api/hypothesis/update data [json::write object hid $hid]" \
                          -pos { my "left+15 top+55" at "left bottom" of ".jumbotron" }] \
                     [_html::editor procedure \
                          -initval $procedure \
                          -title Procedure \
                          -width 400 \
                          -save "route /api/experiment/update data $proceduredata" \
                          -pos { my "left+15 top-47" at "right top" of "#hypothesis" }] \
                     [_html::editor resources \
                          -initval $resources \
                          -title Resources \
                          -width 400 \
                          -save "route /api/experiment/update data $resourcesdata" \
                          -pos { my "left+15 top-46" at "right top" of "#procedure" }] \
                     [_html::dynamic-list vars \
                          -add "route /api/variable/new data [json::write object eid $eid]" \
                          -rm "route /api/variable/rm" \
                          -existing $varlist \
                          -title Variables \
                          -width 350 \
                          -pos { my "left+15 top-47" at "right top" of "#resources" }] \
                     [_html::boxgroups groups {Design {hypothesis procedure resources vars} \
                                                   Measurement {upload preview}} \
                          -pos { my "left+15 top+15" at "left bottom" of ".jumbotron" }]]

    set r [Html style $r css]
    return [Http Ok $r $page]
}
