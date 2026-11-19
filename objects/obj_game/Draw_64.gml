/// obj_game — Draw GUI
// GUI space is 480x270 (see display_set_gui_maximize in Begin Step).
// Temporary UI; obj_ui takes over HP / cooldowns later.

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

// ---- Upgrades screen (title room) ----
if (room == rm_title && menu_kind == "meta") {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text_transformed(GAME_W / 2, 16, "UPGRADES", 1.25, 1.25, 0);
    draw_set_color(make_color_rgb(190, 150, 255));
    draw_text_transformed(GAME_W / 2, 34, "Essence: " + string(global.meta.essence), 0.8, 0.8, 0);
    menu_draw();
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var _it = menu_items[menu_sel];
    var _desc = _it[$ "desc"] ?? "";
    draw_set_color(c_ltgray);
    draw_text_ext_transformed(GAME_W / 2, GAME_H - 30, _desc, 14, (GAME_W - 40) / 0.7, 0.7, 0.7, 0);
    if (meta_msg_t > 0) {
        draw_set_alpha(min(1, meta_msg_t / 20));
        draw_set_color(make_color_rgb(255, 220, 120));
        draw_text_transformed(GAME_W / 2, GAME_H - 12, meta_msg, 0.7, 0.7, 0);
        draw_set_alpha(1);
    } else {
        draw_set_color(c_dkgray);
        draw_text_transformed(GAME_W / 2, GAME_H - 12, "Esc: back", 0.6, 0.6, 0);
    }
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    exit;
}

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
    draw_set_color(make_color_rgb(190, 150, 255));
    draw_text_transformed(GAME_W / 2, 116, "Essence " + string(global.meta.essence)
        + "     Staff: " + meta_staff_def(global.meta.staff).name
        + ((global.meta.wins > 0) ? "     Wins " + string(global.meta.wins) : ""), 0.6, 0.6, 0);
    menu_draw();
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_dkgray);
    draw_text(GAME_W / 2, GAME_H - 30, "WASD move   Space dash   Mouse aim");
    draw_text(GAME_W / 2, GAME_H - 16, "LMB / RMB / Q / E (+ R / F) cast   Esc pause");
    draw_set_halign(fa_right);
    draw_set_valign(fa_bottom);
    draw_text_transformed(GAME_W - 4, GAME_H - 2, "VFX: pixelfx by Patch (MIT)", 0.5, 0.5, 0);
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

// Boss health bar
if (instance_exists(obj_archmage)) {
    var _boss = obj_archmage;
    var _hb_w = 220, _hb_x = GAME_W / 2 - _hb_w / 2, _hb_y = 22;
    var _hb_f = clamp(_boss.hp / _boss.max_hp, 0, 1);
    draw_set_color(c_black);
    draw_set_alpha(0.6);
    draw_rectangle(_hb_x - 2, _hb_y - 2, _hb_x + _hb_w + 2, _hb_y + 7, false);
    draw_set_alpha(1);
    var _hb_c = (_boss.phase == 1) ? global.element_color[ELEMENT.BURN]
            : ((_boss.phase == 2) ? global.element_color[ELEMENT.FREEZE] : global.element_color[ELEMENT.SHOCK]);
    draw_set_color(_hb_c);
    draw_rectangle(_hb_x, _hb_y, _hb_x + _hb_w * _hb_f, _hb_y + 5, false);
    draw_set_color(c_white);
    draw_line(_hb_x + _hb_w * 0.66, _hb_y - 1, _hb_x + _hb_w * 0.66, _hb_y + 6);   // phase marks
    draw_line(_hb_x + _hb_w * 0.33, _hb_y - 1, _hb_x + _hb_w * 0.33, _hb_y + 6);
    draw_set_halign(fa_center);
    draw_text_transformed(GAME_W / 2, _hb_y - 12, "THE ARCHMAGE", 0.6, 0.6, 0);
    draw_set_halign(fa_left);
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
    var _keys = global.slot_keys;
    var _bw = 20, _gap = 4;
    var _x0 = GAME_W / 2 - (MAX_SLOTS * _bw + (MAX_SLOTS - 1) * _gap) / 2;
    var _y0 = GAME_H - _bw - 6;
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    for (var i = 0; i < MAX_SLOTS; i++) {
        var _bx = _x0 + i * (_bw + _gap);
        var _s  = obj_player.slots[i];
        var _locked = (i >= global.run.slot_count);
        draw_set_color(c_black);
        draw_set_alpha(_locked ? 0.3 : 0.6);
        draw_rectangle(_bx, _y0, _bx + _bw, _y0 + _bw, false);
        draw_set_alpha(1);
        if (_locked) {
            // Locked: dim box with a small padlock
            draw_set_color(make_color_rgb(60, 56, 72));
            draw_rectangle(_bx, _y0, _bx + _bw, _y0 + _bw, true);
            var _cx = _bx + _bw / 2, _cy = _y0 + _bw / 2;
            draw_rectangle(_cx - 3, _cy - 1, _cx + 3, _cy + 4, false);
            draw_circle(_cx, _cy - 2, 2.5, true);
        }
        else if (!is_undefined(_s)) {
            var _def = spell_get(_s.id);
            var _col = global.element_color[_def.element];
            // Cooldown shade, shrinking from the top
            var _max = max(1, spell_cooldown(_def, _s.tier) * 60 * obj_player.cd_mult);
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
            draw_text_transformed(_bx + _bw / 2 + 1, _y0 + _bw / 2 + 1, _def.short, 0.75, 0.75, 0);
        } else {
            draw_set_color(c_dkgray);
            draw_rectangle(_bx, _y0, _bx + _bw, _y0 + _bw, true);
        }
        draw_set_color(_locked ? make_color_rgb(70, 66, 82) : c_white);
        draw_text_transformed(_bx + _bw / 2, _y0 - 5, _keys[i], 0.6, 0.6, 0);
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
        _won ? "The Archmage is defeated!  " + string(global.run.rooms_cleared) + " rooms cleared"
             : "Act " + string(global.run.act) + ", room " + string(global.run.room) + "  -  " + string(global.run.rooms_cleared) + " rooms cleared",
        0.7, 0.7, 0);
    draw_set_color(c_white);
    draw_set_color(make_color_rgb(190, 150, 255));
    draw_text_transformed(GAME_W / 2, GAME_H / 2 + 6, "+" + string(global.run.essence_final) + " Essence  (total " + string(global.meta.essence) + ")", 0.7, 0.7, 0);
    draw_set_color(c_white);
    draw_text(GAME_W / 2, GAME_H / 2 + 20, "R: new run     Esc: title");
    draw_set_halign(fa_left);
}
