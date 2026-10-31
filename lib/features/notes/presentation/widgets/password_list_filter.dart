import 'package:pocket_notes/features/notes/data/models/password_entry.dart';

class PasswordListFilter {
  const PasswordListFilter._();

  static const String all = 'All';

  static List<String> labelsFor(Iterable<String> categories) {
    final present = categories.toSet();
    final labels = <String>[all];
    for (final category in PasswordEntry.categories) {
      if (present.contains(category)) labels.add(category);
    }
    final extras =
        present
            .where((category) => !PasswordEntry.categories.contains(category))
            .toList()
          ..sort();
    labels.addAll(extras);
    return labels;
  }

  static bool matches({required String category, required String selected}) {
    if (selected == all) return true;
    return category == selected;
  }
}
