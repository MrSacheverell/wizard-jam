/// obj_game — Step
// Not frozen by hitstop: these inputs must always work.

// ---- Title screen ----
if (room == rm_title) {
    global.paused = false;
    if (menu_kind != "title" && menu_kind != "meta") menu_open(menu_title_items(), "title");
    if (menu_kind == "meta" && keyboard_check_pressed(vk_escape)) { menu_open(menu_title_items(), "title"); exit; }
    if (meta_msg_t > 0) meta_msg_t--;
    if (global.debug && keyboard_check_pressed(vk_f7)) { global.meta.essence += 100; save_write(); if (menu_kind == "meta") meta_refresh_menu(); }
    if (keyboard_check_pressed(vk_f1)) global.debug = !global.debug;
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
    // F6: jump to the Archmage with every slot unlocked and filled (boss testing)
    if (keyboard_check_pressed(vk_f6) && room == rm_arena_test) {
        var _r = global.run;
        _r.act = ACTS;
        _r.room = ROOMS_PER_ACT;
        _r.slot_count = MAX_SLOTS;
        var _pool = ["fireball", "chain_lightning", "frost_nova", "arcane_disc", "meteor", "wisp", "blink"];
        for (var i = 0; i < MAX_SLOTS; i++) {
            if (is_undefined(_r.slots[i])) {
                for (var j = 0; j < array_length(_pool); j++) {
                    if (run_owns_spell(_pool[j]) == -1) { _r.slots[i] = { id: _pool[j], tier: 2, cd: 0 }; break; }
                }
            }
        }
        global.picking = false;
        room_restart();
    }
    // F7: +100 Essence (test the Upgrades menu)
    if (keyboard_check_pressed(vk_f7)) { global.meta.essence += 100; save_write(); }
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
