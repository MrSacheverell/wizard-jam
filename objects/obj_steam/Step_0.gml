/// obj_steam — Step
if (game_frozen()) exit;
life--;
if (life <= 0) { instance_destroy(); exit; }

var _me = id;
with (obj_enemy) {
    if (point_distance(x, y, _me.x, _me.y) < _me.r + hurt_r) {
        slow_t = max(slow_t, 8);
    }
}
