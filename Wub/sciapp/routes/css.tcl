# [/css] is created by loading the contents of ./custom.css
proc /css { r args } [subst {
    set css {[::fread custom.css]};
    return \[Http Ok \$r \$css text/css\]
}]
