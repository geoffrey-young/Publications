#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "mod_perl.h"
#include "mod_perl_xs.h"

MODULE = Cookbook::SimpleRequest          PACKAGE = Cookbook::SimpleRequest

PROTOTYPES: ENABLE

int
assbackwards(r, ...)
  Apache r

  CODE:
    get_set_IV(r->assbackwards);

  OUTPUT:
    RETVAL
