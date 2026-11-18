/// obj_enemy — Step  (children inherit this; customise via ai_step)
if (game_frozen()) exit;

if (flash > 0) flash--;

hsp = 0;
vsp = 0;
ai_step();

// Soft separation so crowds spread out instead of stacking
var _o = instance_place(x, y, obj_enemy);
if (_o != noone) {
    var _d = (_o.x == x && _o.y == y) ? random(360) : point_direction(_o.x, _o.y, x, y);
    hsp += lengthdir_x(0.4, _d);
    vsp += lengthdir_y(0.4, _d);
}

// Knockback on top of movement, decaying
hsp += kx;
vsp += ky;
kx *= 0.8;
ky *= 0.8;
if (abs(kx) < 0.05) kx = 0;
if (abs(ky) < 0.05) ky = 0;

move_collide();
depth = -y;

// Contact damage (player's own i-frames stop repeat hits)
if (contact_dmg > 0 && instance_exists(obj_player)) {
    var _p = obj_player;
    if (point_distance(x, y, _p.x, _p.y) < hurt_r + 5) {
        _p.take_damage(contact_dmg, x, y);
    }
}
