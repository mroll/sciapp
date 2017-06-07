auth /container { r args } {
    set page [box container {
        id test
        title Test
        height 300
        width 200
        body {
            box editor {
                id src
                route /api/analysis/run
                data { name matt }
            }
        }
    }]

    Http Ok $r $page
}
