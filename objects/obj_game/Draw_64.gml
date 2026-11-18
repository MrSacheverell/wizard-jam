/// obj_game — Draw GUI
// GUI space is 480x270 (see display_set_gui_maximize in Begin Step).
// Temporary UI; obj_ui takes over HP / cooldowns later.

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

// ---- Title screen ----
if (room == rm_title) {
    var _t = current_time / 1000;
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    // Title with a slow element-color shimmer
    var _cols = global.element_color;
    var _c = merge_color(_cols[ELEMENT.NONE], _cols[1 + (floor(_t) mod 3)], 0.5 + 0.5 * sin(_t * 3));
    draw_set_color(c_black);
    draw_text_transformed(GAME_W / 2 + 2, 72 + 2, "ARCANE OVERLOAD", 2, 2, 0);
    draw_set_color(_c);
    draw_text_transformed(GAME_W / 2, 72, "ARCANE OVERLOAD", 2, 2, 0);
    draw_set_color(c_gray);
    draw_text(GAME_W / 2, 100, "a wizard roguelite");
    menu_draw();
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_dkgray);
    draw_text(GAME_W / 2, GAME_H - 30, "WASD move   Space dash   Mouse aim");
    draw_text(GAME_W / 2, GAME_H - 16, "LMB / RMB / Q / E cast   Esc pause");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    exit;
}

// HP (placeholder)
if (instance_exists(obj_player)) {
    draw_text(6, 4, "HP " + string(ceil(obj_player.hp)) + "/" + string(obj_player.max_hp));
}

// Act / room
if (room == rm_arena_test) {
    var _r = global.run;
    draw_set_halign(fa_right);
    draw_set_color((_r.room == ROOMS_PER_ACT) ? make_color_rgb(255, 210, 80) : c_white);
    draw_text(GAME_W - 6, 4, "ACT " + string(_r.act) + "   ROOM " + string(_r.room) + "/" + string(ROOMS_PER_ACT));
    draw_set_halign(fa_left);
    draw_set_color(c_white);
}

// Banner (room start / room clear)
if (banner_t > 0) {
    var _a = min(1, banner_t / 30);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_alpha(_a);
    draw_set_color(c_black);
    draw_text_transformed(GAME_W / 2 + 1, 56 + 1, banner_text, 1.25, 1.25, 0);
    draw_set_color(c_white);
    draw_text_transformed(GAME_W / 2, 56, banner_text, 1.25, 1.25, 0);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
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

// ---- Spell slots (temporary HUD until obj_ui) ----
if (instance_exists(obj_player)) {
    var _keys = ["LMB", "RMB", "Q", "E"];
    var _bw = 20, _gap = 4;
    var _x0 = GAME_W / 2 - (4 * _bw + 3 * _gap) / 2;
    var _y0 = GAME_H - _bw - 6;
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    for (var i = 0; i < 4; i++) {
        var _bx = _x0 + i * (_bw + _gap);
        var _s  = obj_player.slots[i];
        draw_set_color(c_black);
        draw_set_alpha(0.6);
        draw_rectangle(_bx, _y0, _bx + _bw, _y0 + _bw, false);
        draw_set_alpha(1);
        if (!is_undefined(_s)) {
            var _def = spell_get(_s.id);
            var _col = global.element_color[_def.element];
            // Cooldown shade, shrinking from the top
            var _max = max(1, _def.cooldown * 60 * obj_player.cd_mult);
            var _f = clamp(_s.cd / _max, 0, 1);
            draw_set_color(_col);
            draw_rectangle(_bx, _y0, _bx + _bw, _y0 + _bw, true);
            if (_f > 0) {
                draw_set_alpha(0.55);
                draw_set_color(c_black);
                draw_rectangle(_bx + 1, _y0 + 1, _bx + _bw - 1, _y0 + 1 + (_bw - 2) * _f, false);
                draw_set_alpha(1);
            }
            draw_set_color((_f > 0) ? c_gray : _col);
            draw_text(_bx + _bw / 2 + 1, _y0 + _bw / 2 + 1, _def.short);
        } else {
            draw_set_color(c_dkgray);
            draw_rectangle(_bx, _y0, _bx + _bw, _y0 + _bw, true);
        }
        draw_set_color(c_white);
        draw_text(_bx + _bw / 2, _y0 - 6, _keys[i]);
    }
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// Upgrade picker
if (global.picking) picker_draw();

// Pause menu
if (global.paused) {
    draw_set_alpha(0.6);
    draw_set_color(c_black);
    draw_rectangle(0, 0, GAME_W, GAME_H, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(GAME_W / 2, menu_y0() - 18, "PAUSED");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    menu_draw();
}

// Death / victory screen
if (run_over) {
    var _won = global.run.won;
    draw_set_alpha(0.5);
    draw_set_color(c_black);
    draw_rectangle(0, GAME_H / 2 - 30, GAME_W, GAME_H / 2 + 34, false);
    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_set_color(_won ? make_color_rgb(255, 210, 80) : c_red);
    draw_text(GAME_W / 2, GAME_H / 2 - 20, _won ? "VICTORY!" : "YOU DIED");
    draw_set_color(c_ltgray);
    draw_text_transformed(GAME_W / 2, GAME_H / 2 - 6,
        _won ? "The Archmage awaits... in a future build."
             : "Act " + string(global.run.act) + ", room " + string(global.run.room) + "  -  " + string(global.run.rooms_cleared) + " rooms cleared",
        0.7, 0.7, 0);
    draw_set_color(c_white);
    draw_text(GAME_W / 2, GAME_H / 2 + 12, "R: new run     Esc: title");
    draw_set_halign(fa_left);
}
