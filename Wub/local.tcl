namespace eval ::Sciapp {
    variable headers {
            {<link rel="stylesheet"
                href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.6/css/bootstrap.min.css"
                integrity="sha384-rwoIResjU2yc3z8GV/NPeZWAv56rSmLldC3R/AZzGRnGxQQKnKkoFVhFQhNUwEyJ"
                crossorigin="anonymous">}
            {<script src="https://code.jquery.com/jquery-3.1.1.slim.min.js"
                integrity="sha384-A7FZj7v+d/sdmMqp/nOQwliLvUsJfDHW+k9Omg/a/EheAdgtzNs3hpfag6Ed950n"
                crossorigin="anonymous"></script>}
            {<script src="https://cdnjs.cloudflare.com/ajax/libs/tether/1.4.0/js/tether.min.js"
                integrity="sha384-DztdAPBWPRXSA/3eYEEUWrWCy7G5KFbe8fFjk5JAIxUYHKkDx6Qin1DkWx51bBrb"
                crossorigin="anonymous"></script>}
            {<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.6/js/bootstrap.min.js"
                integrity="sha384-vBWWzlZJ8ea9aCX4pEW3rVHjgjt7zpkNpZk+02D9phzyeVkE+jo0ieGizqPLForn"
                crossorigin="anonymous"></script>}
            {<link href="https://fonts.googleapis.com/css?family=Slabo+27px" rel="stylesheet">}
        }

    proc list_group_link { href text } {
        return [<a> href $href class "list-group-item list-group-item-action" $text]
    }

    proc / { r args } {
        variable headers

        dict set r -headers $headers
        dict set r -title Sciapp

        set page [<div> id "main-title" class "jumbotron" \
                      [<h1> Questions]]

        set qlist "[list_group_link "#" "What does the magnetic field of the sun look like?"] \
                   [list_group_link "#" "What chemicals are in a sharpie?"] \
                   [list_group_link "#" "At what temperature does THC vaporize?"] \
                   [list_group_link "#" "What is the frequency spectrum of the regional rail?"]"

        append page [<div> class container \
                         [<div> class row \
                              [<div> class "offset-md-3 col-md-6" \
                                   [<ul> class list-group $qlist]]]]

        set r [Html style $r css]
        return [Http Ok $r $page]
    }

    proc /css { r args } {
        set css {
            body {
              font-family: 'Slabo 27px', serif;
            }

            #main-title {
              background-color: #700cce;
              color: white;
              text-align: center;
            }

            hr {
                position: relative;
                top: -20px;
                width: 70%;
            }

            .jumbotron {
                border-radius: 0;
            }

            .list-group-item:hover {
                background-color: #700cce;
                color: white;
            }
        }

        return [Http Ok $r $css text/css]
    }

    namespace export -clear *
    namespace ensemble create -subcommands {}

}
