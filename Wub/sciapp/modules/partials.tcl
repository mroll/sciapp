namespace eval ::_html {
    
    proc jquery { } {
        return {<script src="https://code.jquery.com/jquery-3.2.1.min.js"
            integrity="sha256-hwg4gsxgFZhOsEEamdOYGBf13FyQuiTwlAQgxVSNgt4="
            crossorigin="anonymous"></script>}
    }

    proc jqueryui { } {
        return {<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js" \
                    integrity="sha256-VazP97ZCwtekAsvgPBSUwPFKdrwD3unUfSGVYrahUqU=" \
                    crossorigin="anonymous"></script>}
    }

    proc jqueryui-css { } {
        # available themes (https://code.jquery.com/ui/)
        # ----------------
        # base black-tie blitzer cupertino dark-hive dot-luv eggplant
        # excite-bike flick hot-sneaks humanity le-frog mint-choc
        # overcast pepper-grinder redmond smoothness south-street start
        # sunny swanky-purse trontastic ui-darkness ui-lightness vader

        return {<link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/black-tie/jquery-ui.css">}
    }

    proc bootstrap { } {
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

    proc qlistitem { id question } {
        <div> class input-group \
            [siblings \
                 [<a> class "list-group-item list-group-item-action" \
                      href /questions?$id \
                      style "border-radius: 0; padding-top: 0; padding-bottom: 0;" $question] \
                 [<span> \
                      [subst {<button data-id="$id" class="rm-question btn btn-secondary" type="button">-</button>}]]]
    }

    proc siblings { args } {
        join $args \n
    }

    proc container { args } { <div> class container {*}$args }
    proc row       { args } { <div> class row {*}$args }
    proc col       { args } { <div> class {*}$args }

    proc usercreds { url btntext } {
        return [<form> action $url method post \
                 [siblings \
                   [<div> class form-group \
                     [<input> id name name name type text class "form-control user-input-lg sciapp-inverse" placeholder "name" {}]] \
                     [<div> class form-group \
                       [<input> id password name password type password class "form-control user-input-lg sciapp-inverse" placeholder "password" {}]] \
                      [post $url -text $btntext -ids {name password}]]]
    }

    proc post { url args } {
        set onchange_js {
            \\\$('#@id').on('input', e => \{
              \\\$('#_@id').val(e.target.value);
            \});
        }

        set onchange_callbacks [list [join [lmap id [dict get $args -ids] { string map "@id $id" $onchange_js }] \n]]
        set themeclass sciapp
        if { [dict exists $args -style] } {
            if { [dict get $args -style] eq "inv" } {
                set themeclass sciapp-inverse
            }
        }

        return [<form> action $url method post \
                    [siblings \
                         {*}[lmap id [dict get $args -ids] { <input> type hidden name "_$id" id "_$id" {} }] \
                         [string map "@cbs $onchange_callbacks" {
                             <script>
                             \\\$(document).ready(() => {
                                 @cbs
                             });
                             </script>
                         }] \
                         [subst {<button class="$themeclass list-group-item list-group-item-action btn-list-group"
                             type="submit">[dict get $args -text]</button>}]]]
    }

    proc get { url args } {
        <a> href $url \
            class "list-group-item list-group-item-action nav-link" \
            style "border-radius: 0; padding-bottom: 5px; padding-top: 5px;" [dict get $args -text]
    }

    proc nav { args } {
        return [<ul> class "nav flex-column" \
                    [siblings {*}[lmap { url txt } $args { <li> class nav-item \
                                                                 [if { [dict exists $txt -ids] } {
                                                                     post $url {*}$txt
                                                                 } else {
                                                                     get $url {*}$txt
                                                                 }] }]]]
    }

    proc box { id args } {
        set kwargs [lrange $args 0 end-1]
        set child [lindex $args end]
        set pos "my: \"center\", at: \"center\", of: window"
        set width {"auto"}
        set height {"auto"}

        # these conditionals can definitely be generalized and shortened.
        if { [dict exists $kwargs -pos] } {
            set my [dict get $kwargs -pos my]
            set at [dict get $kwargs -pos at]
            set of [dict get $kwargs -pos of]

            set pos [string map [list @my $my @at $at @of $of] {my: "@my", at: "@at", of: "@of"}]

            dict unset kwargs -pos
        }
        if { [dict exists $kwargs -width] } {
            set width [dict get $kwargs -width]
            dict unset kwargs -width
        }
        if { [dict exists $kwargs -height] } {
            set width [dict get $kwargs -height]
            dict unset kwargs -height
        }

        set context [list @id $id @pos $pos @height $height @width $width]
        set js [string map $context {
            <script>
            $(document).ready(() => {
                $("#@id").dialog({
                    dialogClass: 'no-close',
                    resizable: false,
                    position: {@pos},
                    height: @height,
                    width: @width
                });
            });
            </script>
        }]

        siblings $js [col {} id $id {*}$kwargs $child]
    }

}
