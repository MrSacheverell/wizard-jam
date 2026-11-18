/// obj_player — Begin Step
// Input is read here, NOT frozen by hitstop, so presses during a freeze
// still count. Movement itself happens in Step (which is frozen).

if (global.paused) exit;

in_x = keyboard_check(ord("D")) - keyboard_check(ord("A"));
in_y = keyboard_check(ord("S")) - keyboard_check(ord("W"));

// Normalize so diagonals aren't ~41% faster
if (in_x != 0 && in_y != 0) {
    in_x *= 0.7071;
    in_y *= 0.7071;
}

if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_shift)) {
    dash_buffer = DASH_BUFFER;
}

// Spells: left mouse auto-casts while held; other slots buffer their press
cast_held = mouse_check_button(mb_left);
if (mouse_check_button_pressed(mb_left))  cast_buffer[0] = CAST_BUFFER;
if (mouse_check_button_pressed(mb_right)) cast_buffer[1] = CAST_BUFFER;
if (keyboard_check_pressed(ord("Q")))     cast_buffer[2] = CAST_BUFFER;
if (keyboard_check_pressed(ord("E")))     cast_buffer[3] = CAST_BUFFER;
if (keyboard_check_pressed(ord("R")))     cast_buffer[4] = CAST_BUFFER;   // locked slots are simply empty
if (keyboard_check_pressed(ord("F")))     cast_buffer[5] = CAST_BUFFER;
