// =====================================================================
// scr_run — run state, arena layouts and room flow.
//
// A run is 3 acts x 4 rooms. Each room: fight -> cleared -> pick upgrade
// -> door opens -> walk through -> next random arena. Room 4 of each act
// is the elite room (bigger wave, rare upgrade). Act 3 room 4 will become
// the Archmage boss; for now it's the final elite wave.
//
// All run state lives in global.run so it survives room changes; the
// player copies from it on Create and writes HP back every step.
// =====================================================================

#macro ACTS            3
#macro ROOMS_PER_ACT   4
#macro ARENA_DOOR_X    400   // center of the door gap in the top wall
#macro ARENA_SPAWN_X   400   // player start
#macro ARENA_SPAWN_Y   440
#macro MAX_SLOTS       6     // LMB, RMB, Q, E, R, F
#macro START_SLOTS     4     // R unlocks after the act 1 elite room, F after act 2

global.slot_keys = ["LMB", "RMB", "Q", "E", "R", "F"];

/// @func run_new()
/// Fresh run state. Starts with Magic Bolt + 1 random spell (design doc).
function run_new() {
    // Starting loadout comes from the equipped staff (scr_meta)
    var _staff = meta_staff_def(global.meta.staff);
    var _second = _staff.spell;
    if (_second == "") {
        var _pool = [];
        var _ids = variable_struct_get_names(global.spell_db);
        for (var i = 0; i < array_length(_ids); i++) {
            if (_ids[i] != "magic_bolt" && meta_spell_unlocked(_ids[i])) array_push(_pool, _ids[i]);
        }
        _second = _pool[irandom(array_length(_pool) - 1)];
    }
    var _el_dur = [1, 1, 1, 1];                    // per-element duration multiplier
    if (_staff.el != ELEMENT.NONE) _el_dur[_staff.el] = 1.5;
    var _hp = 5 + global.meta.hp_lvl;

    return {
        act:   1,
        room:  1,
        phase: "fight",           // fight / cleared / pick / door
        layout: -1,
        last_layout: -1,

        hp: _hp,
        max_hp: _hp,
        el_dur: _el_dur,
        essence: 0,               // earned this run; banked by run_bank_essence()
        essence_final: 0,
        banked: false,
        slots: [
            { id: "magic_bolt", tier: 1, cd: 0 },
            { id: _second,      tier: 1, cd: 0 },
            undefined,
            undefined,
            undefined,          // R: locked until the act 1 elite room is cleared
            undefined,          // F: locked until the act 2 elite room is cleared
        ],
        slot_count: START_SLOTS,

        // Passive effects (see scr_upgrades)
        cd_mult:       1,
        area_mult:     1,
        status_mult:   1,
        extra_proj:    0,
        heal_on_clear: 0,
        passives:      {},        // passive id -> stacks taken

        rooms_cleared: 0,
        won: false,
    };
}

// ---------------------------------------------------------------------
// Arena layouts. Inner walls only, as [x, y, w, h] in pixels (16px grid).
// The room is 800x480; the border, door and player spawn are added by
// arena_build(). Keep the spawn (bottom center) and door (top center) clear.
// These are data stand-ins until arenas are painted in the room editor.
// ---------------------------------------------------------------------
global.arena_layouts = [
    { name: "Pillars", walls: [
        [160, 112, 32, 32], [608, 112, 32, 32], [160, 336, 32, 32], [608, 336, 32, 32],
        [336, 208, 48, 16], [416, 208, 48, 16],
    ]},
    { name: "Crossroads", walls: [
        [240, 224, 96, 32], [464, 224, 96, 32],
        [384, 144, 32, 48], [384, 288, 32, 48],
    ]},
    { name: "Scattered", walls: [
        [128, 128, 32, 32], [304, 160, 32, 32], [464, 160, 32, 32], [640, 128, 32, 32],
        [208, 320, 32, 32], [560, 320, 32, 32], [384, 240, 32, 32],
    ]},
    { name: "Halls", walls: [
        [112, 176, 224, 16], [464, 176, 224, 16],
        [112, 320, 224, 16], [464, 320, 224, 16],
    ]},
    { name: "Ring", walls: [
        [288, 176, 80, 16], [432, 176, 80, 16],
        [288, 304, 80, 16], [432, 304, 80, 16],
        [288, 192, 16, 48], [496, 192, 16, 48],
        [288, 256, 16, 48], [496, 256, 16, 48],
    ]},
    { name: "Open", walls: [
        [96, 96, 32, 32], [672, 96, 32, 32], [96, 368, 32, 32], [672, 368, 32, 32],
    ]},
];

// The Archmage's sanctum: open floor, four pillars to hide behind
global.boss_layout = { name: "Sanctum", walls: [
    [176, 144, 32, 32], [592, 144, 32, 32], [176, 320, 32, 32], [592, 320, 32, 32],
]};

/// @func run_is_boss_room()
function run_is_boss_room() {
    return global.run.act == ACTS && global.run.room == ROOMS_PER_ACT;
}

/// @func run_pick_layout()
/// Random layout, never the same one twice in a row.
function run_pick_layout() {
    var _n = array_length(global.arena_layouts);
    var _l = irandom(_n - 1);
    if (_n > 1) while (_l == global.run.last_layout) _l = irandom(_n - 1);
    global.run.last_layout = _l;
    global.run.layout = _l;
}

/// @func arena_build()
/// Called from the arena room's creation code. Builds walls, door, player
/// and the room's enemy wave from global.run.
function arena_build() {
    var _r = global.run;
    if (_r.layout < 0) run_pick_layout();

    var _w = room_width, _h = room_height, _t = 16;
    var _gx = ARENA_DOOR_X - 16;          // door gap: 32px wide in the top wall

    // Border (top wall is 2 tiles tall, with the door gap)
    dev_wall(0, 0, _gx, _t * 2);
    dev_wall(_gx + 32, 0, _w - (_gx + 32), _t * 2);
    dev_wall(0, _h - _t, _w, _t);
    dev_wall(0, 0, _t, _h);
    dev_wall(_w - _t, 0, _t, _h);

    // Layout (the boss room always uses the sanctum)
    var _boss = run_is_boss_room();
    var _walls = _boss ? global.boss_layout.walls : global.arena_layouts[_r.layout].walls;
    for (var i = 0; i < array_length(_walls); i++) {
        var _b = _walls[i];
        dev_wall(_b[0], _b[1], _b[2], _b[3]);
    }

    // Door (locked: it places its own blocker in the gap)
    instance_create_layer(_gx, 0, "Instances", obj_door);

    // Player
    instance_create_layer(ARENA_SPAWN_X, ARENA_SPAWN_Y, "Instances", obj_player);

    // Boss room: just the Archmage
    if (_boss) {
        instance_create_layer(room_width / 2, 150, "Instances", obj_archmage);
        _r.hp = _r.max_hp;                 // the sanctum restores you before the fight
        player_sync();
        with (obj_player) fx_burst(x, y - 8, make_color_rgb(255, 90, 110), 16);
        _r.phase = "fight";
        with (obj_game) banner_show("ACT 3  -  THE ARCHMAGE");
        return;
    }

    // Enemies
    var _elite = (_r.room == ROOMS_PER_ACT);
    var _count = 4 + _r.act * 2 + _r.room + (_elite ? 4 : 0);
    // Elites: elite rooms get 1 + act of them; later acts sprinkle them elsewhere
    var _elites = _elite ? 1 + _r.act : ((_r.act >= 2 && random(1) < 0.25 * (_r.act - 1)) ? 1 : 0);
    run_spawn_wave(_count, _elites);

    _r.phase = "fight";
    var _label = "ACT " + string(_r.act) + "  -  " + (_elite ? "ELITE ROOM" : "ROOM " + string(_r.room));
    with (obj_game) banner_show(_label);
}

/// @func run_enemy_table(act)
/// Which enemies appear in each act, as [object, weight] pairs.
function run_enemy_table(_act) {
    switch (_act) {
        case 1:  return [[obj_shambler, 6], [obj_bat, 3], [obj_bomber, 1], [obj_archer, 1]];
        case 2:  return [[obj_shambler, 4], [obj_bat, 3], [obj_bomber, 2], [obj_archer, 2], [obj_brute, 1], [obj_hexer, 1]];
        default: return [[obj_shambler, 3], [obj_bat, 3], [obj_bomber, 2], [obj_archer, 2], [obj_brute, 2], [obj_hexer, 2]];
    }
}

/// @func weighted_pick(table)  -> the first element of a randomly chosen [value, weight] pair
function weighted_pick(_table) {
    var _total = 0;
    for (var i = 0; i < array_length(_table); i++) _total += _table[i][1];
    var _roll = random(_total);
    for (var i = 0; i < array_length(_table); i++) {
        _roll -= _table[i][1];
        if (_roll <= 0) return _table[i][0];
    }
    return _table[0][0];
}

/// @func run_spawn_wave(count, elites)
/// Spawns enemies on free floor away from the player, scaled by act.
/// The first `elites` of them get a random elite modifier.
function run_spawn_wave(_count, _elites = 0) {
    var _act     = global.run.act;
    var _table   = run_enemy_table(_act);
    var _hp_mult = 1 + 0.35 * (_act - 1);          // tougher in later acts

    var _made = 0, _tries = 0;
    while (_made < _count && _tries < 300) {
        _tries++;
        var _x = random_range(40, room_width - 40);
        var _y = random_range(64, room_height - 40);
        if (point_distance(_x, _y, ARENA_SPAWN_X, ARENA_SPAWN_Y) < 150) continue;
        if (collision_rectangle(_x - 10, _y - 10, _x + 10, _y + 6, obj_wall, false, true) != noone) continue;

        var _e = instance_create_layer(_x, _y, "Instances", weighted_pick(_table));
        _e.max_hp = round(_e.max_hp * _hp_mult);
        _e.hp     = _e.max_hp;
        if (_elites > 0) {
            _e.apply_elite(choose("fast", "armored", "splitting", "vampiric"));
            _elites--;
        }
        _made++;
    }
}

/// @func run_update()
/// Room flow, called from obj_game Step while playing an arena.
function run_update() {
    var _r = global.run;
    switch (_r.phase) {

        case "fight":
            if (!instance_exists(obj_enemy) && run_is_boss_room()) {
                // Boss down: victory after a moment to enjoy it
                _r.rooms_cleared++;
                _r.essence += 40;
                clear_timer = 150;
                _r.phase = "victory";
                break;
            }
            if (!instance_exists(obj_enemy)) {
                _r.rooms_cleared++;
                _r.essence += 2 + _r.act + ((_r.room == ROOMS_PER_ACT) ? 5 : 0);
                if (_r.heal_on_clear > 0) {
                    _r.hp = min(_r.max_hp, _r.hp + _r.heal_on_clear);
                    player_sync();
                }
                banner_show("ROOM CLEAR");
                // Elite rooms in acts 1 and 2 unlock a new spell slot (R, then F)
                if (_r.room == ROOMS_PER_ACT && _r.act < ACTS && _r.slot_count < MAX_SLOTS) {
                    _r.slot_count++;
                    banner_show("NEW SPELL SLOT: " + global.slot_keys[_r.slot_count - 1]);
                    fx_burst(obj_player.x, obj_player.y - 8, global.element_color[ELEMENT.NONE], 20);
                }
                clear_timer = 45;
                _r.phase = "cleared";
            }
            break;

        case "cleared":
            clear_timer--;
            if (clear_timer <= 0) {
                picker_open(_r.room == ROOMS_PER_ACT);   // elite room: rare picks
                _r.phase = "pick";
            }
            break;

        case "pick":
            picker_update();       // sets phase to "door" when done
            break;

        case "door":
            break;                 // obj_door calls room_advance() when entered

        case "victory":
            clear_timer--;
            if (clear_timer <= 0) {
                _r.won = true;
                run_over = true;
                run_bank_essence();
            }
            break;
    }
}

/// @func room_advance()
/// Next room / act, or victory after the last room of act 3.
function room_advance() {
    var _r = global.run;
    _r.room++;
    if (_r.room > ROOMS_PER_ACT) {
        _r.room = 1;
        _r.act++;
        if (_r.act > ACTS) {
            _r.act = ACTS;
            _r.room = ROOMS_PER_ACT;
            _r.won = true;
            with (obj_game) run_over = true;
            return;
        }
        // Between acts: the shop goes here (week 3)
    }
    run_pick_layout();
    room_restart();
}

/// @func banner_show(text)
/// Big centered message (room start, room clear) that fades out.
function banner_show(_text) {
    with (obj_game) {
        banner_text = _text;
        banner_t    = 110;
    }
}

/// @func heart_drop(x, y)
/// Drops a heart pickup (heals 1 HP) on free floor near (x, y).
function heart_drop(_x, _y) {
    _x = clamp(_x, 24, room_width - 24);
    _y = clamp(_y, 48, room_height - 24);
    return instance_create_layer(_x, _y, "Instances", obj_heart);
}
