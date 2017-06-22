auth /book { r args } {
    Query::with $r {}

    set name [book name $id]

    lappend page [box container sitenav \
                    width 200 \
                    pos { my "right top" at "right-15 bottom+15" of ".jumbotron" } {
                        {box nav /dashboard {text dashboard}}
                        {box get /logout text logout}
                    }]

    set cover [lindex [book img $id] 0]
    lappend page [box container coverimg \
                      pos { my "left top" at "left+15 bottom+15" of ".jumbotron" } {
                          {box siblings \
                              [<img> id bookcover$id] \
                              [<script> [string map [mapvars id cover] {
                                  $(document).ready(() => {
                                      $('#bookcover@id').attr('src', `data:image/png;base64, @cover`);
                                  });
                              }]]}
                      }]

    lappend page [box container bookname \
                      pos { my "left top" at "right+15 top" of "#coverimg" } {
                          {<div> [<h1> {*}$name]}
                      }
                 ]

    lappend page [box container rmbook \
                      pos { my "left top" at "left bottom+5" of "#bookname" } \
                      width 200 {
                          {box litem _rmbook \
                               text "delete book" \
                               class "sciapp-inverse btn-sciapp" \
                               cb [string map [mapvars id] {
                                   $.post('/api/book/rm', { id: @id }, data => {
                                       window.location = '/dashboard';
                                   });
                               }]}
                      }]

    set coverid bookcover$id
    lappend page [box container coverimg-upload \
                      pos { my "left top" at "left bottom+5" of "#coverimg" } {
                          {box fileupload _coverimgupload \
                               route /api/book/update \
                               payload "bid $id" \
                               cb [string map [mapvars coverid] {
                                   $('#@coverid').attr('src', `data:image/png;base64, ${data.img}`);
                                 }]
                           }
                      }]
    

    set r [Html style $r css]
    return [Http Ok $r [box siblings {*}$page]]
}
