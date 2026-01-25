class ChecklistItemResponseDto {
  final String id;
  final String? taskId;
  final String description;
  final bool isRequired;
  final bool isChecked;
  final String createdAt;

  ChecklistItemResponseDto({
    required this.id,
    this.taskId,
    required this.description,
    required this.isRequired,
    required this.isChecked,
    required this.createdAt,
  });

  factory ChecklistItemResponseDto.fromJson(Map<String, dynamic> json) {
    return ChecklistItemResponseDto(
      id: json['id'] as String,
      taskId: json['taskId'] as String?,
      description: json['description'] as String,
      isRequired: json['isRequired'] as bool,
      isChecked: json['isChecked'] as bool,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (taskId != null) 'taskId': taskId,
      'description': description,
      'isRequired': isRequired,
      'isChecked': isChecked,
      'createdAt': createdAt,
    };
  }
}
