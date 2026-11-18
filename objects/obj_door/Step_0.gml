/// obj_door — Step
if (game_frozen() || obj_game.run_over) exit;
glow += 0.08;

if (is_open && instance_exists(obj_player) && obj_player.state != PSTATE.DEAD) {
    var _p = obj_player;
    if (_p.y < y + 40 && abs(_p.x - (x + 16)) < 16) {
        room_advance();
    }
}
