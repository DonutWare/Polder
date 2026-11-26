import "package:web/web.dart";

bool goBackInBrowser() {
  window.history.back();
  return true;
}

bool goForwardInBrowser() {
  window.history.forward();
  return true;
}
