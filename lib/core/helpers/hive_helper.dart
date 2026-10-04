import 'package:hive/hive.dart';

class HiveHelper {
  static const noteBox = "Note_Box";
  static const noteKey = "Note_Key";

  /// كل نوت عبارة عن Map فيها: title - content - date
  static List myNotes = [];
  static bool isNewestFirst = true;

  static Future<void> getNotes() async {
    await Future.delayed(Duration(seconds: 1));
    myNotes = await Hive.box(noteBox).get(noteKey) ?? [];
  }

  static void addNote(String title, String content) async {
    myNotes.insert(0, {
      "title": title,
      "content": content,
      "date": DateTime.now().toString(),
    });
    await Hive.box(noteBox).put(noteKey, myNotes);
  }

  static void deleteNote(int index) async {
    myNotes.removeAt(index);
    await Hive.box(noteBox).put(noteKey, myNotes);
  }

  static void deleteAllNotes() async {
    myNotes.clear();
    await Hive.box(noteBox).put(noteKey, myNotes);
  }

  static void updateNote(int index, String title, String content) async {
    myNotes[index] = {
      "title": title,
      "content": content,
      "date": DateTime.now().toString(),
    };
    await Hive.box(noteBox).put(noteKey, myNotes);
  }

  static void sortNotes() async {
    isNewestFirst = !isNewestFirst;
    myNotes.sort((a, b) {
      final dateA = DateTime.parse(a["date"]);
      final dateB = DateTime.parse(b["date"]);
      return isNewestFirst ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    });
    await Hive.box(noteBox).put(noteKey, myNotes);
  }

  /// بتحول التاريخ لشكل زي: Edited: Sun Jan 2, 2022 10:05 AM
  static String formatDate(String date) {
    final d = DateTime.parse(date);
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    ];
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, "0");
    final amPm = d.hour < 12 ? "AM" : "PM";
    return "Edited: ${days[d.weekday - 1]} ${months[d.month - 1]} ${d.day}, ${d.year} $hour:$minute $amPm";
  }

  ///Requirment:
  ///(1) add note
  ///(2) delete note
  ///(3) update note
  ///(4) delete all notes
  ///(5) search notes
  ///(6) sort notes
}
