auth /dashboard { r args } {
    Query::with $r {}

    set booklist [lmap book [user books $username] {
        <tr> [box siblings {*}[lmap col [lrange $book 0 end-1] { <td> $col }]]
    }]
    
    lappend page [box container logout \
                      width 300 \
                      pos { my "left top" at "left+15 bottom+15" of ".jumbotron" } {
                          {box get /logout text logout}
                      }]

    lappend page [box container books \
                      title Books \
                      pos { my "left top" at "right+15 top" of "#logout" } \
                      width 1000 {
                          {box datatable _books \
                               addroute /api/books/new \
                               rmroute /api/books/rm \
                               existing $booklist \
                               hdrs [lrange [book columns] 0 end-1] \
                               init {
                                   table.rows().every(function ( rowidx, tblloop, rowloop ) {
                                       var id = this.data()[0];

                                       $('#_books').append(`<form id="book${id}" action="/book" method="get">
                                                           <input type="hidden" name="id" value="${id}">
                                                           </form>`);
                                   });
                                   
                                   $('#_books tr').click(function() {
                                       var id = $($(this).children()[0]).text();
                                       $(`#book${id}`).submit();
                                   });
                               }}
                      }]

    lappend page [box container newbook \
                      pos { my "left top" at "left bottom+5" of "#logout" } {
                          {<button> newbook-btn id newbook-btn data-toggle modal \
                               data-target "#newbook-modal" \
                               class "sciapp btn btn-sciapp" "new book"}
                      }]

    lappend page [box modal newbook-modal btnid newbook-btn {
        {box textform _newbook \
             action /api/book/new \
             names [lrange [book columns] 1 end-1] \
             cb {(data) => {
                 $('#newbook-modal').modal('hide');

                 var table = $('#_books').DataTable();
                 table.row.add(Object.keys(data).map(k => {
                     return data[k];
                 })).draw();

                 var bid = data.id;
                 $('#_books').append(`<form id="book${bid}" action="/book" method="get">
                                     <input type="hidden" name="id" value="${bid}">
                                     </form>`);
                 $('#_books tr').click(function() {
                     var id = $($(this).children()[0]).text();
                     $(`#book${id}`).submit();
                 });
             }}}
    }]
                      

    set r [Html style $r css]
    return [Http Ok $r [box siblings {*}$page]]
}
