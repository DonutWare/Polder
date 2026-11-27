#include "include/polder_account_link/polder_account_link_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <libsecret/secret.h>

#include <cstring>

#define POLDER_ACCOUNT_LINK_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), polder_account_link_plugin_get_type(), PolderAccountLinkPlugin))

struct _PolderAccountLinkPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(PolderAccountLinkPlugin, polder_account_link_plugin, g_object_get_type())

static const SecretSchema* shared_account_schema() {
  static const SecretSchema schema = {
      "org.knaapen.polder.SharedAccount",
      SECRET_SCHEMA_NONE,
      {
          {"namespace", SECRET_SCHEMA_ATTRIBUTE_STRING},
          {nullptr, SECRET_SCHEMA_ATTRIBUTE_STRING},
      },
  };
  return &schema;
}

static const gchar* string_argument(FlValue* args, const gchar* key) {
  if (args == nullptr || fl_value_get_type(args) != FL_VALUE_TYPE_MAP) return nullptr;
  FlValue* value = fl_value_lookup_string(args, key);
  if (value == nullptr || fl_value_get_type(value) != FL_VALUE_TYPE_STRING) return nullptr;
  return fl_value_get_string(value);
}

static FlMethodResponse* failure(GError* error) {
  return FL_METHOD_RESPONSE(fl_method_error_response_new("failed", error->message, nullptr));
}

static FlMethodResponse* read_account(const gchar* name_space) {
  g_autoptr(GError) error = nullptr;
  gchar* secret =
      secret_password_lookup_sync(shared_account_schema(), nullptr, &error, "namespace", name_space, nullptr);
  if (error != nullptr) return failure(error);
  if (secret == nullptr) return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_null()));
  g_autoptr(FlValue) result = fl_value_new_string(secret);
  secret_password_free(secret);
  return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

static FlMethodResponse* write_account(const gchar* name_space, const gchar* name, const gchar* json) {
  g_autoptr(GError) error = nullptr;
  g_autofree gchar* label = g_strdup_printf("Polder account %s", name != nullptr ? name : "");
  secret_password_store_sync(shared_account_schema(), SECRET_COLLECTION_DEFAULT, label, json, nullptr, &error,
                             "namespace", name_space, nullptr);
  if (error != nullptr) return failure(error);
  return FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
}

static FlMethodResponse* remove_account(const gchar* name_space) {
  g_autoptr(GError) error = nullptr;
  secret_password_clear_sync(shared_account_schema(), nullptr, &error, "namespace", name_space, nullptr);
  if (error != nullptr) return failure(error);
  return FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
}

static FlMethodResponse* handle(FlMethodCall* method_call) {
  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);
  const gchar* name_space = string_argument(args, "namespace");
  if (name_space == nullptr) {
    return FL_METHOD_RESPONSE(fl_method_error_response_new("bad_args", "namespace is required", nullptr));
  }
  if (strcmp(method, "read") == 0) return read_account(name_space);
  if (strcmp(method, "remove") == 0) return remove_account(name_space);
  if (strcmp(method, "write") == 0) {
    const gchar* json = string_argument(args, "json");
    if (json == nullptr) return FL_METHOD_RESPONSE(fl_method_error_response_new("bad_args", "json is required", nullptr));
    return write_account(name_space, string_argument(args, "name"), json);
  }
  return FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call, gpointer user_data) {
  g_autoptr(FlMethodResponse) response = handle(method_call);
  fl_method_call_respond(method_call, response, nullptr);
}

static void polder_account_link_plugin_class_init(PolderAccountLinkPluginClass* klass) {}

static void polder_account_link_plugin_init(PolderAccountLinkPlugin* self) {}

void polder_account_link_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  PolderAccountLinkPlugin* plugin =
      POLDER_ACCOUNT_LINK_PLUGIN(g_object_new(polder_account_link_plugin_get_type(), nullptr));
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                                                             "polder/account_link", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb, g_object_ref(plugin), g_object_unref);
  g_object_unref(plugin);
}
