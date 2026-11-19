// =====================================================================
// scr_spells — elements, the spell database, casting and projectile spawning
// Adding a spell = adding an entry to global.spell_db, not a new object.
// =====================================================================

enum ELEMENT { NONE, BURN, FREEZE, SHOCK }

// One strong color per element (design doc): orange Burn, cyan Freeze, yellow Shock
global.element_color = [
    make_color_rgb(200, 170, 255),  // NONE  (arcane violet)
    make_color_rgb(255, 140,  40),  // BURN
    make_color_rgb( 90, 220, 255),  // FREEZE
    make_color_rgb(255, 230,  60),  // SHOCK
];

// ---------------------------------------------------------------------
// Spell database. Each entry:
//   name, short (HUD label), element, cooldown (seconds), cast(caster, tier, dir)
// cast() receives the caster instance, the spell tier (1..3) and the aim
// direction in degrees. Return false from cast() to NOT start the cooldown
// (e.g. Chain Lightning with no target in range).
// ---------------------------------------------------------------------
global.spell_db = {

    magic_bolt: {
        name:     "Magic Bolt",
        short:    "MB",
        element:  ELEMENT.NONE,
        cooldown: 0.25,
        desc:     "Fast bolt toward the cursor. Hold to auto-cast.",
        tiers:    ["", "Bolts pierce 1 enemy.", "Bolts pierce 2 enemies."],
        cast: function(_caster, _tier, _dir) {
            var _n = 1 + global.run.extra_proj;
            for (var i = 0; i < _n; i++) {
                projectile_spawn(_caster.x, _caster.y, _dir + (i - (_n - 1) / 2) * 8, {
                    spd:    6,
                    dmg:    1,
                    life:   45,
                    radius: 3,
                    knock:  1.6,
                    size:   2,
                    element: ELEMENT.NONE,
                    color:  global.element_color[ELEMENT.NONE],
                    pierce: _tier - 1,          // T2 pierce 1, T3 pierce 2
                });
            }
        },
    },

    fireball: {
        name:     "Fireball",
        short:    "FB",
        element:  ELEMENT.BURN,
        cooldown: 1.2,
        desc:     "Slow orb that explodes, burning everything in the blast.",
        tiers:    ["", "Bigger blast.", "Huge blast."],
        cast: function(_caster, _tier, _dir) {
            var _n = 1 + global.run.extra_proj;
            for (var i = 0; i < _n; i++)
            projectile_spawn(_caster.x, _caster.y, _dir + (i - (_n - 1) / 2) * 14, {
                spd:       3.5,
                dmg:       2,          // explosion damage (direct hit = explosion)
                life:      60,         // explodes where it fizzles, too
                radius:    4,
                knock:     2.5,
                size:      4,
                element:   ELEMENT.BURN,
                color:     global.element_color[ELEMENT.BURN],
                explode_r: (_tier >= 3) ? 44 : ((_tier == 2) ? 34 : 26),
            });
        },
    },

    chain_lightning: {
        name:     "Chain Lightning",
        short:    "CL",
        element:  ELEMENT.SHOCK,
        cooldown: 2.0,
        desc:     "Strikes the enemy nearest the cursor, then jumps to 3 more.",
        tiers:    ["", "Jumps to 5 enemies.", "Jumps to 7 enemies."],
        cast: function(_caster, _tier, _dir) {
            var _jump_table = [3, 5, 7];
            var _jumps = _jump_table[clamp(_tier, 1, 3) - 1];

            // First target: nearest the cursor, else nearest the caster
            var _cur = enemy_nearest(global.mouse_wx, global.mouse_wy, 64, []);
            if (_cur == noone) _cur = enemy_nearest(_caster.x, _caster.y, 160, []);
            if (_cur == noone) return false;    // nothing in range: no cooldown

            var _col = global.element_color[ELEMENT.SHOCK];
            var _pts = [[_caster.x, _caster.y - 10]];
            var _hit = [];

            for (var i = 0; i <= _jumps && _cur != noone; i++) {
                // Read position BEFORE damaging: the hit may kill and destroy it
                var _nx = _cur.x, _ny = _cur.y, _nz = _cur.z;
                array_push(_hit, _cur);
                array_push(_pts, [_nx, _ny - 8 - _nz]);

                var _px = _pts[i][0], _py = _pts[i][1];
                var _d = point_direction(_px, _py, _nx, _ny);
                _cur.take_hit(1, lengthdir_x(0.8, _d), lengthdir_y(0.8, _d), ELEMENT.SHOCK);
                var _from = point_direction(_nx, _ny - 8 - _nz, _pts[i][0], _pts[i][1]);
                fx_anim(spr_fx_zap, _nx, _ny - 8 - _nz, 0.6, _from - 180, -_ny - 3);

                _cur = enemy_nearest(_nx, _ny, 72, _hit);
            }

            var _l = instance_create_depth(0, 0, -99999, obj_lightning);
            _l.points = _pts;
            _l.color  = _col;
            shake(2);
            hitstop(2);
        },
    },

    frost_nova: {
        name:     "Frost Nova",
        short:    "FN",
        element:  ELEMENT.FREEZE,
        cooldown: 6.0,
        desc:     "Ring of frost around you. Frozen enemies can't move or hurt you.",
        tiers:    ["", "Wider ring.", "Huge ring."],
        cast: function(_caster, _tier, _dir) {
            // Ring around the caster; aim doesn't matter
            var _r = (_tier >= 3) ? 70 : ((_tier == 2) ? 56 : 42);
            spell_explode(_caster.x, _caster.y, _r, 1, ELEMENT.FREEZE, 1.2,
                          global.element_color[ELEMENT.FREEZE]);
        },
    },

    arcane_disc: {
        name:     "Arcane Disc",
        short:    "AD",
        element:  ELEMENT.NONE,
        cooldown: 1.5,
        desc:     "Spinning disc flies out and returns, hitting both ways. Big hit.",
        tiers:    ["", "Throws 2 discs.", "Throws 3 discs."],
        cast: function(_caster, _tier, _dir) {
            var _n = _tier;                         // T1 1 disc, T2 2, T3 3
            for (var i = 0; i < _n; i++) {
                projectile_spawn(_caster.x, _caster.y, _dir + (i - (_n - 1) / 2) * 22, {
                    kind:   "disc",
                    spd:    5.5,
                    dmg:    2,                      // 2 = big hit: Shatters frozen enemies
                    life:   300,                    // safety; it ends when it gets back to you
                    radius: 6,
                    knock:  1.8,
                    size:   4,
                    element: ELEMENT.NONE,
                    color:  global.element_color[ELEMENT.NONE],
                    pierce: 999,
                    owner:  _caster,
                });
            }
        },
    },

    meteor: {
        name:     "Meteor",
        short:    "ME",
        element:  ELEMENT.BURN,
        cooldown: 8.0,
        desc:     "Lands at the cursor after a moment for a huge burning hit.",
        tiers:    ["", "Larger impact.", "Splits into 3 meteors."],
        cast: function(_caster, _tier, _dir) {
            var _tx = global.mouse_wx, _ty = global.mouse_wy + 8;   // cursor aims at the body; land at its feet
            var _r = (_tier >= 2) ? 52 : 40;
            meteor_drop(_tx, _ty, _r, 0);
            if (_tier >= 3) {
                meteor_drop(_tx - 36, _ty + 14, 28, 8);
                meteor_drop(_tx + 36, _ty + 14, 28, 14);
            }
        },
    },

    blink: {
        name:     "Blink",
        short:    "BL",
        element:  ELEMENT.SHOCK,
        cooldown: 5.0,
        cd_tiers: [5.0, 3.5, 2.5],
        desc:     "Teleport to the cursor, shocking enemies where you leave and land.",
        tiers:    ["", "Cooldown 3.5 s.", "Cooldown 2.5 s and bigger shocks."],
        cast: function(_caster, _tier, _dir) {
            var _col = global.element_color[ELEMENT.SHOCK];
            var _r   = (_tier >= 3) ? 38 : 28;
            var _range = 150;

            // Destination: cursor (at feet level), capped to range, walked back out of walls
            var _tx = global.mouse_wx, _ty = global.mouse_wy + 8;
            var _d  = min(_range, point_distance(_caster.x, _caster.y, _tx, _ty));
            var _a  = point_direction(_caster.x, _caster.y, _tx, _ty);
            var _ok = false, _nx = _caster.x, _ny = _caster.y;
            with (_caster) {
                while (_d > 0) {
                    _nx = x + lengthdir_x(_d, _a);
                    _ny = y + lengthdir_y(_d, _a);
                    if (_nx > 16 && _nx < room_width - 16 && _ny > 32 && _ny < room_height - 16
                    && !place_meeting(_nx, _ny, global.solids)) { _ok = true; break; }
                    _d -= 4;
                }
            }
            if (!_ok) return false;     // no room to land: no cooldown

            var _ox = _caster.x, _oy = _caster.y;
            fx_anim(spr_fx_blink_out, _ox, _oy);
            spell_explode(_ox, _oy, _r, 1, ELEMENT.SHOCK, 2, _col);
            _caster.x = _nx;
            _caster.y = _ny;
            _caster.iframes = max(_caster.iframes, 15);
            fx_anim(spr_fx_blink_in, _nx, _ny);
            spell_explode(_nx, _ny, _r, 1, ELEMENT.SHOCK, 2, _col);

            var _l = instance_create_depth(0, 0, -99999, obj_lightning);
            _l.points = [[_ox, _oy - 8], [_nx, _ny - 8]];
            _l.color  = _col;
        },
    },

    wisp: {
        name:     "Wisp",
        short:    "WI",
        element:  ELEMENT.FREEZE,
        cooldown: 10.0,
        desc:     "Summons an orbiting frost wisp that shoots enemies for 8 s.",
        tiers:    ["", "Summons 2 wisps.", "Wisps last 12 s."],
        cast: function(_caster, _tier, _dir) {
            var _n   = (_tier >= 2) ? 2 : 1;
            var _dur = ((_tier >= 3) ? 12 : 8) * 60;
            for (var i = 0; i < _n; i++) {
                var _w = instance_create_depth(_caster.x, _caster.y, -_caster.y, obj_wisp);
                _w.owner = _caster;
                _w.angle = i * 180;
                _w.life  = _dur;
                _w.life_max = _dur;
            }
        },
    },
};

/// @func spell_get(spell_id)
function spell_get(_spell_id) {
    return global.spell_db[$ _spell_id];
}

/// @func spell_cast(caster, slot_index)
/// Casts the spell in a slot toward the mouse and starts its cooldown.
function spell_cast(_caster, _slot) {
    var _s = _caster.slots[_slot];
    if (is_undefined(_s)) return false;
    var _def = spell_get(_s.id);
    if (is_undefined(_def)) return false;

    var _dir = point_direction(_caster.x, _caster.y - 8, global.mouse_wx, global.mouse_wy);
    var _ok  = _def.cast(_caster, _s.tier, _dir);
    if (_ok == false) return false;

    // Cast feedback: a flash at the staff in the spell's color, and a little recoil
    var _col = global.element_color[_def.element];
    var _sx = _caster.x + lengthdir_x(8, _dir);
    var _sy = _caster.y - 10 + lengthdir_y(8, _dir);
    fx_burst(_sx, _sy, _col, 4);
    var _flash = instance_create_depth(_sx, _sy + 6, -_caster.y - 20, obj_fx_ring);
    _flash.r = 1; _flash.r_max = 7; _flash.life_max = 6; _flash.life = 6; _flash.color = _col;
    if (_s.id != "frost_nova" && _s.id != "wisp" && _s.id != "blink" && _caster.state != PSTATE.DASH) {
        var _k = clamp(_def.cooldown * 0.6, 0.25, 1.5);     // bigger spells kick harder
        _caster.hsp -= lengthdir_x(_k, _dir);
        _caster.vsp -= lengthdir_y(_k, _dir);
    }

    _s.cd = round(spell_cooldown(_def, _s.tier) * 60 * _caster.cd_mult);
    return true;
}

/// @func projectile_spawn(x, y, dir, config)
/// x/y are the GROUND position (feet level); projectiles draw z pixels above it.
/// Any field in config overrides obj_projectile's defaults.
function projectile_spawn(_x, _y, _dir, _cfg) {
    var _p = instance_create_depth(_x, _y, -_y, obj_projectile);
    var _keys = variable_struct_get_names(_cfg);
    for (var i = 0; i < array_length(_keys); i++) {
        variable_instance_set(_p, _keys[i], _cfg[$ _keys[i]]);
    }
    _p.dir = _dir;
    _p.hsp = lengthdir_x(_p.spd, _dir);
    _p.vsp = lengthdir_y(_p.spd, _dir);
    return _p;
}

/// @func enemy_nearest(x, y, range, exclude_array)
/// Nearest living enemy within range (ground plane), skipping ids in exclude.
function enemy_nearest(_x, _y, _range, _exclude) {
    var _best = noone;
    var _bd   = _range;
    with (obj_enemy) {
        if (hp > 0 && !array_contains(_exclude, id)) {
            var _d = point_distance(x, y, _x, _y);
            if (_d < _bd) { _bd = _d; _best = id; }
        }
    }
    return _best;
}

/// @func spell_explode(x, y, radius, dmg, element, knock, colour, [vfx])
/// Area damage + knockback away from the center. vfx: true draws the matching
/// effect (Burn: pixelfx explosion, Freeze: pixelfx frost nova, else a ring);
/// false when the caller draws its own (Meteor).
function spell_explode(_x, _y, _r, _dmg, _el, _knock, _col, _vfx = true) {
    _r *= global.run.area_mult;    // Big Magic passive
    with (obj_enemy) {
        if (hp > 0 && point_distance(x, y, _x, _y) < _r + hurt_r) {
            var _d = point_direction(_x, _y, x, y);
            take_hit(_dmg, lengthdir_x(_knock, _d), lengthdir_y(_knock, _d), _el);
        }
    }
    if (_vfx) {
        switch (_el) {
            case ELEMENT.BURN:      // pixelfx Explosion, drawn for a 26 px blast
                fx_anim(spr_fx_blast_s, _x, _y, clamp(_r / 26, 0.75, 1.75));
                break;
            case ELEMENT.FREEZE:    // pixelfx Frost Nova, drawn for a 42 px ring
                fx_anim(spr_fx_nova, _x, _y, clamp(_r / 42, 0.75, 1.75));
                break;
            default:
                var _ring = instance_create_depth(_x, _y, -_y - 2, obj_fx_ring);
                _ring.r_max = _r;
                _ring.color = _col;
                fx_burst(_x, _y - 6, _col, 18);
                break;
        }
        fx_burst(_x, _y - 6, c_white, 6);
    }
    shake(3);
    hitstop(2);
}

/// @func spell_cooldown(def, tier)
/// Cooldown in seconds; spells with cd_tiers get faster per tier (Blink).
function spell_cooldown(_def, _tier) {
    if (variable_struct_exists(_def, "cd_tiers")) return _def.cd_tiers[clamp(_tier, 1, 3) - 1];
    return _def.cooldown;
}

/// @func meteor_drop(x, y, radius, delay_frames)
/// Telegraphed meteor: shadow grows for 0.6 s (+delay), then a huge burning blast.
function meteor_drop(_x, _y, _r, _delay) {
    var _m = instance_create_depth(_x, _y, -_y, obj_meteor);
    _m.r     = _r;
    _m.fall  = 36 + _delay;
    _m.fall_max = _m.fall;
    return _m;
}
