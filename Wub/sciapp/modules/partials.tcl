proc ::<jquery> { } {
    return {<script src="https://code.jquery.com/jquery-3.2.1.min.js"
        integrity="sha256-hwg4gsxgFZhOsEEamdOYGBf13FyQuiTwlAQgxVSNgt4="
        crossorigin="anonymous"></script>}
}

proc ::<bootstrap> { } {
    return {
        <link rel="stylesheet"
            href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.6/css/bootstrap.min.css"
            integrity="sha384-rwoIResjU2yc3z8GV/NPeZWAv56rSmLldC3R/AZzGRnGxQQKnKkoFVhFQhNUwEyJ"
            crossorigin="anonymous">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/tether/1.4.0/js/tether.min.js"
            integrity="sha384-DztdAPBWPRXSA/3eYEEUWrWCy7G5KFbe8fFjk5JAIxUYHKkDx6Qin1DkWx51bBrb"
            crossorigin="anonymous"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.6/js/bootstrap.min.js"
            integrity="sha384-vBWWzlZJ8ea9aCX4pEW3rVHjgjt7zpkNpZk+02D9phzyeVkE+jo0ieGizqPLForn"
            crossorigin="anonymous"></script>
    }
}

proc ::question_list_item { id question } {
    return "<div class=\"qrow input-group\"> \
                  <a href=\"/question?$id\" style=\"border-radius: 0; padding-top: 0; padding-bottom: 0;\" class=\"list-group-item list-group-item-action\">$question</a> \
                  <span class=\"user-input-lg input-group-btn\"> \
                    <button data-id=\"$id\" class=\"rm-question btn btn-secondary\" type=\"button\">-</button> \
                  </span>
                </div>"
}

proc ::<siblings> { args } {
    join $args \n
}

proc ::<usercreds> { url btntext } {
    return [<form> action $url method post \
                [<siblings> \
                     [<div> class form-group \
                          [<input> id name name name type text class "user-input-lg form-control" placeholder "name" {}]] \
                     [<div> class form-group \
                          [<input> id password name password type password class "user-input-lg form-control" placeholder "password" {}]] \
                     [<post> $url -text $btntext -ids {name password}]]]
                 
}

proc ::<post> { url args } {
    set onchange_js {
        \$('#@id').on('input', e => \{
            \$('#_@id').val(e.target.value);
        \});
    }

    set onchange_callbacks [list [join [lmap id [dict get $args -ids] { string map "@id $id" $onchange_js }] \n]]
    set themeclass [if { [dict exists $args -style] } {
        if { [dict get $args -style] eq "reg" } {
            set rtn sciapp
            set rtn
        } else {
            set rtn sciapp-inverse
            set rtn
        }
    } else {
        set rtn sciapp
        set rtn
    }]

    return [<form> action $url method post \
                [<siblings> \
                     {*}[lmap id [dict get $args -ids] { <input> type hidden name "_$id" id "_$id" {} }] \
                     [string map "@cbs $onchange_callbacks" {
                         <script>
                         \$(document).ready(() => {
                             @cbs
                         });
                         </script>
                     }] \
                     [subst {<button class="$themeclass list-group-item list-group-item-action btn-list-group"
                                     type="submit">[dict get $args -text]</button>}]]]
}

proc ::<get> { url args } {
    <a> href $url \
        class "list-group-item list-group-item-action nav-link" \
        style "border-radius: 0; padding-bottom: 5px; padding-top: 5px;" [dict get $args -text]
}

proc ::<nav> { args } {
    return [<ul> class "nav flex-column" \
                [<siblings> {*}[lmap { url txt } $args { <li> class nav-item \
                                                             [if { [dict exists $txt -ids] } {
                                                                 <post> $url {*}$txt
                                                             } else {
                                                                 <get> $url {*}$txt
                                                             }] }]]]
}
