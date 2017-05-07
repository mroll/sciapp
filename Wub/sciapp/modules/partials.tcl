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
                         [<div> \
                              [<input> id name name name type text class "form-control user-input-lg sciapp-inverse" placeholder "name" {}]] \
                         [<div> \
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
        set class "list-group-item list-group-item-action nav-link" 
        set style "border-radius: 0; padding-bottom: 5px; padding-top: 5px;" 
        if { [dict exists $args -style] } {
            append style [dict get $args -style]
        }
        if { [dict exists $args -class] } {
            lappend class [dict get $args -class]
        }

        <a> href $url \
            class $class \
            style $style \
            [dict get $args -text]
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

    proc lgroup_item { txt args } {
        set class list-text
        set id {}

        dict for {k v} $args {
            switch $k {
                -class { set class $v }
                -id { set id [list id $v] }
            }
        }
        
        <span> {*}$id class "list-group-item $class" style "border-radius: 0;" $txt
    }

    proc dirlink { cwd path dialogid } {
        set dir [regsub -all / $path _]
        set js [string map [list @cwd $cwd @dir $dir @dialogid $dialogid] {
            <script>
            $(document).ready(() => {
                $('#@dir').on('click', () => {
                    $.post('/api/ls', { cwd: "@cwd", dir: "@dir", dialog: "@dialogid" }, data => {
                        $('#@dialogid').dialog("option", "resizable", false);
                        $('#@dialogid').html(JSON.parse(data).html);
                    });
                });
            });
            </script>
        }]

        if { $path eq "UPDIR" } { set path .. }
        if { $path eq "DOTDIR" } { set path . }

        siblings $js [lgroup_item $path -id $dir]
    }

    proc filelink { cwd path dialogid } {
        set dir [regsub -all {\.} $path _]
        set js [string map [list @cwd $cwd @dir $dir @dialogid $dialogid] {
            <script>
            $(document).ready(() => {
                $('#@dir').on('click', () => {
                    $.post('/api/preview', { cwd: "@cwd", dir: "@dir", dialog: "@dialogid" }, data => {
                        console.log(data.html);
                        $('#@dialogid').dialog("option", "width", 500);
                        $('#@dialogid').dialog("option", "resizable", true);
                        $('#@dialogid').html(data.html);
                    });
                });
            });
            </script>
        }]

        siblings $js [lgroup_item $path -id $dir]
    }

    proc html_escape { string } {
        set patterns { & \\&amp\; < \\&lt\; > \\&gt\; }
        dict for {k v} $patterns  {
            set string [regsub -all $k $string $v]
        }
        set string
    }

    proc preview { cwd path dialogid } {
        menulist \
            [dirlink $cwd DOTDIR $dialogid] \
            [<pre> style "font-size: 10px;" [html_escape [exec cat $cwd/$path]]]
    }

    proc files { path } {
        split [exec ls -1 $path] \n
    }

    proc menulist { args } {
        return [<ul> class "nav flex-column" [siblings {*}$args]]
    }

    proc ls { cwd path dialogid } {
        menulist \
            [dirlink $cwd UPDIR $dialogid] \
            {*}[lmap f [files $cwd] { if { [file isdirectory $cwd/$f] } {
                dirlink $cwd $f $dialogid
            } else {
                filelink $cwd $f $dialogid
            }}]
    }

    proc box { id args } {
        set kwargs [lrange $args 0 end-1]
        set child [lindex $args end]
        set pos "my: \"center\", at: \"center\", of: window"
        set width {"auto"}
        set height {"auto"}
        set dialogClass "no-close custom"
        set title $id

        # parse keyword arguments out of the dictionary.
        # might be a way to put this all in a single proc..
        #     kwargs $kwargs
        # and then all the names of the keys would be in
        # scope in just the right way to be subst'd into
        # the template string.
        dict for {k v} $kwargs {
            switch $k {
                -pos {
                    set my [dict get $kwargs -pos my]
                    set at [dict get $kwargs -pos at]
                    set of [dict get $kwargs -pos of]

                    # use Html's dict2json for this
                    set pos [string map [list @my $my @at $at @of $of] {my: "@my", at: "@at", of: "@of"}]

                    dict unset kwargs -pos
                }
                -width {
                    set width [dict get $kwargs -width]
                    dict unset kwargs -width
                }
                -height {
                    set height [dict get $kwargs -height]
                    dict unset kwargs -height
                }
                -hidetitle {
                    lappend dialogClass notitle
                    dict unset kwargs -hidetitle
                }
                -padded {
                    lappend dialogClass padded
                    dict unset kwargs -padded
                }
                -title {
                    set title [dict get $kwargs -title]
                    dict unset kwargs -title
                }
            }
        }

        set context [list @id $id @title $title @pos $pos @height $height @width $width @dialogClass $dialogClass]
        set js [string map $context {
            <script>
            $(document).ready(() => {
                $("#@id").dialog({
                    title: "@title",
                    dialogClass: "@dialogClass",
                    resizable: false,
                    position: {@pos},
                    minHeight: 0,
                    maxHeight: @height,
                    width: @width,
                });
            });
            </script>
        }]

        siblings [col {} id $id {*}$kwargs $child] $js 
    }

}
