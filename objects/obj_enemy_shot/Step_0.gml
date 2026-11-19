/// obj_enemy_shot — Step
if (game_frozen()) exit;

var _p = instance_exists(obj_player) ? obj_player : noone;

switch (kind) {

case "orb":
case "bolt":
    if (kind == "orb" && _p != noone) {
        var _want = point_direction(x, y, _p.x, _p.y);
        dir += clamp(angle_difference(_want, dir), -turn, turn);
    }
    x += lengthdir_x(spd, dir);
    y += lengthdir_y(spd, dir);
    depth = -y - 1;
    life--;
    if (life <= 0 || (kind == "bolt" && position_meeting(x, y, obj_wall))) {
        fx_burst(x, y - z, color, 6);
        instance_destroy();
        exit;
    }
    if (_p != noone && point_distance(x, y, _p.x, _p.y) < 7) {
        if (_p.take_damage(dmg, x, y) || _p.state != PSTATE.DASH) {
            fx_burst(x, y - z, color, 10);
            instance_destroy();       // dashing through it with i-frames dodges it
        }
    }
    break;

case "lob":
    t += 1 / dur;
    x = lerp(sx, tx, t);
    y = lerp(sy, ty, t);
    z = 8 + sin(t * pi) * arc;
    depth = -y - 1;
    if (t >= 1) {
        if (_p != noone && point_distance(_p.x, _p.y, tx, ty) < 12) _p.take_damage(dmg, sx, sy);
        fx_burst(tx, ty - 2, color, 6);
        instance_destroy();
    }
    break;

case "zone":
    timer++;
    depth = -y + 50;          // under actors
    if (timer >= delay) {
        if (_p != noone && point_distance(_p.x, _p.y, x, y) < r + 4) _p.take_damage(dmg, x, y);
        fx_anim(spr_fx_blast_s, x, y, r / 26);
        shake(3);
        instance_destroy();
    }
    break;

case "ring":
    r += grow;
    depth = -y + 50;
    if (_p != noone && !hit_done && dmg > 0) {
        var _d = point_distance(_p.x, _p.y, x, y);
        if (abs(_d - r) < 6) {
            if (_p.take_damage(dmg, x, y)) hit_done = true;   // one hit per ring
        }
    }
    if (r >= r_max) instance_destroy();
    break;

case "beam":
    timer++;
    depth = -y + 50;
    if (timer >= delay && timer < delay + strike && _p != noone) {
        // distance from the player to the beam's line segment
        var _ex = x + lengthdir_x(len, dir), _ey = y + lengthdir_y(len, dir);
        var _vx = _ex - x, _vy = _ey - y;
        var _tt = clamp(((_p.x - x) * _vx + (_p.y - y) * _vy) / (_vx * _vx + _vy * _vy), 0, 1);
        var _cx = x + _vx * _tt, _cy = y + _vy * _tt;
        if (point_distance(_p.x, _p.y, _cx, _cy) < r) _p.take_damage(dmg, _cx, _cy);
    }
    if (timer == delay) shake(2);
    if (timer >= delay + strike) instance_destroy();
    break;
}
