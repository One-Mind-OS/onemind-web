/// Knowledge Base and Document models with JSON serialization
class KnowledgeBaseModel {
  final String? id;
  final String name;
  final String? description;
  final int documentCount;
  final String embeddingModel;
  final DateTime createdAt;
  final DateTime updatedAt;

  KnowledgeBaseModel({
    this.id,
    required this.name,
    this.description,
    this.documentCount = 0,
    this.embeddingModel = 'text-embedding-3-small',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create a copy with modified fields
  KnowledgeBaseModel copyWith({
    String? id,
    String? name,
    String? description,
    int? documentCount,
    String? embeddingModel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KnowledgeBaseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      documentCount: documentCount ?? this.documentCount,
      embeddingModel: embeddingModel ?? this.embeddingModel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create from JSON
  factory KnowledgeBaseModel.fromJson(Map<String, dynamic> json) {
    return KnowledgeBaseModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      documentCount: json['document_count'] as int? ?? 0,
      embeddingModel: json['embedding_model'] as String? ?? 'text-embedding-3-small',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (description != null) 'description': description,
      'document_count': documentCount,
      'embedding_model': embeddingModel,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'KnowledgeBaseModel(id: $id, name: $name, documentCount: $documentCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KnowledgeBaseModel &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.documentCount == documentCount &&
        other.embeddingModel == embeddingModel;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, description, documentCount, embeddingModel);
  }
}

/// Document model for knowledge base contents
class DocumentModel {
  final String? id;
  final String kbId;
  final String? filename;
  final String? contentType;
  final int? fileSize;
  final String? embeddingStatus;
  final DateTime? embeddingGeneratedAt;
  final DateTime createdAt;

  DocumentModel({
    this.id,
    required this.kbId,
    this.filename,
    this.contentType,
    this.fileSize,
    this.embeddingStatus,
    this.embeddingGeneratedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create from JSON
  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String?,
      kbId: json['kb_id'] as String,
      filename: json['filename'] as String?,
      contentType: json['content_type'] as String?,
      fileSize: json['file_size'] as int?,
      embeddingStatus: json['embedding_status'] as String?,
      embeddingGeneratedAt: json['embedding_generated_at'] != null
          ? DateTime.parse(json['embedding_generated_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'kb_id': kbId,
      if (filename != null) 'filename': filename,
      if (contentType != null) 'content_type': contentType,
      if (fileSize != null) 'file_size': fileSize,
      if (embeddingStatus != null) 'embedding_status': embeddingStatus,
      if (embeddingGeneratedAt != null)
        'embedding_generated_at': embeddingGeneratedAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'DocumentModel(id: $id, filename: $filename, size: $fileSize, embeddingStatus: $embeddingStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DocumentModel &&
        other.id == id &&
        other.kbId == kbId &&
        other.filename == filename &&
        other.embeddingStatus == embeddingStatus;
  }

  @override
  int get hashCode {
    return Object.hash(id, kbId, filename, embeddingStatus);
  }
}

/// Semantic Search Result model
class SemanticSearchResult {
  final String id;
  final String kbId;
  final String? filename;
  final String content;
  final double similarityScore;
  final DateTime createdAt;

  SemanticSearchResult({
    required this.id,
    required this.kbId,
    this.filename,
    required this.content,
    required this.similarityScore,
    required this.createdAt,
  });

  /// Create from JSON
  factory SemanticSearchResult.fromJson(Map<String, dynamic> json) {
    return SemanticSearchResult(
      id: json['id'] as String,
      kbId: json['kb_id'] as String,
      filename: json['filename'] as String?,
      content: json['content'] as String,
      similarityScore: (json['similarity_score'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kb_id': kbId,
      if (filename != null) 'filename': filename,
      'content': content,
      'similarity_score': similarityScore,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'SemanticSearchResult(id: $id, filename: $filename, score: ${similarityScore.toStringAsFixed(2)})';
  }
}
