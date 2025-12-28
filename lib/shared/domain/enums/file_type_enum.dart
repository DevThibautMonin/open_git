enum FileTypeEnum {
  dart(assetPath: "assets/file_type_icons/dart.svg"),

  javascript(assetPath: "assets/file_type_icons/javascript.svg"),
  typescript(assetPath: "assets/file_type_icons/typescript.svg"),
  markdown(assetPath: "assets/file_type_icons/markdown.svg"),
  json(assetPath: "assets/file_type_icons/json.svg"),
  yaml(assetPath: "assets/file_type_icons/yaml.svg"),
  swift(assetPath: "assets/file_type_icons/swift.svg"),
  kotlin(assetPath: "assets/file_type_icons/kotlin.svg"),

  image(assetPath: "assets/file_type_icons/default_image.svg"),
  folder(assetPath: "assets/file_type_icons/default_file.svg"),

  unknown(assetPath: "assets/file_type_icons/default_file.svg")
  ;

  final String assetPath;

  const FileTypeEnum({
    required this.assetPath,
  });
}
