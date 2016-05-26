#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "mod_perl.h"

static FILE *original_log;

MODULE = Cookbook::DivertErrorLog      PACKAGE = Cookbook::DivertErrorLog

PROTOTYPES: ENABLE

int
set(s, fd)
  Apache::Server s
  int fd

  PREINIT:
    pool *p;

  CODE:
    RETVAL = 1;

    /* Get a memory pool */
    p = perl_get_startup_pool();

    /* Stash away the pointer to the current error_log */
    original_log = s->error_log;

    /* 
     * Open the new error_log descriptor for writing.
     * Make sure the original error_log is restored and
     * return undef on failure
     */
    if (!(s->error_log = ap_pfdopen(p, fd, "w"))) {
      s->error_log = original_log;
      XSRETURN_UNDEF;
    }

    /* Make stderr point to the new error_log as well */
    dup2(fileno(s->error_log), STDERR_FILENO);

  OUTPUT:
    RETVAL

char *
restore(s)
  Apache::Server s

  PREINIT:
    char *fname;

  CODE:
    /* Restore the stashed error_log pointer */
    s->error_log = original_log;

    /* Point stderr back to the original error_log */
    dup2(fileno(s->error_log), STDERR_FILENO);

    /* Return the original error_log file, just to be informative */
    RETVAL = s->error_fname;

  OUTPUT:
    RETVAL
