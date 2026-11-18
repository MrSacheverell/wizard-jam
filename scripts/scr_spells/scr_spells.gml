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
//   name, element, cooldown (seconds), cast(caster, tier, dir)
// cast() receives the caster instance, the spell tier (1..3) and the aim
// direction in degrees, and spawns whatever the spell makes.
// ---------------------------------------------------------------------
global.spell_db = {

    magic_bolt: {
        name:     "Magic Bolt",
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

    // fireball, chain_lightning ... go here next
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
    _def.cast(_caster, _s.tier, _dir);
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
