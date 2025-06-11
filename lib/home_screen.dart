import 'package:flutter/material.dart';
import 'package:todo_UASMDI/auth_service.dart';
import 'package:todo_UASMDI/signin_screen.dart';
import 'package:todo_UASMDI/google_calender_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> todoList = [];
  final TextEditingController _controller = TextEditingController();
  int updateIndex = -1;

  void addList(String task) async {
    if (task.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task cannot be empty!")),
      );
      return;
    }
    setState(() {
      todoList.add(task);
      _controller.clear();
    });

    // Tambahkan ke Google Calendar
    try {
      await GoogleCalendarService().insertEvent(task);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task added to Google Calendar")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add to Google Calendar. Check your Google Calendar API setup and internet connection.")),
      );
      print('Error adding to Google Calendar: $e'); // Untuk debugging
    }
  }

  void updateListItem(String task, int index) {
    if (task.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task cannot be empty!")),
      );
      return;
    }
    setState(() {
      todoList[index] = task;
      updateIndex = -1;
      _controller.clear();
    });
  }

  void deleteItem(int index) {
    setState(() {
      todoList.removeAt(index);
    });
  }

  void _signOut(BuildContext context) async {
    await AuthService().signOut();
    // Gunakan pushReplacement untuk mencegah pengguna kembali ke HomeScreen setelah logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50, // Latar belakang lebih terang
      appBar: AppBar(
        title: const Text(
          "My Todo List",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26, // Ukuran font lebih besar
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700, // Warna biru tua untuk AppBar
        elevation: 4, // Menambahkan sedikit bayangan untuk efek modern
        actions: [
          IconButton(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout, color: Colors.white, size: 28),
            tooltip: 'Sign Out', // Tooltip untuk aksesibilitas
          ),
          const SizedBox(width: 10), // Memberi sedikit jarak
        ],
      ),
      body: Padding( // Menggunakan Padding alih-alih Container margin
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: todoList.isEmpty
                  ? Center(
                      child: Text(
                        "No tasks yet! Add one below.",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blueGrey.shade600,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: todoList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0), // Jarak antar card
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15), // Sudut lebih membulat
                          ),
                          color: Colors.blue.shade600, // Warna biru menengah untuk Card
                          elevation: 3, // Bayangan untuk kesan elegan
                          child: Padding( // Padding di dalam Card
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    todoList[index],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600, // Sedikit lebih tebal
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _controller.clear();
                                      _controller.text = todoList[index];
                                      updateIndex = index;
                                    });
                                  },
                                  icon: const Icon(Icons.edit_note, size: 28, color: Colors.white70), // Icon edit yang lebih relevan
                                  tooltip: 'Edit Task',
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => deleteItem(index),
                                  icon: const Icon(Icons.delete_forever, size: 28, color: Colors.white70), // Icon delete yang lebih relevan
                                  tooltip: 'Delete Task',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20), // Jarak antara daftar dan input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: updateIndex != -1 ? 'Edit Task' : 'Add New Task...',
                      labelStyle: TextStyle(color: Colors.blueGrey.shade700),
                      hintText: 'Enter your task here',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), // Sudut membulat
                        borderSide: BorderSide.none, // Menghilangkan border default
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade700, width: 2), // Border fokus warna biru tua
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade300), // Border normal warna biru terang
                      ),
                      filled: true,
                      fillColor: Colors.blue.shade50, // Warna latar belakang input
                      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12), // Jarak antara input dan tombol
                FloatingActionButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      updateIndex != -1
                          ? updateListItem(_controller.text, updateIndex)
                          : addList(_controller.text);
                    } else {
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Task field cannot be empty!")),
                      );
                    }
                  },
                  backgroundColor: Colors.blue.shade700, // Warna biru tua untuk FAB
                  foregroundColor: Colors.white,
                  elevation: 5, // Bayangan lebih kuat
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Membuat FAB berbentuk persegi panjang dengan sudut membulat
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(updateIndex != -1 ? Icons.check_circle_outline : Icons.add, size: 30), // Icon yang lebih modern
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}