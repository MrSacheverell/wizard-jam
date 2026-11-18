// =====================================================================
// scr_enemy_shots — spawners for enemy projectiles (obj_enemy_shot)
// =====================================================================

/// @func enemy_shot_lob(x, y, target_x, target_y)
/// Archer arrow: arcs from (x,y) to the target over ~0.8-1.3 s, marker on the ground.
function enemy_shot_lob(_x, _y, _tx, _ty) {
    var _s = instance_create_depth(_x, _y, -_y, obj_enemy_shot);
    _s.kind  = "lob";
    _s.sx = _x; _s.sy = _y;
    _s.tx = _tx; _s.ty = _ty;
    _s.dur   = 45 + point_distance(_x, _y, _tx, _ty) / 8;
    _s.arc   = 30 + point_distance(_x, _y, _tx, _ty) / 6;
    _s.color = make_color_rgb(230, 210, 170);
    return _s;
}

/// @func enemy_shot_orb(x, y, dir)
/// Hexer orb: slow, homes in gently, lasts 6 s.
function enemy_shot_orb(_x, _y, _dir) {
    var _s = instance_create_depth(_x, _y, -_y, obj_enemy_shot);
    _s.kind  = "orb";
    _s.dir   = _dir;
    _s.color = make_color_rgb(190, 90, 255);
    return _s;
}
