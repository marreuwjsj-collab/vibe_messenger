class MediaAttachment { final String id; final String path; final String mimeType; final int size; const MediaAttachment({required this.id, required this.path, required this.mimeType, required this.size}); }
abstract interface class MediaRepository { Future<MediaAttachment> upload(String path); Future<String> download(String id); }
