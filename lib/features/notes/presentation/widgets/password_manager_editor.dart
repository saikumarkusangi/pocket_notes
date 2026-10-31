import 'package:flutter/material.dart';
import 'package:pocket_notes/features/notes/data/models/password_entry.dart';

class PasswordManagerEditor extends StatefulWidget {
  const PasswordManagerEditor({
    super.key,
    required this.titleController,
    required this.bodyController,
    this.titleHint = 'Password name',
    String? bodyHint,
    this.autofocusBody = false,
    this.actionButtonColor = Colors.purple,
  });

  final TextEditingController titleController;
  final TextEditingController bodyController;
  final String titleHint;
  final bool autofocusBody;
  final Color actionButtonColor;

  @override
  State<PasswordManagerEditor> createState() => _PasswordManagerEditorState();
}

class _PasswordManagerEditorState extends State<PasswordManagerEditor> {
  static const Color _generateColor = Color(0xFF22C55E);
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _backupEmailController;
  late final TextEditingController _passwordController;
  late final FocusNode _accountFocusNode;
  late String _category;
  late String _lastSyncedBody;
  bool _obscurePassword = true;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    final entry = PasswordEntry.fromBody(widget.bodyController.text);
    _category = entry.category;
    _usernameController = TextEditingController(text: entry.username);
    _emailController = TextEditingController(text: entry.email);
    _backupEmailController = TextEditingController(text: entry.backupEmail);
    _passwordController = TextEditingController(text: entry.password);
    _accountFocusNode = FocusNode();
    _lastSyncedBody = widget.bodyController.text;
    _usernameController.addListener(_syncBody);
    _emailController.addListener(_syncBody);
    _backupEmailController.addListener(_syncBody);
    _passwordController.addListener(_syncBody);
    if (widget.autofocusBody) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _accountFocusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(PasswordManagerEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bodyController.text == _lastSyncedBody) return;
    _applyEntry(PasswordEntry.fromBody(widget.bodyController.text));
    _lastSyncedBody = widget.bodyController.text;
  }

  @override
  void dispose() {
    _usernameController
      ..removeListener(_syncBody)
      ..dispose();
    _emailController
      ..removeListener(_syncBody)
      ..dispose();
    _backupEmailController
      ..removeListener(_syncBody)
      ..dispose();
    _passwordController
      ..removeListener(_syncBody)
      ..dispose();
    _accountFocusNode.dispose();
    super.dispose();
  }

  void _applyEntry(PasswordEntry entry) {
    _isApplying = true;
    _category = entry.category;
    _usernameController.text = entry.username;
    _emailController.text = entry.email;
    _backupEmailController.text = entry.backupEmail;
    _passwordController.text = entry.password;
    _isApplying = false;
    setState(() {});
  }

  void _syncBody() {
    if (_isApplying) return;
    final encoded = PasswordEntry(
      category: _category,
      username: _usernameController.text,
      email: _emailController.text,
      backupEmail: _backupEmailController.text,
      password: _passwordController.text,
    ).toBody();
    if (widget.bodyController.text == encoded) return;
    _lastSyncedBody = encoded;
    widget.bodyController.text = encoded;
  }

  void _changeCategory(String? value) {
    if (value == null || value == _category) return;
    setState(() => _category = value);
    _syncBody();
  }

  void _generatePassword() {
    _passwordController.text = PasswordEntry.generatePassword();
    setState(() => _obscurePassword = false);
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  List<String> _categoryOptions() {
    if (PasswordEntry.categories.contains(_category)) {
      return PasswordEntry.categories;
    }
    return [...PasswordEntry.categories, _category];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PasswordLabeledField(
            label: 'Account',
            child: TextField(
              controller: widget.titleController,
              focusNode: _accountFocusNode,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              style: _fieldTextStyle,
              cursorColor: widget.actionButtonColor,
              decoration: _passwordFieldDecoration(
                hintText: widget.titleHint,
                focusColor: widget.actionButtonColor,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _PasswordLabeledField(
            label: 'Category',
            child: DropdownButtonFormField<String>(
              initialValue: _category,
              items: [
                for (final category in _categoryOptions())
                  DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  ),
              ],
              onChanged: _changeCategory,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF9AA0A6),
              ),
              style: _fieldTextStyle,
              decoration: _passwordFieldDecoration(
                focusColor: widget.actionButtonColor,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _PasswordLabeledField(
            label: 'Username',
            child: TextField(
              controller: _usernameController,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username],
              style: _fieldTextStyle,
              cursorColor: widget.actionButtonColor,
              decoration: _passwordFieldDecoration(
                hintText: 'Username',
                focusColor: widget.actionButtonColor,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _PasswordLabeledField(
            label: 'Email ID',
            child: TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              style: _fieldTextStyle,
              cursorColor: widget.actionButtonColor,
              decoration: _passwordFieldDecoration(
                hintText: 'Email ID',
                focusColor: widget.actionButtonColor,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _PasswordLabeledField(
            label: 'Backup Email ID',
            child: TextField(
              controller: _backupEmailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: _fieldTextStyle,
              cursorColor: widget.actionButtonColor,
              decoration: _passwordFieldDecoration(
                hintText: 'Backup Email ID',
                focusColor: widget.actionButtonColor,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _PasswordLabeledField(
            label: 'Password',
            child: TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              style: _fieldTextStyle,
              cursorColor: widget.actionButtonColor,
              decoration: _passwordFieldDecoration(
                hintText: 'Password',
                focusColor: widget.actionButtonColor,
                suffixIcon: IconButton(
                  onPressed: _togglePasswordVisibility,
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF9AA0A6),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: _generatePassword,
            style: TextButton.styleFrom(
              foregroundColor: _generateColor,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Generate Password',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: _generateColor,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(3),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const TextStyle _fieldTextStyle = TextStyle(
  color: Color(0xFF1A1A1A),
  fontSize: 15,
  fontWeight: FontWeight.w500,
);

InputDecoration _passwordFieldDecoration({
  String? hintText,
  Widget? suffixIcon,
  required Color focusColor,
}) {
  const radius = BorderRadius.all(Radius.circular(14));
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: Color(0xFFB0B4BA), fontSize: 15),
    filled: true,
    fillColor: const Color(0xFFF4F5F7),
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: const OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide.none,
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: focusColor),
    ),
  );
}

class _PasswordLabeledField extends StatelessWidget {
  const _PasswordLabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
