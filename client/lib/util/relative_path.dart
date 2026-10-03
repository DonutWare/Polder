abstract final class RelativePath {
  static bool isWithin(String path, String ancestor) => path.startsWith("$ancestor/");

  static String? parent(String path) {
    final index = path.lastIndexOf("/");
    return index < 0 ? null : path.substring(0, index);
  }

  static String name(String path) => path.substring(path.lastIndexOf("/") + 1);

  static String sibling(String path, String name) {
    final parentPath = parent(path);
    return parentPath == null ? name : "$parentPath/$name";
  }
}
