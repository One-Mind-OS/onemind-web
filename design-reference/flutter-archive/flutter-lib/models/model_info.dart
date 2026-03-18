class ModelInfo {
  final String modelId;
  final String modelName;
  final String provider;
  final String description;
  final int contextWindow;
  final bool supportsStreaming;
  final bool supportsFunctionCalling;
  final bool supportsVision;
  final double? inputPricePerMtok;
  final double? outputPricePerMtok;

  ModelInfo({
    required this.modelId,
    required this.modelName,
    required this.provider,
    required this.description,
    required this.contextWindow,
    required this.supportsStreaming,
    required this.supportsFunctionCalling,
    required this.supportsVision,
    this.inputPricePerMtok,
    this.outputPricePerMtok,
  });

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      modelId: json['model_id'],
      modelName: json['model_name'],
      provider: json['provider'],
      description: json['description'],
      contextWindow: json['context_window'],
      supportsStreaming: json['supports_streaming'],
      supportsFunctionCalling: json['supports_function_calling'],
      supportsVision: json['supports_vision'],
      inputPricePerMtok: json['input_price_per_mtok']?.toDouble(),
      outputPricePerMtok: json['output_price_per_mtok']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model_id': modelId,
      'model_name': modelName,
      'provider': provider,
      'description': description,
      'context_window': contextWindow,
      'supports_streaming': supportsStreaming,
      'supports_function_calling': supportsFunctionCalling,
      'supports_vision': supportsVision,
      if (inputPricePerMtok != null) 'input_price_per_mtok': inputPricePerMtok,
      if (outputPricePerMtok != null)
        'output_price_per_mtok': outputPricePerMtok,
    };
  }

  String get formattedContextWindow {
    if (contextWindow >= 1000000) {
      return '${(contextWindow / 1000000).toStringAsFixed(1)}M';
    } else if (contextWindow >= 1000) {
      return '${(contextWindow / 1000).toStringAsFixed(0)}K';
    }
    return contextWindow.toString();
  }

  String? get formattedPricing {
    if (inputPricePerMtok == null || outputPricePerMtok == null) {
      return null;
    }
    return '\$${inputPricePerMtok!.toStringAsFixed(2)} / \$${outputPricePerMtok!.toStringAsFixed(2)} per 1M tokens';
  }
}
