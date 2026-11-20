// =====================================================================
// scr_fx — cheap particle effects. Placeholder until pixelfx goes in.
// The system is (re)created lazily, so it survives room changes safely.
// =====================================================================

function fx_ensure() {
    if (!variable_global_exists("pt_spark")) {
        var _t = part_type_create();
        part_type_shape(_t, pt_shape_square);
        part_type_size(_t, 0.03, 0.06, -0.002, 0);
        part_type_speed(_t, 0.8, 2.6, -0.08, 0);
        part_type_direction(_t, 0, 360, 0, 0);
        part_type_life(_t, 10, 22);
        part_type_alpha2(_t, 1, 0);
        part_type_blend(_t, true);      // additive glow
        global.pt_spark = _t;
    }
    if (!variable_global_exists("ps") || !part_system_exists(global.ps)) {
        global.ps = part_system_create();
        part_system_depth(global.ps, -100000);   // above everything in the room
    }
}

/// @func fx_burst(x, y, colour, count)
function fx_burst(_x, _y, _col, _count) {
    fx_ensure();
    part_particles_create_color(global.ps, _x, _y, global.pt_spark, _col, _count);
}

/// @func fx_text(x, y, text, colour)
/// Floating callout, e.g. reaction names. Teaches players what just happened.
function fx_text(_x, _y, _text, _col) {
    var _t = instance_create_depth(_x, _y, -99998, obj_fx_text);
    _t.text  = _text;
    _t.color = _col;
    return _t;
}

/// @func fx_anim(sprite, x, y, [scale], [angle], [depth])
/// Plays a one-shot animated effect sprite (pixelfx sheets) and removes itself.
/// Pauses during hitstop so impacts freeze together with the action.
function fx_anim(_spr, _x, _y, _scale = 1, _angle = 0, _depth = undefined) {
    var _f = instance_create_depth(_x, _y, _depth ?? (-_y - 2), obj_fx_anim);
    _f.sprite_index = _spr;
    _f.image_index  = 0;
    _f.image_xscale = _scale;
    _f.image_yscale = _scale;
    _f.image_angle  = _angle;
    return _f;
}

/// @func fx_damage(x, y, amount, colour, big)
/// Floating damage number. big = boosted hit (Shatter / Superconduct): larger, gold.
function fx_damage(_x, _y, _amount, _col, _big) {
    var _txt = (frac(_amount) == 0) ? string(_amount) : string_format(_amount, 0, 1);
    var _t = fx_text(_x + random_range(-4, 4), _y, _txt, _col);
    _t.size     = _big ? 1.5 : 0.85;
    _t.vy       = _big ? 0.6 : 0.5;
    _t.life_max = _big ? 45 : 32;
    _t.life     = _t.life_max;
    return _t;
}

/// @func combo_add()
/// Counts a kill toward the combo (kills within 2 s of each other chain).
function combo_add() {
    with (obj_game) {
        combo_count++;
        combo_timer = 120;
        combo_pop   = 1;
        global.run.best_combo = max(global.run[$ "best_combo"] ?? 0, combo_count);
        if (combo_count == 10 || combo_count == 25 || combo_count == 50 || combo_count == 100) {
            if (instance_exists(obj_player)) {
                var _call = fx_text(obj_player.x, obj_player.y - 36, string(combo_count) + " COMBO!", make_color_rgb(255, 210, 80));
                _call.size = 1.4;
            }
            screen_flash(0.15);
            sfx(snd_combo, 0);
        }
    }
}
