/// obj_door — Create
// Sits in the 32px gap of the top wall. Locked: an invisible obj_wall
// blocks the gap. Opens after the upgrade pick; walking in = next room.
is_open = false;
glow    = 0;
blocker = instance_create_layer(x, y, "Instances", obj_wall);
blocker.image_xscale = 2;
blocker.image_yscale = 2;
blocker.visible = false;
depth = -(y + 32);

door_open = function() {
    if (is_open) return;
    is_open = true;
    if (instance_exists(blocker)) instance_destroy(blocker);
    fx_burst(x + 16, y + 20, global.element_color[ELEMENT.NONE], 16);
    sfx(snd_door, 0, 0.7);
    shake(2);
};
