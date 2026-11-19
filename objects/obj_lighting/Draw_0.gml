/// obj_lighting — Draw
if (room != rm_arena_test || !global.lighting) exit;

var _cam = view_camera[0];
cx = camera_get_view_x(_cam);
cy = camera_get_view_y(_cam);
if (!surface_exists(surf))   surf   = surface_create(GAME_W, GAME_H);
if (!surface_exists(surf_l)) surf_l = surface_create(GAME_W, GAME_H);

// 1. Lights only
surface_set_target(surf_l);
draw_clear_alpha(c_black, 1);
gpu_set_blendmode(bm_add);

var _L = id;   // so 'with' blocks can reach light()
var _t = current_time / 1000;

// ---- The wizard's lantern (always: keeps your surroundings and shadows readable) ----
with (obj_player) {
    _L.light(x, y - 8, 115, make_color_rgb(220, 210, 255), 0.55);
    _L.light(x, y - 10, 40, global.element_color[ELEMENT.NONE], 0.35);
}

// ---- Projectiles ----
with (obj_projectile) _L.light(x, y - z, 20 + size * 7, color, 0.9);

// ---- pixelfx effects, fading out as they play ----
with (obj_fx_anim) {
    var _fl = _L.fx_light(sprite_index);
    var _k  = 1 - image_index / max(1, image_number);
    _L.light(x, y - 8, _fl[1] * image_xscale, _fl[0], _k);
}

// ---- Blast rings (Overload, Blink shocks) ----
with (obj_fx_ring) _L.light(x, y - 6, r_max * 1.6, color, life / life_max);

// ---- Lightning arcs: light at every joint ----
with (obj_lightning) {
    var _a = life / life_max;
    for (var i = 0; i < array_length(points); i++) {
        _L.light(points[i][0], points[i][1], 50, color, _a * (0.7 + random(0.3)));
    }
}

// ---- Meteors: the rock glows as it falls, the target glows red beneath ----
with (obj_meteor) {
    var _f = 1 - fall / fall_max;
    var _h = (1 - _f) * 180;
    _L.light(x + _h * 0.5, y - _h, 55, global.element_color[ELEMENT.BURN], 0.9);
    _L.light(x, y, r * 1.3, c_red, 0.25 + 0.35 * _f);
}

// ---- Wisps ----
with (obj_wisp) _L.light(x, y - z, 38, global.element_color[ELEMENT.FREEZE], 0.8);

// ---- Steam clouds ----
with (obj_steam) _L.light(x, y - 4, r * 1.5, c_white, 0.25 * min(1, life / 60));

// ---- Enemy attacks ----
with (obj_enemy_shot) {
    switch (kind) {
        case "orb":
        case "bolt": _L.light(x, y - z, 30, color, 0.85); break;
        case "lob":  _L.light(tx, ty, 18, c_red, 0.3 + 0.4 * t); break;
        case "zone": _L.light(x, y, r * 1.6, color, 0.2 + 0.5 * (timer / delay)); break;
        case "ring": _L.light(x, y, r * 1.2, color, 0.25); break;
        case "beam":
            if (timer >= delay) {
                for (var d = 0; d < len; d += 40) _L.light(x + lengthdir_x(d, dir), y + lengthdir_y(d, dir), 45, color, 0.8);
            }
            break;
    }
}

// ---- Enemies: elements glow, the Archmage burns, telegraphs flare ----
with (obj_enemy) {
    if (status_el != ELEMENT.NONE) _L.light(x, y - 10 - z, 26 * size_mult, global.element_color[status_el], 0.6);
    if (tint != c_white) _L.light(x, y - 10 - z, 30, tint, 0.5);   // wind-ups / telegraphs
    if (is_boss) _L.light(x, y - 16, 80, death_color, 0.5 + 0.1 * sin(_t * 4));
}

// ---- Pickups and the door ----
with (obj_heart) _L.light(x, y - 8, 24, make_color_rgb(255, 80, 100), 0.6);
with (obj_door) {
    if (is_open) _L.light(x + 16, y + 20, 75, global.element_color[ELEMENT.NONE], 0.6 + 0.2 * sin(glow * 2));
    else         _L.light(x + 16, y + 20, 30, make_color_rgb(120, 110, 150), 0.3);
}

gpu_set_blendmode(bm_normal);
surface_reset_target();

// 2. Ambient + lights
surface_set_target(surf);
draw_clear(merge_color(ambient(), c_white, global.flash_amount));
gpu_set_blendmode(bm_add);
draw_surface(surf_l, 0, 0);
gpu_set_blendmode(bm_normal);
surface_reset_target();

// 3. Multiply the scene, 4. add the lights as a soft bloom
gpu_set_blendmode_ext(bm_dest_colour, bm_zero);
draw_surface(surf, cx, cy);
gpu_set_blendmode(bm_add);
draw_surface_ext(surf_l, cx, cy, 1, 1, 0, c_white, glow_alpha);
gpu_set_blendmode(bm_normal);
