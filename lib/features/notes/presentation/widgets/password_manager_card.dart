import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_notes/features/notes/data/models/note_model.dart';
import 'package:pocket_notes/features/notes/data/models/password_entry.dart';

class PasswordManagerCard extends StatelessWidget {
  const PasswordManagerCard({super.key, required this.note, this.onTap});

  final NoteModel note;
  final VoidCallback? onTap;

  static const List<Color> _avatarColors = [
    Color(0xFF1769FF),
    Color(0xFFE1306C),
    Color(0xFF7B61FF),
    Color(0xFF111111),
    Color(0xFF0A66C2),
    Color(0xFF16A34A),
  ];

  @override
  Widget build(BuildContext context) {
    final entry = PasswordEntry.fromBody(note.body);
    final title = note.title.trim().isEmpty ? 'Untitled' : note.title.trim();
    final email = entry.email.trim().isEmpty ? 'No email' : entry.email.trim();
    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: const Color(0x14000000),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              _PasswordAvatar(title: title),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8B9098),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _CopyPasswordButton(password: entry.password),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordAvatar extends StatelessWidget {
  const _PasswordAvatar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final letter = title.characters.first.toUpperCase();
    final colorIndex =
        title.hashCode.abs() % PasswordManagerCard._avatarColors.length;
    final color = PasswordManagerCard._avatarColors[colorIndex];
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        letter,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CopyPasswordButton extends StatelessWidget {
  const _CopyPasswordButton({required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _copyPassword(context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE4E4E7)),
          ),
          child: const Icon(
            Icons.copy_rounded,
            size: 18,
            color: Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Future<void> _copyPassword(BuildContext context) async {
    if (password.isEmpty) {
      _showMessage(context, 'No password to copy');
      return;
    }
    await Clipboard.setData(ClipboardData(text: password));
    if (!context.mounted) return;
    _showMessage(context, 'Password copied');
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
