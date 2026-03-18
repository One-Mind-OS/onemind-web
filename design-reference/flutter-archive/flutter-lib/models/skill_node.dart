class SkillNode {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String branch;
  final int levelRequired;
  final List<String> prerequisites;
  final bool unlocked;

  SkillNode({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.branch,
    required this.levelRequired,
    this.prerequisites = const [],
    this.unlocked = false,
  });

  SkillNode copyWith({bool? unlocked}) {
    return SkillNode(
      id: id,
      name: name,
      description: description,
      icon: icon,
      branch: branch,
      levelRequired: levelRequired,
      prerequisites: prerequisites,
      unlocked: unlocked ?? this.unlocked,
    );
  }
}
