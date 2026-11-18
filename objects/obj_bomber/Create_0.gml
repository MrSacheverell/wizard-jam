/// obj_bomber — Create   (parent: obj_enemy)
// Runs at you, lights its fuse when close, then explodes. Also explodes
// when killed, hurting you AND nearby enemies. Counter: kill it at range.
event_inherited();

max_hp      = 2;
hp          = max_hp;
move_speed  = 1.05;
contact_dmg = 0;          // it hurts by exploding, not by touch
hurt_r      = 6;
death_color = make_color_rgb(255, 120, 40);
fuse        = -1;         // >= 0: counting down to boom
blast_r     = 34;

ai_step = function() {
    if (fuse >= 0) {
        fuse--;
        tint = ((fuse div 3) mod 2 == 0) ? c_red : c_white;
        if (fuse <= 0) die();
        return;
    }
    if (!instance_exists(obj_player) || obj_player.state == PSTATE.DEAD) return;
    var _p = obj_player;
    var _dir = point_direction(x, y, _p.x, _p.y);
    hsp = lengthdir_x(move_speed, _dir);
    vsp = lengthdir_y(move_speed, _dir);
    facing = (_p.x >= x) ? 1 : -1;
    if (point_distance(x, y, _p.x, _p.y) < 22) fuse = 30;   // half a second to get away
};

on_death = function() {
    var _bx = x, _by = y, _r = blast_r;
    // Player
    if (instance_exists(obj_player)) {
        with (obj_player) {
            if (point_distance(x, y, _bx, _by) < _r + 4) take_damage(1, _bx, _by);
        }
    }
    // Other enemies (chain reactions welcome)
    with (obj_enemy) {
        if (id != other.id && hp > 0 && point_distance(x, y, _bx, _by) < _r + hurt_r) {
            var _d = point_direction(_bx, _by, x, y);
            take_hit(2, lengthdir_x(3, _d), lengthdir_y(3, _d), ELEMENT.NONE);
        }
    }
    fx_anim(spr_fx_blast_s, _bx, _by, _r / 26);               // pixelfx Explosion
    fx_burst(_bx, _by - 6, death_color, 10);
    fx_burst(_bx, _by - 6, c_yellow, 8);
    shake(5);
    hitstop(3);
};
