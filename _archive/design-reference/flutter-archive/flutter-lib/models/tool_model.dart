class ToolModel {
  final String name;
  final String category;
  final String description;
  final String provider;
  final Map<String, dynamic>? parameters;

  ToolModel({
    required this.name,
    required this.category,
    required this.description,
    required this.provider,
    this.parameters,
  });

  factory ToolModel.fromJson(Map<String, dynamic> json) {
    return ToolModel(
      name: json['name'],
      category: json['category'],
      description: json['description'],
      provider: json['provider'],
      parameters: json['parameters'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'provider': provider,
      if (parameters != null) 'parameters': parameters,
    };
  }
}
