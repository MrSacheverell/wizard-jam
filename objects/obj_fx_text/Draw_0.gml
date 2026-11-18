/// obj_fx_text — Draw
var _a = min(1, life / 15);
var _s = 0.5 + 0.15 * max(0, (life - (life_max - 6)) / 6);   // quick pop on spawn
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_alpha(_a);
draw_set_color(c_black);
draw_text_transformed(x + 1, y + 1, text, _s, _s, 0);
draw_set_color(color);
draw_text_transformed(x, y, text, _s, _s, 0);
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
