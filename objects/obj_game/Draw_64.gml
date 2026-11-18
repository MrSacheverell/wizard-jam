/// obj_game — Draw GUI
// GUI space is 480x270 (see display_set_gui_maximize in Begin Step).
// Temporary UI; obj_ui takes over HP / cooldowns later.

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

// HP (placeholder)
if (instance_exists(obj_player)) {
    draw_text(6, 4, "HP " + string(obj_player.hp) + "/" + string(obj_player.max_hp));
}

// Pause
if (global.paused) {
    draw_set_alpha(0.5);
    draw_set_color(c_black);
    draw_rectangle(0, 0, GAME_W, GAME_H, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_text(GAME_W / 2, GAME_H / 2 - 6, "PAUSED");
    draw_set_halign(fa_left);
}

// Death screen
if (run_over) {
    draw_set_halign(fa_center);
    draw_set_color(c_red);
    draw_text(GAME_W / 2, GAME_H / 2 - 12, "YOU DIED");
    draw_set_color(c_white);
    draw_text(GAME_W / 2, GAME_H / 2 + 4, "Press R to restart");
    draw_set_halign(fa_left);
}

// Debug overlay (F1)
if (global.debug) {
    var _y = 20;
    draw_set_color(c_lime);
    draw_text(6, _y, "fps " + string(fps) + "  real " + string(floor(fps_real))); _y += 12;
    draw_text(6, _y, "win " + string(win_w) + "x" + string(win_h) + "  scale " + string(scale)); _y += 12;
    draw_text(6, _y, "inst " + string(instance_count) + "  seed " + string(run_seed)); _y += 12;
    if (instance_exists(obj_player)) {
        draw_text(6, _y, "state " + string(obj_player.state) + "  dash_cd " + string(obj_player.dash_cd_timer)); _y += 12;
    }
    draw_text(6, _y, "F2 hit test   F3 hurt self");
    draw_set_color(c_white);
}
