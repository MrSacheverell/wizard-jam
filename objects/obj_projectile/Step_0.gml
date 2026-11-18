/// obj_projectile — Step
if (game_frozen()) exit;

// ---- Disc: decelerate outward, then home back to the caster ----
if (kind == "disc") {
    spin += 25;
    if (!returning) {
        spd -= 0.16;
        if (spd <= 0) {
            returning = true;
            spd  = 0;
            hits = [];          // can hit the same enemies again on the way back
        }
        hsp = lengthdir_x(spd, dir);
        vsp = lengthdir_y(spd, dir);
    } else {
        if (!instance_exists(owner)) { instance_destroy(); exit; }
        spd = min(spd + 0.25, 7);
        dir = point_direction(x, y, owner.x, owner.y);
        hsp = lengthdir_x(spd, dir);
        vsp = lengthdir_y(spd, dir);
        if (point_distance(x, y, owner.x, owner.y) < spd + 4) { instance_destroy(); exit; }
    }
}

x += hsp;
y += vsp;
depth = -y - 1;

// Lifetime
life--;
if (life <= 0) {
    finish();
    exit;
}

// Walls (checked at the ground position). Discs pass through walls.
if (kind != "disc"
&& (position_meeting(x, y, obj_wall) || (array_length(global.solids) > 0 && position_meeting(x, y, global.solids)))) {
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

    var _kd = (kind == "disc") ? point_direction(x, y, _hit.x, _hit.y) : dir;
    _hit.take_hit(dmg, lengthdir_x(knock, _kd), lengthdir_y(knock, _kd), element);
    array_push(hits, _hit);
    if (kind == "bolt" && element == ELEMENT.NONE) fx_anim(spr_fx_spark, x, y - z, 0.7, dir, -y - 3);   // pixelfx Hit Spark
    else fx_burst(x, y - z, color, 6);

    if (pierce <= 0) {
        instance_destroy();
    } else {
        pierce--;
    }
}
