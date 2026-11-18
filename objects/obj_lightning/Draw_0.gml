/// obj_lightning — Draw
// Re-jitters every frame so the arc crackles.
var _a = life / life_max;
gpu_set_blendmode(bm_add);

for (var i = 0; i < array_length(points) - 1; i++) {
    var _x1 = points[i][0],     _y1 = points[i][1];
    var _x2 = points[i + 1][0], _y2 = points[i + 1][1];
    var _len = point_distance(_x1, _y1, _x2, _y2);
    var _dir = point_direction(_x1, _y1, _x2, _y2);
    var _segs = max(2, floor(_len / 10));

    var _px = _x1, _py = _y1;
    for (var s = 1; s <= _segs; s++) {
        var _t  = s / _segs;
        var _off = (s == _segs) ? 0 : random_range(-5, 5);
        var _nx = lerp(_x1, _x2, _t) + lengthdir_x(_off, _dir + 90);
        var _ny = lerp(_y1, _y2, _t) + lengthdir_y(_off, _dir + 90);

        draw_set_alpha(0.5 * _a);
        draw_set_color(color);
        draw_line_width(_px, _py, _nx, _ny, 3);
        draw_set_alpha(_a);
        draw_set_color(c_white);
        draw_line_width(_px, _py, _nx, _ny, 1);

        _px = _nx;
        _py = _ny;
    }
}

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_color(c_white);
