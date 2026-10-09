import "package:polder/util/remote_path.dart";

String uniqueName(String base, String extension, Set<String> taken) {
  final suffix = extension.isEmpty ? "" : ".$extension";
  var name = "$base$suffix";
  for (var number = 2; taken.contains(name); number++) {
    name = "$base $number$suffix";
  }
  return name;
}

String uniqueFileName(String name, Set<String> taken) =>
    uniqueName(RemotePath.withoutExtension(name), RemotePath.extension(name), taken);
