import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:midterm/backend/controllers/TodoController.dart';
import 'package:midterm/widgets/CustomInputAdd.dart';
import '../../../../theme/color.dart';
import '../model/TodoModel.dart';

class AddToDoPage extends StatefulWidget {
  final Function(TodoModel) onSaveTask;
  final TodoModel? initialTask;

  const AddToDoPage({
    super.key,
    required this.onSaveTask,
    this.initialTask,
  });

  @override
  State<AddToDoPage> createState() => _AddToDoPageState();
}

class _AddToDoPageState extends State<AddToDoPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late DateTime _dueDate;
  late TimeOfDay _dueTime;
  late String _selectedColor;
  late bool _isNotified;

  @override
  void initState() {
    super.initState();
    // Initialize fields based on initialTask
    _titleController.text = widget.initialTask?.title ?? '';
    _descController.text = widget.initialTask?.description ?? '';
    _dueDate = widget.initialTask?.dueDate ?? DateTime.now();
    _dueTime = widget.initialTask != null
        ? TimeOfDay.fromDateTime(widget.initialTask!.dueDate)
        : TimeOfDay.now();
    _selectedColor = widget.initialTask?.color ?? 'red';
    _isNotified = widget.initialTask?.isNotified ?? false;

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Define slide animation from bottom to top
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    // Start the animation when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    // Combine date and time into a single DateTime
    final combinedDateTime = DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _dueTime.hour,
      _dueTime.minute,
    );

    final task = TodoModel(
      id: widget.initialTask?.id ?? '680a7b98866922b1b773',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      dueDate: combinedDateTime,
      color: _selectedColor,
      isCompleted: widget.initialTask?.isCompleted ?? false,
      isNotified: _isNotified,
    );

    try {
      Document response =
          widget.initialTask == null ? await create(task) : await update(task);
      final data = response.data;
      print("✅ $data");
    } catch (e) {
      print("🛑 Error: $e");
    }

    widget.onSaveTask(task);
    Navigator.pop(context);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.lightGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.lightGreen,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dueTime) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.initialTask == null
                          ? 'Thêm mới công việc'
                          : 'Chỉnh sửa công việc',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _saveTask,
                    padding: EdgeInsets.zero,
                    splashRadius: 0.1,
                    icon: ImageIcon(
                      const AssetImage('assets/Note-check.png'),
                      size: 30,
                      color: AppColors.textColorGreen,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Field
                          const Text(
                            'Tên công việc:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          CustomInputAdd(
                            controller: _titleController,
                            hintText: 'Tên công việc',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập tên công việc';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Description Field
                          const Text(
                            'Mô tả chi tiết:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          CustomInputAdd(
                            controller: _descController,
                            hintText: 'Mô tả công việc',
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập mô tả công việc';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Due Date and Time Field
                          const Text(
                            'Thời gian hoàn thành:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectDate(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 20, color: Colors.grey),
                                        const SizedBox(width: 10),
                                        Text(
                                          '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectTime(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.access_time,
                                            size: 20, color: Colors.grey),
                                        const SizedBox(width: 10),
                                        Text(
                                          _dueTime.format(context),
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Color Selection
                          const Text(
                            'Mức độ cấp thiết:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Column(
                            children: [
                              _buildColorOption('red', 'Rất khẩn cấp'),
                              const SizedBox(height: 8),
                              _buildColorOption('blue', 'Khẩn cấp'),
                              const SizedBox(height: 8),
                              _buildColorOption('yellow', 'Bình thường'),
                              const SizedBox(height: 8),
                              _buildColorOption('green', 'Không khẩn cấp'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Notification Toggle
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isNotified = !_isNotified;
                                  });
                                },
                                splashRadius: 0.1,
                                padding: EdgeInsets.all(0),
                                icon: Image.asset(
                                  _isNotified
                                      ? 'assets/Notification_on.png'
                                      : 'assets/Notification.png',
                                  width: 30,
                                  height: 30,
                                  color: _isNotified
                                      ? null
                                      : AppColors.textColorGrey,
                                ),
                                
                              ),
                              const Text(
                                'Bật thông báo',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(String color, String label) {
    final isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Row(
        children: [
          Container(
            width: 80,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: _getColor(color).withOpacity(0.5),
              border: Border.all(
                color: isSelected ? Colors.black : Colors.transparent,
                width: isSelected ? 0.5 : 0,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Icon(
                      Icons.check,
                      color: _getColor(color),
                      size: 16,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(String color) {
    switch (color) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
}
