auth /dashboard { r args } {
    set js [string map [list @qlistitem [_html::qlistitem \${id} \${question}]] {
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

                        $(`@qlistitem`).prependTo('#question-list');
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
                  [<h1> Scope]]

    set qadd [<div> class input-group \
                  {<input id="question" type="text" class="form-control" placeholder="Ask anything...">
                   <span>
                    <button id="add-question" class="btn btn-secondary" type="button">+</button>
                   </span>}]

    set qlist [lmap { id q } [user questions $name] { _html::qlistitem $id $q }]

    append page [_html::siblings \
                     [_html::box mainmenu \
                          -title {Main Menu} \
                          -pos { my "left+15 top+15" at "left bottom" of ".jumbotron" } \
                          -width 400 \
                          [_html::nav \
                               /hypothesis {-text Hypothesis} \
                               /design {-text {Experiment Design}} \
                               /measurements {-text Measurements} \
                               /analysis {-text Analysis} \
                               /conclusions {-text Conclusions}]] \
                     [_html::box question-input \
                          -pos { my "left top+15" at "left bottom" of "#mainmenu" } \
                          -width 400 \
                          -hidetitle 1 \
                          [_html::siblings $qadd [<ul> id question-list class list-group \
                                                      [_html::siblings {*}$qlist]]]] \
                     [_html::box logout \
                          -pos { my "left top+15" at "left bottom" of "#question-input" } \
                          -width 400 \
                          -hidetitle 1 \
                          [<div> [_html::nav /logout {-text Logout}]]] \
                     [_html::filenav file-nav \
                          -title {File Navigator} \
                          -pos { my "left top-47" at "right+400 top" of "#mainmenu" } \
                          -width 800 \
                          -height 500]]

    append page $js

    set r [Html style $r css]
    return [Http Ok $r $page]
}

proc /test { r args } {
    puts "query: [Query::value [Query::parse $r] _question]"

    return [Http Redirect $r /dashboard]
}
