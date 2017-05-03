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
