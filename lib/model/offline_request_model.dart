class OfflineRequestModel {
  final String queueId;
  final String action; // 'create', 'update', 'delete', 'toggle_complete'
  final dynamic taskId;
  final Map<String, dynamic>? taskData;

  OfflineRequestModel({
    required this.queueId,
    required this.action,
    required this.taskId,
    this.taskData,
  });

  factory OfflineRequestModel.fromJson(Map<String, dynamic> json) {
    return OfflineRequestModel(
      queueId: json['queueId'] as String,
      action: json['action'] as String,
      taskId: json['taskId'],
      taskData: json['taskData'] != null ? Map<String, dynamic>.from(json['taskData']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'queueId': queueId,
      'action': action,
      'taskId': taskId,
      'taskData': taskData,
    };
  }
}
