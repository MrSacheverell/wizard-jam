// =====================================================================
// scr_audio — sound effects. Every SFX goes through sfx(), which:
//   - scales by the SFX volume setting (pause/title menu, saved in the ini)
//   - nudges the pitch a little each time, so repeats don't sound robotic
//   - skips a sound if the same one started under 40 ms ago (no 12x stacking)
// Music is separate: use global.music_volume for it when it goes in.
// =====================================================================

global.sfx_volume   = 0.8;      // overwritten by save_load()
global.music_volume = 0.7;
global.sfx_recent   = {};       // sound name -> current_time of last play

audio_channel_num(48);

// Cast sound per spell id
global.spell_sounds = {
    magic_bolt:      { snd: snd_cast_bolt,      gain: 0.55 },
    fireball:        { snd: snd_cast_fire,      gain: 0.9  },
    chain_lightning: { snd: snd_cast_lightning, gain: 0.9  },
    frost_nova:      { snd: snd_cast_frost,     gain: 1    },
    arcane_disc:     { snd: snd_cast_disc,      gain: 0.8  },
    meteor:          { snd: snd_cast_meteor,    gain: 0.9  },
    blink:           { snd: snd_cast_blink,     gain: 0.9  },
    wisp:            { snd: snd_cast_wisp,      gain: 0.8  },
};

/// @func sfx(sound, [pitch_var], [gain])
/// Plays a sound effect. pitch_var 0.1 = random pitch between 0.9 and 1.1.
function sfx(_snd, _pitch_var = 0.08, _gain = 1) {
    if (global.sfx_volume <= 0) return -1;
    var _key = audio_get_name(_snd);
    var _last = global.sfx_recent[$ _key] ?? -1000;
    if (current_time - _last < 40) return -1;
    global.sfx_recent[$ _key] = current_time;
    var _pitch = 1 + random_range(-_pitch_var, _pitch_var);
    return audio_play_sound(_snd, 0, false, _gain * global.sfx_volume, 0, _pitch);
}

/// @func spell_sfx(spell_id)
function spell_sfx(_sid) {
    var _e = global.spell_sounds[$ _sid];
    if (!is_undefined(_e)) sfx(_e.snd, 0.07, _e.gain);
}

/// @func sfx_cycle_volume()
/// Menu option: 100% -> 80 -> 60 -> 40 -> 20 -> off -> 100%. Saved right away.
function sfx_cycle_volume() {
    var _v = round(global.sfx_volume * 5) - 1;
    if (_v < 0) _v = 5;
    global.sfx_volume = _v / 5;
    save_write();
    sfx(snd_menu_select, 0);
}
