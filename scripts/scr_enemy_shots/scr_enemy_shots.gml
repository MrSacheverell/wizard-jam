// =====================================================================
// scr_enemy_shots — spawners for enemy projectiles (obj_enemy_shot)
// =====================================================================

/// @func enemy_shot_lob(x, y, target_x, target_y)
/// Archer arrow: arcs from (x,y) to the target over ~0.8-1.3 s, marker on the ground.
function enemy_shot_lob(_x, _y, _tx, _ty) {
    var _s = instance_create_depth(_x, _y, -_y, obj_enemy_shot);
    _s.kind  = "lob";
    sfx(snd_enemy_shot, 0.12, 0.5);
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
    sfx(snd_hex_orb, 0.08, 0.7);
    _s.dir   = _dir;
    _s.color = make_color_rgb(190, 90, 255);
    return _s;
}

/// @func enemy_shot_bolt(x, y, dir, speed, colour)
/// Straight shot; stops at walls.
function enemy_shot_bolt(_x, _y, _dir, _spd, _col) {
    var _s = instance_create_depth(_x, _y, -_y, obj_enemy_shot);
    _s.kind  = "bolt";
    sfx(snd_enemy_shot, 0.12, 0.5);
    _s.dir   = _dir;
    _s.spd   = _spd;
    _s.life  = 240;
    _s.color = _col;
    return _s;
}

/// @func enemy_shot_zone(x, y, radius, delay_frames, colour)
/// Ground circle that fills, then erupts. Standing in it when it erupts hurts.
function enemy_shot_zone(_x, _y, _r, _delay, _col) {
    var _s = instance_create_depth(_x, _y, -_y + 50, obj_enemy_shot);
    _s.kind  = "zone";
    _s.r     = _r;
    _s.delay = _delay;
    _s.color = _col;
    return _s;
}

/// @func enemy_shot_ring(x, y, speed, max_radius, colour)
/// Expanding ring; touching its edge hurts. Dash through it (i-frames).
function enemy_shot_ring(_x, _y, _grow, _rmax, _col) {
    var _s = instance_create_depth(_x, _y, -_y + 50, obj_enemy_shot);
    _s.kind  = "ring";
    _s.r     = 8;
    _s.grow  = _grow;
    _s.r_max = _rmax;
    _s.color = _col;
    return _s;
}

/// @func enemy_shot_beam(x, y, dir, length, delay_frames, colour)
/// Thin warning line, then a thick strike along it for a few frames.
function enemy_shot_beam(_x, _y, _dir, _len, _delay, _col) {
    var _s = instance_create_depth(_x, _y, -_y + 50, obj_enemy_shot);
    _s.kind  = "beam";
    _s.dir   = _dir;
    _s.len   = _len;
    _s.r     = 6;
    _s.delay = _delay;
    _s.color = _col;
    return _s;
}
