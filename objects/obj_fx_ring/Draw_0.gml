/// obj_fx_ring — Draw
var _a = life / life_max;
var _cy = y - 6;
gpu_set_blendmode(bm_add);
draw_set_color(color);
draw_set_alpha(0.3 * _a);
draw_circle(x, _cy, r, false);
draw_set_alpha(_a);
draw_circle(x, _cy, r, true);
draw_circle(x, _cy, r - 1, true);
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_color(c_white);
