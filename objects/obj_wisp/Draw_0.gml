/// obj_wisp — Draw
var _col = global.element_color[ELEMENT.FREEZE];
var _dy  = y - z + sin(current_time / 150 + angle) * 1.5;
var _a   = (life < 60) ? ((life div 4) mod 2) : 1;   // blink before it expires

draw_set_alpha(0.25);
draw_set_color(c_black);
draw_circle(x, y, 2, false);

gpu_set_blendmode(bm_add);
draw_set_color(_col);
draw_set_alpha(0.35 * _a);
draw_circle(x, _dy, 6, false);
draw_set_alpha(_a);
draw_circle(x, _dy, 3, false);
gpu_set_blendmode(bm_normal);
draw_set_color(c_white);
draw_circle(x, _dy, 1.5, false);
draw_set_alpha(1);
