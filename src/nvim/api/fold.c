// fold.c: API for fold operations

#include <stdbool.h>

#include "nvim/api/private/defs.h"
#include "nvim/api/private/helpers.h"
#include "nvim/buffer.h"
#include "nvim/cursor.h"
#include "nvim/fold.h"
#include "nvim/pos.h"
#include "nvim/window.h"

// nvim_create_fold() API implementation {{{1
/// Create a fold in the current window
///
/// @param start_line First line of the fold (1-indexed)
/// @param end_line Last line of the fold (1-indexed) 
/// @param recursive Whether to create nested folds recursively
/// @return true if fold was created successfully, false otherwise
bool nvim_create_fold(linenr_T start_line, linenr_T end_line, bool recursive) {
  win_T *win = curwin;
  if (!win) {
    api_set_error(err_api_invalid_window, "No current window");
    return false;
  }

  // Validate line numbers
  if (start_line < 1 || end_line < 1 || start_line > win->w_buffer->b_ml.ml_line_count
      || end_line > win->w_buffer->b_ml.ml_line_count) {
    api_set_error(err_api_invalid_argument, "Invalid line range");
    return false;
  }

  if (start_line > end_line) {
    // Swap if range is reversed
    linenr_T temp = start_line;
    start_line = end_line;
    end_line = temp;
  }

  // Check if fold creation is allowed with current foldmethod
  if (!foldManualAllowed(true)) {
    return false;  // Error message already set by foldManualAllowed
  }

  // Create the fold
  pos_T start_pos = {start_line, 0};
  pos_T end_pos = {end_line, 0};
  
  foldCreate(win, start_pos, end_pos);
  
  return true;
}

// nvim_delete_fold() API implementation {{{1
/// Delete folds in the current window
///
/// @param start_line First line of the range to delete folds from (1-indexed)
/// @param end_line Last line of the range to delete folds from (1-indexed)
/// @param recursive Whether to delete nested folds recursively
/// @return true if folds were deleted successfully, false otherwise
bool nvim_delete_fold(linenr_T start_line, linenr_T end_line, bool recursive) {
  win_T *win = curwin;
  if (!win) {
    api_set_error(err_api_invalid_window, "No current window");
    return false;
  }

  // Validate line numbers
  if (start_line < 1 || end_line < 1 || start_line > win->w_buffer->b_ml.ml_line_count
      || end_line > win->w_buffer->b_ml.ml_line_count) {
    api_set_error(err_api_invalid_argument, "Invalid line range");
    return false;
  }

  if (start_line > end_line) {
    // Swap if range is reversed
    linenr_T temp = start_line;
    start_line = end_line;
    end_line = temp;
  }

  // Check if fold deletion is allowed with current foldmethod
  if (!foldManualAllowed(false)) {
    return false;  // Error message already set by foldManualAllowed
  }

  // Delete the folds
  deleteFold(win, start_line, end_line, recursive, false);
  
  return true;
}