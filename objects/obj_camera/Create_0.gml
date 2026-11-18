/// obj_camera — Create
// Persistent. Created by obj_game; do not place in rooms.

cam = camera_create_view(0, 0, GAME_W, GAME_H);

cx = 0;          // smoothed focus point (world space)
cy = 0;

follow_speed = 0.15;   // 0..1, higher = tighter follow
lead_factor  = 0.20;   // how far toward the mouse the camera leans
lead_max     = 40;     // cap on lean, in pixels

shake_amt    = 0;
shake_decay  = 0.85;   // per-frame multiplier
