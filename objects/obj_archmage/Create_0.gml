/// obj_archmage — Create   (parent: obj_enemy)
// The final boss (act 3, room 4). Three phases by HP:
//   1 (100-66%): Fire     - fireball volleys, meteor rain, teleports
//   2 ( 66-33%): + Frost/Lightning - frost rings to dash through, lightning lines
//   3 ( 33-0% ): Everything, faster and bigger
// Each phase change: teleport to the center, shockwave, summon adds.
// Freeze only slows it (no stun-lock), but every reaction works on it,
// so Shatter / Superconduct / Overload are how you burst it down.
event_inherited();

max_hp       = 150;
hp           = max_hp;
move_speed   = 0.45;
contact_dmg  = 1;
hurt_r       = 10;
knock_resist = 0.95;
death_color  = make_color_rgb(255, 200, 90);
is_boss      = true;
z            = 4;          // floats slightly
spawn_t      = 70;         // dramatic entrance

phase      = 1;
enum ARCH { IDLE, CAST, RECOVER, TRANSITION }
astate     = ARCH.IDLE;
atimer     = 60;           // frames until the next attack
attack     = "";
cast_t     = 0;
last_attack = "";
wander_dir = random(360);

var _c = global.element_color;
col_fire  = _c[ELEMENT.BURN];
col_frost = _c[ELEMENT.FREEZE];
col_shock = _c[ELEMENT.SHOCK];

/// Attacks available in each phase
attacks_for_phase = function(_ph) {
    switch (_ph) {
        case 1:  return ["volley", "meteors", "volley", "teleport"];
        case 2:  return ["volley", "meteors", "ring", "beams", "teleport"];
        default: return ["volley", "meteors", "ring", "beams", "ring_volley", "teleport"];
    }
};

/// Teleport to a spot 90-170 px from the player (or the given point)
arch_teleport = function(_tx = undefined, _ty = undefined) {
    var _ox = x, _oy = y;
    if (!is_undefined(_tx)) {
        x = _tx; y = _ty;
    } else if (instance_exists(obj_player)) {
        var _p = obj_player;
        repeat (40) {
            var _a = random(360), _d = random_range(90, 170);
            var _nx = _p.x + lengthdir_x(_d, _a), _ny = _p.y + lengthdir_y(_d, _a);
            if (_nx < 48 || _nx > room_width - 48 || _ny < 64 || _ny > room_height - 40) continue;
            if (collision_rectangle(_nx - 12, _ny - 10, _nx + 12, _ny + 4, obj_wall, false, true) != noone) continue;
            x = _nx; y = _ny;
            break;
        }
    }
    fx_anim(spr_fx_blink_out, _ox, _oy);
    fx_anim(spr_fx_blink_in, x, y);
    sfx(snd_cast_blink, 0.05, 0.8);
};

/// Start an attack: sets the cast (wind-up) time
begin_attack = function(_name) {
    attack = _name;
    last_attack = _name;
    astate = ARCH.CAST;
    var _fast = (phase == 3) ? 0.7 : 1;
    switch (_name) {
        case "volley":      cast_t = round(30 * _fast); break;
        case "meteors":     cast_t = round(24 * _fast); break;
        case "ring":        cast_t = round(36 * _fast); break;
        case "beams":       cast_t = round(20 * _fast); break;
        case "ring_volley": cast_t = round(40 * _fast); break;
        case "teleport":    cast_t = 14; break;
    }
};

/// Release the attack (end of wind-up)
release_attack = function() {
    var _p = obj_player;
    var _dir = point_direction(x, y, _p.x, _p.y);
    switch (attack) {
        case "volley":
            sfx(snd_cast_fire, 0.08, 0.8);
            var _n = (phase == 3) ? 7 : 5;
            for (var i = 0; i < _n; i++) {
                enemy_shot_bolt(x, y, _dir + (i - (_n - 1) / 2) * 13, 2.6, col_fire);
            }
            break;

        case "meteors":
            sfx(snd_cast_meteor, 0.08, 0.8);
            var _m = (phase == 1) ? 3 : ((phase == 2) ? 4 : 5);
            enemy_shot_zone(_p.x, _p.y, 24, 54, col_fire);        // one always on you
            repeat (_m - 1) {
                enemy_shot_zone(_p.x + random_range(-70, 70), _p.y + random_range(-50, 50), 22, irandom_range(48, 70), col_fire);
            }
            break;

        case "ring":
            sfx(snd_cast_frost, 0.05, 0.9);
            enemy_shot_ring(x, y, (phase == 3) ? 2.0 : 1.65, 190, col_frost);
            break;

        case "beams":
            var _k = (phase == 3) ? 7 : 5;
            var _off = random(360);
            for (var i = 0; i < _k; i++) {
                enemy_shot_beam(x, y - 6, _off + i * (360 / _k), 260, (phase == 3) ? 48 : 56, col_shock);
            }
            break;

        case "ring_volley":
            sfx(snd_cast_frost, 0.05, 0.9);
            sfx(snd_cast_fire, 0.08, 0.7);
            enemy_shot_ring(x, y, 1.6, 190, col_frost);
            for (var i = 0; i < 12; i++) enemy_shot_bolt(x, y, i * 30, 1.8, col_fire);
            break;

        case "teleport":
            arch_teleport();
            break;
    }
    shake(2);
};

/// Phase change: center, shockwave, summon adds
enter_phase = function(_ph) {
    phase  = _ph;
    astate = ARCH.TRANSITION;
    atimer = 80;
    flash  = 10;
    arch_teleport(room_width / 2, room_height / 2 - 40);
    var _wave = enemy_shot_ring(x, y, 3, 220, (_ph == 2) ? col_frost : col_shock);
    _wave.dmg = 0;                                   // the phase shockwave is just a cue
    // Two hearts to keep the fight going
    heart_drop(x - 40, y + 30);
    heart_drop(x + 40, y + 30);
    banner_show("THE ARCHMAGE: PHASE " + string(_ph));
    fx_text(x, y - 40, (_ph == 2) ? "FROST AND STORM!" : "ALL THE ELEMENTS!", c_white);
    hitstop(6);
    shake(6);
    screen_flash(0.6);
    sfx(snd_boss_phase, 0, 1);
    // Adds
    var _adds = (_ph == 2) ? [obj_shambler, obj_shambler] : [obj_bat, obj_hexer, obj_bomber, obj_shambler];
    var _mult = (_ph == 2) ? 1 : 1.5;
    for (var i = 0; i < array_length(_adds); i++) {
        var _a = i * (360 / array_length(_adds)) + 45;
        var _e = instance_create_layer(x + lengthdir_x(90, _a), clamp(y + lengthdir_y(70, _a), 64, room_height - 40), "Instances", _adds[i]);
        _e.max_hp = round(_e.max_hp * _mult);
        _e.hp = _e.max_hp;
    }
};

ai_step = function() {
    if (!instance_exists(obj_player) || obj_player.state == PSTATE.DEAD) return;
    var _p = obj_player;
    facing = (_p.x >= x) ? 1 : -1;

    // Phase thresholds
    if (phase == 1 && hp <= max_hp * 0.66) { enter_phase(2); return; }
    if (phase == 2 && hp <= max_hp * 0.33) { enter_phase(3); return; }

    switch (astate) {
        case ARCH.TRANSITION:
            tint = merge_color(c_white, death_color, 0.5 + 0.5 * sin(atimer / 3));
            atimer--;
            if (atimer <= 0) { tint = c_white; astate = ARCH.IDLE; atimer = 30; }
            break;

        case ARCH.IDLE:
            // Drift slowly, keeping some distance
            var _d = point_distance(x, y, _p.x, _p.y);
            var _toward = point_direction(x, y, _p.x, _p.y);
            if (random(1) < 0.02) wander_dir = _toward + choose(-90, 90);
            var _fwd = (_d > 140) ? move_speed : ((_d < 80) ? -move_speed : 0);
            hsp = lengthdir_x(_fwd, _toward) + lengthdir_x(move_speed * 0.6, wander_dir);
            vsp = lengthdir_y(_fwd, _toward) + lengthdir_y(move_speed * 0.6, wander_dir);
            atimer--;
            if (atimer <= 0) {
                var _list = attacks_for_phase(phase);
                var _pick = _list[irandom(array_length(_list) - 1)];
                if (_pick == last_attack) _pick = _list[irandom(array_length(_list) - 1)];   // avoid repeats
                begin_attack(_pick);
            }
            break;

        case ARCH.CAST:
            // Wind-up: glow in the attack's element color and stand still
            var _col = (attack == "ring" || attack == "ring_volley") ? col_frost
                     : ((attack == "beams") ? col_shock : ((attack == "teleport") ? c_white : col_fire));
            tint = merge_color(c_white, _col, 0.5 + 0.5 * sin(cast_t / 2));
            if (cast_t mod 5 == 0) fx_burst(x + facing * 6, y - 26, _col, 2);
            cast_t--;
            if (cast_t <= 0) {
                tint = c_white;
                release_attack();
                astate = ARCH.RECOVER;
                atimer = (phase == 1) ? 45 : ((phase == 2) ? 60 : 35);
            }
            break;

        case ARCH.RECOVER:
            atimer--;
            if (atimer <= 0) {
                astate = ARCH.IDLE;
                atimer = (phase == 1) ? irandom_range(40, 70) : ((phase == 2) ? irandom_range(50, 80) : irandom_range(25, 45));
            }
            break;
    }
};

// Dying ends the fight: everything else in the room goes with it
on_death = function() {
    with (obj_enemy) if (id != other.id && hp > 0) die();
    with (obj_enemy_shot) instance_destroy();
    fx_anim(spr_fx_blast_l, x, y, 1.5);
    fx_text(x, y - 40, "THE ARCHMAGE FALLS", death_color);
    hitstop(12);
    shake(10);
    screen_flash(0.9);
    sfx(snd_explode_big, 0, 1);
    sfx(snd_boss_phase, 0, 0.6);
};
