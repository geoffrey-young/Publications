#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "mod_perl.h"

MODULE = Cookbook::Apache         PACKAGE = Cookbook::Apache

PROTOTYPES: ENABLE

double
_bytes_sent(r)
  Apache r

  CODE:
    RETVAL = (double) r->bytes_sent / 1024;

  OUTPUT:
    RETVAL
