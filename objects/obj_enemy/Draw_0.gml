/// obj_enemy — Draw
// Shadow
draw_set_alpha(0.35);
draw_set_color(c_black);
draw_ellipse(x - 6, y - 2, x + 6, y + 2, false);
draw_set_alpha(1);
draw_set_color(c_white);

// Body, flashing white when hit
if (flash > 0) gpu_set_fog(true, c_white, 0, 1);
draw_sprite_ext(sprite_index, image_index, x, y, facing, 1, 0, c_white, 1);
if (flash > 0) gpu_set_fog(false, c_white, 0, 0);

if (global.debug) {
    draw_set_color(c_red);
    draw_circle(x, y, hurt_r, true);
    draw_set_color(c_white);
}
