/// obj_enemy — Draw
// Shadow (stays on the ground; flyers' shadows shrink a little with height)
var _sw = 6 - min(z, 12) * 0.15;
draw_set_alpha(0.35);
draw_set_color(c_black);
draw_ellipse(x - _sw, y - 2, x + _sw, y + 2, false);
draw_set_alpha(1);
draw_set_color(c_white);

// Body, flashing white when hit
if (flash > 0) gpu_set_fog(true, c_white, 0, 1);
draw_sprite_ext(sprite_index, image_index, x, y - z, facing, 1, 0, tint, 1);
if (flash > 0) gpu_set_fog(false, c_white, 0, 0);

// Element pip above the head
if (status_el != ELEMENT.NONE) {
    var _col = global.element_color[status_el];
    var _py  = y - z - 20;
    var _blink = (status_t < 40) && ((status_t div 4) mod 2 == 0);  // blink as it expires
    if (!_blink) {
        gpu_set_blendmode(bm_add);
        draw_set_alpha(0.5);
        draw_set_color(_col);
        draw_circle(x, _py, 3, false);
        draw_set_alpha(1);
        gpu_set_blendmode(bm_normal);
        draw_set_color(_col);
        draw_circle(x, _py, 1.5, false);
        draw_set_color(c_white);
    }
}

if (global.debug) {
    draw_set_color(c_red);
    draw_circle(x, y, hurt_r, true);
    draw_set_color(c_white);
}
