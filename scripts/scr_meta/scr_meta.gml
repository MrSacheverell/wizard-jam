// =====================================================================
// scr_meta — meta progression: Essence, permanent upgrades, unlocks, saving.
//
// Essence is earned every run (even on death) and banked when the run ends.
// Spend it in the title screen's Upgrades menu on:
//   Vitality      +1 max HP per level (3 levels)
//   Spell unlocks  runs start with Bolt, Fireball, Chain Lightning, Frost Nova;
//                  the other 4 must be unlocked to show up in upgrade picks
//   Staves         starting loadouts; each makes its element last 50% longer
//
// Saved with ini_ functions: a file on desktop, localStorage in the browser.
// =====================================================================

#macro SAVE_FILE "arcane_overload.ini"

global.meta_shop = {
    hp_costs: [30, 60, 100],
    spells: [
        { sid: "arcane_disc", cost: 40 },
        { sid: "blink",       cost: 50 },
        { sid: "meteor",      cost: 60 },
        { sid: "wisp",        cost: 70 },
    ],
    staves: [
        { sid: "apprentice", name: "Apprentice Staff", spell: "",                el: ELEMENT.NONE,   cost: 0,
          desc: "Magic Bolt plus a random unlocked spell." },
        { sid: "fire",       name: "Fire Staff",       spell: "fireball",        el: ELEMENT.BURN,   cost: 50,
          desc: "Start with Fireball. Burn lasts 50% longer." },
        { sid: "storm",      name: "Storm Staff",      spell: "chain_lightning", el: ELEMENT.SHOCK,  cost: 50,
          desc: "Start with Chain Lightning. Shock lasts 50% longer." },
        { sid: "frost",      name: "Frost Staff",      spell: "frost_nova",      el: ELEMENT.FREEZE, cost: 50,
          desc: "Start with Frost Nova. Freeze lasts 50% longer." },
    ],
};

/// @func meta_default()
function meta_default() {
    return {
        essence:    0,
        hp_lvl:     0,
        wins:       0,
        best_rooms: 0,
        staff:      "apprentice",
        unlocked:   { magic_bolt: true, fireball: true, chain_lightning: true, frost_nova: true },
        staves:     { apprentice: true },
    };
}

/// @func save_load()
function save_load() {
    global.meta = meta_default();
    var _m = global.meta;
    ini_open(SAVE_FILE);
    _m.essence    = ini_read_real("meta", "essence", 0);
    _m.hp_lvl     = ini_read_real("meta", "hp_lvl", 0);
    _m.wins       = ini_read_real("meta", "wins", 0);
    _m.best_rooms = ini_read_real("meta", "best_rooms", 0);
    _m.staff      = ini_read_string("meta", "staff", "apprentice");
    var _u = string_split(ini_read_string("meta", "unlocked", ""), ",", true);
    for (var i = 0; i < array_length(_u); i++) _m.unlocked[$ _u[i]] = true;
    var _s = string_split(ini_read_string("meta", "staves", ""), ",", true);
    for (var i = 0; i < array_length(_s); i++) _m.staves[$ _s[i]] = true;
    ini_close();
    if (!(_m.staves[$ _m.staff] ?? false)) _m.staff = "apprentice";
}

/// @func save_write()
function save_write() {
    var _m = global.meta;
    ini_open(SAVE_FILE);
    ini_write_real("meta", "essence", _m.essence);
    ini_write_real("meta", "hp_lvl", _m.hp_lvl);
    ini_write_real("meta", "wins", _m.wins);
    ini_write_real("meta", "best_rooms", _m.best_rooms);
    ini_write_string("meta", "staff", _m.staff);
    ini_write_string("meta", "unlocked", string_join_ext(",", variable_struct_get_names(_m.unlocked)));
    ini_write_string("meta", "staves", string_join_ext(",", variable_struct_get_names(_m.staves)));
    ini_close();
}

/// @func meta_spell_unlocked(spell_id)
function meta_spell_unlocked(_sid) {
    return global.meta.unlocked[$ _sid] ?? false;
}

/// @func meta_staff_def(staff_id)
function meta_staff_def(_sid) {
    var _list = global.meta_shop.staves;
    for (var i = 0; i < array_length(_list); i++) if (_list[i].sid == _sid) return _list[i];
    return _list[0];
}

/// @func run_bank_essence()
/// Adds this run's Essence to the save. Safe to call more than once per run.
function run_bank_essence() {
    var _r = global.run;
    if (_r.banked) return;
    var _bonus = 0;
    if (!_r.won && instance_exists(obj_archmage)) {
        _bonus = floor(20 * (1 - obj_archmage.hp / obj_archmage.max_hp));   // partial credit for boss damage
    }
    _r.essence_final = _r.essence + _bonus;
    _r.banked = true;
    var _m = global.meta;
    _m.essence   += _r.essence_final;
    _m.best_rooms = max(_m.best_rooms, _r.rooms_cleared);
    if (_r.won) _m.wins++;
    save_write();
}

// ---------------------------------------------------------------------
// Upgrades menu (title screen). Uses scr_menu with kind "meta".
// Item actions are bound to small structs, so they call into obj_game with with().
// ---------------------------------------------------------------------

function meta_message(_text) {
    with (obj_game) { meta_msg = _text; meta_msg_t = 120; }
}

function meta_refresh_menu() {
    with (obj_game) {
        var _sel = menu_sel;
        menu_items = meta_menu_items();
        menu_sel = min(_sel, array_length(menu_items) - 1);
    }
}

function meta_spend(_cost) {
    if (global.meta.essence < _cost) {
        meta_message("Not enough Essence (need " + string(_cost) + ")");
        return false;
    }
    global.meta.essence -= _cost;
    return true;
}

function meta_buy_hp() {
    var _m = global.meta;
    if (_m.hp_lvl >= 3) return;
    if (!meta_spend(global.meta_shop.hp_costs[_m.hp_lvl])) return;
    _m.hp_lvl++;
    save_write();
    meta_message("Vitality " + string(_m.hp_lvl) + "/3: you now start with " + string(5 + _m.hp_lvl) + " HP");
    meta_refresh_menu();
}

function meta_buy_spell(_sid, _cost) {
    if (meta_spell_unlocked(_sid)) return;
    if (!meta_spend(_cost)) return;
    global.meta.unlocked[$ _sid] = true;
    save_write();
    meta_message(spell_get(_sid).name + " unlocked: it can now appear in runs");
    meta_refresh_menu();
}

function meta_buy_staff(_sid, _cost) {
    var _m = global.meta;
    if (!(_m.staves[$ _sid] ?? false)) {
        if (!meta_spend(_cost)) return;
        _m.staves[$ _sid] = true;
    }
    _m.staff = _sid;
    save_write();
    meta_message(meta_staff_def(_sid).name + " equipped");
    meta_refresh_menu();
}

/// @func meta_menu_items()
function meta_menu_items() {
    var _m = global.meta, _shop = global.meta_shop;
    var _items = [];

    // Vitality
    if (_m.hp_lvl < 3) {
        var _c = _shop.hp_costs[_m.hp_lvl];
        array_push(_items, { label: "Vitality " + string(_m.hp_lvl + 1) + "/3   " + string(_c) + " E",
            desc: "+1 max HP in every run (" + string(5 + _m.hp_lvl) + " -> " + string(6 + _m.hp_lvl) + ").",
            action: function() { meta_buy_hp(); } });
    } else {
        array_push(_items, { label: "Vitality 3/3   maxed", desc: "You start every run with 8 HP.", action: function() {} });
    }

    // Spell unlocks
    for (var i = 0; i < array_length(_shop.spells); i++) {
        var _e = _shop.spells[i];
        var _d = spell_get(_e.sid);
        if (meta_spell_unlocked(_e.sid)) {
            array_push(_items, { label: _d.name + "   unlocked", desc: _d.desc, action: function() {} });
        } else {
            array_push(_items, { label: "Unlock " + _d.name + "   " + string(_e.cost) + " E", desc: _d.desc,
                action: method({ sid: _e.sid, cost: _e.cost }, function() { meta_buy_spell(sid, cost); }) });
        }
    }

    // Staves
    for (var i = 0; i < array_length(_shop.staves); i++) {
        var _s = _shop.staves[i];
        var _own = _m.staves[$ _s.sid] ?? false;
        var _label = (_m.staff == _s.sid) ? _s.name + "   equipped"
                   : (_own ? "Equip " + _s.name : _s.name + "   " + string(_s.cost) + " E");
        array_push(_items, { label: _label, desc: _s.desc,
            action: method({ sid: _s.sid, cost: _s.cost }, function() { meta_buy_staff(sid, cost); }) });
    }

    array_push(_items, { label: "Back", desc: "", action: function() { with (obj_game) menu_open(menu_title_items(), "title"); } });
    return _items;
}
