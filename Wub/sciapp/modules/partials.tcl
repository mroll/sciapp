namespace eval ::box {
    proc dict2json { d } {
        dict for {k v} $d {
            puts "$k: $v"
            if { [string range $v 0 3] eq "#var" } {
                lappend pairs $k; lappend pairs [string range $v 4 end]
            } else {
                lappend pairs $k; lappend pairs [json::write string $v]
            }
        }

        json::write object {*}$pairs
    }

    proc widget { name defaults args body } {
        dict for {k v} $defaults {
            # if { [string range $v 0 4] eq "#json" } {
            #     lappend sets [list set $k [dict2json [string range $v 5 end]]]
            # } else {
                lappend sets [list set $k $v]
            # }
        }
        set sets [join $sets \n]

        proc $name $args [string map [mapvars sets body] {@sets; @body}]
    }
    
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

    proc simplemde { } {
        return {
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/simplemde/latest/simplemde.min.css">
            <script src="https://cdn.jsdelivr.net/simplemde/latest/simplemde.min.js"></script>
        }
    }

    proc mathbox { } {
        <script> src "../assets/js/mathbox/mathbox-bundle.js"
    }

    proc inputgroup { args } {
        <div> class input-group [siblings {*}$args]
    }

    set textinput_defaults { placeholder {} }
    widget textinput $textinput_defaults { id args } {
        dict with args {}
        <input> id $id type text class form-control placeholder $placeholder
    }

    # might be able to get real flexibility out of this if we
    # optionally pass in an href or a callback.
    # not currently using the callback.
    set dynlistrow_defaults { text {} href {} cb {} }
    widget dynlist-row $dynlistrow_defaults { id args } {
        dict with args {}

        <div> class input-group \
            [siblings \
                 [<a> class "list-group-item list-group-item-action list-text" \
                      href $href \
                      style "border-radius: 0; padding-top: 0; padding-bottom: 0" $text] \
                 [<span> \
                      [subst {<button data-id="$id" class="rm-item btn-dyn-list btn btn-secondary" type="button">-</button>}]]]
    }


    set dyninput_defaults { inputid {} placeholder {} cb {} }
    widget dynamic-input {} { id args } {
        dict with args {}

        inputgroup [textinput $inputid placeholder $placeholder] \
            [button $buttonid text + cb $cb]
    }

    dynamic-input new-q inputid new-q-input placeholder "Ask anything..." cb \
        [string map [mapvars inputid listitem addroute rmroute data id listid] {
            var value = $('#@inputid').val();
            if (value == '') {
                return;
            }
            data = { value: value, data: @data };

            $.post('@addroute', data, function(data) {
                if (data.message == "success") {
                    var id = data.id;

                    $(`@listitem`).prependTo('#@listid');
                    $('#@inputid').val('')
                    $('.rm-item').click(deleteitem);
                }
            });
        }]

    inputgroup [get 


    set dynlist_defaults { addroute {} rmroute {} data {} existing {} }
    widget dynamic-list $dynlist_defaults { id args } {
        dict with args {}

        set data [dict2json $data]
        
        set inputid $id-input
        set buttonid $id-add
        set listid $id-list

        set inputrow [inputgroup [textinput $inputid] [button $id]]

        # set input [<div> class input-group \
        #                  [string map [mapvars inputid buttonid] {
        #                      <input id="@inputid" type="text" class="form-control" placeholder="" />
        #                      <span>
        #                      <button id="@buttonid" class="btn btn-secondary btn-dyn-list" type="button">+</button>
        #                      </span>}]]

        # set itemrow [siblings [$litemfn \${id} text \${value}]]

        set itemrow [inputgroup [get 

        set js [string map [mapvars listid listitem addroute data rmroute buttonid inputid] {
            <script>
            $(document).ready(function() {
                $('#@buttonid').on('click', e => {
                    e.preventDefault();

                    var value = $('#@inputid').val();
                    if (value == '') {
                        return;
                    }
                    data = { value: value, data: @data };

                    $.post('@addroute', data, function(data) {
                        if (data.message == "success") {
                            var id = data.id;

                            $(`@listitem`).prependTo('#@listid');
                            $('#@inputid').val('')
                            $('.rm-item').click(deleteitem);
                        }
                    });
                });

                function deleteitem(e) {
                    e.preventDefault();

                    var el = $(e.target),
                    data = { id: el.attr('data-id') };

                    $.post('@rmroute', data, data => {
                        el.closest('div').remove();
                    });
                }

                $('.rm-item').click(deleteitem);
            });
            </script>
        }]

        siblings \
            $js \
            $input \
            [<ul> id $listid class list-group [siblings {*}$existing]]
    }


    proc uploader { id payload args } {
        box $id {*}$args \
            [file_upload $id-upload $payload]
    }

    proc file_upload { id payload } {
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
            [string map [mapvars payload] {<script>
                function handlefiles(files) {
                    $('#file-upload-btn').prop("disabled", false);
                    $('#file-select').text(files[0].name);

                    // var dat = new FormData($('#file-upload-form')[0]);
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
                    data.set("payload", @payload);
                    
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

    proc filenav { id cwd args } {
        # uniq name for upload
        _html::box $id {*}$args \
            [_html::siblings \
                 [_html::file_upload file-upload [json::write object path {$('#file-nav').data("cwd")}]] \
                 [_html::ls ls $cwd file-preview]]
    }

    proc siblings { args } {
        join $args \n
    }

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

    set litem_defaults { text {} class list-text }
    widget litem $litem_defaults { id args } {
        set html [<span> id $id class "list-group-item $class" \
                      style "border-radius: 0; padding-top: 0; padding-bottom: 0;" $text]

        if { [info exists cb] } {
            lappend html [string map [mapvars id cb] {
                <script>
                $(document).ready(() => {
                    $('#@id').on('click', () => { @cb });
                });
                </script>
            }]
        }

        siblings {*}$html
    }

    proc litem { id txt args } {
        set class list-text

        dict for {k v} $args {
            switch $k {
                class { set class $v }
            }
        }
        
        set html [<span> id $id class "list-group-item $class" \
                      style "border-radius: 0; padding-top: 0; padding-bottom: 0;" $txt]

        if { [dict exists $args cb] } {
            set cb [dict get $args cb]
            set callback [string map [mapvars id cb] {
                <script>
                $(document).ready(() => {
                    $('#@id').on('click', () => { @cb });
                });
                </script>
            }]
        }

        siblings $callback $html
    }

    proc list2js { l } {
        return \[[join [concat [lmap x $l { json::write string "$x" }]] ", "]\]
    }

    proc boxgroups { id groups args } {
        set labels [dict keys $groups]
        set groups [dict values $groups]
        set boxids [concat {*}$groups]

        set boxidsjs [list2js $boxids]
        set groupsjs [lmap g $groups { list2js $g }]

        # this whole section of assignments should get cleaned up.
        set pairs [lmap l $labels g $groupsjs { list $l $g }]
        set groupdictjs [json::write object {*}[concat {*}$pairs]]

        set js [string map [mapvars groupdictjs boxidsjs] {
            <script>
                  var groups = @groupdictjs;
                  var boxids = @boxidsjs;
            </script>
        }]

        foreach group $groups label $labels {
            set group [list2js $group]

            set callback [string map [mapvars label] {
                for (let bid of boxids) {
                    $(`#${bid}`).dialog("close");
                }

                for (let bid of groups["@label"]) {
                    $(`#${bid}`).dialog("open");
                }
            }]
            lappend md [litem ${label}group $label cb $callback]
        }

        box $id {*}$args [siblings $js [<ul> [siblings {*}$md]]]

    }


    proc dirlink { windowid cwd path dialogid } {
        set dir [regsub -all / $path ___]
        set js [string map [list @windowid $windowid @cwd $cwd @dir $dir @dialogid $dialogid] {
            <script>
            $(document).ready(() => {
                $('#@dir').on('click', () => {
                    $.post('/api/ls', { windowid: "@windowid", cwd: "@cwd", dir: "@dir", dialog: "@dialogid" }, data => {
                        $('#@dialogid').dialog("option", "resizable", false);
                        $('#@windowid').html(JSON.parse(data).html);
                    });
                });
            });
            </script>
        }]

        if { $path eq "UPDIR" } { set path .. }
        if { $path eq "DOTDIR" } { set path . }

        siblings $js [litem id $dir route $path]
    }

    proc rfilelink { cwd path windowid } {
        set dir [regsub -all {\.} $path ___]
        set js [string map [list @windowid $windowid @cwd $cwd @dir $dir] {
            <script>
            $(document).ready(() => {
                $('#@dir').on('click', () => {
                    $.post('/api/preview', { windowid: "@windowid", cwd: "@cwd", dir: "@dir" }, data => {
                        $('#@windowid').html(data.html);
                        $('#@windowid').data("filename", "@cwd/@dir");
                    });
                });
            });
            </script>
        }]

        siblings $js [litem $dir $path]
    }

    proc tool { id getfile windowid } {
        set js [string map [mapvars id getfile windowid] {<script>
            $(document).ready(() => {
                $('#@id').on('click', () => {
                    $.post('/api/operator', { path: @getfile, operator: "@id", windowid: "@windowid" }, data => {
                        $('#@windowid').html(data.html);
                    });
                });
            });
            </script>}]

        siblings $js [litem $id $id]
    }

    proc showdata { id data } {
        <pre> id $id $data
    }

    proc filelink { windowid cwd fname dialogid } {
        if { [file isdirectory $cwd/$fname] } {
            return [dirlink $windowid $cwd $fname $dialogid]
        }
        return [rfilelink $cwd $fname $dialogid]
    }

    proc filelinks { windowid cwd dialogid } {
        lmap f [files $cwd] { filelink $windowid $cwd $f $dialogid }
    }

    proc html_escape { string } {
        set patterns { & \\&amp\; < \\&lt\; > \\&gt\; }
        dict for {k v} $patterns  {
            set string [regsub -all $k $string $v]
        }
        set string
    }

    proc fileviewer { id args } {
        box $id {*}$args [<div> class filepreview]
    }

    set button_defaults { text Button }
    widget button $button_defaults { id args } {
        dict with args {}

        set html [<button> id $id class "btn btn-sciapp sciapp" $text]

        if { [info exists cb] } {
            lappend html [string map [mapvars id cb] {
                <script>
                $(document).ready(() => {
                    $('#@id').on('click', () => { @cb });
                });
                </script>
            }]
        }

        siblings {*}$html
    }

    set editor_defaults { route / data null }
    widget editor $editor_defaults { id args } {
        dict with args {}

        set data [dict2json $data]

        siblings \
            [string map [mapvars id route data] {
                <input type="textarea"  id="@id-editbox"></input>
                <script>
                $(document).ready(() => {
                    var simplemde = new SimpleMDE({
                        element: $("#@id-editbox")[0],
                        status: false,
                        toolbar: false,
                    });

                    $('#save').on('click', () => {
                        $.post("@route", { data: @data, value: simplemde.value() }, data => {
                            console.log('saved!');
                        });
                    });
                });
                </script>
            }] \
            [button save text Save]
    }

    set container_defaults {
        width {"width"}
        height {"auto"}
        minwidth "false"
        maxwidth "false"
        minheight "false"
        maxheight "false"
        draggable "true"
        dialogclass "no-close custom"
        pos "my center at center of #varwindow"
        title {}
        
    }
    widget container $container_defaults { id args } {
        set content [uplevel [lindex $args end]]
        set args    [lrange $args 0 end-1]

        dict with args {}
        set pos [dict2json $pos]
        
        set context  [mapvars id title pos height width \
                          minheight maxheight dialogclass \
                          minwidth maxwidth]
        set js [string map $context {
            <script>
            $(document).ready(() => {
                $("#@id").dialog({
                    title: "hello",
                    dialogClass: "no-close custom",
                    position: @pos,
                    height: @height,
                    width: @width,
                    minHeight: @minheight,
                    maxHeight: @maxheight,
                    minWidth: @minwidth,
                    maxWidth: @maxwidth,
                });

            });
            </script>
        }]
        
        siblings [col {} id $id $content] $js 
    }

    proc preview { id cwd path } {
        menulist [list id $id] \
            [<pre> style "font-size: 10px;" [html_escape [exec cat $cwd/$path]]]
    }

    proc files { path } {
        split [exec ls -1 $path] \n
    }

    proc menulist { kwargs args } {
        return [<ul> class "nav flex-column" {*}$kwargs [siblings {*}$args]]
    }

    proc ls { id cwd dialogid } {
        menulist [list id $id] \
            [dirlink $id $cwd UPDIR $dialogid] \
            {*}[filelinks $id $cwd $dialogid]
    }


    namespace export -clear *
    namespace ensemble create -subcommands { container editor dynamic-list }
}
