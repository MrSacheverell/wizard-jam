/// obj_lighting — Create
// Persistent. Created by obj_game. Draws the light layer over the arena:
//  1. Draw every light source onto a black surface (soft colored circles, additive)
//  2. Make a second surface: the ambient color (how dark it is) + those lights
//  3. Multiply the scene by it: dark where no light, full color where lit
//  4. Add a faint copy of the lights alone on top for a soft bloom
// Depth -90000: above actors and walls; the pixelfx effects (-95000),
// lightning, particles and callouts draw above it and stay bright.

depth      = -90000;
surf       = -1;       // ambient + lights: multiplies the scene
surf_l     = -1;       // lights only: also added on top as bloom
glow_alpha = 0.22;     // strength of the bloom pass
cx = 0;                // camera position this frame (lights are drawn screen-relative)
cy = 0;

/// Ambient color: lower = darker. Tuned so the floor and shadows stay readable.
ambient = function() {
    if (run_is_boss_room()) return make_color_rgb(135, 100, 115);   // blood-red sanctum
    switch (global.run.act) {
        case 1:  return make_color_rgb(125, 138, 150);   // Haunted Forest: cool dusk
        case 2:  return make_color_rgb(112, 112, 165);   // Crystal Caves: blue
        default: return make_color_rgb(150, 132, 140);   // Sky Citadel: warm
    }
};

/// Adds one light: world position, radius in pixels, color, strength 0..1
light = function(_x, _y, _r, _col, _a) {
    if (_a <= 0.01 || _r <= 1) return;
    draw_sprite_ext(spr_light, 0, _x - cx, _y - cy, _r / 32, _r / 32, 0, _col, _a);
};

/// Light color and radius for each pixelfx effect sprite
fx_light = function(_spr) {
    switch (_spr) {
        case spr_fx_blast_s:   return [global.element_color[ELEMENT.BURN],   75];
        case spr_fx_blast_l:   return [global.element_color[ELEMENT.BURN],  120];
        case spr_fx_nova:      return [global.element_color[ELEMENT.FREEZE], 90];
        case spr_fx_shatter:   return [global.element_color[ELEMENT.FREEZE], 55];
        case spr_fx_zap:       return [global.element_color[ELEMENT.SHOCK],  45];
        case spr_fx_blink_out:
        case spr_fx_blink_in:  return [global.element_color[ELEMENT.NONE],   55];
        case spr_fx_spark:     return [global.element_color[ELEMENT.NONE],   28];
    }
    return [c_white, 40];
};
