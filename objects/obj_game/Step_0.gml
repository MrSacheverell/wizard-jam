/// obj_game — Step
// Not frozen by hitstop: these inputs must always work.

// Pause (only while alive)
if (keyboard_check_pressed(vk_escape) && !run_over) {
    global.paused = !global.paused;
}

// Instant restart on death screen
if (run_over && keyboard_check_pressed(ord("R"))) {
    run_restart();
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
}

// ---- Dev: refill the test arena a second after it's cleared ----
if (room == rm_arena_test && !run_over && !global.paused) {
    if (!instance_exists(obj_enemy)) {
        dev_wave_timer++;
        if (dev_wave_timer > 60) {
            dev_spawn_wave(8);
            dev_wave_timer = 0;
        }
    }
}
