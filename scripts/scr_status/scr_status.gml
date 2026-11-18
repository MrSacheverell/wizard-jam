// =====================================================================
// scr_status — elements on enemies. ALL reaction logic will live here.
// Week 1: apply/refresh an element, Burn ticks damage.
// Week 2: the reaction table (Shatter, Overload, Steam, Superconduct).
// =====================================================================

#macro STATUS_DUR 180     // default element duration, frames (3 s)
#macro BURN_TICK  45      // frames between Burn damage ticks
#macro BURN_DMG   1

/// @func status_apply(target, element, duration)
function status_apply(_t, _el, _dur) {
    if (_el == ELEMENT.NONE || !instance_exists(_t)) return;

    with (_t) {
        // ---- Week 2: reaction check goes here ----
        // if (status_el != ELEMENT.NONE && status_el != _el) {
        //     status_react(id, status_el, _el);   // Shatter / Overload / Steam / Superconduct
        //     exit;
        // }
        if (status_el != _el) burn_tick = 0;
        status_el = _el;
        status_t  = max(status_t, _dur);
    }
}

/// @func status_tick()
/// Called from obj_enemy Step (in the enemy's scope).
function status_tick() {
    if (status_t <= 0) return;
    status_t--;

    if (status_el == ELEMENT.BURN) {
        burn_tick++;
        if (burn_tick >= BURN_TICK) {
            burn_tick = 0;
            hp   -= BURN_DMG;
            flash = 3;
            fx_burst(x, y - 8 - z, global.element_color[ELEMENT.BURN], 4);
            if (hp <= 0) { die(); return; }
        }
    }

    if (status_t <= 0) status_el = ELEMENT.NONE;
}
