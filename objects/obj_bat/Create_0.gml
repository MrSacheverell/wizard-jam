/// obj_bat — Create   (parent: obj_enemy)
// Flies in a sine wave toward the player, telegraphs (red), then dives.
event_inherited();

max_hp      = 2;
hp          = max_hp;
move_speed  = 0.9;
contact_dmg = 0;          // only hurts while diving
hurt_r      = 6;
flying      = true;
z           = 14;
death_color = make_color_rgb(170, 120, 200);
image_speed = 1;

enum BAT { HOVER, TELEGRAPH, DIVE, RECOVER }
bstate     = BAT.HOVER;
btimer     = irandom_range(60, 120);
wave_t     = random(100);
dive_dir   = 0;
dive_speed = 3.2;

ai_step = function() {
    if (!instance_exists(obj_player) || obj_player.state == PSTATE.DEAD) { bstate = BAT.HOVER; return; }
    var _p    = obj_player;
    var _dist = point_distance(x, y, _p.x, _p.y);
    var _dir  = point_direction(x, y, _p.x, _p.y);
    facing = (_p.x >= x) ? 1 : -1;
    wave_t++;

    switch (bstate) {
        case BAT.HOVER:
            // Close in to ~70px, weaving side to side
            var _fwd = (_dist > 70) ? move_speed : -0.3;
            var _side = sin(wave_t / 12) * 1.1;
            hsp = lengthdir_x(_fwd, _dir) + lengthdir_x(_side, _dir + 90);
            vsp = lengthdir_y(_fwd, _dir) + lengthdir_y(_side, _dir + 90);
            z = 14 + sin(wave_t / 8) * 2;
            btimer--;
            if (btimer <= 0 && _dist < 130) {
                bstate = BAT.TELEGRAPH;
                btimer = 24;
            }
            break;

        case BAT.TELEGRAPH:
            // Hang in the air, flash red, rise a little: "I'm about to dive"
            tint = ((btimer div 3) mod 2 == 0) ? c_red : c_white;
            z = lerp(z, 20, 0.2);
            btimer--;
            if (btimer <= 0) {
                tint        = c_white;
                dive_dir    = _dir;
                bstate      = BAT.DIVE;
                btimer      = 22;
                contact_dmg = 1;
            }
            break;

        case BAT.DIVE:
            hsp = lengthdir_x(dive_speed, dive_dir);
            vsp = lengthdir_y(dive_speed, dive_dir);
            z = lerp(z, 4, 0.3);
            btimer--;
            if (btimer <= 0) {
                bstate      = BAT.RECOVER;
                btimer      = 30;
                contact_dmg = 0;
            }
            break;

        case BAT.RECOVER:
            // Drift and climb back up; this is the punish window
            z = lerp(z, 14, 0.08);
            btimer--;
            if (btimer <= 0) {
                bstate = BAT.HOVER;
                btimer = irandom_range(90, 150);
            }
            break;
    }
};
