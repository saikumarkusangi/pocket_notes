import 'package:pocket_notes/features/notes/data/models/note_model.dart';

/// Temporary sample data until notes persistence is wired up.
class NotesSampleData {
  static final List<NoteModel> notes = [
    NoteModel(
      id: '1',
      title: 'Tax payment before the end of march',
      body:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      createdAt: DateTime(2024, 11, 25),
    ),
    NoteModel(
      id: '2',
      title: 'Weekend plans',
      body:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      createdAt: DateTime(2024, 11, 25),
      isIdea: true,
    ),
    NoteModel(
      id: '3',
      title: 'Grocery reminders',
      body:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      createdAt: DateTime(2024, 11, 25),
    ),
    NoteModel(
      id: '4',
      title: 'Project ideas',
      body:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      createdAt: DateTime(2024, 11, 25),
      isIdea: true,
    ),
    NoteModel(
      id: '5',
      title: 'Meeting notes',
      body:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      createdAt: DateTime(2024, 11, 25),
    ),
  ];

  static NoteModel? findById(String id) {
    for (final note in notes) {
      if (note.id == id) return note;
    }
    return null;
  }
}
