class Message {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<ImageAttachment>? images; // Vision support

  Message({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
    this.images,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Attachment for vision/image support
class ImageAttachment {
  final String base64Data;
  final String mimeType; // 'image/jpeg', 'image/png', etc.
  final String fileName;

  ImageAttachment({
    required this.base64Data,
    required this.mimeType,
    required this.fileName,
  });

  Map<String, dynamic> toJson() => {
    'type': 'image',
    'source': {
      'type': 'base64',
      'media_type': mimeType,
      'data': base64Data,
    }
  };
}
