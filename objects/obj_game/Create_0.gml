/// obj_game — Create
// Persistent. Created by rm_init's creation code (the first room in the room order).

// ---- Scaling: we draw application_surface ourselves (see Post Draw) ----
application_surface_draw_enable(false);
surface_resize(application_surface, GAME_W, GAME_H);

win_w = 0;      // last known window/canvas size, forces a resize on frame 1
win_h = 0;
scale = 1;
off_x = 0;      // letterbox offsets
off_y = 0;

// ---- Run state ----
run_seed = irandom(999999);
random_set_seed(run_seed);
hitstop_frames = 0;
run_over = false;

// ---- Menus (see scr_menu) ----
menu_items   = [];
menu_sel     = 0;
menu_kind    = "";
menu_last_mx = 0;
menu_last_my = 0;

/// Called by the player when HP hits 0.
on_player_death = function() {
    run_over = true;
};

/// Instant restart. For now this reloads the arena; once room flow exists
/// it will reset run state and jump to act 1, room 1.
run_restart = function() {
    run_over = false;
    hitstop_frames = 0;
    global.paused = false;
    run_seed = irandom(999999);
    random_set_seed(run_seed);
    room_goto(rm_arena_test);
};

/// Back to the title screen (browser "Quit", and Esc on the death screen).
go_title = function() {
    run_over = false;
    hitstop_frames = 0;
    global.paused = false;
    room_goto(rm_title);
};

/// Opens the pause menu.
pause_open = function() {
    global.paused = true;
    menu_open(menu_pause_items(), "pause");
};

// ---- Camera (persistent, created once) ----
instance_create_depth(0, 0, 0, obj_camera);

// Dev: test-arena wave refill timer (see Step)
dev_wave_timer = 0;

room_goto(rm_title);
