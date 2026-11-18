/// obj_game — Begin Step
// Runs before every gameplay Step, so hitstop/scaling/mouse are ready.

// ---- 1. Window / browser resize ----
var _bw, _bh;
if (os_browser != browser_not_a_browser) {
    _bw = browser_width;
    _bh = browser_height;
} else {
    _bw = window_get_width();
    _bh = window_get_height();
}

if ((_bw != win_w || _bh != win_h) && _bw > 0 && _bh > 0) {
    win_w = _bw;
    win_h = _bh;

    if (os_browser != browser_not_a_browser) {
        window_set_size(_bw, _bh);   // resizes the HTML5 canvas
    }

    scale = min(_bw / GAME_W, _bh / GAME_H);
    if (INTEGER_SCALE) scale = max(1, floor(scale));

    off_x = floor((_bw - GAME_W * scale) / 2);
    off_y = floor((_bh - GAME_H * scale) / 2);

    // GUI layer is 480x270 too, scaled and letterboxed the same way,
    // so Draw GUI code and mouse-to-GUI coords line up with the game.
    display_set_gui_maximize(scale, scale, off_x, off_y);
}

// ---- 2. Hitstop ----
// Set the flag BEFORE ticking, so hitstop(3) freezes exactly 3 frames.
global.frozen = (hitstop_frames > 0);
if (hitstop_frames > 0) hitstop_frames--;

// ---- 3. World-space mouse ----
// Mouse in GUI space (0..480, 0..270) + camera position = world position.
var _gx = clamp(device_mouse_x_to_gui(0), 0, GAME_W);
var _gy = clamp(device_mouse_y_to_gui(0), 0, GAME_H);
var _cam = view_camera[0];
global.mouse_wx = camera_get_view_x(_cam) + _gx;
global.mouse_wy = camera_get_view_y(_cam) + _gy;
