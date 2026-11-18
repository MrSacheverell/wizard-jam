// =====================================================================
// scr_core — macros, enums, globals and shared helpers
// Script asset: create a Script named scr_core and paste this whole file.
// Top-level code in a script runs once at game start, before the first room.
// =====================================================================

#macro GAME_W 480
#macro GAME_H 270
#macro INTEGER_SCALE true   // false = fill the window (fractional scale, slightly uneven pixels)

enum PSTATE { IDLE, RUN, DASH, HURT, DEAD }

// ---- globals (safe defaults before obj_game exists) ----
global.frozen   = false;   // true during hitstop frames
global.paused   = false;
global.debug    = false;
global.mouse_wx = 0;       // mouse position in world (room) space
global.mouse_wy = 0;
global.solids   = [];      // tilemap id(s) + obj_wall; rebuilt each Room Start

/// @func approach(current, target, amount)
/// Moves current toward target by at most amount.
function approach(_a, _b, _amt) {
    if (_a < _b) return min(_a + _amt, _b);
    return max(_a - _amt, _b);
}

/// @func game_frozen()
/// Gameplay objects call this at the top of Step: if (game_frozen()) exit;
function game_frozen() {
    return global.frozen || global.paused;
}

/// @func hitstop(frames)
/// Freeze gameplay for N frames. Overlapping calls keep the longest one.
function hitstop(_frames) {
        with (obj_game) hitstop_frames = max(hitstop_frames, _frames);
}

/// @func shake(amount)
/// Screen shake in pixels. Scale it to damage dealt.
function shake(_amount) {
    with (obj_camera) shake_amt = max(shake_amt, _amount);
}

/// @func move_collide()
/// Moves the calling instance by its hsp/vsp, sliding along walls.
/// Axis-separated so diagonal movement slides cleanly along walls.
/// Uses the instance's collision mask, so give actors a small feet-only mask.
function move_collide() {
    var _s = global.solids;

    // Horizontal
    if (place_meeting(x + hsp, y, _s)) {
        var _st = sign(hsp);
        while (!place_meeting(x + _st, y, _s)) x += _st;
        hsp = 0;
    } else {
        x += hsp;
    }

    // Vertical
    if (place_meeting(x, y + vsp, _s)) {
        var _st = sign(vsp);
        while (!place_meeting(x, y + _st, _s)) y += _st;
        vsp = 0;
    } else {
        y += vsp;
    }
}
