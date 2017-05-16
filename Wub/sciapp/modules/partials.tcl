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

    proc file_upload { id getdir } {
        # need to get uniq names for local javascript variables

        siblings \
            {<form id="file-upload-form" enctype="multipart/form-data">
                <div class="input-group">
                  <input id="file-upload" name="file" type="file"
                  style="display: none;"
                  onchange="handlefiles(this.files)" />

                  <button id="file-upload-btn"
                  class="btn btn-sciapp sciapp"
                  type="button" disabled>Upload</button>

                <a class="list-group-item list-group-item-action list-text"
                id="file-select" href="#"
                style="border-radius: 0; padding-top: 0; padding-bottom: 0;">Choose File</a>
                </div>
                </form>} \
            [string map [mapvars getdir] {<script>
                function handlefiles(files) {
                    $('#file-upload-btn').prop("disabled", false);
                    $('#file-select').text(files[0].name);

                    var dat = new FormData($('#file-upload-form')[0]);
                }

                $('#file-select').on('click', e => {
                    var fileElem = $('#file-upload');
                    if (fileElem) {
                        fileElem.click();
                    }
                    e.preventDefault();
                });

                $('#file-upload-btn').on('click', function() {
                    var data = new FormData($('#file-upload-form')[0]);
                    data.set("path", @getdir);
                    
                    $.ajax({
                        url: '/api/upload',
                        type: 'POST',
                        data: data,

                        // You *must* include these options!
                        cache: false,
                        contentType: false,
                        processData: false,

                        xhr: function() {
                            var myXhr = $.ajaxSettings.xhr();
                            return myXhr;
                        },
                        success: function(data) {
                            $('#file-select').text('Choose File');
                            $('#file-upload-btn').prop("disabled", "true");
                        }
                    });
                });
                </script>}]
    }

    proc filenav { id args } {
        # uniq name for upload
        _html::box $id {*}$args \
            [_html::siblings \
                 [_html::file_upload file-upload {$('#file-nav').data("cwd")}] \
                 [_html::ls . $id]]
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
                              [<input> id name name name type text \
                                   class "form-control user-input-lg sciapp-inverse" \
                                   placeholder "name" {}]] \
                         [<div> \
                              [<input> id password name password type password \
                                   class "form-control user-input-lg sciapp-inverse" \
                                   placeholder "password" {}]] \
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
                         [subst {<button class="$themeclass list-group-item list-group-item-action list-text"
                             type="submit">[dict get $args -text]</button>}]]]
    }

    proc get { url args } {
        set class "list-group-item list-group-item-action nav-link list-text" 
        set style "border-radius: 0; padding-bottom: 0; padding-top: 0;" 
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
                    [siblings {*}[lmap { url txt } $args {
                        <li> class nav-item \
                            [if { [dict exists $txt -ids] } {
                                post $url {*}$txt
                            } else {
                                get $url {*}$txt
                            }]
                    }]]]
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
        
        <span> {*}$id class "list-group-item $class" \
            style "border-radius: 0; padding-top: 0; padding-bottom: 0;" $txt
    }

    proc dirlink { cwd path dialogid } {
        set dir [regsub -all / $path ___]
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

    proc rfilelink { cwd path dialogid } {
        set dir [regsub -all {\.} $path ___]
        set js [string map [list @cwd $cwd @dir $dir @dialogid $dialogid] {
            <script>
            $(document).ready(() => {
                $('#@dir').on('click', () => {
                    $.post('/api/preview', { cwd: "@cwd", dir: "@dir", dialog: "@dialogid" }, data => {
                        $('#@dialogid').html(data.html);
                    });
                });
            });
            </script>
        }]

        siblings $js [lgroup_item $path -id $dir]
    }

    proc filelink { cwd fname dialogid } {
        if { [file isdirectory $cwd/$fname] } {
            return [dirlink $cwd $fname $dialogid]
        }
        return [rfilelink $cwd $fname $dialogid]
    }

    proc filelinks { cwd dialogid } {
        lmap f [files $cwd] { filelink $cwd $f $dialogid }
    }

    proc html_escape { string } {
        set patterns { & \\&amp\; < \\&lt\; > \\&gt\; }
        dict for {k v} $patterns  {
            set string [regsub -all $k $string $v]
        }
        return $string
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

    proc ls { cwd dialogid } {
        menulist \
            [dirlink $cwd UPDIR $dialogid] \
            {*}[filelinks $cwd $dialogid]
    }

    proc mapvars { args } {
        foreach v $args { lappend res @$v; lappend res [uplevel [list set $v]] }
        set res
    }

    proc box { id args } {
        set kwargs [lrange $args 0 end-1]
        set child [lindex $args end]
        set pos "my: \"center\", at: \"center\", of: window"
        set width {"auto"}
        set height {"auto"}
        set dialogClass "no-close custom"
        set title $id
        set minwidth "false"
        set maxwidth "false"
        set minheight "false"
        set maxheight "false"
        set draggable "false"

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
                    set width $v
                    dict unset kwargs -width
                }
                -height {
                    set height [dict get $kwargs -height]
                    dict unset kwargs -height
                }
                -minwidth {
                    set minwidth [dict get $kwargs -minwidth]
                    dict unset kwargs -width
                }
                -minheight {
                    set minheight [dict get $kwargs -minheight]
                    dict unset kwargs -minheight
                }
                -maxwidth {
                    set maxwidth [dict get $kwargs -maxwidth]
                    dict unset kwargs -width
                }
                -maxheight {
                    set maxheight [dict get $kwargs -maxheight]
                    dict unset kwargs -maxheight
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
                -draggable {
                    set draggable [dict get $kwargs -draggable]
                    dict unset kwargs -draggable
                }
            }
        }

        set context [mapvars id title pos height width dialogClass \
                         minheight maxheight draggable]

        set js [string map $context {
            <script>
            $(document).ready(() => {
                $("#@id").dialog({
                    title: "@title",
                    dialogClass: "@dialogClass",
                    resizable: false,
                    draggable: @draggable,
                    position: {@pos},
                    width: @width,
                    height: @height,
                    minHeight: @minheight,
                    maxHeight: @maxheight,
                });
            });
            </script>
        }]

        siblings [col {} id $id {*}$kwargs $child] $js 
    }

}
