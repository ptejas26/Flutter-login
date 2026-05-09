import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';

class TaskListScreen extends StatefulWidget {

  final User user;

  const TaskListScreen({super.key, required this.user});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // Now using the Task model instead of dynamic
  List<Task> _tasks = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;

  // State for API Query Params
  bool? _filterCompleted; // null: all, true: completed, false: pending
  int _currentSkip = 0;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks({bool isRefresh = true}) async {
    if (isRefresh) {
      setState(() {
        _isLoading = true;
        _currentSkip = 0;
      });
    }

    final result = await ApiService.getTasks(
      completed: _filterCompleted,
      limit: _limit,
      skip: _currentSkip,
    );

    if (mounted && result['success']) {
      // Map the dynamic list from JSON to our Task objects
      final List<Task> fetchedTasks = (result['data'] as List)
          .map((json) => Task.fromJson(json))
          .toList();

      setState(() {
        if (isRefresh) {
          _tasks = fetchedTasks;
        } else {
          _tasks.addAll(fetchedTasks);
        }
        _isLoading = false;
        _isLoadingMore = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Error fetching tasks')),
      );
    }
  }

  void _loadMore() {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
      _currentSkip += _limit;
    });
    _fetchTasks(isRefresh: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Your Slate-50 background
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
                : RefreshIndicator(
              onRefresh: () => _fetchTasks(isRefresh: true),
              child: _tasks.isEmpty ? _buildEmptyState() : _buildList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { /* Navigate to CreateTaskScreen */ },
        backgroundColor: const Color(0xFF3B82F6),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Task Manager',
        style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
      ),
      actions: [
        TextButton.icon(
          onPressed: _isLoading ? null : _handleLogout,
          icon: _isLoading
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
            ),
          )
              : const Icon(
            Icons.logout,
            color: Color(0xFFEF4444),
            size: 18,
          ),
          label: const Text(
            'Logout',
            style: TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        )
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFFE5E7EB), height: 1),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      color: Colors.white,
      child: Row(
        children: [
          _filterChip("All", null),
          const SizedBox(width: 8),
          _filterChip("Pending", false),
          const SizedBox(width: 8),
          _filterChip("Completed", true),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool? value) {
    final bool isSelected = _filterCompleted == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _filterCompleted = value);
          _fetchTasks();
        }
      },
      selectedColor: const Color(0xFF3B82F6),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF64748B),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: const Color(0xFFF1F5F9),
      elevation: 0,
      pressElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.all(20), // Add padding here for better spacing
      itemCount: _tasks.length + 1, // +1 to accommodate the "Load More" button
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == _tasks.length) {
          return _buildLoadMoreButton(); // Append the button to the end of the list
        }
        final task = _tasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: GestureDetector(
          onTap: () { /* Logic to call API and toggle completed */ },
          child: Icon(
            task.completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: task.completed ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
            size: 28,
          ),
        ),
        title: Text(
          task.description,
          style: TextStyle(
            decoration: task.completed ? TextDecoration.lineThrough : null,
            color: task.completed ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            "Created: ${task.createdAt.day}/${task.createdAt.month}/${task.createdAt.year}",
            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
        ),
        trailing: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    // Only show if we potentially have more tasks to load
    if (_tasks.length < _limit) return const SizedBox(height: 40);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: _isLoadingMore
            ? const CircularProgressIndicator(strokeWidth: 2)
            : TextButton(
          onPressed: _loadMore,
          child: const Text(
            "Load More Tasks",
            style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment_turned_in_outlined, size: 64, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          const Text(
            "No tasks found",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          Text(
            _filterCompleted == null ? "Start by adding a new task!" : "No tasks match this filter.",
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await StorageService.getAuthToken();
      final result = await ApiService.logout(
          email: widget.user.email,
          token: '$token'
      );

      if (result['success']) {
        await StorageService.clearAll();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged out successfully'),
              backgroundColor: Color(0xFF10B981),
            ),
          );

          // Navigate back to login screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error during logout, please try again'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
