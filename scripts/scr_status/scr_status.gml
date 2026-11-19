// =====================================================================
// scr_status — elements on enemies and ALL reaction logic.
//
// An enemy holds one element at a time. When a DIFFERENT element lands,
// the two react and the old element is used up:
//
//   Burn  + Shock  (either order)  -> OVERLOAD     small explosion that spreads Burn
//   Burn  + Freeze (either order)  -> STEAM        cloud that slows enemies
//   Shock + Freeze (either order)  -> SUPERCONDUCT +50% damage taken for 4 s
//   Freeze + any hit of 2+ damage  -> SHATTER      double damage, removes Freeze
//                                   (checked first, so Freeze -> Fireball = Shatter;
//                                    Burn -> Frost Nova = Steam)
// =====================================================================

#macro STATUS_DUR   180   // default element duration, frames (3 s)
#macro FREEZE_DUR   120   // frozen enemies can't move or hurt you (2 s)
#macro BURN_TICK    45    // frames between Burn damage ticks
#macro BURN_DMG     1
#macro SUPER_DUR    240   // Superconduct vulnerability (4 s)
#macro SUPER_MULT   1.5
#macro SHATTER_MULT 2
#macro BIG_HIT      2     // damage needed to Shatter a frozen enemy

global.react_depth = 0;   // guards chain reactions (Overload -> Overload -> ...)

global.react_color = {
    overload:     make_color_rgb(255, 190,  60),
    steam:        make_color_rgb(230, 235, 245),
    superconduct: make_color_rgb(200, 120, 255),
    shatter:      make_color_rgb(150, 240, 255),
};

/// @func status_apply(target, element, duration)
function status_apply(_t, _el, _dur) {
    if (_el == ELEMENT.NONE || !instance_exists(_t)) return;

    with (_t) {
        var _old = status_el;
        if (_old == ELEMENT.NONE || _old == _el) {
            if (_old != _el) burn_tick = 0;
            status_el = _el;
            status_t  = max(status_t, _dur);
        } else {
            // Different element: react, and both are used up
            status_el = ELEMENT.NONE;
            status_t  = 0;
            burn_tick = 0;
            status_react(_old, _el);
        }
    }
}

/// @func status_react(old_element, new_element)
/// Runs in the enemy's scope.
function status_react(_a, _b) {
    var _pair = function(_a, _b, _x, _y) { return (_a == _x && _b == _y) || (_a == _y && _b == _x); };

    if (_pair(_a, _b, ELEMENT.BURN, ELEMENT.SHOCK)) {
        // OVERLOAD: explosion that spreads Burn (can chain into other Shocked enemies)
        fx_text(x, y - 24 - z, "OVERLOAD", global.react_color.overload);
        screen_flash(0.25);
        if (global.react_depth < 6) {
            global.react_depth++;
            spell_explode(x, y, 24, 1, ELEMENT.BURN, 1.5, global.react_color.overload);
            global.react_depth--;
        }
    }
    else if (_pair(_a, _b, ELEMENT.BURN, ELEMENT.FREEZE)) {
        // STEAM: lingering cloud that slows anything inside it
        fx_text(x, y - 24 - z, "STEAM", global.react_color.steam);
        screen_flash(0.1);
        instance_create_depth(x, y, -y - 1, obj_steam);
    }
    else if (_pair(_a, _b, ELEMENT.SHOCK, ELEMENT.FREEZE)) {
        // SUPERCONDUCT: takes extra damage for a while
        fx_text(x, y - 24 - z, "SUPERCONDUCT", global.react_color.superconduct);
        screen_flash(0.15);
        vuln_t = SUPER_DUR;
        fx_burst(x, y - 8 - z, global.react_color.superconduct, 8);
    }
}

/// @func status_tick()
/// Called from obj_enemy Step (in the enemy's scope).
function status_tick() {
    if (vuln_t > 0) vuln_t--;
    if (slow_t > 0) slow_t--;
    if (status_t <= 0) return;
    status_t--;

    if (status_el == ELEMENT.BURN) {
        burn_tick++;
        if (burn_tick >= BURN_TICK) {
            burn_tick = 0;
            hp   -= BURN_DMG;
            flash = 3;
            fx_damage(x, y - 18 - z, BURN_DMG, global.element_color[ELEMENT.BURN], false);
            fx_burst(x, y - 8 - z, global.element_color[ELEMENT.BURN], 4);
            if (hp <= 0) { die(); return; }
        }
    }

    if (status_t <= 0) status_el = ELEMENT.NONE;
}
