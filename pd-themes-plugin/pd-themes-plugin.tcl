package provide pd-themes 0.1

namespace eval pd_themes {
    variable this_path
    variable current_name
    variable current_theme
    variable hover_theme
    variable selected_theme
    variable num_themes
    variable canvas_height
}

proc ::pd_themes::trimsubstringright {str substr} {
    set l [expr {[string length $substr]-1}]
    if {[string range $str end-$l end] == $substr} {
        incr l
        return [string range $str 0 end-$l]
    } else {
        return -code error "$str does not end in $substr"
    }
}

proc ::pd_themes::reset_defaults {} {
    array set ::pd_colors {
        selected "#0000ff"
        selection_rectangle "#000000"
        txt_highlight "#c0c0c0"
        txt_highlight_front "#000000"
        msg_iolet "#000000"
        msg_iolet_border "#000000"
        signal_iolet "#000000"
        signal_iolet_border "#000000"
        obj_box_outline "#000000"
        obj_box_fill "#ffffff"
        obj_box_text "#000000"
        msg_box_outline "#000000"
        msg_box_fill "#ffffff"
        msg_box_text "#000000"
        atom_box_outline "#000000"
        atom_box_focus_outline "#000000"
        atom_box_fill "#ffffff"
        atom_box_text "#000000"
        atom_box_label "#000000"
        msg_cord "#000000"
        signal_cord "#0000ff"
        obj_box_outline_broken "#ff0000"
        canvas_fill "#ffffff"
        canvas_text_cursor "#000000"
        comment "#000000"
        graph_outline "#000000"
        graph_text "#000000"
        graph_open "#c0c0c0"
        array_name "#000000"
        array_values "#000000"
        gop_box "#ff8080"
        text_window_fill "#ffffff"
        text_window_text "#000000"
        text_window_hl_text "#000000"
        text_window_highlight "#c0c0c0"
        text_window_cursor "#000000"
        pdwindow_fill "#ffffff"
        pdwindow_fatal_text "#dd0000"
        pdwindow_fatal_highlight "#ffe0e8"
        pdwindow_error_text "#dd0000"
        pdwindow_post_text "#000000"
        pdwindow_debug_text "#484848"
        pdwindow_hl_text "#000000"
        helpbrowser_fill "#ffffff"
        helpbrowser_text "#000000"
        helpbrowser_highlight "#c0c0c0"
        helpbrowser_hl_text "#000000"
    }
}

proc ::pd_themes::safe_color {key} {
    if {[info exists ::pd_colors($key)] && $::pd_colors($key) ne ""} {
        return $::pd_colors($key)
    }
    # If color is not set in theme, use the default
    ::pd_themes::reset_defaults
    return $::pd_colors($key)
}

proc ::pd_themes::apply_theme_to_window {window} {
    if {![winfo exists $window]} {
        return
    }

    if {[winfo class $window] eq "PatchWindow"} {
        if {![winfo exists ${window}.c]} {
            # If the canvas doesn't exist yet, schedule another attempt
            after 100 [list ::pd_themes::apply_theme_to_window $window]
            return
        }
        if {[catch {
            ${window}.c configure -background [safe_color canvas_fill]
            ${window}.c configure -selectbackground [safe_color selection_rectangle]
            ${window}.c configure -insertbackground [safe_color canvas_text_cursor]
        } err]} {
            # If we catch an error, log it and schedule another attempt
            puts "Error applying theme to $window: $err"
            after 100 [list ::pd_themes::apply_theme_to_window $window]
        }
    } elseif {[winfo class $window] eq "HelpBrowser"} {
        if {[winfo exists ${window}.canvas.f]} {
            ${window}.canvas.f configure -background [safe_color helpbrowser_fill]
        }
    } elseif {[winfo exists $window.text]} {
        $window.text configure -foreground [safe_color text_window_text]
        $window.text configure -background [safe_color text_window_fill]
        $window.text configure -insertbackground [safe_color text_window_cursor]
        $window.text configure -selectbackground [safe_color text_window_highlight]
        $window.text configure -selectforeground [safe_color text_window_hl_text]
    }
}

proc ::pd_themes::apply_theme_to_window {window} {
    if {![winfo exists $window]} {
        return
    }

    if {[winfo class $window] eq "PatchWindow"} {
        if {[winfo exists ${window}.c]} {
            ${window}.c configure -background [safe_color canvas_fill]
            ${window}.c configure -selectbackground [safe_color selection_rectangle]
            ${window}.c configure -insertbackground [safe_color canvas_text_cursor]
        }
    } elseif {[winfo class $window] eq "HelpBrowser"} {
        if {[winfo exists ${window}.canvas.f]} {
            ${window}.canvas.f configure -background [safe_color helpbrowser_fill]
        }
    } elseif {[winfo exists $window.text]} {
        $window.text configure -foreground [safe_color text_window_text]
        $window.text configure -background [safe_color text_window_fill]
        $window.text configure -insertbackground [safe_color text_window_cursor]
        $window.text configure -selectbackground [safe_color text_window_highlight]
        $window.text configure -selectforeground [safe_color text_window_hl_text]
    }
}

proc ::pd_themes::apply_theme_to_all_windows {} {
    foreach wind [wm stackorder .] {
        catch {::pd_themes::apply_theme_to_window $wind}
    }
}

proc ::pd_themes::setup_window_bindings {} {
    bind PatchWindow <Visibility> {
        after idle [list ::pd_themes::apply_theme_to_window %W]
    }
}

proc ::pd_themes::set_theme {name} {
    variable this_path
    variable current_name

    # check for theme
    if { ![file exists $this_path/themes/$name-theme.tcl] } {
        ::pdwindow::error "no theme '$name-theme.tcl'\n"
        return
    }

    #store name
    set current_name $name

    #reset defaults
    ::pd_themes::reset_defaults

    #load theme
    if {[catch {source $this_path/themes/${name}-theme.tcl} err]} {
        ::pdwindow::error "Error loading theme: $err\n"
        return
    }

    # Apply to all existing windows
    after 100 ::pd_themes::apply_theme_to_all_windows

    # Set up for future windows
    ::pd_themes::setup_window_bindings

    ::pdwindow::post "Theme '$name' applied\n"
}

proc ::pd_themes::init {mymenu} {
    set ::pd_themes::this_path $::current_plugin_loadpath
    $mymenu add command -label [_ "PD Themes..."] \
        -command {::pd_themes::opendialog}

    # Try to load the default theme
    if {[file exists $::pd_themes::this_path/current-theme.txt]} {
        if {![catch {set fp [open $::pd_themes::this_path/current-theme.txt r]}]} {
            set theme_name [read -nonewline $fp]
            close $fp
            after 500 [list ::pd_themes::set_theme $theme_name]
        }
    } else {
        ::pdwindow::post "No default theme found. Using built-in colors.\n"
    }

    # Set up bindings for future windows
    ::pd_themes::setup_window_bindings
}

proc ::pd_themes::opendialog {} {
    variable this_path
    variable current_name
    variable hover_theme
    variable selected_theme
    variable num_themes
    variable canvas_height
    set hover_theme ""
    set selected_theme ""
    array set temp_theme [array get ::pd_colors]
    if {[winfo exists .colortheme_dialog]} {
        wm deiconify .colortheme_dialog
        raise .colortheme_dialog
        focus .colortheme_dialog
        return
    }
    toplevel .colortheme_dialog -class ColorThemeDialog
    wm title .colortheme_dialog [_ "Color Themes"]
    wm group .colortheme_dialog .
    wm resizable .colortheme_dialog 0 1
    wm transient .colortheme_dialog
    wm minsize .colortheme_dialog 400 380
    if {$::windowingsystem eq "aqua"} {
        .colortheme_dialog configure -menu $::dialog_menubar
    }
    set themes [lsort [glob -path $this_path/themes/ *-theme.tcl]]
    frame .colortheme_dialog.theme_list
    scrollbar .colortheme_dialog.theme_list.sy -command \
        ".colortheme_dialog.theme_list.c yview"
    canvas .colortheme_dialog.theme_list.c -yscrollcommand \
        ".colortheme_dialog.theme_list.sy set" -width 400

    grid .colortheme_dialog.theme_list -sticky nwes -row 0 -column 0 \
        -padx 5 -pady 5 -columnspan 3
    grid .colortheme_dialog.theme_list.c -sticky ns -row 0 -column 0
    grid .colortheme_dialog.theme_list.sy -sticky ns -row 0 -column 1
    grid columnconfigure .colortheme_dialog.theme_list 0 -weight 1
    grid rowconfigure .colortheme_dialog.theme_list 0 -weight 1

    grid rowconfigure .colortheme_dialog 0 -weight 1

    set height 5
    set fontinfo [list $::font_family -14 $::font_weight]
    set mwidth [font measure $fontinfo M]
    set mheight [expr {[font metrics $fontinfo -linespace] + 5}]
    set boxheight [expr {$mheight * 3 + 18}]
    set boxincr [expr {$boxheight + 5}]
    set corner [expr {$mheight/4}]
    set counter 0
    set names ""
    foreach i $themes {
        ::pd_themes::reset_defaults
        source ${i}
        set name [{::pd_themes::trimsubstringright} [file tail ${i}] -theme.tcl]
        lappend names $name
        frame .colortheme_dialog.theme_list.c.f$counter
        .colortheme_dialog.theme_list.c create rectangle 0 $height 400 \
            [expr {$height + $boxheight}] -outline black -width 1 -tags \
            box$counter
        .colortheme_dialog.theme_list.c create window 0 $height -window \
            .colortheme_dialog.theme_list.c.f$counter -anchor nw -width \
            400 -height $boxheight
        canvas .colortheme_dialog.theme_list.c.f$counter.c -width 400 -height \
            $boxheight -background $::pd_colors(canvas_fill) \
            -highlightthickness 0
        grid .colortheme_dialog.theme_list.c.f$counter.c
        bind .colortheme_dialog.theme_list.c.f$counter.c <MouseWheel> \
            [list {::pd_themes::scroll} $counter %y %D $boxincr]

        if {$::windowingsystem eq "win32"} {
            .colortheme_dialog.theme_list.c.f$counter.c configure \
                -yscrollincrement 1
        }
        if {$::windowingsystem eq "x11"} {
            bind .colortheme_dialog.theme_list.c.f$counter.c <Button-4> \
                {event generate %W <MouseWheel> -delta 1 -y %y}
            bind .colortheme_dialog.theme_list.c.f$counter.c <Button-5> \
                {event generate %W <MouseWheel> -delta -1 -y %y}
            bind .colortheme_dialog.theme_list.c.f$counter.c <Shift-Button-4> \
                {break}
            bind .colortheme_dialog.theme_list.c.f$counter.c <Shift-Button-5> \
                {break}
        }
        bind .colortheme_dialog.theme_list.c.f$counter.c <Motion> \
            [list {::pd_themes::motion} $counter]
        bind .colortheme_dialog.theme_list.c.f$counter.c <ButtonPress> \
            [list {::pd_themes::click} $counter]
        .colortheme_dialog.theme_list.c.f$counter.c create rectangle 0 0 \
            400 $boxheight -outline black -width 1 -tags box$counter
        .colortheme_dialog.theme_list.c.f$counter.c create rectangle 2 0 \
            [expr {2 + $mwidth * [string length $name] + 4}] [expr {$mheight}] -fill black
        .colortheme_dialog.theme_list.c.f$counter.c create text 4 3 \
            -text ${name} -anchor nw -font $fontinfo -fill white
        incr height $boxincr
        incr counter
    }
    set canvas_height $height
    set num_themes $counter
    .colortheme_dialog.theme_list.c configure -scrollregion \
        [list 0 0 400 $height]
    button .colortheme_dialog.apply -text [_ "Apply"] \
         -command [list {::pd_themes::apply} $names]
    button .colortheme_dialog.close -text [_ "Close"] \
         -command "destroy .colortheme_dialog"
    button .colortheme_dialog.save -text [_ "Save Current"] \
        -command {::pd_themes::make_default}
    grid .colortheme_dialog.apply -row 1 -column 0
    grid .colortheme_dialog.close -row 1 -column 1
    grid .colortheme_dialog.save -row 1 -column 2
    grid columnconfigure .colortheme_dialog 0 -weight 1 -uniform a
    grid columnconfigure .colortheme_dialog 1 -weight 1 -uniform a
    grid columnconfigure .colortheme_dialog 2 -weight 1 -uniform a
    if {$::windowingsystem eq "aqua"} {
        button .colortheme_dialog.dark -text [_ "Save as Dark Theme"] \
            -command [list {::pd_themes::save_dark} $names]
        button .colortheme_dialog.undark -text [_ "Delete Dark Theme"] \
            -command {::pd_themes::delete_dark}
        grid .colortheme_dialog.dark -row 2 -column 0 -pady 5
        grid .colortheme_dialog.undark -row 2 -column 1 -pady 5
        grid configure .colortheme_dialog.apply -pady 1
    } else {
        grid configure .colortheme_dialog.apply -pady 5
        grid configure .colortheme_dialog.close -pady 5
        grid configure .colortheme_dialog.save -pady 5
    }
    bind .colortheme_dialog.theme_list.c <MouseWheel> \
        [list {::pd_themes::mainscroll} %y %D $boxincr]
    if {$::windowingsystem eq "win32"} {
        .colortheme_dialog.theme_list.c configure -yscrollincrement 1
    }
    if {$::windowingsystem eq "x11"} {
        bind .colortheme_dialog.theme_list.c <Button-4> \
            {event generate %W <MouseWheel> -delta 1 -y %y}
        bind .colortheme_dialog.theme_list.c <Button-5> \
            {event generate %W <MouseWheel> -delta -1 -y %y}
        bind .colortheme_dialog.theme_list.c <Shift-Button-4> \
            {break}
        bind .colortheme_dialog.theme_list.c <Shift-Button-5> \
            {break}
    }
    bind .colortheme_dialog <Motion><Leave> {
        if {${::pd_themes::hover_theme} ne "" && \
        ${::pd_themes::selected_theme} ne ${::pd_themes::hover_theme}} {
            .colortheme_dialog.theme_list.c.f${::pd_themes::hover_theme}.c \
                itemconfigure box${::pd_themes::hover_theme} -outline \
                black -width 1
            .colortheme_dialog.theme_list.c \
                itemconfigure box${::pd_themes::hover_theme} -outline \
                black -width 1
        }
        set {::pd_themes::hover_theme} ""
    }
    array set ::pd_colors [array get temp_theme]
}

proc ::pd_themes::motion {box} {
    if {$box ne ${::pd_themes::hover_theme}} {
        if {${::pd_themes::hover_theme} ne "" && \
        ${::pd_themes::hover_theme} ne \
        ${::pd_themes::selected_theme} } {
            .colortheme_dialog.theme_list.c.f${::pd_themes::hover_theme}.c \
                itemconfigure box${::pd_themes::hover_theme} -outline \
                black -width 1
            .colortheme_dialog.theme_list.c \
                itemconfigure box${::pd_themes::hover_theme} -outline \
                black -width 1
        }
        if {$box ne ${::pd_themes::selected_theme}} {
            .colortheme_dialog.theme_list.c.f$box.c itemconfigure \
                box$box -outline blue -width 7
            .colortheme_dialog.theme_list.c itemconfigure \
                box$box -outline blue -width 7
        }
        set {::pd_themes::hover_theme} $box
    }
}

proc ::pd_themes::click {box} {
    if {${::pd_themes::selected_theme} ne "" && \
    ${::pd_themes::selected_theme} ne $box} {
        .colortheme_dialog.theme_list.c.f${::pd_themes::selected_theme}.c \
            itemconfigure box${::pd_themes::selected_theme} -outline \
            black -width 1
        .colortheme_dialog.theme_list.c \
            itemconfigure box${::pd_themes::selected_theme} -outline \
            black -width 1
    }
    set {::pd_themes::hover_theme} $box
    set {::pd_themes::selected_theme} $box

    .colortheme_dialog.theme_list.c.f$box.c itemconfigure \
        box${::pd_themes::hover_theme} -outline \
        green -width 7
    .colortheme_dialog.theme_list.c itemconfigure \
        box${::pd_themes::hover_theme} -outline \
        green -width 7
}

proc ::pd_themes::scroll {box coord units boxincr} {
    variable num_themes
    set ocanvy [.colortheme_dialog.theme_list.c canvasy 0]
    .colortheme_dialog.theme_list.c yview scroll [expr {- ($units)}] units
    {::pd_themes::motion} [expr max(0, min($box + int($coord + \
        [.colortheme_dialog.theme_list.c canvasy 0] - $ocanvy)/$boxincr, \
        $num_themes-1))]
}

proc ::pd_themes::mainscroll {coord units boxincr} {
    variable num_themes
    set coord [.colortheme_dialog.theme_list.c canvasy $coord]
    set ocanvy [.colortheme_dialog.theme_list.c canvasy 0]
    .colortheme_dialog.theme_list.c yview scroll [expr {- ($units)}] units
    {::pd_themes::motion} [expr max(0, min(int($coord + \
        [.colortheme_dialog.theme_list.c canvasy 0] - $ocanvy)/$boxincr, $num_themes - 1))]
}

proc ::pd_themes::apply {names} {
    variable selected_theme
    if {$selected_theme eq ""} {return}
    {::pd_themes::set_theme} [lindex $names $selected_theme]
}

proc ::pd_themes::make_default {} {
    variable current_name
    variable this_path
    if {[catch {set fp [open $this_path/current-theme.txt w]}]} {
        ::pdwindow::error "couldn't open file for writing\n"
        return
    }
    puts -nonewline $fp $current_name
    close $fp
    ::pdwindow::post "saved $current_name as the theme\n"
}

proc ::pd_themes::save_dark {names} {
    variable this_path
    variable selected_theme
    if {$selected_theme eq ""} {return}
    set name [lindex $names $selected_theme]
    if {[catch {set fp [open $this_path/dark-theme.txt w]}]} {
        ::pdwindow::error "couldn't open file for writing\n"
        return
    }
    puts -nonewline $fp $name
    close $fp
    ::pdwindow::post "saved $name as the dark theme\n"
}

proc ::pd_themes::delete_dark {} {
    variable this_path
    if {[catch {file delete $this_path/dark-theme.txt}]} {
        ::pdwindow::error "couldn't delete dark theme file\n"
        return
    }
    ::pdwindow::post "deleted dark-theme.txt\n"
}

# Initialize the theme system
if {$::windowingsystem eq "aqua"} {
    ::pd_themes::init .menubar.apple.preferences
} else {
    ::pd_themes::init .menubar.file.preferences
}
