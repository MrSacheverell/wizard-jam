// =====================================================================
// scr_menu — one small menu system for the title screen and pause menu.
// Runs in obj_game's scope. Mouse (hover + click) and keyboard
// (W/S or arrows, Enter/Space) both work.
// =====================================================================

#macro MENU_ITEM_H 16
#macro MENU_ITEM_W 140

/// True when running in a browser (HTML5 export)
function is_browser() {
    return os_browser != browser_not_a_browser;
}

/// @func menu_open(items, kind)
/// items: array of { label, action } where action is a function.
/// kind:  "title" or "pause", so we know which menu is showing.
function menu_open(_items, _kind) {
    menu_items = _items;
    menu_sel   = 0;
    menu_kind  = _kind;
}

/// @func menu_y0()
/// Top of the first item, menu centered a little below the middle.
function menu_y0() {
    return GAME_H / 2 + 6 - (array_length(menu_items) * MENU_ITEM_H) / 2;
}

/// @func menu_update()
/// Handles input; runs the chosen item's action.
function menu_update() {
    var _n = array_length(menu_items);
    if (_n == 0) return;

    // Keyboard
    if (keyboard_check_pressed(ord("W")) || keyboard_check_pressed(vk_up))   menu_sel = (menu_sel - 1 + _n) mod _n;
    if (keyboard_check_pressed(ord("S")) || keyboard_check_pressed(vk_down)) menu_sel = (menu_sel + 1) mod _n;

    // Mouse hover
    var _y0 = menu_y0();
    var _hover = -1;
    for (var i = 0; i < _n; i++) {
        var _iy = _y0 + i * MENU_ITEM_H;
        if (abs(global.mouse_gx - GAME_W / 2) < MENU_ITEM_W / 2
        && global.mouse_gy >= _iy && global.mouse_gy < _iy + MENU_ITEM_H) {
            _hover = i;
        }
    }
    if (_hover != -1 && (window_mouse_get_x() != menu_last_mx || window_mouse_get_y() != menu_last_my)) {
        menu_sel = _hover;   // only steal selection when the mouse actually moves
    }
    menu_last_mx = window_mouse_get_x();
    menu_last_my = window_mouse_get_y();

    // Confirm
    var _go = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)
           || (mouse_check_button_pressed(mb_left) && _hover != -1);
    if (_go) {
        if (_hover != -1 && mouse_check_button_pressed(mb_left)) menu_sel = _hover;
        var _act = menu_items[menu_sel].action;
        _act();
    }
}

/// @func menu_draw()
/// Draws the items (call from Draw GUI).
function menu_draw() {
    var _y0 = menu_y0();
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    for (var i = 0; i < array_length(menu_items); i++) {
        var _iy  = _y0 + i * MENU_ITEM_H + MENU_ITEM_H / 2;
        var _sel = (i == menu_sel);
        if (_sel) {
            draw_set_alpha(0.25);
            draw_set_color(global.element_color[ELEMENT.NONE]);
            draw_rectangle(GAME_W / 2 - MENU_ITEM_W / 2, _iy - MENU_ITEM_H / 2 + 1,
                           GAME_W / 2 + MENU_ITEM_W / 2, _iy + MENU_ITEM_H / 2 - 1, false);
            draw_set_alpha(1);
        }
        draw_set_color(_sel ? c_white : c_gray);
        var _label = menu_items[i].label;
        draw_text(GAME_W / 2, _iy, _sel ? "> " + _label + " <" : _label);
    }
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

/// @func menu_title_items()
function menu_title_items() {
    var _items = [
        { label: "Start", action: function() { obj_game.run_restart(); } },
    ];
    if (!is_browser()) {
        array_push(_items, { label: "Quit", action: function() { game_end(); } });
    }
    return _items;
}

/// @func menu_pause_items()
function menu_pause_items() {
    return [
        { label: "Resume",      action: function() { global.paused = false; } },
        { label: "Restart run", action: function() { obj_game.run_restart(); } },
        { label: is_browser() ? "Quit to title" : "Quit",
          action: function() {
              if (is_browser()) obj_game.go_title(); else game_end();
          } },
    ];
}
