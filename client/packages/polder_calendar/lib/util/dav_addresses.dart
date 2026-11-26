String _base(String serverUrl) => serverUrl.endsWith("/") ? serverUrl.substring(0, serverUrl.length - 1) : serverUrl;

String webdavAddress(String serverUrl, String username) =>
    "${_base(serverUrl)}/dav/files/${Uri.encodeComponent(username)}/";

String caldavAddress(String serverUrl) => "${_base(serverUrl)}/dav/";

String calendarAddress(String serverUrl, String username, String segment) =>
    "${_base(serverUrl)}/dav/calendars/${Uri.encodeComponent(username)}/${Uri.encodeComponent(segment)}/";

String subscriptionAddress(String serverUrl, String url) => url.startsWith("/") ? "${_base(serverUrl)}$url" : url;

String webcalAddress(String address) => address.replaceFirst(RegExp(r"^https?://"), "webcal://");
