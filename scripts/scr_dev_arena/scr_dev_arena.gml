// =====================================================================
// scr_dev_arena — TEMPORARY test arena built from code.
// Lets rm_arena_test run without hand-placing anything. Delete once real
// arenas are painted in the room editor (Collision tile layer + obj_player).
// =====================================================================

/// @func dev_wall(x, y, w, h)
/// Creates a scaled obj_wall block. Sizes in pixels (multiples of 16).
function dev_wall(_x, _y, _w, _h) {
    var _i = instance_create_layer(_x, _y, "Instances", obj_wall);
    _i.image_xscale = _w / 16;
    _i.image_yscale = _h / 16;
    _i.depth = -(_y + _h);
    return _i;
}

/// @func dev_build_test_arena()
function dev_build_test_arena() {
    var _t = 16;
    var _w = room_width;
    var _h = room_height;

    // Border
    dev_wall(0, 0, _w, _t * 2);           // top wall is 2 tiles tall (3/4 view look)
    dev_wall(0, _h - _t, _w, _t);
    dev_wall(0, 0, _t, _h);
    dev_wall(_w - _t, 0, _t, _h);

    // Pillars to dash around
    dev_wall(160, 112, 32, 32);
    dev_wall(608, 112, 32, 32);
    dev_wall(160, 336, 32, 32);
    dev_wall(608, 336, 32, 32);

    // Center obstacle with a gap, to test sliding along walls
    dev_wall(336, 208, 48, 16);
    dev_wall(416, 208, 48, 16);

    // Player
    if (!instance_exists(obj_player)) {
        instance_create_layer(_w / 2, _h - 80, "Instances", obj_player);
    }

    // Enemies
    dev_spawn_wave(6);
}

/// @func dev_spawn_wave(count)
/// Spawns Shamblers (and ~30% Bats) on free floor, away from the player.
function dev_spawn_wave(_count) {
    var _px = instance_exists(obj_player) ? obj_player.x : room_width / 2;
    var _py = instance_exists(obj_player) ? obj_player.y : room_height / 2;
    var _made = 0, _tries = 0;
    while (_made < _count && _tries < 200) {
        _tries++;
        var _x = random_range(40, room_width - 40);
        var _y = random_range(56, room_height - 40);
        if (point_distance(_x, _y, _px, _py) < 140) continue;
        if (collision_rectangle(_x - 8, _y - 8, _x + 8, _y + 4, obj_wall, false, true) != noone) continue;
        instance_create_layer(_x, _y, "Instances", (random(1) < 0.3) ? obj_bat : obj_shambler);
        _made++;
    }
}
