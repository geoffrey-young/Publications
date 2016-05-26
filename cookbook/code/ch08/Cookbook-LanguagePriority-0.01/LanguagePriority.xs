#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "mod_perl.h"

/* copied from mod_negotiation.c */
typedef struct {
    array_header *language_priority;
} neg_dir_config;

module MODULE_VAR_EXPORT negotiation_module;

/* XS specific stuff */
typedef neg_dir_config * Cookbook__LanguagePriority;

MODULE = Cookbook::LanguagePriority   PACKAGE = Cookbook::LanguagePriority

PROTOTYPES: DISABLE

Cookbook::LanguagePriority
get(package, r)
  SV *package
  Apache r

  CODE:
    RETVAL = ap_get_module_config(r->per_dir_config, &negotiation_module);

  OUTPUT:
    RETVAL

void
priority(cfg)
  Cookbook::LanguagePriority cfg

  CODE:
    ST(0) = array_header2avrv(cfg->language_priority);
