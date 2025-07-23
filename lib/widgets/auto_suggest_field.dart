import 'package:flutter/material.dart';

class AutoSuggestField extends StatefulWidget {
  final List<String> options;
  final String? initialValue;
  final String hintText;
  final ValueChanged<String?> onChanged;

  const AutoSuggestField({
    required this.options,
    this.initialValue,
    required this.hintText,
    required this.onChanged,
    super.key,
  });

  @override
  State<AutoSuggestField> createState() => _AutoSuggestFieldState();
}

class _AutoSuggestFieldState extends State<AutoSuggestField> {
  late TextEditingController _controller;
  List<String> _filteredOptions = [];
  String? _selectedValue;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    _controller = TextEditingController(text: _selectedValue ?? '');
    _filteredOptions = widget.options;
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = _controller.text.toLowerCase();
    setState(() {
      _filteredOptions =
          widget.options
              .where((option) => option.toLowerCase().contains(text))
              .toList();
    });
  }

  void _selectOption(String value) {
    setState(() {
      _selectedValue = value;
      _controller.text = value;
      widget.onChanged(value);
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.hintText,
            suffixIcon:
                _controller
                        .text
                        .isNotEmpty // Show clear button only if input exists
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _controller.clear();
                          _filteredOptions = widget.options;
                          _selectedValue = null;
                          _focusNode.unfocus();
                          widget.onChanged(null);
                        });
                      },
                    )
                    : null,
          ),
        ),
        if (_focusNode.hasFocus && _filteredOptions.isNotEmpty)
          Material(
            elevation: 4,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 200),
              child: ListView.builder(
                itemCount: _filteredOptions.length,
                itemBuilder: (context, index) {
                  final option = _filteredOptions[index];
                  return ListTile(
                    title: Text(option),
                    onTap: () => _selectOption(option),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
