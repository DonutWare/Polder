import "package:flutter/services.dart";

/// True for `--flavor dev`: the side-by-side development build with its own app id and orange branding.
const isDevFlavor = appFlavor == "dev";

const devFlavorOrange = Color(0xFFFF8A1F);

const desktopIntegrationsInDevFlavor = false;

const desktopIntegrationsEnabled = !isDevFlavor || desktopIntegrationsInDevFlavor;
