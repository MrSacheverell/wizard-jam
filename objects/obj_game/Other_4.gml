/// obj_game — Room Start
// Rebuild the list of solid things for this arena.
// Each arena room: a Tile layer named "Collision" (any tile = wall).
// obj_wall is a fallback for odd shapes / quick testing.

global.solids = [];

var _lay = layer_get_id("Collision");
if (_lay != -1) {
    var _tm = layer_tilemap_get_id(_lay);
    if (_tm != -1) {
        array_push(global.solids, _tm);
        layer_set_visible(_lay, false); // hide it if you paint walls on a separate visual layer
                                        // (delete this line if Collision IS your visible wall layer)
    }
}
array_push(global.solids, obj_wall);
