/// obj_heart — Draw
var _h  = 6 + sin(bob) * 2 + pop_t;       // float height
var _cx = x, _cy = y - _h;
var _col = make_color_rgb(235, 60, 85);

// Shadow
draw_set_alpha(0.3);
draw_set_color(c_black);
draw_ellipse(x - 4, y - 1, x + 4, y + 1, false);
draw_set_alpha(1);

// Glow
gpu_set_blendmode(bm_add);
draw_set_alpha(0.25 + 0.1 * sin(bob * 2));
draw_set_color(_col);
draw_circle(_cx, _cy, 7, false);
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

// Heart: two circles and a triangle
draw_set_color(c_black);
draw_circle(_cx - 2, _cy - 1, 3, false);
draw_circle(_cx + 2, _cy - 1, 3, false);
draw_triangle(_cx - 5, _cy, _cx + 5, _cy, _cx, _cy + 6, false);
draw_set_color(_col);
draw_circle(_cx - 2, _cy - 1, 2, false);
draw_circle(_cx + 2, _cy - 1, 2, false);
draw_triangle(_cx - 4, _cy, _cx + 4, _cy, _cx, _cy + 4, false);
draw_set_color(c_white);
draw_point(_cx - 2, _cy - 2);
