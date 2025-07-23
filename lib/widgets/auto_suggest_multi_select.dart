import 'package:flutter/material.dart';

class AutoSuggestMultiSelect extends StatefulWidget {
  final List<String> options;
  final List<String> initialValues;
  final String hintText;
  final ValueChanged<List<String>> onChanged;

  const AutoSuggestMultiSelect({
    super.key,
    this.initialValues = const [],
    required this.options,
    this.hintText = '',
    required this.onChanged,
  });

  @override
  State<AutoSuggestMultiSelect> createState() => _AutoSuggestMultiSelectState();
}

class _AutoSuggestMultiSelectState extends State<AutoSuggestMultiSelect> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late List<String> _selected;
  List<String> _filteredOptions = [];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValues;
    _filteredOptions = widget.options;
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = _textController.text.toLowerCase();
    setState(() {
      _filteredOptions =
          widget.options
              .where(
                (option) =>
                    option.toLowerCase().contains(text) &&
                    !_selected.contains(option),
              )
              .toList();
    });
  }

  void _addOption(String value) {
    if (!_selected.contains(value)) {
      setState(() {
        _selected.add(value);
        _textController.clear();
        _filteredOptions =
            widget.options.where((opt) => !_selected.contains(opt)).toList();
        widget.onChanged(_selected);
      });
    }
  }

  void _removeOption(String value) {
    setState(() {
      _selected.remove(value);
      _filteredOptions =
          widget.options.where((opt) => !_selected.contains(opt)).toList();
      widget.onChanged(_selected);

      if (_selected.isEmpty) {
        _textController.clear(); // Reset the text field
        _filteredOptions = widget.options;
        _focusNode.unfocus(); // Reset the options
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _textController,
          focusNode: _focusNode,
          decoration: InputDecoration(hintText: widget.hintText),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _selected
                    .map(
                      (e) => Chip(
                        label: Text(e),
                        onDeleted: () => _removeOption(e),
                      ),
                    )
                    .toList(),
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
                    onTap: () => _addOption(option),
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
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
