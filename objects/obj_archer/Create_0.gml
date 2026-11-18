/// obj_archer — Create   (parent: obj_enemy)
// Keeps its distance and lobs arrows at where you ARE when it fires.
// A red marker shows where each arrow lands: keep moving.
event_inherited();

max_hp      = 2;
hp          = max_hp;
move_speed  = 0.7;
contact_dmg = 1;
hurt_r      = 6;
death_color = make_color_rgb(200, 170, 110);

shoot_t = irandom_range(70, 120);
aim_t   = 0;          // > 0: drawing the bow (stands still, flashes)
strafe  = choose(-1, 1);

ai_step = function() {
    if (!instance_exists(obj_player) || obj_player.state == PSTATE.DEAD) return;
    var _p = obj_player;
    var _dist = point_distance(x, y, _p.x, _p.y);
    var _dir  = point_direction(x, y, _p.x, _p.y);
    facing = (_p.x >= x) ? 1 : -1;

    // Drawing the bow
    if (aim_t > 0) {
        aim_t--;
        tint = ((aim_t div 3) mod 2 == 0) ? make_color_rgb(255, 160, 80) : c_white;
        if (aim_t <= 0) {
            tint = c_white;
            enemy_shot_lob(x, y, _p.x, _p.y);
            shoot_t = irandom_range(100, 150);
        }
        return;
    }

    // Hold 100-150 px away, strafing a little
    var _fwd = 0;
    if (_dist < 100) _fwd = -move_speed;
    else if (_dist > 150) _fwd = move_speed;
    hsp = lengthdir_x(_fwd, _dir) + lengthdir_x(0.35 * strafe, _dir + 90);
    vsp = lengthdir_y(_fwd, _dir) + lengthdir_y(0.35 * strafe, _dir + 90);
    if (random(1) < 0.01) strafe = -strafe;

    shoot_t--;
    if (shoot_t <= 0 && _dist < 230) aim_t = 24;
};
