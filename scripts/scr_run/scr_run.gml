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

/// @func run_new()
/// Fresh run state. Starts with Magic Bolt + 1 random spell (design doc).
function run_new() {
    var _second = choose("fireball", "chain_lightning", "frost_nova");
    return {
        act:   1,
        room:  1,
        phase: "fight",           // fight / cleared / pick / door
        layout: -1,
        last_layout: -1,

        hp: 5,
        max_hp: 5,
        slots: [
            { id: "magic_bolt", tier: 1, cd: 0 },
            { id: _second,      tier: 1, cd: 0 },
            undefined,
            undefined,
        ],

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

    // Layout
    var _walls = global.arena_layouts[_r.layout].walls;
    for (var i = 0; i < array_length(_walls); i++) {
        var _b = _walls[i];
        dev_wall(_b[0], _b[1], _b[2], _b[3]);
    }

    // Door (locked: it places its own blocker in the gap)
    instance_create_layer(_gx, 0, "Instances", obj_door);

    // Player
    instance_create_layer(ARENA_SPAWN_X, ARENA_SPAWN_Y, "Instances", obj_player);

    // Enemies
    var _elite = (_r.room == ROOMS_PER_ACT);
    var _count = 4 + _r.act * 2 + _r.room + (_elite ? 4 : 0);
    run_spawn_wave(_count);

    _r.phase = "fight";
    var _label = "ACT " + string(_r.act) + "  -  " + (_elite ? "ELITE ROOM" : "ROOM " + string(_r.room));
    with (obj_game) banner_show(_label);
}

/// @func run_spawn_wave(count)
/// Spawns enemies on free floor away from the player, scaled by act.
function run_spawn_wave(_count) {
    var _act = global.run.act;
    var _bat_chance = 0.1 + 0.12 * _act;           // more Bats in later acts
    var _hp_mult    = 1 + 0.35 * (_act - 1);       // tougher in later acts

    var _made = 0, _tries = 0;
    while (_made < _count && _tries < 300) {
        _tries++;
        var _x = random_range(40, room_width - 40);
        var _y = random_range(64, room_height - 40);
        if (point_distance(_x, _y, ARENA_SPAWN_X, ARENA_SPAWN_Y) < 150) continue;
        if (collision_rectangle(_x - 10, _y - 10, _x + 10, _y + 6, obj_wall, false, true) != noone) continue;

        var _e = instance_create_layer(_x, _y, "Instances", (random(1) < _bat_chance) ? obj_bat : obj_shambler);
        _e.max_hp = round(_e.max_hp * _hp_mult);
        _e.hp     = _e.max_hp;
        _made++;
    }
}

/// @func run_update()
/// Room flow, called from obj_game Step while playing an arena.
function run_update() {
    var _r = global.run;
    switch (_r.phase) {

        case "fight":
            if (!instance_exists(obj_enemy)) {
                _r.rooms_cleared++;
                if (_r.heal_on_clear > 0) {
                    _r.hp = min(_r.max_hp, _r.hp + _r.heal_on_clear);
                    player_sync();
                }
                banner_show("ROOM CLEAR");
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
