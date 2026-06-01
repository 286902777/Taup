import 'package:mime_type/mime_type.dart';
import 'package:taup/data/video_data.dart';
import 'package:taup/tool/config_tool.dart';

class LocalFileData {
  final String name;
  final String path;
  final int size;
  final DocumentType type;

  LocalFileData({
    required this.name,
    required this.path,
    required this.size,
    required this.type,
  });

  factory LocalFileData.fromJson(Map<String, dynamic> json) {
    DocumentType type = DocumentType.video;
    final name = json['type'];
    if (name == 'png' || name == 'jpg' || name == 'image' || name == 'webp') {
      type = DocumentType.image;
    }
    return LocalFileData(
      name: json["name"],
      path: json["path"],
      size: json["size"] ?? 0,
      type: type,
    );
  }

  String get sizeStr => ConfigTool.formatFileSize(size);

  Map<String, dynamic> toJson() => {
    "name": name,
    "path": path,
    "size": size,
    "type": type.value,
  };

  VideoData toVideo() {
    return VideoData.fromDocument(name: name, path: path);
  }

  static LocalFileData create({
    required String fileName,
    required String filePath,
    required int size,
  }) {
    late DocumentType type;
    final String mimeType = mime(fileName) ?? '';
    if (mimeType.startsWith('image')) {
      type = DocumentType.image;
    } else {
      type = DocumentType.video;
    }
    return LocalFileData(
      name: fileName,
      path: filePath.split('Documents').last,
      size: size,
      type: type,
    );
  }

  String get filePath => '${ConfigTool.instance.directory}$path';
}

enum DocumentType {
  image('image'),
  video('video');

  final String value;

  const DocumentType(this.value);
}
