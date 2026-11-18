/// obj_camera — End Step
// Runs after everything moved this frame. NOT frozen by hitstop,
// so shake keeps rattling during the freeze (that's the good part).

var _tx = cx, _ty = cy;

if (instance_exists(obj_player)) {
    var _p = obj_player;
    var _lx = clamp((global.mouse_wx - _p.x) * lead_factor, -lead_max, lead_max);
    var _ly = clamp((global.mouse_wy - _p.y) * lead_factor, -lead_max, lead_max);
    _tx = _p.x + _lx;
    _ty = _p.y - 8 + _ly;   // -8: center on the body, not the feet
}

if (!global.paused) {
    cx = lerp(cx, _tx, follow_speed);
    cy = lerp(cy, _ty, follow_speed);
}

// Top-left of the view, clamped to the room (centered if room is smaller)
var _vx = (room_width  <= GAME_W) ? (room_width  - GAME_W) / 2 : clamp(cx - GAME_W / 2, 0, room_width  - GAME_W);
var _vy = (room_height <= GAME_H) ? (room_height - GAME_H) / 2 : clamp(cy - GAME_H / 2, 0, room_height - GAME_H);

// Shake
var _sx = 0, _sy = 0;
if (shake_amt > 0.1) {
    _sx = random_range(-shake_amt, shake_amt);
    _sy = random_range(-shake_amt, shake_amt);
    shake_amt *= shake_decay;
} else {
    shake_amt = 0;
}

// Round to whole pixels: we render at 480x270, so sub-pixel camera = jitter
camera_set_view_pos(cam, round(_vx + _sx), round(_vy + _sy));
