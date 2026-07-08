import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:taup/data/video_data.dart';
import 'package:video_player/video_player.dart' hide VideoAudioTrack;

import '../myWidget/video_edit/audio_helper_service.dart';
import '../myWidget/video_edit/clips_previewer.dart';
import '../myWidget/video_edit/example_audio_tracks_constant.dart';
import '../myWidget/video_edit/preview_video.dart';
import '../myWidget/video_edit/video_initializing_widget.dart';
import '../myWidget/video_edit/video_progress_alert.dart';
import '../tool/config_tool.dart';

/// A sample page demonstrating how to use the video-editor.
class EditContentPage extends StatefulWidget {
  /// Creates a [VideoEditorBasicExamplePage] widget.
  final VideoData data;
  final Function(String fileName)? doneTap;
  const EditContentPage({super.key, required this.data, this.doneTap});

  @override
  State<EditContentPage> createState() => _EditContentPageState();
}

class _EditContentPageState extends State<EditContentPage> {
  final _editorKey = GlobalKey<ProImageEditorState>();

  final _taskId = DateTime.now().microsecondsSinceEpoch.toString();

  /// The target format for the exported video.
  final _outputFormat = VideoOutputFormat.mp4;

  /// Indicates whether a seek operation is in progress.
  bool _isSeeking = false;

  /// Stores the currently selected trim duration span.
  TrimDurationSpan? _durationSpan;

  /// Temporarily stores a pending trim duration span.
  TrimDurationSpan? _tempDurationSpan;

  /// Controls video playback and trimming functionalities.
  ProVideoController? _proVideoController;

  /// Stores generated thumbnails for the trimmer bar and filter background.
  List<ImageProvider>? _thumbnails;

  /// Holds information about the selected video.
  ///
  /// This will be populated via [_setMetadata].
  late VideoMetadata _videoMetadata;

  /// Number of thumbnails to generate across the video timeline.
  final int _thumbnailCount = 7;

  /// The video currently loaded in the editor.
  late EditorVideo _video = EditorVideo.file(
    io.File('${ConfigTool.instance.directory}/myApp${widget.data.path}'),
  );

  final _proVideoEditor = ProVideoEditor.instance;

  String? _outputPath;
  final Map<String, Uint8List> _cachedKeyFrames = {};
  final Map<String, List<Uint8List>> _cachedKeyFrameList = {};

  /// The duration it took to generate the exported video.
  Duration _videoGenerationTime = Duration.zero;
  VideoPlayerController? _videoController;
  AudioHelperService? _audioService;

  final _updateClipsNotifier = ValueNotifier(false);

  VideoPlayerController get _activeVideoController => _videoController!;

  AudioHelperService get _activeAudioService => _audioService!;

  late final ProImageEditorConfigs _configs = ProImageEditorConfigs(
    dialogConfigs: DialogConfigs(
      widgets: DialogWidgets(
        loadingDialog: (message, configs) =>
            VideoProgressAlert(taskId: _taskId),
      ),
    ),
    mainEditor: MainEditorConfigs(
      tools: [
        SubEditorMode.paint,
        SubEditorMode.text,
        SubEditorMode.cropRotate,
        SubEditorMode.tune,
        SubEditorMode.filter,
        SubEditorMode.emoji,
      ],
      widgets: MainEditorWidgets(
        removeLayerArea:
            (removeAreaKey, editor, rebuildStream, isLayerBeingTransformed) =>
                VideoEditorRemoveArea(
                  removeAreaKey: removeAreaKey,
                  editor: editor,
                  rebuildStream: rebuildStream,
                  isLayerBeingTransformed: isLayerBeingTransformed,
                ),
      ),
    ),
    paintEditor: const PaintEditorConfigs(
      tools: [
        PaintMode.freeStyle,
        PaintMode.arrow,
        PaintMode.line,
        PaintMode.rect,
        PaintMode.circle,
        PaintMode.dashLine,
        PaintMode.polygon,
        // Blur and pixelate are not supported.
        // PaintMode.pixelate,
        // PaintMode.blur,
        PaintMode.eraser,
      ],
    ),
    audioEditor: AudioEditorConfigs(audioTracks: kExampleAudioTracks),
    clipsEditor: ClipsEditorConfigs(
      clips: [
        VideoClip(
          id: '001',
          title: 'My awesome video',
          // subtitle: 'Optional',
          duration: Duration.zero,
          clip: EditorVideoClip.autoSource(
            assetPath: _video.assetPath,
            bytes: _video.byteArray,
            file: _video.file,
            networkUrl: _video.networkUrl,
          ),
        ),
      ],
    ),
    videoEditor: const VideoEditorConfigs(
      initialMuted: false,
      initialPlay: false,
      isAudioSupported: true,
      minTrimDuration: Duration(seconds: 1),
      playTimeSmoothingDuration: Duration(milliseconds: 600),
    ),
    imageGeneration: const ImageGenerationConfigs(
      captureImageByteFormat: ImageByteFormat.rawStraightRgba,
    ),
  );

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _disposePlayback();
    _updateClipsNotifier.dispose();
    super.dispose();
  }

  void _disposePlayback() {
    _videoController?.removeListener(_onDurationChange);
    final videoController = _videoController;
    final audioService = _audioService;
    _videoController = null;
    _audioService = null;
    if (videoController != null) {
      unawaited(videoController.dispose());
    }
    if (audioService != null) {
      unawaited(audioService.dispose());
    }
  }

  Future<VideoPlayerController?> _createPlaybackController(String path) async {
    _disposePlayback();

    final videoController = VideoPlayerController.file(io.File(path));
    final audioService = AudioHelperService(videoController: videoController);
    _videoController = videoController;
    _audioService = audioService;

    await Future.wait([
      videoController.initialize(),
      videoController.setLooping(false),
      videoController.setVolume(_configs.videoEditor.initialMuted ? 0 : 100),
      _configs.videoEditor.initialPlay
          ? videoController.play()
          : videoController.pause(),
      audioService.initialize(),
    ]);

    if (!mounted || _videoController != videoController) return null;

    videoController.addListener(_onDurationChange);
    return videoController;
  }

  /// Loads and sets [_videoMetadata] for the given [_video].
  Future<void> _setMetadata() async {
    _videoMetadata = await _proVideoEditor.getMetadata(_video);
  }

  /// Generates thumbnails for the given [_video].
  Future<void> _generateThumbnails({bool updateClipThumbnails = true}) async {
    if (!mounted) return;
    var imageWidth =
        MediaQuery.sizeOf(context).width /
        _thumbnailCount *
        MediaQuery.devicePixelRatioOf(context);

    List<Uint8List> thumbnailList = [];

    /// On android `getKeyFrames` is a way faster than `getThumbnails` but
    /// the timestamps are more "random". If you want the best results i
    /// recommend you to use only `getThumbnails`.
    final duration = _videoMetadata.duration;
    final segmentDuration = duration.inMilliseconds / _thumbnailCount;
    thumbnailList = await _proVideoEditor.getThumbnails(
      ThumbnailConfigs(
        video: _video,
        outputSize: Size.square(imageWidth),
        boxFit: ThumbnailBoxFit.cover,
        timestamps: List.generate(_thumbnailCount, (i) {
          final midpointMs = (i + 0.5) * segmentDuration;
          return Duration(milliseconds: midpointMs.round());
        }),
        outputFormat: ThumbnailFormat.jpeg,
      ),
    );

    List<ImageProvider> temporaryThumbnails = thumbnailList
        .map(MemoryImage.new)
        .toList();

    if (updateClipThumbnails) {
      _configs.clipsEditor.clips.first = _configs.clipsEditor.clips.first
          .copyWith(thumbnails: temporaryThumbnails);
    }

    /// Optional precache every thumbnail
    var cacheList = temporaryThumbnails.map(
      (item) => precacheImage(item, context),
    );
    await Future.wait(cacheList);
    _thumbnails = temporaryThumbnails;

    if (_proVideoController != null) {
      _proVideoController!.thumbnails = _thumbnails;
    }
  }

  Future<void> _initializePlayer() async {
    await _setMetadata();

    _configs.clipsEditor.clips.first = _configs.clipsEditor.clips.first
        .copyWith(duration: _videoMetadata.duration);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateThumbnails();
    });

    final videoController = await _createPlaybackController(
      '${ConfigTool.instance.directory}/myApp${widget.data.path}',
    );
    if (!mounted || videoController == null) return;

    _proVideoController = ProVideoController(
      videoPlayer: _buildVideoPlayer(),
      initialResolution: _videoMetadata.resolution,
      videoDuration: _videoMetadata.duration,
      fileSize: _videoMetadata.fileSize,
      thumbnails: _thumbnails,
    );

    setState(() {});
  }

  void _onDurationChange() {
    final videoController = _videoController;
    final proVideoController = _proVideoController;
    if (videoController == null || proVideoController == null) return;

    final totalVideoDuration = _videoMetadata.duration;
    final duration = videoController.value.position;
    proVideoController.setPlayTime(duration);

    if (_durationSpan != null && duration >= _durationSpan!.end) {
      _seekToPosition(_durationSpan!);
    } else if (duration >= totalVideoDuration) {
      _seekToPosition(
        TrimDurationSpan(start: Duration.zero, end: totalVideoDuration),
      );
    }
  }

  Future<void> _seekToPosition(TrimDurationSpan span) async {
    final videoController = _videoController;
    final proVideoController = _proVideoController;
    if (videoController == null || proVideoController == null) return;

    _durationSpan = span;

    if (_isSeeking) {
      _tempDurationSpan = span; // Store the latest seek request
      return;
    }
    _isSeeking = true;

    proVideoController.pause();
    proVideoController.setPlayTime(_durationSpan!.start);

    await videoController.pause();
    await videoController.seekTo(span.start);

    _isSeeking = false;

    // Check if there's a pending seek request
    if (_tempDurationSpan != null) {
      TrimDurationSpan nextSeek = _tempDurationSpan!;
      _tempDurationSpan = null; // Clear the pending seek
      await _seekToPosition(nextSeek); // Process the latest request
    }
  }

  /// Generates the final video based on the given [parameters].
  ///
  /// Applies blur, color filters, cropping, rotation, flipping, and trimming
  /// before exporting using FFmpeg. Measures and stores the generation time.
  Future<void> _generateVideo(CompleteParameters parameters) async {
    final videoController = _videoController;
    final audioService = _audioService;
    if (videoController == null || audioService == null) return;

    final stopwatch = Stopwatch()..start();

    unawaited(videoController.pause());
    unawaited(audioService.pause());

    final AudioTrack? selectedAudioTrack = parameters.audioTracks.isNotEmpty
        ? parameters.audioTracks.first
        : null;
    final double volumeBalance = selectedAudioTrack?.volumeBalance ?? 0;
    double overlayVolume = 1;
    double originalVolume = 1;
    if (volumeBalance < 0) {
      overlayVolume += volumeBalance;
    } else {
      originalVolume -= volumeBalance;
    }

    final exportModel = VideoRenderData(
      id: _taskId,
      videoSegments: [VideoSegment(video: _video, volume: originalVolume)],
      outputFormat: _outputFormat,
      enableAudio: _proVideoController?.isAudioEnabled ?? true,
      imageLayers: parameters.layers.isNotEmpty
          ? [ImageLayer(image: EditorLayerImage.memory(parameters.image))]
          : null,
      blur: parameters.blur,
      colorFilters: parameters.colorFilters
          .map((el) => ColorFilter(matrix: el))
          .toList(),
      startTime: parameters.startTime,
      endTime: parameters.endTime,
      transform: parameters.isTransformed
          ? ExportTransform(
              width: parameters.cropWidth,
              height: parameters.cropHeight,
              rotateTurns: parameters.rotateTurns,
              x: parameters.cropX,
              y: parameters.cropY,
              flipX: parameters.flipX,
              flipY: parameters.flipY,
            )
          : null,
      audioTracks: selectedAudioTrack != null
          ? [
              VideoAudioTrack(
                path: (await audioService.safeCustomAudioPath(
                  selectedAudioTrack,
                ))!,
                volume: overlayVolume,
              ),
            ]
          : [],
    );

    final now = DateTime.now().millisecondsSinceEpoch;
    try {
      _outputPath = await ProVideoEditor.instance.renderVideoToFile(
        '${ConfigTool.instance.directory}/myApp/$now.mp4',
        exportModel,
      );
      widget.doneTap?.call('/$now.mp4');
      await saveVideoToGallery(
        '${ConfigTool.instance.directory}/myApp/$now.mp4',
      );
    } on RenderCanceledException {
      stopwatch.stop();
      _outputPath = null;
      _videoGenerationTime = Duration.zero;
      return;
    }
    _videoGenerationTime = stopwatch.elapsed;
  }

  Future<void> saveVideoToGallery(String videoPath) async {
    try {
      final videoFile = io.File(videoPath);
      final result = await ImageGallerySaver.saveFile(videoFile.path);

      if (result['isSuccess'] == true) {
        print('✅ 视频保存成功: ${result['filePath']}');
      } else {
        print('❌ 视频保存失败');
      }
    } catch (e) {
      print('保存出错: $e');
    }
  }

  /// Closes the video editor and opens a preview screen if a video was
  /// exported.
  ///
  /// If [_outputPath] is available, it navigates to [PreviewVideo].
  /// Afterwards, it pops the current editor page.
  void _handleCloseEditor(EditorMode editorMode) async {
    if (editorMode != EditorMode.main) return Navigator.pop(context);

    if (_outputPath != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PreviewVideo(
            filePath: _outputPath!,
            generationTime: _videoGenerationTime,
          ),
        ),
      );
      _outputPath = null;
    } else {
      return Navigator.pop(context);
    }
  }

  Future<VideoClip?> _addClip() async {
    // Open video picker
    final result = await FilePicker.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    // User cancelled picker
    if (!mounted || result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    final path = file.path;
    if (path == null) return null;

    // Extract file name for display
    final name = file.name;
    final title = name.split('.').first;
    LoadingDialog.instance.show(context, configs: _configs);
    final meta = await _proVideoEditor.getMetadata(EditorVideo.file(path));
    LoadingDialog.instance.hide();

    // Create and return your video clip
    return VideoClip(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      clip: EditorVideoClip.file(path),
      duration: meta.duration,
    );
  }

  Future<void> _mergeClips(
    List<VideoClip> clips,
    void Function(double) onProgress,
  ) async {
    LoadingDialog.instance.show(context, configs: _configs);
    final updatedFile = io.File(
      '${ConfigTool.instance.directory}/myApp${widget.data.path}',
    );

    _updateClipsNotifier.value = true;
    await _proVideoEditor.renderVideoToFile(
      updatedFile.path,
      VideoRenderData(
        id: _taskId,
        videoSegments: clips.map((el) {
          final clip = el.clip;
          return VideoSegment(
            video: EditorVideo.autoSource(
              networkUrl: clip.networkUrl,
              assetPath: clip.assetPath,
              byteArray: clip.bytes,
              file: clip.file,
            ),
            startTime: el.trimSpan?.start,
            endTime: el.trimSpan?.end,
          );
        }).toList(),
      ),
    );
    if (!mounted) {
      LoadingDialog.instance.hide();
      return;
    }

    _video = EditorVideo.file(updatedFile.path);

    await _setMetadata();
    await _generateThumbnails(updateClipThumbnails: false);
    _configs.clipsEditor.clips.first = _configs.clipsEditor.clips.first
        .copyWith(duration: _videoMetadata.duration);

    final videoController = await _createPlaybackController(updatedFile.path);
    if (!mounted || videoController == null) {
      LoadingDialog.instance.hide();
      return;
    }

    final editor = _editorKey.currentState!;

    _proVideoController =
        ProVideoController(
          videoPlayer: _buildVideoPlayer(),
          initialResolution: _videoMetadata.resolution,
          videoDuration: _videoMetadata.duration,
          fileSize: _videoMetadata.fileSize,
          thumbnails: _thumbnails,
        )..initialize(
          configsFunction: () => _configs.videoEditor,
          callbacksAudioFunction: () =>
              editor.audioEditorCallbacks ?? const AudioEditorCallbacks(),
          callbacksFunction: () =>
              editor.callbacks.videoEditorCallbacks ?? VideoEditorCallbacks(),
        );
    LoadingDialog.instance.hide();

    if (!mounted) return;

    editor.initializeVideoEditor();

    _updateClipsNotifier.value = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: _proVideoController == null
          ? const VideoInitializingWidget()
          : _buildEditor(),
    );
  }

  Widget _buildEditor() {
    return ProImageEditor.video(
      _proVideoController!,
      key: _editorKey,
      callbacks: ProImageEditorCallbacks(
        onCompleteWithParameters: _generateVideo,
        onCloseEditor: _handleCloseEditor,
        videoEditorCallbacks: VideoEditorCallbacks(
          onPause: _activeVideoController.pause,
          onPlay: _activeVideoController.play,
          onMuteToggle: (isMuted) {
            if (isMuted) {
              _activeAudioService.setVolume(0);
              _activeVideoController.setVolume(0);
            } else {
              _activeAudioService.balanceAudio();
            }
          },
          onTrimSpanUpdate: (durationSpan) {
            if (_activeVideoController.value.isPlaying) {
              _proVideoController!.pause();
            }
          },
          onTrimSpanEnd: _seekToPosition,
        ),
        audioEditorCallbacks: AudioEditorCallbacks(
          onBalanceChange: _activeAudioService.balanceAudio,
          onStartTimeChange: (startTime) async {
            await Future.value([
              _activeAudioService.seek(startTime),
              _activeVideoController.seekTo(Duration.zero),
            ]);
          },
          onPlay: _activeAudioService.play,
          onStop: (audio) => _activeAudioService.pause(),
        ),
        clipsEditorCallbacks: ClipsEditorCallbacks(
          onBuildPlayer: (controller, videoClip) {
            return ClipsPreviewer(
              videoConfigs: _configs.videoEditor,
              proController: controller,
              videoClip: videoClip,
            );
          },
          onMergeClips: _mergeClips,
          onReadKeyFrame: (source) async {
            if (_cachedKeyFrames.containsKey(source.id)) {
              return _cachedKeyFrames[source.id]!;
            }

            final result = await _proVideoEditor.getKeyFrames(
              KeyFramesConfigs(
                video: EditorVideo.autoSource(
                  assetPath: source.clip.assetPath,
                  byteArray: source.clip.bytes,
                  file: source.clip.file,
                  networkUrl: source.clip.networkUrl,
                ),
                outputSize: const Size.square(200),
                boxFit: ThumbnailBoxFit.cover,
                maxOutputFrames: 1,
                outputFormat: ThumbnailFormat.jpeg,
              ),
            );
            _cachedKeyFrames[source.id] = result.first;
            return result.first;
          },
          onReadKeyFrames: (source) async {
            if (_cachedKeyFrameList.containsKey(source.id)) {
              return _cachedKeyFrameList[source.id]!;
            }

            final result = await _proVideoEditor.getKeyFrames(
              KeyFramesConfigs(
                video: EditorVideo.autoSource(
                  assetPath: source.clip.assetPath,
                  byteArray: source.clip.bytes,
                  file: source.clip.file,
                  networkUrl: source.clip.networkUrl,
                ),
                outputSize: const Size.square(200),
                boxFit: ThumbnailBoxFit.cover,
                maxOutputFrames: _thumbnailCount,
                outputFormat: ThumbnailFormat.jpeg,
              ),
            );
            _cachedKeyFrameList[source.id] = result;
            return result;
          },
          onAddClip: _addClip,
        ),
      ),
      configs: _configs,
    );
  }

  Widget _buildVideoPlayer() {
    return ValueListenableBuilder(
      valueListenable: _updateClipsNotifier,
      builder: (_, isLoading, _) {
        final videoController = _videoController;
        return Center(
          child:
              isLoading ||
                  videoController == null ||
                  !videoController.value.isInitialized
              ? const CircularProgressIndicator.adaptive()
              : AspectRatio(
                  aspectRatio: videoController.value.size.aspectRatio,
                  child: VideoPlayer(videoController),
                ),
        );
      },
    );
  }
}
