/// obj_game — Step
// Not frozen by hitstop: these inputs must always work.

// ---- Title screen ----
if (room == rm_title) {
    global.paused = false;
    if (menu_kind != "title") menu_open(menu_title_items(), "title");
    menu_update();
    exit;
}

// ---- Auto-pause when the game loses focus ----
// Browser: tab hidden/switched. Desktop: window lost focus (alt-tab).
if (!global.paused && !run_over) {
    var _lost = is_browser() ? os_is_paused() : !window_has_focus();
    if (_lost) pause_open();
}

// ---- Pause menu ----
if (keyboard_check_pressed(vk_escape) && !run_over) {
    if (global.paused) global.paused = false; else pause_open();
}
else if (global.paused) {
    menu_update();
}

// ---- Death screen ----
if (run_over) {
    if (keyboard_check_pressed(ord("R"))) run_restart();
    else if (keyboard_check_pressed(vk_escape)) go_title();
}

// ---- Debug keys (remove or gate before release) ----
if (keyboard_check_pressed(vk_f1)) global.debug = !global.debug;

if (global.debug) {
    // F2: test feel — big hit
    if (keyboard_check_pressed(vk_f2)) { hitstop(4); shake(5); }
    // F3: hurt the player from the mouse position
    if (keyboard_check_pressed(vk_f3)) {
        with (obj_player) take_damage(1, global.mouse_wx, global.mouse_wy);
    }
    // F4: kill every enemy (skip to the upgrade pick)
    if (keyboard_check_pressed(vk_f4)) {
        with (obj_enemy) die();
    }
}

// ---- Room flow: clear -> pick upgrade -> door ----
if (room == rm_arena_test && !run_over && !global.paused) {
    run_update();
}

// Banner fade
if (banner_t > 0 && !global.paused) banner_t--;
