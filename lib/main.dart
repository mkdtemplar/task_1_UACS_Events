import 'package:flutter/material.dart';

import './events.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove the debug banner
        debugShowCheckedModeBanner: false,
        title: 'UACS Events',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // All journals
  List<Map<String, dynamic>> _events = [];

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshEvents() async {
    final data = await SQLHelper.getEvents();
    setState(() {
      _events = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshEvents(); // Loading the diary when the app starts
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  void _showForm(int? id) async {
    if (id != null) {
      final existingEvent =
      _events.firstWhere((element) => element['id'] == id);
      _titleController.text = existingEvent['title'];
      _descriptionController.text = existingEvent['description'];
      _durationController.text = existingEvent['eventduration'].toString();
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 120,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'Event Title'),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(hintText: 'Description'),
                keyboardType: TextInputType.text,
              ),
              TextField(
                controller: _durationController,
                decoration: const InputDecoration(hintText: 'Duration'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _addItem();
                  }

                  if (id != null) {
                    await _updateItem(id);
                  }
                  _titleController.text = '';
                  _descriptionController.text = '';
                  _durationController.text = '';
                  Navigator.of(context).pop();
                },
                child: Text(id == null ? 'Create New' : 'Update'),
              )
            ],
          ),
        ));
  }

  Future<void> _addItem() async {
    await SQLHelper.createEvent(_titleController.text,
        _descriptionController.text, int.parse(_durationController.text));
    _refreshEvents();
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(id, _titleController.text,
        _descriptionController.text, int.parse(_durationController.text));
    _refreshEvents();
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteEvent(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted event!'),
    ));
    _refreshEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UACS Events'),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) => Card(
          color: Colors.blue[200],
          margin: const EdgeInsets.all(15),
          child: ListTile(
              leading: const Icon(
                Icons.event_available,
                color: Colors.green,
              ),
              title: Text(_events[index]['title']),
              subtitle: Text(
                  '${_events[index]['description']}, Duration: ${_events[index]['eventduration']}'),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.purple,
                      ),
                      onPressed: () => _showForm(_events[index]['id']),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () => _deleteItem(_events[index]['id']),
                    ),
                  ],
                ),
              )),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
