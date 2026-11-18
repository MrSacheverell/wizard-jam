/// obj_camera — Room Start
// Rooms reset view settings, so re-apply them on every room.

view_enabled    = true;
view_visible[0] = true;
view_camera[0]  = cam;
view_set_xport(0, 0);
view_set_yport(0, 0);
view_set_wport(0, GAME_W);
view_set_hport(0, GAME_H);

shake_amt = 0;

// Snap to the player so the camera doesn't swoop in from (0,0)
if (instance_exists(obj_player)) {
    cx = obj_player.x;
    cy = obj_player.y - 8;
} else {
    cx = room_width / 2;
    cy = room_height / 2;
}
