// =====================================================================
// scr_lighting — settings and helpers for the light layer (obj_lighting).
// =====================================================================

global.lighting     = true;  // pause menu toggle (turn off on slow machines)
global.flash_amount = 0;     // 0..1: brightens the whole scene for a moment

/// @func screen_flash(amount)
/// Screen-wide flash of light (reactions, boss moments). Decays on its own.
function screen_flash(_amount) {
    global.flash_amount = max(global.flash_amount, _amount);
}