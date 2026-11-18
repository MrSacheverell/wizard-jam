/// obj_game — Post Draw
// Draw the 480x270 game surface scaled up and letterboxed.
draw_clear(c_black);
gpu_set_texfilter(false);      // crisp pixels
gpu_set_blendenable(false);    // surface is opaque; skip blending (cheaper)
draw_surface_ext(application_surface, off_x, off_y, scale, scale, 0, c_white, 1);
gpu_set_blendenable(true);
