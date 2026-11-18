/// rm_init creation code
// Boot: create the persistent game controller. obj_game sends us on to the arena.
if (!instance_exists(obj_game)) instance_create_depth(0, 0, 0, obj_game);
