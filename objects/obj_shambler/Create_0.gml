/// obj_shambler — Create   (parent: obj_enemy)
event_inherited();

max_hp      = 3;
hp          = max_hp;
move_speed  = random_range(0.45, 0.7);   // slight variety so crowds don't move in lockstep
contact_dmg = 1;
hurt_r      = 7;
wobble      = random(1000);

// Walks straight at the player with a little sway
ai_step = function() {
    if (!instance_exists(obj_player) || obj_player.state == PSTATE.DEAD) return;
    var _dir = point_direction(x, y, obj_player.x, obj_player.y);
    _dir += sin((current_time + wobble) / 300) * 20;
    hsp = lengthdir_x(move_speed, _dir);
    vsp = lengthdir_y(move_speed, _dir);
    facing = (obj_player.x >= x) ? 1 : -1;
};
