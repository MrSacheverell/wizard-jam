/// obj_door — Draw
// Dark archway; glowing violet portal once open.
draw_set_color(make_color_rgb(20, 16, 28));
draw_rectangle(x, y, x + 31, y + 31, false);
draw_set_color(make_color_rgb(120, 110, 150));
draw_rectangle(x, y, x + 31, y + 31, true);

if (is_open) {
    var _col = global.element_color[ELEMENT.NONE];
    var _p = 0.5 + 0.5 * sin(glow * 2);
    gpu_set_blendmode(bm_add);
    draw_set_color(_col);
    draw_set_alpha(0.35 + 0.25 * _p);
    draw_rectangle(x + 3, y + 3, x + 28, y + 31, false);
    draw_set_alpha(0.25);
    draw_rectangle(x - 2, y + 24, x + 33, y + 40, false);   // light spilling onto the floor
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    // Up-arrow hint
    draw_set_color(c_white);
    var _ay = y + 12 - _p * 3;
    draw_triangle(x + 16, _ay, x + 11, _ay + 6, x + 21, _ay + 6, false);
} else {
    // Locked: two bars
    draw_set_color(make_color_rgb(90, 80, 110));
    draw_rectangle(x + 8, y + 4, x + 11, y + 31, false);
    draw_rectangle(x + 20, y + 4, x + 23, y + 31, false);
}
draw_set_alpha(1);
draw_set_color(c_white);
