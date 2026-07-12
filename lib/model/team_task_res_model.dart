enum taskStatus {
  pending,
  inProgress,
  completed,
}

enum taskPriority {
  low,
  medium,
  high,
}

class TeamTaskResModel {
  dynamic id;
  String? taskName;
  String? taskDescription;
  taskStatus? status;
  String? dueDate;
  taskPriority? priority;

  TeamTaskResModel({
    this.id,
    this.taskName,
    this.status,
    this.taskDescription,
    this.dueDate,
    this.priority,
  });

  TeamTaskResModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    taskName = json['task_name'];
    taskDescription = json['task_description'];

    final statusStr = json['task_status'];
    status = taskStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => taskStatus.pending,
    );

    final priorityStr = json['task_priority'];
    priority = taskPriority.values.firstWhere(
      (e) => e.name == priorityStr,
      orElse: () => taskPriority.medium,
    );

    final rawDate = json['task_due_date'];
    if (rawDate is int) {
      final date = DateTime.fromMillisecondsSinceEpoch(rawDate * 1000);
      dueDate = "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
    } else if (rawDate is String) {
      dueDate = rawDate;
    } else {
      dueDate = "";
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['task_name'] = taskName;
    data['task_description'] = taskDescription;
    data['task_status'] = status?.name;
    data['task_priority'] = priority?.name;

    if (dueDate != null && dueDate!.isNotEmpty) {
      try {
        final parts = dueDate!.split('-');
        if (parts.length == 3 && parts[0].length == 2 && parts[2].length == 4) {
          final parsedDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
          data['task_due_date'] = parsedDate.millisecondsSinceEpoch ~/ 1000;
        } else {
          final parsedDate = DateTime.parse(dueDate!);
          data['task_due_date'] = parsedDate.millisecondsSinceEpoch ~/ 1000;
        }
      } catch (_) {
        data['task_due_date'] = dueDate;
      }
    } else {
      data['task_due_date'] = null;
    }
    return data;
  }
}


