/// obj_wisp — Step
if (game_frozen()) exit;
if (!instance_exists(owner) || owner.state == PSTATE.DEAD) { instance_destroy(); exit; }

angle = (angle + 3) mod 360;
x = owner.x + lengthdir_x(orbit_r, angle);
y = owner.y + lengthdir_y(orbit_r, angle) * 0.6;
depth = -y;

life--;
if (life <= 0) {
    fx_burst(x, y - z, global.element_color[ELEMENT.FREEZE], 8);
    instance_destroy();
    exit;
}

fire_t--;
if (fire_t <= 0) {
    var _t = enemy_nearest(x, y, 150, []);
    if (_t != noone) {
        fire_t = fire_rate;
        projectile_spawn(x, y, point_direction(x, y, _t.x, _t.y), {
            spd:    5,
            dmg:    1,
            life:   40,
            radius: 3,
            knock:  0.8,
            size:   2,
            z:      z,
            element: ELEMENT.FREEZE,
            color:  global.element_color[ELEMENT.FREEZE],
        });
    } else {
        fire_t = 10;   // nothing in range: check again soon
    }
}
