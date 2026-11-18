/// obj_brute — Draw
event_inherited();

// Shield: a thick arc in front, on the side it's facing
if (spawn_t <= 0) {
    var _col = (status_el == ELEMENT.FREEZE) ? c_gray : make_color_rgb(190, 200, 220);
    var _r = 9 * size_mult;
    var _a1 = face_dir - 45, _a2 = face_dir + 45;
    var _x1 = x + lengthdir_x(_r, _a1), _y1 = y - 7 + lengthdir_y(_r, _a1) * 0.6;
    var _xm = x + lengthdir_x(_r + 1, face_dir), _ym = y - 7 + lengthdir_y(_r + 1, face_dir) * 0.6;
    var _x2 = x + lengthdir_x(_r, _a2), _y2 = y - 7 + lengthdir_y(_r, _a2) * 0.6;
    draw_set_color(c_black);
    draw_line_width(_x1, _y1 + 1, _xm, _ym + 1, 4);
    draw_line_width(_xm, _ym + 1, _x2, _y2 + 1, 4);
    draw_set_color(_col);
    draw_line_width(_x1, _y1, _xm, _ym, 3);
    draw_line_width(_xm, _ym, _x2, _y2, 3);
    draw_set_color(c_white);
}
