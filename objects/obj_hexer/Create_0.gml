/// obj_hexer — Create   (parent: obj_enemy)
// Teleports around you, then channels a slow homing orb.
// Counter: Freeze interrupts the channel (and frozen Hexers can't act).
event_inherited();

max_hp      = 3;
hp          = max_hp;
move_speed  = 0.4;
contact_dmg = 1;
hurt_r      = 6;
death_color = make_color_rgb(190, 90, 255);

enum HEX { IDLE, CAST }
hstate = HEX.IDLE;
timer  = irandom_range(60, 120);
cast_t = 0;

hex_teleport = function() {
    if (!instance_exists(obj_player)) return;
    var _p = obj_player;
    repeat (30) {
        var _a = random(360), _d = random_range(90, 150);
        var _nx = _p.x + lengthdir_x(_d, _a);
        var _ny = _p.y + lengthdir_y(_d, _a);
        if (_nx < 32 || _nx > room_width - 32 || _ny < 48 || _ny > room_height - 32) continue;
        if (collision_rectangle(_nx - 8, _ny - 8, _nx + 8, _ny + 4, obj_wall, false, true) != noone) continue;
        fx_burst(x, y - 8, death_color, 10);
        x = _nx;
        y = _ny;
        fx_burst(x, y - 8, death_color, 10);
        return;
    }
};

ai_step = function() {
    if (!instance_exists(obj_player) || obj_player.state == PSTATE.DEAD) return;
    var _p = obj_player;
    facing = (_p.x >= x) ? 1 : -1;

    switch (hstate) {
        case HEX.IDLE:
            // Drift sideways around the player
            var _dir = point_direction(x, y, _p.x, _p.y);
            hsp = lengthdir_x(move_speed, _dir + 90);
            vsp = lengthdir_y(move_speed, _dir + 90);
            timer--;
            if (timer <= 0) {
                hex_teleport();
                hstate = HEX.CAST;
                cast_t = 36;
            }
            break;

        case HEX.CAST:
            // Channel: glow violet, then release the orb
            tint = merge_color(c_white, death_color, 0.5 + 0.5 * sin(cast_t / 2));
            if (cast_t mod 6 == 0) fx_burst(x, y - 14, death_color, 2);
            cast_t--;
            if (cast_t <= 0) {
                tint = c_white;
                enemy_shot_orb(x, y, point_direction(x, y, _p.x, _p.y));
                hstate = HEX.IDLE;
                timer = irandom_range(120, 170);
            }
            break;
    }
};

on_hit = function(_element) {
    if (_element == ELEMENT.FREEZE && hstate == HEX.CAST) {
        hstate = HEX.IDLE;
        timer  = 90;
        tint   = c_white;
        fx_text(x, y - 24, "INTERRUPTED", global.element_color[ELEMENT.FREEZE]);
    }
};
