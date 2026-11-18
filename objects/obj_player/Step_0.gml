/// obj_player — Step
if (game_frozen()) exit;

// ---- Timers ----
if (dash_cd_timer > 0) dash_cd_timer--;
if (iframes > 0) iframes--;

// ---- State machine ----
switch (state) {

    case PSTATE.IDLE:
    case PSTATE.RUN:
        var _tx = in_x * move_speed;
        var _ty = in_y * move_speed;
        hsp = approach(hsp, _tx, (in_x != 0) ? accel : fric);
        vsp = approach(vsp, _ty, (in_y != 0) ? accel : fric);

        // Dash (buffered)
        if (dash_buffer > 0 && dash_cd_timer == 0) {
            // Dash toward input; if standing still, dash toward the mouse
            if (in_x != 0 || in_y != 0) {
                var _len = point_distance(0, 0, in_x, in_y);
                dash_dx = in_x / _len;
                dash_dy = in_y / _len;
            } else {
                var _d = point_direction(x, y, global.mouse_wx, global.mouse_wy);
                dash_dx = lengthdir_x(1, _d);
                dash_dy = lengthdir_y(1, _d);
            }
            state         = PSTATE.DASH;
            dash_timer    = dash_time;
            dash_cd_timer = dash_cooldown;
            dash_buffer   = 0;
            iframes       = max(iframes, dash_time + 2);
        } else {
            state = (abs(hsp) + abs(vsp) > 0.1) ? PSTATE.RUN : PSTATE.IDLE;
        }
        break;

    case PSTATE.DASH:
        hsp = dash_dx * dash_speed;
        vsp = dash_dy * dash_speed;
        dash_timer--;
        if (dash_timer <= 0) {
            // Carry a bit of momentum out of the dash so it doesn't stop dead
            hsp = dash_dx * move_speed;
            vsp = dash_dy * move_speed;
            state = PSTATE.RUN;
        }
        break;

    case PSTATE.HURT:
        hsp = approach(hsp, 0, 0.25);
        vsp = approach(vsp, 0, 0.25);
        hurt_timer--;
        if (hurt_timer <= 0) state = PSTATE.IDLE;
        break;

    case PSTATE.DEAD:
        hsp = 0;
        vsp = 0;
        break;
}

if (dash_buffer > 0) dash_buffer--;

// ---- Move + collide ----
move_collide();

// ---- Look & sort ----
if (state != PSTATE.DEAD) {
    facing = (global.mouse_wx >= x) ? 1 : -1;
}
depth = -y;
