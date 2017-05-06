auth /hypothesis { r args } {
	variable headers

    dict set r -headers $headers
    dict set r -title Sciapp

	set page [<div> id "main-title" class "jumbotron" \
                  [<h1> Hypothesis]]

    append page [<div> class row \
                     [<div> class "offset-md-2 col-md-4" \
                          [<siblings> [<span> "Hello, $name"] \
                               {<a href="/dashboard" style="border-radius: 0;" class="list-group-item list-group-item-action">Dashboard</a>} \
                               {<a href="/hypothesis" style="border-radius: 0;" class="list-group-item list-group-item-action">Hypothesis</a>} \
							   {<a href="/logout" style="border-radius: 0;" class="list-group-item list-group-item-action">Logout</a>}]]]

	set r [Html style $r css]
	return [Http Ok $r $page]
}
