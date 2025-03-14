import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class TaskManagerLogo extends StatelessWidget {
  final double size;
  final bool isHorizontal;

  const TaskManagerLogo({
    super.key,
    this.size = 40,
    this.isHorizontal = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.check_circle_outline,
              size: size * 0.7,
              color: Colors.white,
            ),
          ],
        ),
        if (isHorizontal) ...[
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Task',
                style: TextStyle(
                  fontSize: size * 0.45,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'Manager',
                style: TextStyle(
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 203, 217, 240),
          secondary: const Color.fromARGB(255, 255, 255, 255),
        ),
        useMaterial3: true,
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          secondary: Colors.orange,
          brightness: Brightness.dark,
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = false;
  bool _showSearch = false;
  String _searchQuery = '';
  TaskSortOption _sortOption = TaskSortOption.dateCreated;
  final List<Task> _tasks = [];
  final List<String> _categories = [
    'All Tasks',
    'Work',
    'Personal',
    'Shopping'
  ];
  DateTime? _selectedDate;
  TaskPriority _selectedPriority = TaskPriority.medium;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _taskController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Task> _getFilteredAndSortedTasks(String category) {
    List<Task> filteredTasks = category == 'All Tasks'
        ? _tasks
        : _tasks.where((task) => task.category == category).toList();

    if (_searchQuery.isNotEmpty) {
      filteredTasks = filteredTasks.where((task) {
        return task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            task.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    switch (_sortOption) {
      case TaskSortOption.dateCreated:
        filteredTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case TaskSortOption.dueDate:
        filteredTasks.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
      case TaskSortOption.priority:
        filteredTasks
            .sort((a, b) => b.priority.index.compareTo(a.priority.index));
      case TaskSortOption.alphabetical:
        filteredTasks.sort((a, b) => a.title.compareTo(b.title));
    }

    return filteredTasks;
  }

  void _addTask(String title, String category) {
    if (title.isEmpty) return;

    setState(() {
      _tasks.add(Task(
        title: title,
        category: category,
        description: _descriptionController.text,
        isCompleted: false,
        dueDate: _selectedDate,
        priority: _selectedPriority,
        createdAt: DateTime.now(),
      ));
    });
    _taskController.clear();
    _descriptionController.clear();
    _selectedDate = null;
  }

  void _toggleTaskStatus(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildTaskCard(Task task, {bool isGridView = false}) {
    final Color priorityColor = task.priority.color;
    final bool isOverdue = task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        !task.isCompleted;

    return Hero(
      tag: 'task-${task.hashCode}',
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: isGridView ? 8 : 16,
          vertical: isGridView ? 8 : 8,
        ),
        color: isOverdue ? Colors.red.withOpacity(0.1) : null,
        child: InkWell(
          onTap: () => _showTaskDetails(task),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: isGridView
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: priorityColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: priorityColor.withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (task.dueDate != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: isOverdue ? Colors.red : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('MMM d, y').format(task.dueDate!),
                              style: TextStyle(
                                color:
                                    isOverdue ? Colors.red : Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  )
                : ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: task.isCompleted,
                          onChanged: (bool? value) {
                            _toggleTaskStatus(_tasks.indexOf(task));
                          },
                        ),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: priorityColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: priorityColor.withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.description.isNotEmpty)
                          Text(
                            task.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (task.dueDate != null)
                          Text(
                            'Due: ${DateFormat('MMM d, y').format(task.dueDate!)}',
                            style: TextStyle(
                              color: isOverdue ? Colors.red : null,
                            ),
                          ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editTask(task);
                        } else if (value == 'delete') {
                          setState(() {
                            _tasks.remove(task);
                          });
                        }
                      },
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _editTask(Task task) {
    _taskController.text = task.title;
    _descriptionController.text = task.description;
    _selectedPriority = task.priority;
    _selectedDate = task.dueDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'Enter task title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter task description',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                ),
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: priority.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(priority.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (TaskPriority? value) {
                  if (value != null) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'No due date'
                      : 'Due: ${DateFormat('MMM d, y').format(_selectedDate!)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _taskController.clear();
              _descriptionController.clear();
              _selectedDate = null;
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_taskController.text.isNotEmpty) {
                setState(() {
                  task.title = _taskController.text;
                  task.description = _descriptionController.text;
                  task.priority = _selectedPriority;
                  task.dueDate = _selectedDate;
                });
                Navigator.pop(context);
                _taskController.clear();
                _descriptionController.clear();
                _selectedDate = null;
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTaskDetails(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: task.priority.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (task.description.isNotEmpty) ...[
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(task.description),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                const Icon(Icons.category),
                const SizedBox(width: 8),
                Text('Category: ${task.category}'),
              ],
            ),
            const SizedBox(height: 8),
            if (task.dueDate != null) ...[
              Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8),
                  Text(
                    'Due Date: ${DateFormat('MMM d, y').format(task.dueDate!)}',
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 8),
                Text(
                  'Created: ${DateFormat('MMM d, y').format(task.createdAt)}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'Enter task title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter task description',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categories[1],
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
                items: _categories.skip(1).map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? value) {},
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                ),
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: priority.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(priority.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (TaskPriority? value) {
                  if (value != null) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'No due date'
                      : 'Due: ${DateFormat('MMM d, y').format(_selectedDate!)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _taskController.clear();
              _descriptionController.clear();
              _selectedDate = null;
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_taskController.text.isNotEmpty) {
                _addTask(_taskController.text, _categories[1]);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                autofocus: true,
              )
            : const TaskManagerLogo(),
        backgroundColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.85),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.9),
                Theme.of(context).colorScheme.secondary.withOpacity(0.7),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                }
              });
            },
          ),
          PopupMenuButton<TaskSortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (TaskSortOption value) {
              setState(() {
                _sortOption = value;
              });
            },
            itemBuilder: (context) => TaskSortOption.values.map((option) {
              return PopupMenuItem(
                value: option,
                child: Row(
                  children: [
                    Icon(
                      option.icon,
                      color: _sortOption == option
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      option.label,
                      style: TextStyle(
                        color: _sortOption == option
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        fontWeight: _sortOption == option
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categories.map((category) => Tab(text: category)).toList(),
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _categories.map((category) {
          final filteredTasks = _getFilteredAndSortedTasks(category);

          if (filteredTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No tasks yet'
                        : 'No tasks match your search',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          if (_isGridView) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                return _buildTaskCard(filteredTasks[index], isGridView: true);
              },
            );
          }

          return ListView.builder(
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              return _buildTaskCard(filteredTasks[index]);
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        label: const Text('Add Task'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

enum TaskSortOption {
  dateCreated,
  dueDate,
  priority,
  alphabetical;

  String get label {
    switch (this) {
      case TaskSortOption.dateCreated:
        return 'Date Created';
      case TaskSortOption.dueDate:
        return 'Due Date';
      case TaskSortOption.priority:
        return 'Priority';
      case TaskSortOption.alphabetical:
        return 'Alphabetical';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskSortOption.dateCreated:
        return Icons.access_time;
      case TaskSortOption.dueDate:
        return Icons.calendar_today;
      case TaskSortOption.priority:
        return Icons.flag;
      case TaskSortOption.alphabetical:
        return Icons.sort_by_alpha;
    }
  }
}

enum TaskPriority {
  low,
  medium,
  high;

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }
}

class Task {
  String title;
  String category;
  String description;
  bool isCompleted;
  DateTime? dueDate;
  TaskPriority priority;
  DateTime createdAt;

  Task({
    required this.title,
    required this.category,
    this.description = '',
    required this.isCompleted,
    this.dueDate,
    this.priority = TaskPriority.medium,
    required this.createdAt,
  });
}
