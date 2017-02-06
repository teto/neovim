#ifndef NVIM_FOLD_H
#define NVIM_FOLD_H

#include "nvim/pos.h"

/*
 * Info used to pass info about a fold from the fold-detection code to the
 * code that displays the foldcolumn.
 *
 * Example:
 * 123
 * |
 * ||| <- here fi_low_level=2, level=3
 * ||
 * ||
 * 
 * 
 */
/// TODO REMOVE THAT THING !!
typedef struct foldinfo {
  linenr_T fi_lnum;             /* line number where fold starts */
  int fi_level;                 /* level of the fold; when this is zero the
                                   other fields are invalid */
  int fi_low_level;             /**!< lowest fold level that starts in the same
                                   line=> bigger number i.e. fi_low_level >= fi_level */
  /* int fi_closed_nested_levels;    /1* number from toplevel *1/ */
  /* int fi_open_nested_levels;    /1* number *1/ */
  int fi_widest_cell_width;
} foldinfo_T;

/* local declarations. {{{1 */
/* typedef fold_T {{{2 */
/*
 * The toplevel folds for each window are stored in the w_folds growarray.
 * Each toplevel fold can contain an array of second level folds in the
 * fd_nested growarray.
 * The info stored in both growarrays is the same: An array of fold_T.
 */
typedef struct {
  linenr_T fd_top;              /* first line of fold; for nested fold
                                 * relative to parent */
  linenr_T fd_len;              //!< number of lines in the fold
  garray_T fd_nested;           //!< array of nested folds
  char fd_flags;                //!< @see FD_OPEN, etc...
  char fd_small;                /* TRUE, FALSE or MAYBE: fold smaller than
                                   'foldminlines'; MAYBE applies to nested
                                   folds too */
} fold_T;

#define FD_OPEN         0       /* fold is open (nested ones can be closed) */
#define FD_CLOSED       1       /* fold is closed */
#define FD_LEVEL        2       /* depends on 'foldlevel' (nested folds too) */

#define MAX_LEVEL       20      /* maximum fold depth */

/* Define "fline_T", passed to get fold level for a line. {{{2 */
typedef struct {
  win_T       *wp;              /* window */
  linenr_T lnum;                /* current line number */
  linenr_T off;                 /* offset between lnum and real line number */
  linenr_T lnum_save;           /* line nr used by foldUpdateIEMSRecurse() */
  int lvl;                      /* current level (-1 for undefined) */
  int lvl_next;                 /* level used for next line */
  int start;                    /* number of folds that are forced to start at
                                   this line. */
  int end;                      /* level of fold that is forced to end below
                                   this line */
  int had_end;                  /* level of fold that is forced to end above
                                   this line (copy of "end" of prev. line) */
} fline_T;


#ifdef INCLUDE_GENERATED_DECLARATIONS
# include "fold.h.generated.h"
#endif
#endif  // NVIM_FOLD_H
