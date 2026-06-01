import '../generated/assets.dart';
import '../tool/config_tool.dart';
import '../tool/time_tool.dart';

class VideoData {
  final int? id;
  final int time;
  final String fileId;
  final int fileCount; //视频数量
  String fileName;
  final bool directory;
  final bool file;
  bool video;
  final bool recommend; //是否推荐
  final String platform; //平台
  final String userId; //用户id
  final String linkId; //link_id
  int size;
  String? email;
  bool local;
  bool history;
  String? thumbnail;
  int duration; //播放时长
  int position; //播放进度
  String? path;
  String? url;

  bool selected = false;

  VideoData({
    required this.id,
    required this.time,
    required this.fileId,
    required this.fileCount,
    required this.fileName,
    required this.thumbnail,
    required this.directory,
    required this.file,
    required this.video,
    required this.local,
    required this.history,
    required this.recommend,
    required this.platform,
    required this.userId,
    required this.linkId,
    required this.size,
    required this.duration,
    required this.position,
    this.email,
    this.path,
    this.url,
  });

  String get filePath => '${ConfigTool.instance.directory}$path';

  String get playTime => TimeTool.formatString(duration);

  String get fillPath {
    if (directory) return Assets.assetsVideoCellBg;
    if (video) return Assets.assetsVideoCellBg;
    return Assets.assetsPhotoCellBg;
  }

  String get videoInfo {
    if (file == true || directory == false) {
      return '${ConfigTool.formatFileSize(size)} · ${TimeTool.formatYmd(time)}';
    }
    return '$fileCount Videos';
  }

  factory VideoData.dbFromMap(Map<String, dynamic> map) {
    return VideoData(
      id: map['id'],
      time: map['time'],
      fileId: map['fileId'],
      fileCount: map['fileCount'],
      fileName: map['fileName'],
      thumbnail: map['thumbnail'],
      directory: map['directory'] == 1,
      file: map['file'] == 1,
      video: map['video'] == 1,
      local: map['local'] == 1,
      history: map['history'] == 1,
      path: map['path'],
      recommend: map['recommend'] == 1,
      platform: map['platform'],
      userId: map['userId'],
      linkId: map['linkId'],
      size: map['size'],
      email: map['email'],
      duration: map['duration'],
      position: map['position'],
    );
  }

  // factory VideoData.openData(
  //     Map<String, dynamic> json,
  //     String linkId,
  //     String platform,
  //     bool recommend,
  //     ) {
  //   final fileMeta = json['haloes'];
  //   final namespace = json['wiivvhthjz']['octoploid']['bibliofilm'];
  //   final String displayName = json['lasiocampa']['fraulein'] ?? '';
  //   final int size = fileMeta['eery'] ?? 0;
  //   final String thumbnail = fileMeta['caroch'] ?? '';
  //   final String name = namespace['draggle'] ?? '';
  //   return VideoData(
  //     id: json["id"],
  //     time: json["animaters"] ?? 0,
  //     fileId: json["spithame"] ?? '',
  //     fileCount: json['uortx7ufl8'] ?? '',
  //     directory: json['torticone'],
  //     file: json['file'],
  //     video: json['ulaula'],
  //     fileName: displayName,
  //     size: size,
  //     userId: name,
  //     thumbnail: thumbnail,
  //     duration: json['duration'] ?? 0,
  //     position: json['position'] ?? 0,
  //     platform: platform,
  //     linkId: linkId,
  //     recommend: recommend,
  //   );
  // }
  //
  // factory VideoData.folderData(Map<String, dynamic> json, VideoData data) {
  //   final fileMeta = json['yabby'];
  //   final namespace = json['salicylal']['ectental'];
  //   final String displayName = json['dedenda']['elfinwood'] ?? '';
  //   final int size = fileMeta['gaminesque'] ?? 0;
  //   final String thumbnail = fileMeta['refires'] ?? '';
  //   final String name = namespace['daytide'] ?? '';
  //   return VideoData(
  //     id: null,
  //     time: json["epibasal"] ?? 0,
  //     fileId: json["ujuykvb6tq"] ?? '',
  //     fileCount: json['zp4v_f4jsa'] ?? '',
  //     directory: json['unwitted'],
  //     file: json['file'],
  //     video: json['herds'],
  //     fileName: displayName,
  //     size: size,
  //     userId: name,
  //     thumbnail: thumbnail,
  //     duration: json['duration'] ?? 0,
  //     position: json['position'] ?? 0,
  //     path: null,
  //     platform: data.platform,
  //     linkId: data.linkId,
  //     recommend: data.recommend,
  //   );
  // }
  //
  // factory VideoData.recommendData(
  //     Map<String, dynamic> json, {
  //       required String platform,
  //     }) {
  //   final fileMeta = json['kyklops'];
  //   final namespace = json['boil']['pvcthjkum9'];
  //   final String displayName = json['baized']['cajava'] ?? '';
  //   final int size = fileMeta['basinal'] ?? 0;
  //   final String thumbnail = fileMeta['zpqofrckcx'] ?? '';
  //   final String name = namespace['bywalking'] ?? '';
  //   return VideoData(
  //     id: null,
  //     time: json["unusefully"] ?? 0,
  //     fileId: json["dpb7wtlffb"] ?? '',
  //     fileCount: json['preimport'] ?? '',
  //     directory: json['eupomatia'],
  //     file: json['file'],
  //     video: json['euphrasies'],
  //     fileName: displayName,
  //     size: size,
  //     userId: name,
  //     thumbnail: thumbnail,
  //     duration: json['duration'] ?? 0,
  //     position: json['position'] ?? 0,
  //     path: null,
  //     platform: platform,
  //     linkId: '',
  //     recommend: true,
  //   );
  // }

  factory VideoData.fromDocument({required String name, required String path}) {
    return VideoData(
      id: null,
      time: DateTime.now().millisecondsSinceEpoch,
      fileId: '',
      fileCount: 0,
      fileName: name,
      thumbnail: null,
      directory: false,
      file: true,
      video: true,
      local: false,
      history: false,
      recommend: false,
      platform: '',
      email: '',
      userId: '',
      linkId: '',
      size: 0,
      duration: 0,
      position: 0,
      path: path,
    );
  }

  // 将对象转换为 Map，用于数据库存储
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': time,
      'fileId': fileId,
      'fileCount': fileCount,
      'fileName': fileName,
      'thumbnail': thumbnail,
      'directory': directory ? 1 : 0,
      'file': file ? 1 : 0,
      'video': video ? 1 : 0,
      'local': local ? 1 : 0,
      'history': history ? 1 : 0,
      'recommend': recommend ? 1 : 0,
      'platform': platform,
      'userId': userId,
      'email': email,
      'linkId': linkId,
      'size': size,
      'duration': duration,
      'position': position,
      'path': path,
    };
  }
}
