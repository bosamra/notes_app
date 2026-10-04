import 'package:notes_app/core/helpers/hive_helper.dart';
import 'package:flutter/material.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _key = GlobalKey<FormState>();
  bool _isLoading = false;
  String _search = "";

  final List<Color> _colors = [
    Color(0xFFD0E4FF),
    Color(0xFFFDECEC),
    Color(0xFFFCEFC7),
    Color(0xFFFDE8E8),
    Color(0xFFE8E8E8),
    Color(0xFFD9F2E6),
  ];

  @override
  void didChangeDependencies() async {
    _isLoading = true;
    await HiveHelper.getNotes();
    _isLoading = false;
    setState(() {});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    /// النوتس بعد البحث
    final filteredNotes = HiveHelper.myNotes
        .where(
          (note) =>
              note["title"].toLowerCase().contains(_search.toLowerCase()) ||
              note["content"].toLowerCase().contains(_search.toLowerCase()),
        )
        .toList();

    return Scaffold(
      backgroundColor: Color(0xFF252525),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _titleController.text = "";
          _contentController.text = "";
          showDialog(
            context: context,
            barrierDismissible: false, // User must tap a button to dismiss
            builder: (BuildContext context) {
              return Form(
                key: _key,
                child: AlertDialog(
                  backgroundColor: Color(0xFF3B3B3B),
                  title: const Text('Add Note'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(hintText: "Title"),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "You should add a title";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _contentController,
                        maxLines: 4,
                        decoration: InputDecoration(hintText: "Content"),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "You should add any content";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        // Get.back();
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      child: const Text('Add'),
                      onPressed: () {
                        if (_key.currentState!.validate()) {
                          HiveHelper.addNote(
                            _titleController.text,
                            _contentController.text,
                          );
                          setState(() {
                            Navigator.pop(context);
                            _titleController.text = "";
                            _contentController.text = "";
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        backgroundColor: Color(0xFF3B3B3B),
        shape: CircleBorder(),
        child: Icon(Icons.add, color: Colors.white, size: 32),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),

              /// Header
              Row(
                children: [
                  Text(
                    "Notes",
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      HiveHelper.sortNotes();
                      setState(() {});
                    },
                    onLongPress: () {
                      HiveHelper.deleteAllNotes();
                      setState(() {});
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF3B3B3B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.sort, color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              /// Search
              TextField(
                onChanged: (value) {
                  setState(() {
                    _search = value;
                  });
                },
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search notes...",
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Color(0xFF3B3B3B),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),

              /// Notes
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : filteredNotes.isEmpty
                    ? Center(
                        child: Text(
                          "No notes",
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredNotes.length,
                        itemBuilder: (context, i) {
                          final note = filteredNotes[i];

                          /// الاندكس الحقيقي جوه myNotes (عشان البحث)
                          final index = HiveHelper.myNotes.indexOf(note);

                          return InkWell(
                            onTap: () {
                              _titleController.text = note["title"];
                              _contentController.text = note["content"];
                              showDialog(
                                context: context,
                                barrierDismissible:
                                    false, // User must tap a button to dismiss
                                builder: (BuildContext context) {
                                  return Form(
                                    key: _key,
                                    child: AlertDialog(
                                      backgroundColor: Color(0xFF3B3B3B),
                                      title: const Text('Update Note'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextFormField(
                                            controller: _titleController,
                                            decoration: InputDecoration(
                                              hintText: "Title",
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "You should add a title";
                                              }
                                              return null;
                                            },
                                          ),
                                          TextFormField(
                                            controller: _contentController,
                                            maxLines: 4,
                                            decoration: InputDecoration(
                                              hintText: "Content",
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "You should add any content";
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () {
                                            // Get.back();
                                            Navigator.pop(context);
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('Update'),
                                          onPressed: () {
                                            if (_key.currentState!.validate()) {
                                              HiveHelper.updateNote(
                                                index,
                                                _titleController.text,
                                                _contentController.text,
                                              );
                                              setState(() {
                                                Navigator.pop(context);
                                                _titleController.text = "";
                                                _contentController.text = "";
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 16),
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: _colors[index % _colors.length],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          note["title"],
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          note["content"],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          HiveHelper.formatDate(note["date"]),
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor: Color(0xFF3B3B3B),
                                            icon: Icon(
                                              Icons.info,
                                              color: Colors.grey,
                                            ),
                                            title: Text(
                                              "Are you sure you want to delete?",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                            actionsAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            actions: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  minimumSize: Size(80, 36),
                                                ),
                                                onPressed: () {
                                                  HiveHelper.deleteNote(index);
                                                  setState(() {
                                                    Navigator.pop(context);
                                                  });
                                                },
                                                child: Text(
                                                  "Yes",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  minimumSize: Size(80, 36),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  "No",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///Requirment:
///(1) add note
///(2) delete note
///(3) update note
///(4) delete all notes
///(5) search notes
///(6) sort notes
