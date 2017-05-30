auth /api/question/rm { r args } {
    Query::with $r {}

    # if the database isn't set up to handle cascading deletions (it
    # isn't currently), then we will have to take care of that here.
    question rm $id

    Http Ok $r [json::write object message "success"]
}
