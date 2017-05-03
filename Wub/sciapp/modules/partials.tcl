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

proc question_list_item { id question } {
    return "<div class=\"qrow input-group\"> \
                  <a href=\"/question?$id\" style=\"border-radius: 0;\" class=\"list-group-item list-group-item-action\">$question</a> \
                  <span class=\"user-input-lg input-group-btn\"> \
                    <button data-id=\"$id\" class=\"rm-question btn btn-secondary\" type=\"button\">-</button> \
                  </span>
                </div>"
}

proc <siblings> { args } {
    join $args \n
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
