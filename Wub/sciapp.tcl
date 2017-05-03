package require json::write
package require sqlite3


proc ::tcl::dict::get? {args} {

    try {                ::set x [dict get {*}$args]
    } on error message { ::set x {} }

    return $x
 }

namespace ensemble configure dict -map [dict merge [namespace ensemble configure dict -map] {get? ::tcl::dict::get?}]

proc ::randint limit {
    expr {int(rand() * $limit +1)}
}

proc ::padfront { s n } {
    concat [string repeat 0 [expr { $n - [string length $s] }]] $s
}

namespace eval ::user {
    proc hash { string } { return [base64::encode [md5::md5 $string]] }

    proc exists { name } {
        return [db exists {select 1 from user where name = $name}]
    }

    proc add { name password } {
        set passhash [hash $password]
        db eval {insert into user (name, password) values ($name, $passhash)}
    }

    proc rmsession { name } {
        db eval {update user set session = NULL where name = $name}
    }

    proc setsession { name session } {
        db eval {update user set session = $session where name = $name}
    }

    proc getsession { name } {
        db eval {select session from user where name = $name}
    }

    proc newsession { name } {
        setsession $name [hash [::padfront [::randint 1e6] 64]]
    }

    proc hassession { name } {
        getsession $name
    }

    proc _password { name } {
        db eval {select password from user where name = $name}
    }

    proc auth { name password } {
        expr { [_password $name] eq [hash $password] }
    }

    namespace export -clear *
    namespace ensemble create -subcommands { rmsession auth exists add setsession getsession newsession }
}

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
                  <span class=\"user-input-lg input-group-btn\"> \
                    <button data-id=\"$id\" class=\"rm-question btn btn-secondary\" type=\"button\">-</button> \
                  </span>
                </div>"
    }

    proc /register { r args } {
        switch [dict get $r -method] {
            GET {
                return [register_get $r $args]
            }
            POST {
                return [register_post $r $args]
            }
        }
    }

    proc /login { r args } {
        switch [dict get $r -method] {
            GET {
                return [login_get $r $args]
            }
            POST {
                return [login_post $r $args]
            }
        }
    }

    proc /logout { r args } {
        set name [_cookiename $r]

        dict set r set-cookie questions=nil
        user rmsession $name

        Http Redirect $r /login
    }

    proc login_get { r args } {
        variable headers

        dict set r -headers $headers
        dict set r -title Sciapp
        
        set page [<div> id "main-title" class "jumbotron" \
                      [<h1> Questions]]
                         
        append page [<div> class row \
                         [<div> class "offset-md-4 col-md-4" \
                              [<usercreds> /login Login]]]

        set r [Html style $r css]
        return [Http Ok $r $page]
    }

    proc login_post { r args } {
        Query::with $r {}

        if { [user auth $name $password] } {
            user newsession $name
            dict set r set-cookie "questions=$name [user getsession $name]"

            return [Http Redirect $r /dashboard]
        }
        
        return [Http Redirect $r /login]
    }

    proc _cookie { r } {
        dict get [Cookies Fetch $r {-name questions}] -value
    }

    proc _cookiename { r } {
        lindex [_cookie $r] 0
    }

    proc _cookieval { r }  {
        lindex [_cookie $r] 1
    }

    proc _cookie? { r } {
        expr { [dict get? $r -cookies] ne {} }
    }

    proc auth { name args body } {
        proc $name $args [subst -nocommands {
            if { [_cookie \$r] eq "nil" } {
                return [Http Redirect \$r /login]
            }
            if { [user getsession [_cookiename \$r]] ne [_cookieval \$r] } {
                return [Http Redirect \$r /login]
            }
            set name [_cookiename \$r]

            $body
        }]
    }
 
    auth /dashboard { r args } {
        variable headers

        dict set r -headers $headers
        dict set r -title Sciapp
        
        set page [<div> id "main-title" class "jumbotron" \
                      [<h1> Questions]]

        append page [<div> class row \
                         [<div> class "offset-md-2 col-md-4" \
                              [join [list [<span> "Hello, $name"] \
                                         {<a href="/logout" style="border-radius: 0;" class="list-group-item list-group-item-action">Logout</a>}] \
                                   \n]]]

        set r [Html style $r css]
        return [Http Ok $r $page]
    }

    proc register_post { r args } {
        Query::with $r {}

        # figure out how to pass a message here
        if { [user exists $name] } {
            return [Http Redirect $r /register]
        }

        user add $name $password
        user newsession $name
        dict set r set-cookie "questions=$name [user getsession $name]"
        
        return [Http Redirect $r /dashboard?name=$name]
    }

    proc <usercreds> { url btntext } {
        return [<form> action $url method post \
                    [join [list [<div> class form-group \
                                     [<input> id name name name type text class "user-input-lg form-control" placeholder "name" {}]] \
                               [<div> class form-group \
                                    [<input> id password name password type password class "user-input-lg form-control" placeholder "password" {}]] \
                               {<button id="register-btn" class="btn sciapp" type="submit">$btntext</button>}] \
                         \n]]
    }

    proc register_get { r args } {
        variable headers

        dict set r -headers $headers
        dict set r -title Sciapp

        set page [<div> id "main-title" class "jumbotron" \
                      [<h1> Questions]]

        append page [<div> class row \
                         [<div> class "offset-md-4 col-md-4" \
                              [<usercreds> /register Register]]]
                                        
        set r [Html style $r css]
        return [Http Ok $r $page]
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
                                   <span class="user-input-lg input-group-btn">
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
                      {<input id="question" type="text" class="user-input-lg form-control" placeholder="Ask anything...">
                       <span style="margin-bottom: 15px;"
                             class="user-input-lg input-group-btn">
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

            /** could break this into regular and inverted classes **/
            .sciapp {
              background-color: #700cce;
                color: white;
                border-radius: 0;
              font-family: 'Slabo 27px', serif;
            }

            body {
                background-color: white;
                font-family: 'Slabo 27px', serif;
            }

            .user-input-lg {
                font-family: 'Slabo 27px', serif;
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

            #name {
              margin-bottom: 10px;
            }

            #register-btn {
              width: 100%;
              cursor: pointer;
            }
        }

        return [Http Ok $r $css text/css]
    }

    namespace export -clear *
    namespace ensemble create -subcommands {}
}

Sciapp init db db/sciapp.sqlite3
