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
