/// obj_player — Draw

// Ground shadow (sells the top-down look, and later the height of lobbed things)
draw_set_alpha(0.35);
draw_set_color(c_black);
draw_ellipse(x - 6, y - 2, x + 6, y + 2, false);
draw_set_alpha(1);
draw_set_color(c_white);

// Blink while invulnerable after a hit (not during dash)
var _visible = true;
if (state == PSTATE.HURT || (iframes > 0 && state != PSTATE.DASH)) {
    _visible = ((iframes div 3) mod 2) == 0;
}

if (_visible) {
    var _col = (state == PSTATE.DASH) ? make_color_rgb(180, 220, 255) : c_white;
    var _alpha = (state == PSTATE.DEAD) ? 0.4 : 1;
    draw_sprite_ext(sprite_index, image_index, x, y, facing, 1, 0, _col, _alpha);
}

// Debug: collision mask + aim line
if (global.debug) {
    draw_set_color(c_lime);
    draw_rectangle(bbox_left, bbox_top, bbox_right - 1, bbox_bottom - 1, true);
    draw_set_color(c_yellow);
    draw_line(x, y - 8, global.mouse_wx, global.mouse_wy);
    draw_set_color(c_white);
}
