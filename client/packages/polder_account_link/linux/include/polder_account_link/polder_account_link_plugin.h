#ifndef FLUTTER_PLUGIN_POLDER_ACCOUNT_LINK_PLUGIN_H_
#define FLUTTER_PLUGIN_POLDER_ACCOUNT_LINK_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define FLUTTER_PLUGIN_EXPORT
#endif

typedef struct _PolderAccountLinkPlugin PolderAccountLinkPlugin;
typedef struct {
  GObjectClass parent_class;
} PolderAccountLinkPluginClass;

FLUTTER_PLUGIN_EXPORT GType polder_account_link_plugin_get_type();

FLUTTER_PLUGIN_EXPORT void polder_account_link_plugin_register_with_registrar(FlPluginRegistrar* registrar);

G_END_DECLS

#endif
