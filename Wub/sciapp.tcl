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

    proc question_list_item { id question } {
        return "<div class=\"qrow input-group\"> \
                  <a href=\"/question?$id\" style=\"border-radius: 0;\" class=\"list-group-item list-group-item-action\">$question</a> \
                  <span class=\"new-q-input input-group-btn\"> \
                    <button data-id=\"$id\" class=\"rm-question btn btn-secondary\" type=\"button\">-</button> \
                  </span>
                </div>"
    }

    proc / { r args } {
        variable headers

        dict set r -headers $headers
        dict set r -title Sciapp

        set page [<div> id "main-title" class "jumbotron" \
                      [<h1> Questions]]

        set js {
            <script>
              $(document).ready(function() {
                  $('#add-question').on('click', e => {
                      e.preventDefault();


                      var question = $('#question').val();
                      if (question == '') {
                          return;
                      }
                      data = { question: question };

                      $.post('/new-question', data, function(data) {
                          data = JSON.parse(data);

                          if (data.message == "success") {
                              var id = data.id;

                              $(`<div class="qrow input-group">
                                   <a href="/question?${id}" style="border-radius: 0;" class="list-group-item list-group-item-action">${question}</a>
                                   <span class="new-q-input input-group-btn">
                                     <button data-id="${id}" class="rm-question btn btn-secondary" type="button">-</button>
                                   </span>
                                 </div>`).prependTo('#question-list');

                              $('#question').val('')

                              $('.rm-question').click(qdelete);
                          }
                      });
                  });

                  function qdelete(e) {
                      e.preventDefault();

                      var el = $(e.target),
                          id = el.attr('data-id'),
                          data = { id: id };

                      $.post('/rm-question', data, data => {
                          el.closest('div').remove();
                      });
                  }

                  $('.rm-question').click(qdelete);
              });
            </script>
        }

        set qadd [<div> class input-group \
                      {<input id="question" type="text" class="new-q-input form-control" placeholder="Ask anything...">
                       <span style="margin-bottom: 15px;"
                             class="new-q-input input-group-btn">
                          <button id="add-question" class="btn btn-secondary" type="button">+</button>
                       </span>}]

        set qlist {}
        set questions [db eval {select * from question order by id desc} values {
            lappend qlist [question_list_item $values(id) $values(question)]
        }]

        append page [<div> class container \
                         [<div> class row \
                              [<div> class "offset-md-3 col-md-6" \
                                   [join [list $qadd [<ul> id question-list class list-group [join $qlist \n]]] \n]]]]
        append page $js

        set r [Html style $r css]
        return [Http Ok $r $page]
    }

    proc dbproc { name sql res } {
        proc $name { r args } [subst -nocommands {
            Query::with \$r {}
            db eval {$sql}
            set lastrowid [db eval {select last_insert_rowid()}]
            return [Http Ok \$r [::json::write string [subst {{$res}}]] application/json]
        }]
    }

    dbproc /new-question {insert into question (question) values ($question)} {"message": "success", "id": "$lastrowid"}
    dbproc /rm-question {delete from question where id = $id} {"message": "success"}

    proc /css { r args } {
        set css {
            body {
                background-color: white;
              font-family: 'Slabo 27px', serif;
            }

            .new-q-input {
                font-family: 'Slabo 27px', serif;
                height: 50px;
                border-radius: 0;
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

            #add-question {
                cursor: pointer;
                border-radius: 0;
                width: 75px;
            }

            .rm-question {
                cursor: pointer;
                border-radius: 0;
                width: 75px;
            }
        }

        return [Http Ok $r $css text/css]
    }

    namespace export -clear *
    namespace ensemble create -subcommands {}
}

Sciapp init db db/sciapp.sqlite3
