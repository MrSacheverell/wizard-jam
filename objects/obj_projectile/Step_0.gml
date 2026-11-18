/// obj_projectile — Step
if (game_frozen()) exit;

x += hsp;
y += vsp;
depth = -y - 1;

// Lifetime
life--;
if (life <= 0) {
    finish();
    exit;
}

// Walls (checked at the ground position)
if (position_meeting(x, y, obj_wall) || (array_length(global.solids) > 0 && position_meeting(x, y, global.solids))) {
    x -= hsp;   // step back so explosions happen in front of the wall
    y -= vsp;
    finish();
    exit;
}

// Enemies: simple distance check on the ground plane (cheap for jam-sized crowds)
var _hit = noone;
var _me = id;
with (obj_enemy) {
    if (hp > 0
    && point_distance(x, y, _me.x, _me.y) < hurt_r + _me.radius
    && !array_contains(_me.hits, id)) {
        _hit = id;
        break;
    }
}

if (_hit != noone) {
    if (explode_r > 0) {
        finish();          // the explosion damages the target and everything near it
        exit;
    }

    _hit.take_hit(dmg, lengthdir_x(knock, dir), lengthdir_y(knock, dir), element);
    array_push(hits, _hit);
    fx_burst(x, y - z, color, 6);

    if (pierce <= 0) {
        instance_destroy();
    } else {
        pierce--;
    }
}
