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
