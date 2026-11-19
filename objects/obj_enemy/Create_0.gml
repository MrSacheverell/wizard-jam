/// obj_enemy — Create  (PARENT: never placed directly)
// Children call event_inherited() first, then override stats and ai_step.

max_hp       = 3;
hp           = max_hp;
dying        = false;
move_speed   = 0.6;
contact_dmg  = 1;        // damage on touching the player (0 = none)
hurt_r       = 7;        // hurt radius on the ground plane
knock_resist = 0;        // 0..1, Shield Brute / Armored elites go higher
death_color  = make_color_rgb(140, 220, 110);
flying       = false;    // true: ignores walls (Bat)
z            = 0;        // draw height above the ground (flyers)
tint         = c_white;  // e.g. red while telegraphing an attack
spawn_t      = 40;       // spawn-in: harmless and inactive for a moment
size_mult    = 1;        // Splitting elites' children are smaller
is_boss      = false;    // bosses are slowed by Freeze instead of stopped

// Elite modifier: "", "fast", "armored", "splitting", "vampiric"
elite       = "";
elite_color = c_white;
regen_t     = 0;

hsp = 0;                 // movement this frame (set by ai_step)
vsp = 0;
kx  = 0;                 // knockback velocity, decays every frame
ky  = 0;
flash  = 0;              // white hit-flash frames
facing = 1;

// Element status and reaction effects (see scr_status)
status_el = ELEMENT.NONE;
status_t  = 0;
burn_tick = 0;
vuln_t    = 0;           // Superconduct: takes extra damage while > 0
slow_t    = 0;           // Steam: moves slowly while > 0

/// Override in children: set hsp/vsp (and facing) for this frame.
ai_step = function() {};

/// Child hook: return true to block a hit (Shield Brute). kx/ky point away from the source.
block_hit = function(_dmg, _kx, _ky) { return false; };

/// Child hook: called on every landed hit (Hexer gets interrupted by Freeze).
on_hit = function(_element) {};

/// Child hook: called when it dies (Bomber explodes).
on_death = function() {};

/// Turns this enemy into an elite.
apply_elite = function(_mod) {
    elite = _mod;
    switch (_mod) {
        case "fast":      move_speed *= 1.6;
                          elite_color = make_color_rgb(255, 220, 60);  break;
        case "armored":   max_hp = ceil(max_hp * 2);
                          knock_resist = max(knock_resist, 0.6);
                          elite_color = make_color_rgb(150, 175, 210); break;
        case "splitting": elite_color = make_color_rgb(120, 230, 120); break;
        case "vampiric":  max_hp = ceil(max_hp * 1.3);
                          elite_color = make_color_rgb(230, 50, 70);   break;
    }
    hp = max_hp;
};

/// Called by projectiles and spells.
take_hit = function(_dmg, _kx, _ky, _element) {
    if (hp <= 0) return;

    if (block_hit(_dmg, _kx, _ky)) {
        kx += _kx * 0.3;
        ky += _ky * 0.3;
        return;
    }

    if (vuln_t > 0) _dmg *= SUPER_MULT;

    // SHATTER: a big hit on a frozen enemy
    if (status_el == ELEMENT.FREEZE && _dmg >= BIG_HIT) {
        _dmg *= SHATTER_MULT;
        status_el = ELEMENT.NONE;
        status_t  = 0;
        fx_text(x, y - 24 - z, "SHATTER", global.react_color.shatter);
        fx_anim(spr_fx_shatter, x, y - z, 0.8 * size_mult);       // pixelfx Ice Shatter
        fx_burst(x, y - 8 - z, global.react_color.shatter, 8);
        hitstop(4);
        shake(4);
    }

    hp    -= _dmg;
    flash  = 5;
    kx    += _kx * (1 - knock_resist);
    ky    += _ky * (1 - knock_resist);
    shake(1);

    // Apply the element (may trigger a reaction), then die if needed,
    // so killing blows still set off Overloads.
    var _dur = ((_element == ELEMENT.FREEZE) ? FREEZE_DUR : STATUS_DUR) * global.run.status_mult * global.run.el_dur[_element];
    status_apply(id, _element, _dur);
    on_hit(_element);

    if (hp <= 0) die();
};

die = function() {
    if (!instance_exists(id) || dying) return;
    dying = true;
    hp = 0;
    on_death();

    // Splitting elites burst into two smaller (non-elite) copies
    if (elite == "splitting" && size_mult == 1) {
        for (var i = 0; i < 2; i++) {
            var _c = instance_create_layer(x + (i * 2 - 1) * 6, y, "Instances", object_index);
            _c.size_mult = 0.7;
            _c.max_hp  = max(1, ceil(max_hp / 3));
            _c.hp      = _c.max_hp;
            _c.hurt_r  = hurt_r * 0.8;
            _c.spawn_t = 12;
            _c.kx      = (i * 2 - 1) * 2.5;
        }
        fx_text(x, y - 24 - z, "SPLIT", elite_color);
    }

    // Sometimes leave a heart (elites more often)
    if (!is_boss && random(1) < ((elite != "") ? 0.25 : 0.06)) heart_drop(x, y);

    fx_burst(x, y - 8 - z, death_color, 12);
    hitstop(3);
    shake(3);
    instance_destroy();
};
