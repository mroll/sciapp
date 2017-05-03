package require json::write
package require sqlite3


proc ::K { x y } { set x }
proc ::fread { fname } { ::K [read [set fp [open $fname]]] [close $fp] }

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

    proc id { name } {
        db eval {select id from user where name = $name}
    }

    proc _password { name } {
        db eval {select password from user where name = $name}
    }

    proc auth { name password } {
        expr { [_password $name] eq [hash $password] }
    }

    proc questions { name } {
        set uid [id $name]
        db eval {select id, question from question inner join userquestions on
            userquestions.uid = $uid and
            userquestions.qid = question.id order by question.id desc}
    }

    proc loggedin { r } {
        if { [::cookie get $r] eq "nil" } {
            return 0
        }
        if { [user getsession [::cookie name $r]] ne [::cookie val $r] } {
            return 0
        }
        return 1
    }

    namespace export -clear *
    namespace ensemble create -subcommands { loggedin id questions rmsession auth exists add setsession getsession newsession }
}

namespace eval ::cookie {
    proc get { r } {
        dict get [Cookies Fetch $r {-name questions}] -value
    }

    proc name { r } {
        lindex [::cookie get $r] 0
    }

    proc val { r }  {
        lindex [::cookie get $r] 1
    }

    proc exists { r } {
        expr { [dict get? $r -cookies] ne {} }
    }

    namespace export -clear *
    namespace ensemble create -subcommands { get name val exists }
}

namespace eval ::question {
    proc text { id } {
        db eval {select question from question where id = $id}
    }

    proc rm { id } {
        db eval {delete from question where id = $id; delete from userquestions where qid = $id}
    }

    proc add { question user } {
        db eval {insert into question (question) values ($question)}

        set uid [user id $user]
        set qid [db eval {select last_insert_rowid()}]
        db eval {insert into userquestions (uid, qid) values ($uid, $qid)}

        return $qid
    }

    namespace export -clear *
    namespace ensemble create -subcommands { text rm add }
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
        if { [user loggedin $r] } {
            return [Http Redirect $r /dashboard]
        }

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
        set name [::cookie name $r]

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

    proc auth { name args body } {
        proc $name $args [subst -nocommands {
            if { [::cookie get \$r] eq "nil" } {
                return [Http Redirect \$r /login]
            }
            if { [user getsession [::cookie name \$r]] ne [::cookie val \$r] } {
                return [Http Redirect \$r /login]
            }
            set name [::cookie name \$r]

            $body
        }]
    }

    proc <siblings> { args } {
        join $args \n
    }
    
    auth /dashboard { r args } {
        variable headers

        dict set r -headers $headers
        dict set r -title Sciapp

        set js [string map [list @qlist_item [question_list_item \${id} \${question}]] {
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

                              $(`@qlist_item`).prependTo('#question-list');
                              $('#question').val('')
                              $('.rm-question').click(qdelete);
                          }
                      });
                  });

                  function qdelete(e) {
                      e.preventDefault();

                      var el = $(e.target),
                          data = { id: el.attr('data-id') };

                      $.post('/rm-question', data, data => {
                          el.closest('div').remove();
                      });
                  }

                  $('.rm-question').click(qdelete);
              });
            </script>
        }]
        
        set page [<div> id "main-title" class "jumbotron" \
                      [<h1> Questions]]

        append page [<div> class row \
                      [<div> class "offset-md-2 col-md-4" \
                        [<siblings> [<span> "Hello, $name"] \
                             {<a href="/logout" style="border-radius: 0;" class="list-group-item list-group-item-action">Logout</a>}]]]

        set qadd [<div> class input-group \
                      {<input id="question" type="text" class="user-input-lg form-control" placeholder="Ask anything...">
                       <span class="user-input-lg input-group-btn">
                          <button id="add-question" class="btn btn-secondary" type="button">+</button>
                       </span>}]

        set qlist [lmap { id q } [user questions $name] { question_list_item $id $q }]

        append page [<div> class container-fluid \
                      [<div> class row \
                        [<div> class "offset-md-4 col-md-4" \
                             [<siblings> $qadd [<ul> id question-list class list-group \
                                                    [<siblings> {*}$qlist]]]]]]

        append page $js

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
        Http Redirect $r /login
    }

    auth /rm-question { r args } {
        Query::with $r {}
        question rm $id

        Http Ok $r [::json::write string {"message": "success"}] application/json
    }

    auth /new-question { r args } {
        Query::with $r {}
        
        set id [question add $question [::cookie name $r]]

        Http Ok $r [::json::write string [subst {{"message": "success", "id": "$id"}}]] application/json
    }

    # load the css from ./custom.ss
    proc /css { r args } [subst { set css {[::fread custom.css]}; return \[Http Ok \$r \$css text/css\] }]

    namespace export -clear *
    namespace ensemble create -subcommands {}
}

Sciapp init db db/sciapp.sqlite3
