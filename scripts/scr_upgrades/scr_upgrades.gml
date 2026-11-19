// =====================================================================
// scr_upgrades — the pick-1-of-3 upgrade screen and passive effects.
// Choices: a new spell, a spell tier-up, or a passive.
// A new spell when every unlocked slot is full means picking a slot to replace.
// Runs in obj_game's scope (picker_*), called from scr_run's room flow.
// =====================================================================

#macro CARD_W 132
#macro CARD_H 112

// ---------------------------------------------------------------------
// Passives. apply() changes global.run; player_sync() pushes it to the player.
// ---------------------------------------------------------------------
global.passive_db = {
    quick_hands: { name: "Quick Hands",   desc: "-10% all spell cooldowns.",          max: 3,
                   apply: function() { global.run.cd_mult *= 0.9; } },
    vitality:    { name: "Vitality",      desc: "+1 max HP, and heal 1.",              max: 3,
                   apply: function() { global.run.max_hp++; global.run.hp++; } },
    big_magic:   { name: "Big Magic",     desc: "+20% size for blasts and novas.",     max: 3,
                   apply: function() { global.run.area_mult += 0.2; } },
    multicast:   { name: "Multicast",     desc: "+1 projectile for Magic Bolt and Fireball.", max: 2,
                   apply: function() { global.run.extra_proj++; } },
    lingering:   { name: "Lingering Hex", desc: "Elements last 50% longer.",           max: 2,
                   apply: function() { global.run.status_mult += 0.5; } },
    second_wind: { name: "Second Wind",   desc: "Heal 1 HP each time you clear a room.", max: 2,
                   apply: function() { global.run.heal_on_clear++; } },
};

/// @func player_sync()
/// Copies run stats onto the live player (after an upgrade or heal).
function player_sync() {
    var _r = global.run;
    _r.hp = min(_r.hp, _r.max_hp);
    with (obj_player) {
        max_hp  = _r.max_hp;
        hp      = _r.hp;
        cd_mult = _r.cd_mult;
        slots   = _r.slots;
    }
}

/// @func run_owns_spell(id)  -> slot index or -1
function run_owns_spell(_id) {
    var _s = global.run.slots;
    for (var i = 0; i < MAX_SLOTS; i++) {
        if (!is_undefined(_s[i]) && _s[i].id == _id) return i;
    }
    return -1;
}

/// @func upgrade_roll(rare)
/// Builds 3 distinct choices. Rare (elite rooms): spells and tier-ups only.
function upgrade_roll(_rare) {
    var _pool = [];
    var _r = global.run;

    // New spells
    var _ids = variable_struct_get_names(global.spell_db);
    for (var i = 0; i < array_length(_ids); i++) {
        if (run_owns_spell(_ids[i]) == -1 && meta_spell_unlocked(_ids[i])) {
            var _d = spell_get(_ids[i]);
            array_push(_pool, { kind: "spell", id: _ids[i], weight: 3,
                title: _d.name, sub: "NEW SPELL", desc: _d.desc,
                color: global.element_color[_d.element] });
        }
    }
    // Tier-ups
    for (var i = 0; i < MAX_SLOTS; i++) {
        var _s = _r.slots[i];
        if (!is_undefined(_s) && _s.tier < 3) {
            var _d = spell_get(_s.id);
            array_push(_pool, { kind: "tier", id: _s.id, weight: 3,
                title: _d.name, sub: "TIER " + string(_s.tier + 1), desc: _d.tiers[_s.tier],
                color: global.element_color[_d.element] });
        }
    }
    // Passives
    if (!_rare) {
        var _pids = variable_struct_get_names(global.passive_db);
        for (var i = 0; i < array_length(_pids); i++) {
            var _p = global.passive_db[$ _pids[i]];
            var _have = _r.passives[$ _pids[i]] ?? 0;
            if (_have < _p.max) {
                array_push(_pool, { kind: "passive", id: _pids[i], weight: 3,
                    title: _p.name, sub: "PASSIVE" + ((_have > 0) ? "  " + string(_have + 1) + "/" + string(_p.max) : ""),
                    desc: _p.desc, color: c_silver });
            }
        }
    }

    // Weighted pick of up to 3, no duplicates
    var _out = [];
    while (array_length(_out) < 3 && array_length(_pool) > 0) {
        var _total = 0;
        for (var i = 0; i < array_length(_pool); i++) _total += _pool[i].weight;
        var _roll = random(_total);
        for (var i = 0; i < array_length(_pool); i++) {
            _roll -= _pool[i].weight;
            if (_roll <= 0) {
                _pool[i].rare = _rare;
                array_push(_out, _pool[i]);
                array_delete(_pool, i, 1);
                break;
            }
        }
    }
    return _out;
}

/// @func upgrade_apply(choice)
/// Returns true when done, false when the player must pick a slot to replace.
function upgrade_apply(_c) {
    var _r = global.run;
    switch (_c.kind) {
        case "spell":
            for (var i = 0; i < _r.slot_count; i++) {
                if (is_undefined(_r.slots[i])) {
                    _r.slots[i] = { id: _c.id, tier: 1, cd: 0 };
                    player_sync();
                    return true;
                }
            }
            return false;    // all full: choose a slot to replace

        case "tier":
            var _i = run_owns_spell(_c.id);
            if (_i != -1) _r.slots[_i].tier = min(3, _r.slots[_i].tier + 1);
            break;

        case "passive":
            var _p = global.passive_db[$ _c.id];
            _p.apply();
            _r.passives[$ _c.id] = (_r.passives[$ _c.id] ?? 0) + 1;
            break;
    }
    player_sync();
    return true;
}

// ---------------------------------------------------------------------
// Picker UI (obj_game scope)
// ---------------------------------------------------------------------

/// @func picker_open(rare)
function picker_open(_rare) {
    pick_choices = upgrade_roll(_rare);
    pick_sel     = 0;
    pick_mode    = "cards";     // or "replace"
    pick_pending = undefined;
    pick_rare    = _rare;
    global.picking = true;
    if (array_length(pick_choices) == 0) picker_close();   // nothing left to offer
}

/// @func picker_close()
function picker_close() {
    global.picking = false;
    global.run.phase = "door";
    with (obj_door) door_open();
    with (obj_player) {                   // don't fire the click/key that picked
        cast_buffer = array_create(MAX_SLOTS, 0);
        dash_buffer = 0;
    }
}

/// Card rectangles: [x1, y1, x2, y2]
function picker_card_rect(_i) {
    var _n   = array_length(pick_choices);
    var _gap = 10;
    var _x0  = GAME_W / 2 - (_n * CARD_W + (_n - 1) * _gap) / 2;
    var _x   = _x0 + _i * (CARD_W + _gap);
    var _y   = GAME_H / 2 - CARD_H / 2 + 6;
    return [_x, _y, _x + CARD_W, _y + CARD_H];
}

/// Replace-mode slot rectangles (same spot as the HUD spell bar, but bigger)
function picker_slot_rect(_i) {
    var _n = global.run.slot_count;
    var _w = 56, _gap = 8;
    var _x0 = GAME_W / 2 - (_n * _w + (_n - 1) * _gap) / 2;
    var _x = _x0 + _i * (_w + _gap);
    var _y = GAME_H / 2 - 20;
    return [_x, _y, _x + _w, _y + 48];
}

function point_in_rect(_px, _py, _r) {
    return _px >= _r[0] && _px < _r[2] && _py >= _r[1] && _py < _r[3];
}

/// @func picker_update()
function picker_update() {
    var _mx = global.mouse_gx, _my = global.mouse_gy;
    var _click = mouse_check_button_pressed(mb_left);

    if (pick_mode == "cards") {
        var _n = array_length(pick_choices);
        for (var i = 0; i < _n; i++) {
            if (point_in_rect(_mx, _my, picker_card_rect(i))) {
                pick_sel = i;
                if (_click) { picker_choose(i); return; }
            }
        }
        if (keyboard_check_pressed(ord("A")) || keyboard_check_pressed(vk_left))  pick_sel = (pick_sel - 1 + _n) mod _n;
        if (keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_right)) pick_sel = (pick_sel + 1) mod _n;
        for (var i = 0; i < _n; i++) {
            if (keyboard_check_pressed(ord(string(i + 1)))) { picker_choose(i); return; }
        }
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) picker_choose(pick_sel);
    }
    else {  // "replace": choose which slot the new spell replaces, or skip
        var _ns = global.run.slot_count;
        for (var i = 0; i < _ns; i++) {
            if (point_in_rect(_mx, _my, picker_slot_rect(i))) {
                pick_sel = i;
                if (_click) { picker_replace(i); return; }
            }
        }
        if (keyboard_check_pressed(ord("A")) || keyboard_check_pressed(vk_left))  pick_sel = (pick_sel - 1 + _ns) mod _ns;
        if (keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_right)) pick_sel = (pick_sel + 1) mod _ns;
        for (var i = 0; i < _ns; i++) {
            if (keyboard_check_pressed(ord(string(i + 1)))) { picker_replace(i); return; }
        }
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) picker_replace(pick_sel);
        if (keyboard_check_pressed(vk_backspace) || mouse_check_button_pressed(mb_right)) {
            pick_mode = "cards";     // back out and choose a different card
            pick_sel = 0;
        }
    }
}

function picker_choose(_i) {
    var _c = pick_choices[_i];
    if (upgrade_apply(_c)) {
        picker_close();
    } else {
        pick_pending = _c;
        pick_mode = "replace";
        pick_sel = 0;
    }
}

function picker_replace(_slot) {
    global.run.slots[_slot] = { id: pick_pending.id, tier: 1, cd: 0 };
    player_sync();
    picker_close();
}

/// @func picker_draw()   (Draw GUI)
function picker_draw() {
    draw_set_alpha(0.65);
    draw_set_color(c_black);
    draw_rectangle(0, 0, GAME_W, GAME_H, false);
    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);

    if (pick_mode == "cards") {
        draw_set_color(pick_rare ? make_color_rgb(255, 210, 80) : c_white);
        draw_text(GAME_W / 2, 34, pick_rare ? "RARE REWARD - CHOOSE ONE" : "CHOOSE AN UPGRADE");

        for (var i = 0; i < array_length(pick_choices); i++) {
            var _c = pick_choices[i];
            var _r = picker_card_rect(i);
            var _sel = (i == pick_sel);
            var _lift = _sel ? -3 : 0;
            var _cx = (_r[0] + _r[2]) / 2;

            draw_set_color(make_color_rgb(24, 20, 34));
            draw_rectangle(_r[0], _r[1] + _lift, _r[2], _r[3] + _lift, false);
            draw_set_color(_sel ? _c.color : merge_color(_c.color, c_black, 0.5));
            draw_rectangle(_r[0], _r[1] + _lift, _r[2], _r[3] + _lift, true);
            if (_sel) draw_rectangle(_r[0] + 1, _r[1] + 1 + _lift, _r[2] - 1, _r[3] - 1 + _lift, true);

            draw_set_color(_c.color);
            draw_text_transformed(_cx, _r[1] + 8 + _lift, _c.sub, 0.6, 0.6, 0);
            draw_set_color(c_white);
            draw_text_ext_transformed(_cx, _r[1] + 22 + _lift, _c.title, 14, (CARD_W - 12) / 0.85, 0.85, 0.85, 0);
            draw_set_color(c_ltgray);
            draw_text_ext_transformed(_cx, _r[1] + 48 + _lift, _c.desc, 14, (CARD_W - 14) / 0.6, 0.6, 0.6, 0);
            draw_set_color(c_gray);
            draw_text_transformed(_cx, _r[3] - 14 + _lift, "[" + string(i + 1) + "]", 0.6, 0.6, 0);
        }
    }
    else {
        draw_set_color(c_white);
        draw_text(GAME_W / 2, 46, "SLOTS FULL - REPLACE WHICH SPELL WITH");
        draw_set_color(pick_pending.color);
        draw_text(GAME_W / 2, 62, string_upper(pick_pending.title) + "?");

        var _keys = global.slot_keys;
        for (var i = 0; i < global.run.slot_count; i++) {
            var _r = picker_slot_rect(i);
            var _s = global.run.slots[i];
            var _d = spell_get(_s.id);
            var _sel = (i == pick_sel);
            var _cx = (_r[0] + _r[2]) / 2;
            draw_set_color(make_color_rgb(24, 20, 34));
            draw_rectangle(_r[0], _r[1], _r[2], _r[3], false);
            draw_set_color(_sel ? c_red : global.element_color[_d.element]);
            draw_rectangle(_r[0], _r[1], _r[2], _r[3], true);
            draw_set_color(c_white);
            draw_text_transformed(_cx, _r[1] + 6, _keys[i], 0.6, 0.6, 0);
            draw_set_color(global.element_color[_d.element]);
            draw_text_ext_transformed(_cx, _r[1] + 18, _d.name, 12, 50 / 0.6, 0.6, 0.6, 0);
            draw_set_color(c_gray);
            draw_text_transformed(_cx, _r[3] - 10, "T" + string(_s.tier), 0.6, 0.6, 0);
        }
        draw_set_color(c_gray);
        draw_text_transformed(GAME_W / 2, GAME_H / 2 + 44, "Click a slot (or 1-" + string(global.run.slot_count) + ").  Right-click / Backspace: go back", 0.6, 0.6, 0);
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
