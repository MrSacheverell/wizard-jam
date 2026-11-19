/// obj_enemy_shot — Draw
switch (kind) {

case "orb":
case "bolt":
    var _dy = y - z;
    draw_set_alpha(0.25); draw_set_color(c_black);
    draw_circle(x, y, 2, false);
    gpu_set_blendmode(bm_add);
    draw_set_color(color);
    draw_set_alpha(0.4);
    if (kind == "bolt") draw_line_width(x - lengthdir_x(8, dir), _dy - lengthdir_y(8, dir), x, _dy, 4);
    draw_circle(x, _dy, 6 + sin(current_time / 80) * 1, false);
    draw_set_alpha(1);
    draw_circle(x, _dy, 3, false);
    gpu_set_blendmode(bm_normal);
    draw_set_color(c_white);
    draw_circle(x, _dy, 1, false);
    break;

case "lob":
    // Landing marker (tightens as the arrow comes down)
    var _mr = 12 - 6 * t;
    draw_set_color(c_red);
    draw_set_alpha(0.35 + 0.4 * t);
    draw_circle(tx, ty, _mr, true);
    draw_circle(tx, ty, 2, false);
    draw_set_alpha(0.3); draw_set_color(c_black);
    draw_circle(x, y, 1.5, false);
    draw_set_alpha(1);
    var _nx = lerp(sx, tx, min(1, t + 0.05));
    var _ny = lerp(sy, ty, min(1, t + 0.05)) - (8 + sin(min(1, t + 0.05) * pi) * arc);
    var _a = point_direction(x, y - z, _nx, _ny);
    draw_set_color(make_color_rgb(230, 210, 170));
    draw_line_width(x - lengthdir_x(5, _a), y - z - lengthdir_y(5, _a), x + lengthdir_x(3, _a), y - z + lengthdir_y(3, _a), 1);
    draw_set_color(c_white);
    draw_circle(x + lengthdir_x(3, _a), y - z + lengthdir_y(3, _a), 1, false);
    break;

case "zone":
    // Outline + a fill that grows until it erupts
    var _f = timer / delay;
    draw_set_color(color);
    draw_set_alpha(0.7);
    draw_circle(x, y, r, true);
    draw_set_alpha(0.15 + 0.25 * _f);
    draw_circle(x, y, r * _f, false);
    break;

case "ring":
    gpu_set_blendmode(bm_add);
    draw_set_color(color);
    draw_set_alpha(0.5);
    draw_circle(x, y, r, true);
    draw_circle(x, y, r - 1, true);
    draw_set_alpha(0.9);
    draw_circle(x, y, r - 2, true);
    gpu_set_blendmode(bm_normal);
    break;

case "beam":
    var _ex = x + lengthdir_x(len, dir), _ey = y + lengthdir_y(len, dir);
    if (timer < delay) {
        // Warning: thin flickering line
        draw_set_color(color);
        draw_set_alpha(0.25 + 0.35 * ((timer div 3) mod 2));
        draw_line_width(x, y, _ex, _ey, 1 + 2 * (timer / delay));
    } else {
        // Strike: thick bright bolt
        gpu_set_blendmode(bm_add);
        draw_set_color(color);
        draw_set_alpha(0.6);
        draw_line_width(x, y, _ex, _ey, r * 2);
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_line_width(x, y, _ex, _ey, 2);
        gpu_set_blendmode(bm_normal);
    }
    break;
}
draw_set_alpha(1);
draw_set_color(c_white);
