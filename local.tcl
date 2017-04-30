namespace eval ::Matt {

    proc / { r args } {
        puts "root::Matt:RequestDict_r: -->\n $r"
        set content $r

        return [Http Ok $r $content text/html]
    }

    namespace export --clear *
    namespace enesemble create -subcommands {}
}
