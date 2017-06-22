auth /question { r args } {
    Query::with $r {}

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
    set notes      [experiment notes $eid]
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
                    width 200 \
                    pos { my "left+15 top+55" at "left bottom" of ".jumbotron" } {
                        {box litem welcomemsg text $name class sciapp}
                        {box nav /dashboard {text dashboard}}
                        {box get /logout text logout}
                    }]

    lappend page [box container hypothesis \
                      title Hypothesis \
                      width 500 \
                      pos { my "center top" at "center bottom+100" of ".jumbotron" } {
                          {box editor hypothesis_editor \
                              route /api/hypothesis/update \
                              data "hid $hid" \
                              initval $hypothesis}
                      }]

    lappend page [box container notes \
                      title Notes \
                      width 600 \
                      pos { my "center top" at "center bottom+100" of ".jumbotron" } {
                          {box editor _notes \
                               route /api/experiment/update \
                               data "eid $eid field notes" \
                               initval $notes}
                      }]

    lappend page [box container resources \
                      title Resources \
                      width 300 \
                      pos { my "center top" at "center bottom+100" of ".jumbotron" } {
                          {box editor resources_editor \
                              route /api/experiment/update \
                              data "eid $eid field resources" \
                              initval $resources}
                      }]

    lappend page [box container procedure \
                      title Procedure \
                      width 300 \
                      pos { my "center top" at "center-320 bottom+100" of ".jumbotron" } {
                          {box editor procedure_editor \
                              route /api/experiment/update \
                              data "eid $eid field procedure" \
                              initval $procedure}
                      }]

    lappend page [box container vars \
                      title Variables \
                      width 300 \
                      pos { my "left top" at "right+15 top-47" of "#resources" } {
                          {box dynamic-list varlist \
                               addroute /api/variable/new \
                               rmroute /api/variable/rm \
                               data "eid $eid" \
                               existing $varlist \
                               placeholder "distance, windspeed, temp, etc..."}
                      }]

    lappend page [box container upload \
                      width 400 \
                      pos { my "center top" at "center bottom+100" of ".jumbotron" } {
                          {box fileupload _upload payload "eid $eid"}
                      }]

    lappend page [box container analysis \
                      title Analysis \
                      width 500 \
                      pos { my "center top" at "center bottom+100" of ".jumbotron" } {
                          {box editor analysis_editor \
                               route /api/experiment/update \
                               data "eid $eid field analysis" \
                               initval $analysis}
                          {box button analyze text Run class full-width cb [string map [mapvars eid] {
                              $.post('/api/operator', {
                                  eid: @eid,
                                  script: simplemde_analysis_editor.value()
                              }, (data) => {
                                  $('#results').text(data.result);
                              });
                          }]}
                          {box showdata results {}}
              }]

    lappend page [box container groups \
                      width 200 \
                      pos { my "left top" at "left bottom+10" of "#sitenav" } {
                          {box boxgroups groups {
                              Hypothesis {hypothesis}
                              Notes {notes}
                              Design {procedure resources vars}
                              Measurement {upload}
                              Analysis {analysis}
                          }}
                      }]

    set r [Html style $r css]
    return [Http Ok $r [box siblings {*}$page]]
}
