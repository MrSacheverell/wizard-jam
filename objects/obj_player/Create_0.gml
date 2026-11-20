/// obj_player — Create
// Sprite: spr_player, origin at the FEET (bottom-center).
// Collision mask: small rectangle around the feet only (see SETUP.md).

// ---- Movement ----
hsp = 0;
vsp = 0;
move_speed = 1.6;    // px/frame at 60 fps
accel      = 0.35;   // speeding up
fric       = 0.30;   // slowing down when no input

// ---- Dash ----
dash_speed    = 4.5;
dash_time     = 9;     // frames the dash lasts
dash_cooldown = 36;    // frames before you can dash again (0.6 s)
dash_timer    = 0;
dash_cd_timer = 0;
dash_buffer   = 0;     // > 0 means a dash press is waiting to fire
DASH_BUFFER   = 6;     // frames a press stays buffered
dash_dx       = 0;
dash_dy       = 0;

// ---- Health ----
max_hp     = 5;
hp         = max_hp;
iframes    = 0;
hurt_time  = 12;       // frames of hurt stun
hurt_timer = 0;
hurt_iframes = 45;     // invulnerability after a hit

// ---- State / look ----
state  = PSTATE.IDLE;
facing = 1;            // 1 = right, -1 = left (follows the mouse)

// ---- Spells (filled in when the spell system lands) ----
// Each slot: { id: "magic_bolt", cd: 0 }  or undefined
slots = array_create(4, undefined);

// ---- Input (captured in Begin Step so it works through hitstop) ----
in_x = 0;
in_y = 0;

/// Take a hit. Returns true if it landed.
take_damage = function(_dmg, _from_x, _from_y) {
    if (iframes > 0 || state == PSTATE.DEAD) return false;

    hp -= _dmg;
    global.run.hp = max(0, hp);
    with (obj_game) hurt_flash = 1;
    var _dir = point_direction(_from_x, _from_y, x, y);
    hsp = lengthdir_x(3, _dir);
    vsp = lengthdir_y(3, _dir);

    hitstop(4);
    shake(4);

    if (hp <= 0) {
        sfx(snd_death, 0);
        hp = 0;
        state = PSTATE.DEAD;
        hsp = 0;
        vsp = 0;
        with (obj_game) on_player_death();
    } else {
        sfx(snd_hurt, 0.05);
        state = PSTATE.HURT;
        hurt_timer = hurt_time;
        iframes = hurt_iframes;
    }
    return true;
};

// ---- Spell casting ----
// Slot 0 = left mouse (hold to auto-cast), 1 = right mouse, 2 = Q, 3 = E, 4 = R, 5 = F
slots       = global.run.slots;     // shared with the run, so upgrades apply live
cast_buffer = array_create(MAX_SLOTS, 0);   // buffered presses, same idea as dash_buffer
CAST_BUFFER = 6;
cast_held   = false;                // left mouse held
cd_mult     = global.run.cd_mult;   // passives like -10% cooldowns change this

// ---- Run stats (HP carries between rooms) ----
max_hp = global.run.max_hp;
hp     = global.run.hp;
