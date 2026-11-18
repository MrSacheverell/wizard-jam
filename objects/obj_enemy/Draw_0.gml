/// obj_enemy — Draw
// Shadow (stays on the ground; flyers' shadows shrink a little with height)
var _sw = (6 - min(z, 12) * 0.15) * size_mult;
draw_set_alpha(0.35);
draw_set_color(c_black);
draw_ellipse(x - _sw, y - 2, x + _sw, y + 2, false);
draw_set_alpha(1);
draw_set_color(c_white);

// Body: frozen enemies turn icy, hit flash goes white
var _tint = tint;
if (status_el == ELEMENT.FREEZE) _tint = merge_color(tint, global.element_color[ELEMENT.FREEZE], 0.65);

var _alpha = 1;
if (spawn_t > 0) {                       // spawn-in: flicker up out of a rune circle
    _alpha = 1 - spawn_t / 40;
    draw_set_alpha(spawn_t / 40);
    draw_set_color(global.element_color[ELEMENT.NONE]);
    draw_circle(x, y, 4 + spawn_t * 0.25, true);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

var _xs = facing * size_mult, _ys = size_mult;

// Elite outline: the sprite drawn 4 times in the elite color, offset 1px
if (elite != "" && spawn_t <= 0) {
    gpu_set_fog(true, elite_color, 0, 1);
    draw_sprite_ext(sprite_index, image_index, x - 1, y - z, _xs, _ys, 0, c_white, 1);
    draw_sprite_ext(sprite_index, image_index, x + 1, y - z, _xs, _ys, 0, c_white, 1);
    draw_sprite_ext(sprite_index, image_index, x, y - z - 1, _xs, _ys, 0, c_white, 1);
    draw_sprite_ext(sprite_index, image_index, x, y - z + 1, _xs, _ys, 0, c_white, 1);
    gpu_set_fog(false, c_white, 0, 0);
}

if (flash > 0) gpu_set_fog(true, c_white, 0, 1);
draw_sprite_ext(sprite_index, image_index, x, y - z, _xs, _ys, 0, _tint, _alpha);
if (flash > 0) gpu_set_fog(false, c_white, 0, 0);

// Element pip above the head
var _py = y - z - 20;
if (status_el != ELEMENT.NONE) {
    var _col = global.element_color[status_el];
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
    }
}

// Superconduct marker: small violet diamond beside the pip
if (vuln_t > 0) {
    var _dx = x + 6;
    draw_set_color(global.react_color.superconduct);
    draw_triangle(_dx, _py - 3, _dx + 2, _py, _dx - 2, _py, false);
    draw_triangle(_dx, _py + 3, _dx + 2, _py, _dx - 2, _py, false);
}
draw_set_color(c_white);

if (global.debug) {
    draw_set_color(c_red);
    draw_circle(x, y, hurt_r, true);
    draw_set_color(c_white);
}
