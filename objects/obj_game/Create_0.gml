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
save_load();                 // meta progression (Essence, unlocks): see scr_meta
global.run = run_new();      // replaced at the start of every run

// ---- Room flow / upgrade picker (see scr_run, scr_upgrades) ----
clear_timer  = 0;
pick_choices = [];
pick_sel     = 0;
pick_mode    = "cards";
pick_pending = undefined;
pick_rare    = false;
banner_text  = "";
banner_t     = 0;

// ---- Menus (see scr_menu) ----
menu_items   = [];
menu_sel     = 0;
menu_kind    = "";
menu_item_h  = MENU_ITEM_H;
menu_scale   = 1;
menu_w       = MENU_ITEM_W;
meta_msg     = "";           // Upgrades menu feedback line
meta_msg_t   = 0;
menu_last_mx = 0;
menu_last_my = 0;

/// Called by the player when HP hits 0.
on_player_death = function() {
    run_over = true;
    run_bank_essence();
};

/// Instant restart: fresh run, act 1 room 1.
run_restart = function() {
    if (room == rm_arena_test) run_bank_essence();   // restarting mid-run still keeps what you earned
    run_over = false;
    hitstop_frames = 0;
    global.paused  = false;
    global.picking = false;
    run_seed = irandom(999999);
    random_set_seed(run_seed);
    global.run = run_new();
    run_pick_layout();
    if (room == rm_arena_test) room_restart(); else room_goto(rm_arena_test);
};

/// Back to the title screen (browser "Quit", and Esc on the death screen).
go_title = function() {
    if (room == rm_arena_test) run_bank_essence();
    run_over = false;
    hitstop_frames = 0;
    global.paused  = false;
    global.picking = false;
    room_goto(rm_title);
};

/// Opens the pause menu.
pause_open = function() {
    global.paused = true;
    menu_open(menu_pause_items(), "pause");
};

// ---- Camera (persistent, created once) ----
instance_create_depth(0, 0, 0, obj_camera);
instance_create_depth(0, 0, -90000, obj_lighting);   // light layer (scr_lighting)

room_goto(rm_title);
