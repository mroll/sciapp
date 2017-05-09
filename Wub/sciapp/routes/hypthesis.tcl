auth /hypothesis { r args } {
	variable headers

    dict set r -headers $headers
    dict set r -title Sciapp

	set page [<div> id "main-title" class "jumbotron" \
                  [<h1> Hypothesis]]

	set noteText [<div> class input-group \
				  {<input id="note-text" type="text" class="form-control" placeholder="Record your thoughts..."><span><button id="save-notes" class="btn btn-secondary" type="button">Save</button></span>}]

	append page [_html::container \
                     [_html::row \
                          [_html::siblings \
                               [_html::box mainmenu \
							   		-title {Main Menu} \
                                    -pos { my "left+15 top+15" at "left bottom" of ".jumbotron" } \
                                    -width 400 \
                                    [_html::nav \
										 /dashboard {-text Dashboard} \
                                         /hypothesis {-text Hypothesis} \
                                         /design {-text {Experiment Design}} \
                                         /measurements {-text Measurements} \
                                         /analysis {-text Analysis} \
                                         /conclusions {-text Conclusions} \
                                         /test {-text Test -ids {question} -style inv}]] \
							   [_html::box notes \
									-title {Notes} \
									-pos { my "center top+15" at "center bottom" of ".jumbotron" } \
									-width 400 \
									[_html::siblings $noteText]] \
                               [_html::box logout \
                                    -title {Logout} \
                                    -pos { my "right-15 top+15" at "right bottom" of ".jumbotron" } \
                                    -width 400 \
                                    -hidetitle 1 \
                                    [<div> [_html::nav /logout {-text Logout}]]] \	
							   ]]]

	set r [Html style $r css]
	return [Http Ok $r $page]
}
