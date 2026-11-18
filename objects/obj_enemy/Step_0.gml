/// obj_enemy — Step  (children inherit this; customise via ai_step)
if (game_frozen()) exit;

if (flash > 0) flash--;

// Spawn-in: fade in, don't move or hurt for a moment (no cheap hits)
if (spawn_t > 0) {
    spawn_t--;
    depth = -y;
    exit;
}

// Elements (Burn ticks can kill, so stop if we died)
status_tick();
if (!instance_exists(id) || hp <= 0) exit;

var _frozen = (status_el == ELEMENT.FREEZE);

// Vampiric elites slowly regenerate
if (elite == "vampiric" && hp < max_hp) {
    regen_t++;
    if (regen_t >= 150) { regen_t = 0; hp = min(max_hp, hp + 1); fx_burst(x, y - 8 - z, elite_color, 4); }
}

hsp = 0;
vsp = 0;
if (!_frozen) ai_step();          // frozen enemies don't think or move

if (slow_t > 0) {                 // Steam
    hsp *= 0.35;
    vsp *= 0.35;
}

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

if (flying) {
    x = clamp(x + hsp, 16, room_width - 16);
    y = clamp(y + vsp, 24, room_height - 16);
} else {
    move_collide();
}
depth = -y;

// Contact damage (frozen enemies are harmless; player i-frames stop repeats)
if (contact_dmg > 0 && !_frozen && instance_exists(obj_player)) {
    var _p = obj_player;
    if (point_distance(x, y, _p.x, _p.y) < hurt_r + 5) {
        if (_p.take_damage(contact_dmg, x, y) && elite == "vampiric") {
            hp = min(max_hp, hp + 2);               // Vampiric: drinks on hit
            fx_burst(x, y - 8 - z, elite_color, 8);
        }
    }
}
