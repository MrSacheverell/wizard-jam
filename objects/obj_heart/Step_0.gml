/// obj_heart — Step
if (game_frozen()) exit;
bob += 0.12;
if (pop_t > 0) pop_t--;
depth = -y;

if (!instance_exists(obj_player) || obj_player.state == PSTATE.DEAD) exit;
var _p = obj_player;
if (_p.hp >= _p.max_hp) { spd = 0; exit; }

var _d = point_distance(x, y, _p.x, _p.y);
if (_d < 48) {
    spd = min(spd + 0.25, 4);
    var _a = point_direction(x, y, _p.x, _p.y);
    x += lengthdir_x(spd, _a);
    y += lengthdir_y(spd, _a);
}
if (_d < 8) {
    _p.hp = min(_p.max_hp, _p.hp + 1);
    global.run.hp = _p.hp;
    fx_burst(_p.x, _p.y - 10, make_color_rgb(255, 90, 110), 10);
    sfx(snd_heal, 0.03);
    fx_text(_p.x, _p.y - 24, "+1 HP", make_color_rgb(255, 120, 140));
    instance_destroy();
}
