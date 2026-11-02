import "package:web/web.dart";

const canSaveInBrowser = true;

void saveInBrowser(Uri url, String name) =>
    (HTMLAnchorElement()
          ..href = url.toString()
          ..download = name)
        .click();
