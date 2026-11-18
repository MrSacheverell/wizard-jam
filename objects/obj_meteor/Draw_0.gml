/// obj_meteor — Draw
var _t   = 1 - fall / fall_max;            // 0 -> 1 as it lands
var _col = global.element_color[ELEMENT.BURN];
var _rr  = r * (0.3 + 0.7 * _t);

// Target ring + shadow on the ground
draw_set_color(_col);
draw_set_alpha(0.6);
draw_circle(x, y, r, true);
draw_set_color(c_black);
draw_set_alpha(0.25 + 0.25 * _t);
draw_circle(x, y, _rr * 0.6, false);
draw_set_alpha(1);

// The meteor, falling at an angle from up-right
var _h  = (1 - _t) * 180;
var _mx = x + _h * 0.5;
var _my = y - _h;
gpu_set_blendmode(bm_add);
draw_set_color(_col);
draw_set_alpha(0.4);
draw_line_width(_mx + 14, _my - 28, _mx, _my, 6);    // trail
draw_circle(_mx, _my, 9, false);
draw_set_alpha(1);
draw_circle(_mx, _my, 6, false);
gpu_set_blendmode(bm_normal);
draw_set_color(c_white);
draw_circle(_mx, _my, 3, false);
