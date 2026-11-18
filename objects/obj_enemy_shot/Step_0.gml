/// obj_enemy_shot — Step
if (game_frozen()) exit;

if (kind == "orb") {
    if (instance_exists(obj_player)) {
        var _want = point_direction(x, y, obj_player.x, obj_player.y);
        dir += clamp(angle_difference(_want, dir), -turn, turn);
    }
    x += lengthdir_x(spd, dir);
    y += lengthdir_y(spd, dir);
    depth = -y - 1;
    life--;
    if (life <= 0) { fx_burst(x, y - z, color, 6); instance_destroy(); exit; }

    if (instance_exists(obj_player) && point_distance(x, y, obj_player.x, obj_player.y) < 7) {
        if (obj_player.take_damage(dmg, x, y) || obj_player.state != PSTATE.DASH) {
            fx_burst(x, y - z, color, 10);
            instance_destroy();       // dashing through it with i-frames dodges it
        }
    }
}
else { // "lob"
    t += 1 / dur;
    x = lerp(sx, tx, t);
    y = lerp(sy, ty, t);
    z = 8 + sin(t * pi) * arc;
    depth = -y - 1;
    if (t >= 1) {
        if (instance_exists(obj_player) && point_distance(obj_player.x, obj_player.y, tx, ty) < 12) {
            obj_player.take_damage(dmg, sx, sy);
        }
        fx_burst(tx, ty - 2, color, 6);
        instance_destroy();
    }
}
