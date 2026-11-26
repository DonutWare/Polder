import "package:web/web.dart";

void setBrowserFavicon(String href) {
  final link = document.querySelector('link[rel="icon"]');
  if (link != null && link.getAttribute("href") != href) link.setAttribute("href", href);
}
