abstract final class RemotePath {
  static const root = "/";

  static String join(String parent, String child) {
    final trimmedChild = child.replaceAll(RegExp(r"^/+|/+$"), "");
    if (trimmedChild.isEmpty) return parent;
    return parent == root ? "/$trimmedChild" : "$parent/$trimmedChild";
  }

  static String parent(String path) {
    final index = path.lastIndexOf("/");
    return index <= 0 ? root : path.substring(0, index);
  }

  static String name(String path) => path == root ? "" : path.substring(path.lastIndexOf("/") + 1);

  static List<String> segments(String path) => path.split("/").where((segment) => segment.isNotEmpty).toList();

  static List<String> ancestry(String path) {
    final result = [root];
    for (final segment in segments(path)) {
      result.add(join(result.last, segment));
    }
    return result;
  }

  static bool isWithin(String path, String ancestor) =>
      ancestor == root ? path.startsWith("/") && path != root : path.startsWith("$ancestor/");

  static String? relativeTo(String path, String ancestor) {
    if (!isWithin(path, ancestor)) return null;
    return ancestor == root ? path.substring(1) : path.substring(ancestor.length + 1);
  }

  static bool isValidName(String name) =>
      name.isNotEmpty &&
      name != "." &&
      name != ".." &&
      !name.contains("/") &&
      !name.contains("\\") &&
      !name.contains("\u0000") &&
      !name.startsWith(".polder");
}
