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
    set analysis   [experiment analysis  $eid]

    set proceduredata [json::write object field [json::write string procedure] eid $eid]
    set resourcesdata [json::write object field [json::write string resources] eid $eid]

    set varlist [lmap { id var } [experiment vars $eid] {
        box inputgroup [box litem var$id text $var] \
            [box button del-var$id class "rm-item" text -]
    }]

    lappend page [box container sitenav \
                    width 350 \
                    pos { my "left+15 top+55" at "left bottom" of ".jumbotron" } {
                        {box nav /dashboard {text dashboard}}
                    }]

    lappend page [box container hypothesis \
                      title Hypothesis \
                      width 400 \
                      pos { my "left top" at "right top" of "#sitenav" } {
                          {box editor hypothesis_editor \
                              route /api/hypothesis/update \
                              data "hid $hid" \
                              initval $hypothesis}
                      }]

    lappend page [box container vars \
                      title Variables \
                      width 400 \
                      pos { my "right top" at "right bottom" of ".jumbotron" } {
                          {box dynamic-list varlist \
                               addroute /api/variable/new \
                               rmroute /api/variable/rm \
                               data "eid $eid" \
                               existing $varlist}
                      }]

    lappend page [box container upload \
                      width 400 \
                      pos { my "left top" at "left bottom+10" of "#sitenav" } {
                          {box fileupload _upload payload "eid $eid"}
                      }]

    lappend page [box container analysis \
                      title Analysis \
                      width 500 \
                      pos {} {
                          {box editor analysis_editor \
                               route /api/experiment/update \
                               data "eid $eid field analysis" \
                               initval $analysis}
                          {box button analyze text Run cb [string map [mapvars eid] {
                              $.post('/api/operator', { eid: @eid, script: simplemde_analysis_editor.value() }, (data) => {
                                  console.log(data);
                                  $('#results').text(data.result);
                              });
                          }]}
                          {box showdata results {}}
              }]

    lappend page [box container groups \
                      width 400 \
                      title groups \
                      pos { my "left top" at "left bottom+10" of "#upload" } {
                          {box boxgroups groups {
                              Design {hypothesis vars}
                              Measurement {upload}
                          }}
                      }]

    set r [Html style $r css]
    return [Http Ok $r [box siblings {*}$page]]
}
