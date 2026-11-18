/// obj_projectile — Draw
var _dy = y - z;

// Ground shadow (sells the height)
draw_set_alpha(0.25);
draw_set_color(c_black);
draw_circle(x, y, max(1, size - 1), false);

// Glow + trail (additive)
gpu_set_blendmode(bm_add);
draw_set_alpha(0.45);
draw_set_color(color);
draw_line_width(x - hsp * 1.5, _dy - vsp * 1.5, x, _dy, size + 1);
draw_circle(x, _dy, size + 2, false);
draw_set_alpha(1);
draw_circle(x, _dy, size, false);
gpu_set_blendmode(bm_normal);

// Hot core
draw_set_color(c_white);
draw_circle(x, _dy, max(1, size - 1), false);
