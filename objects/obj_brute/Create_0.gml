/// obj_brute — Create   (parent: obj_enemy)
// Slow, tough, and turns slowly to keep its shield toward you.
// Blocks hits from the front. Hits of 3+ damage (Meteor) break through,
// and frozen Brutes can't block. Counter: flank it, or Arcane Disc's return.
event_inherited();

max_hp       = 8;
hp           = max_hp;
move_speed   = 0.35;
contact_dmg  = 1;
hurt_r       = 8;
knock_resist = 0.5;
death_color  = make_color_rgb(160, 160, 175);

face_dir   = 270;
turn_speed = 1.6;    // degrees per frame: slow enough to get behind it

ai_step = function() {
    if (!instance_exists(obj_player) || obj_player.state == PSTATE.DEAD) return;
    var _dir = point_direction(x, y, obj_player.x, obj_player.y);
    face_dir += clamp(angle_difference(_dir, face_dir), -turn_speed, turn_speed);
    hsp = lengthdir_x(move_speed, face_dir);
    vsp = lengthdir_y(move_speed, face_dir);
    facing = (lengthdir_x(1, face_dir) >= 0) ? 1 : -1;
};

block_hit = function(_dmg, _kx, _ky) {
    if (_dmg >= 3 || status_el == ELEMENT.FREEZE) return false;
    if (_kx == 0 && _ky == 0) return false;
    var _from = point_direction(0, 0, _kx, _ky) + 180;   // direction the hit came from
    if (abs(angle_difference(_from, face_dir)) < 70) {
        var _sx = x + lengthdir_x(8, face_dir);
        var _sy = y - 8 + lengthdir_y(8, face_dir) * 0.6;
        fx_burst(_sx, _sy, c_white, 4);
        return true;
    }
    return false;
};
