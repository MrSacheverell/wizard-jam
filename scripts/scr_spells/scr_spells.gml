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
        cast: function(_caster, _tier, _dir) {
            projectile_spawn(_caster.x, _caster.y, _dir, {
                spd:    6,
                dmg:    1,
                life:   45,
                radius: 3,
                knock:  1.6,
                size:   2,
                element: ELEMENT.NONE,
                color:  global.element_color[ELEMENT.NONE],
                pierce: (_tier >= 2) ? 1 : 0,   // tier 2: pierce 1 (tier 3 split comes later)
            });
        },
    },

    fireball: {
        name:     "Fireball",
        short:    "FB",
        element:  ELEMENT.BURN,
        cooldown: 1.2,
        cast: function(_caster, _tier, _dir) {
            projectile_spawn(_caster.x, _caster.y, _dir, {
                spd:       3.5,
                dmg:       2,          // explosion damage (direct hit = explosion)
                life:      60,         // explodes where it fizzles, too
                radius:    4,
                knock:     2.5,
                size:      4,
                element:   ELEMENT.BURN,
                color:     global.element_color[ELEMENT.BURN],
                explode_r: (_tier >= 2) ? 34 : 26,   // tier 2: bigger blast (tier 3 burning ground later)
            });
        },
    },

    chain_lightning: {
        name:     "Chain Lightning",
        short:    "CL",
        element:  ELEMENT.SHOCK,
        cooldown: 2.0,
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
                fx_burst(_nx, _ny - 8 - _nz, _col, 5);

                _cur = enemy_nearest(_nx, _ny, 72, _hit);
            }

            var _l = instance_create_depth(0, 0, -99999, obj_lightning);
            _l.points = _pts;
            _l.color  = _col;
            shake(2);
            hitstop(2);
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

    _s.cd = round(_def.cooldown * 60 * _caster.cd_mult);
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

/// @func spell_explode(x, y, radius, dmg, element, knock, colour)
/// Area damage + knockback away from the center, with ring and sparks.
function spell_explode(_x, _y, _r, _dmg, _el, _knock, _col) {
    with (obj_enemy) {
        if (hp > 0 && point_distance(x, y, _x, _y) < _r + hurt_r) {
            var _d = point_direction(_x, _y, x, y);
            take_hit(_dmg, lengthdir_x(_knock, _d), lengthdir_y(_knock, _d), _el);
        }
    }
    var _ring = instance_create_depth(_x, _y, -_y - 2, obj_fx_ring);
    _ring.r_max = _r;
    _ring.color = _col;
    fx_burst(_x, _y - 6, _col, 18);
    fx_burst(_x, _y - 6, c_white, 6);
    shake(3);
    hitstop(2);
}
