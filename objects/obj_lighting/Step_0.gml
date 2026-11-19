/// obj_lighting — Step
// Screen flashes fade quickly (not frozen by hitstop: the flash reads during it)
global.flash_amount *= 0.86;
if (global.flash_amount < 0.01) global.flash_amount = 0;
