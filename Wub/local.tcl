package require json::write
package require sqlite3

namespace eval ::Sciapp {
    variable headers {
            {<link rel="stylesheet"
                href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.6/css/bootstrap.min.css"
                integrity="sha384-rwoIResjU2yc3z8GV/NPeZWAv56rSmLldC3R/AZzGRnGxQQKnKkoFVhFQhNUwEyJ"
                crossorigin="anonymous">}
            {<script src="https://code.jquery.com/jquery-3.2.1.min.js"
                integrity="sha256-hwg4gsxgFZhOsEEamdOYGBf13FyQuiTwlAQgxVSNgt4="
                crossorigin="anonymous"></script>}
            {<script src="https://cdnjs.cloudflare.com/ajax/libs/tether/1.4.0/js/tether.min.js"
                integrity="sha384-DztdAPBWPRXSA/3eYEEUWrWCy7G5KFbe8fFjk5JAIxUYHKkDx6Qin1DkWx51bBrb"
                crossorigin="anonymous"></script>}
            {<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.6/js/bootstrap.min.js"
                integrity="sha384-vBWWzlZJ8ea9aCX4pEW3rVHjgjt7zpkNpZk+02D9phzyeVkE+jo0ieGizqPLForn"
                crossorigin="anonymous"></script>}
            {<link href="https://fonts.googleapis.com/css?family=Slabo+27px" rel="stylesheet">}
        }

    proc init { db file } {
        sqlite3 $db $file
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

        set qadder {
            <script>
              $(document).ready(function() {
                  $('#add-question').on('click', e => {
                      e.preventDefault();
                      
                      var question = $('#question').val(),
                          data = { question: question };

                      $.post('/new-question', data, function(data) {
                          data = JSON.parse(data);

                          if (data.message == "success") {
                              $(`<li class="list-group-item list-group-item-action">${question}</li>`).prependTo('#question-list');
                              $('#question').val('')
                          }
                      });
                  });
              });
            </script>
        }

        set qadd [<div> class input-group \
                      {<input id="question" type="text" class="new-q-input form-control" placeholder="Ask anything...">
                       <span class="new-q-input input-group-btn">
                         <button id="add-question" style="width: 75px;" class="btn btn-secondary" type="button">+</button>
                       </span>}]

        set qlist {}
        set questions [db eval {select * from question} values {
            lappend qlist [list_group_link "#" $values(question)]
        }]

        append page [<div> class container \
                         [<div> class row \
                              [<div> class "offset-md-3 col-md-6" \
                                   "$qadd\n \
                                   [<ul> id question-list class list-group [join $qlist \n]]"]]]
        append page $qadder

        set r [Html style $r css]
        return [Http Ok $r $page]
    }

    proc /new-question { r args } {
        set question [Query::value [Query::parse $r] question]

        db eval {insert into question (question) values ($question)}
        
        set data [::json::write string {{"message": "success"}}]
        
        return [Http Ok $r $data application/json]
    }

    proc /css { r args } {
        set css {
            body {
              font-family: 'Slabo 27px', serif;
            }

            .new-q-input {
                font-family: 'Slabo 27px', serif;
                height: 50px;
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

Sciapp init db db/sciapp.sqlite3
