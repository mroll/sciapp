auth /question { r args } {
    Query::with $r {}

    set page [<div> id "main-title" class "jumbotron" \
                  [<h1> Scope]]


    lappend page [<div> class row \
                    [<div> class "offset-md-3 col-md-6" \
                        [<h3> style "text-align: center;" [question text $qid]]]]


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

    lappend page [box container hypothesis \
                      title Hypothesis \
                      width 400 \
                      pos { my "left+15 top+55" at "left bottom" of ".jumbotron" } {
                          {box editor hypothesis-editor \
                              route /api/hypothesis/update \
                              data "hid $hid" \
                              initval $hypothesis}
                      }]

                      

    set r [Html style $r css]
    return [Http Ok $r [box siblings {*}$page]]
}
