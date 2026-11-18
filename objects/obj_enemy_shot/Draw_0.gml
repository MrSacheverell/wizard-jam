/// obj_enemy_shot — Draw
if (kind == "orb") {
    var _dy = y - z;
    draw_set_alpha(0.25); draw_set_color(c_black);
    draw_circle(x, y, 2, false);
    gpu_set_blendmode(bm_add);
    draw_set_color(color);
    draw_set_alpha(0.4);
    draw_circle(x, _dy, 6 + sin(current_time / 80) * 1, false);
    draw_set_alpha(1);
    draw_circle(x, _dy, 3, false);
    gpu_set_blendmode(bm_normal);
    draw_set_color(c_white);
    draw_circle(x, _dy, 1, false);
}
else {
    // Landing marker (tightens as the arrow comes down)
    var _mr = 12 - 6 * t;
    draw_set_color(c_red);
    draw_set_alpha(0.35 + 0.4 * t);
    draw_circle(tx, ty, _mr, true);
    draw_circle(tx, ty, 2, false);
    // Shadow under the arrow
    draw_set_alpha(0.3); draw_set_color(c_black);
    draw_circle(x, y, 1.5, false);
    draw_set_alpha(1);
    // Arrow, pointing along its arc
    var _nx = lerp(sx, tx, min(1, t + 0.05));
    var _ny = lerp(sy, ty, min(1, t + 0.05)) - (8 + sin(min(1, t + 0.05) * pi) * arc);
    var _a = point_direction(x, y - z, _nx, _ny);
    draw_set_color(make_color_rgb(230, 210, 170));
    draw_line_width(x - lengthdir_x(5, _a), y - z - lengthdir_y(5, _a), x + lengthdir_x(3, _a), y - z + lengthdir_y(3, _a), 1);
    draw_set_color(c_white);
    draw_circle(x + lengthdir_x(3, _a), y - z + lengthdir_y(3, _a), 1, false);
}
draw_set_alpha(1);
draw_set_color(c_white);
