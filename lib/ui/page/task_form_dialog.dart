import 'package:flutter/material.dart';
import '../../model/team_task_res_model.dart';

class TaskFormDialog extends StatefulWidget {
  final TeamTaskResModel? task; // Null for create, non-null for edit

  const TaskFormDialog({super.key, this.task});

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _dateController;

  taskPriority _selectedPriority = taskPriority.medium;
  taskStatus _selectedStatus = taskStatus.pending;

  final List<taskPriority> _priorities = taskPriority.values;
  final List<taskStatus> _statuses = taskStatus.values;

  String _statusDisplayName(taskStatus status) {
    switch (status) {
      case taskStatus.pending:
        return "Pending";
      case taskStatus.inProgress:
        return "In Progress";
      case taskStatus.completed:
        return "Completed";
    }
  }

  String _priorityDisplayName(taskPriority priority) {
    switch (priority) {
      case taskPriority.low:
        return "Low";
      case taskPriority.medium:
        return "Medium";
      case taskPriority.high:
        return "High";
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.taskName ?? "");
    _descController = TextEditingController(text: widget.task?.taskDescription ?? "");
    _dateController = TextEditingController(text: widget.task?.dueDate ?? "");

    if (widget.task != null) {
      _selectedPriority = widget.task!.priority ?? taskPriority.medium;
      _selectedStatus = widget.task!.status ?? taskStatus.pending;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    DateTime initialDate = DateTime.now();
    if (_dateController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(_dateController.text);
      } catch (_) {}
    }

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFF00B4DB),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1D353F),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF00B4DB),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      setState(() {
        _dateController.text = "${selected.day.toString().padLeft(2, '0')}-${selected.month.toString().padLeft(2, '0')}-${selected.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEdit = widget.task != null;

    final dialogBg = isDark ? const Color(0xFF14262F) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? "Edit Task" : "Create Task",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Title Field
                TextFormField(
                  controller: _titleController,
                  style: TextStyle(color: textColor),
                  decoration: _inputDecoration("Task Name"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Task Name cannot be empty";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Description Field
                TextFormField(
                  controller: _descController,
                  style: TextStyle(color: textColor),
                  maxLines: 3,
                  decoration: _inputDecoration("Task Description"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Task Description cannot be empty";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Priority Dropdown
                DropdownButtonFormField<taskPriority>(
                  value: _selectedPriority,
                  style: TextStyle(color: textColor),
                  dropdownColor: dialogBg,
                  decoration: _inputDecoration("Priority"),
                  items: _priorities.map((taskPriority value) {
                    return DropdownMenuItem<taskPriority>(
                      value: value,
                      child: Text(_priorityDisplayName(value), style: TextStyle(color: textColor)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedPriority = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 15),

                // Due Date Picker Field
                TextFormField(
                  controller: _dateController,
                  style: TextStyle(color: textColor),
                  readOnly: true,
                  onTap: _selectDueDate,
                  decoration: _inputDecoration("Due Date").copyWith(
                    suffixIcon: Icon(Icons.calendar_today, color: isDark ? Colors.white60 : Colors.black54),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Due Date cannot be empty";
                    }
                    return null;
                  },
                ),

                // Status Dropdown - Only if Editing
                if (isEdit) ...[
                  const SizedBox(height: 15),
                  DropdownButtonFormField<taskStatus>(
                    value: _selectedStatus,
                    style: TextStyle(color: textColor),
                    dropdownColor: dialogBg,
                    decoration: _inputDecoration("Status"),
                    items: _statuses.map((taskStatus value) {
                      return DropdownMenuItem<taskStatus>(
                        value: value,
                        child: Text(_statusDisplayName(value), style: TextStyle(color: textColor)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedStatus = val;
                        });
                      }
                    },
                  ),
                ],
                const SizedBox(height: 25),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("CANCEL", style: TextStyle(color: isDark ? Colors.white60 : Colors.black45)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4DB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context, {
                            'title': _titleController.text.trim(),
                            'description': _descController.text.trim(),
                            'priority': _selectedPriority.name,
                            'dueDate': _dateController.text.trim(),
                            'status': _selectedStatus.name,
                          });
                        }
                      },
                      child: Text(
                        isEdit ? "SAVE CHANGES" : "CREATE",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00B4DB)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
