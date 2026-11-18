/// obj_steam — Draw
// A few soft, drifting puffs. Fades in fast, out slow.
var _a = min(1, (life_max - life) / 10) * min(1, life / 60);
var _t = (current_time / 1000) + seed;
draw_set_color(global.react_color.steam);
for (var i = 0; i < 6; i++) {
    var _ang = i * 60 + _t * 20;
    var _d   = r * 0.45 + sin(_t * 2 + i) * 3;
    var _px  = x + lengthdir_x(_d, _ang);
    var _py  = y - 4 + lengthdir_y(_d, _ang) * 0.6;
    draw_set_alpha(0.22 * _a);
    draw_circle(_px, _py, r * 0.45, false);
}
draw_set_alpha(0.15 * _a);
draw_circle(x, y - 4, r * 0.6, false);
draw_set_alpha(1);
draw_set_color(c_white);
