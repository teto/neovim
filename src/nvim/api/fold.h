#pragma once

#include <stdbool.h>

#include "nvim/api/private/defs.h"
#include "nvim/pos_defs.h"

// API functions for fold operations
bool nvim_create_fold(linenr_T start_line, linenr_T end_line, bool recursive);
bool nvim_delete_fold(linenr_T start_line, linenr_T end_line, bool recursive);