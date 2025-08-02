import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../photo/bloc/photo_bloc.dart';
import '../values/bloc/available_values_bloc.dart';
import '../widgets/datetime_widget.dart';
import '../helpers/read_exif.dart';
import '../photo/models/photo.dart';
import 'auto_suggest_multi_field.dart';

class EditDialog extends StatefulWidget {
  final Photo editRecord;

  const EditDialog({super.key, required this.editRecord});

  @override
  State<StatefulWidget> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _record = {};

  @override
  void initState() async {
    super.initState();
    _record = {...widget.editRecord.toMap()};
    // if (!_record.containsKey('thumb') {
    //    Map<String, dynamic> exif = await readExif(
    //       _record['filename'],
    //     );
    //     _record = {..._record, ...exif};
    //     print(_record);
    // }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final controllerHeadline = TextEditingController(text: _record['headline']);

    return MultiBlocProvider(
      providers: [
        BlocProvider<PhotoBloc>(create: (context) => PhotoBloc()),
        BlocProvider<AvailableValuesBloc>(
          create:
              (context) => AvailableValuesBloc()..add(FetchAvailableValues()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.close), // Close button
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Edit'),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  ElevatedButton(
                    child: const Text('Read Exif'),
                    onPressed: () async {
                      Map<String, dynamic> exif = await readExif(
                        _record['filename'],
                      );
                      _record = {..._record, ...exif};
                    },
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    child: const Text('Save'),
                    onPressed: () {
                      _formKey.currentState!.save();
                      print('\n\nedited photo $_record');
                      // if (_record.containsKey('thumb')) {
                      //   PhotoBloc().add(PhotoUpdate(_record as Photo));
                      // } else {
                      //   PhotoBloc().add(PhotoAdd(_record as Photo));
                      // }
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (width > 600)
                  Expanded(
                    child: Column(
                      children: [
                        Image.network(
                          _record.containsKey('thumb')
                              ? _record['thumb']
                              : _record['url'],
                          width: 400,
                          // height: 400,
                          fit: BoxFit.cover,
                        ),
                        TextFormField(
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Aperture',
                          ),
                          controller: TextEditingController(
                            text: _record['aperture'].toString(),
                          ),
                          textAlign: TextAlign.right,
                        ),
                        TextFormField(
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Shutter',
                          ),
                          controller: TextEditingController(
                            text: _record['shutter'],
                          ),
                        ),
                        TextFormField(
                          enabled: false,
                          decoration: const InputDecoration(labelText: 'ISO'),
                          controller: TextEditingController(
                            text: _record['iso'].toString(),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                if (width > 600) SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: controllerHeadline,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter Headline.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Headline',
                          suffixIcon:
                              controllerHeadline.text.isEmpty
                                  ? null
                                  : IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _record['headline'] = '';
                                      });
                                    },
                                  ),
                        ),
                        onSaved:
                            (value) => {
                              setState(() {
                                _record['headline'] = value!;
                              }),
                            },
                      ),
                      DatetimeWidget(
                        dateAndTime: _record['date'],
                        format: 'yyyy-MM-dd HH:mm',
                        labelText: 'Date',
                        onDone: (value) {
                          setState(() {
                            _record['date'] = value;
                          });
                        },
                      ),
                      TextFormField(
                        enabled: false,
                        controller: TextEditingController(
                          text: _record['filename'],
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Filename',
                        ),
                      ),
                      AutoSuggestMultiField(
                        fields: [
                          FieldConfig(
                            fieldKey: 'email',
                            hintText: 'photographer',
                            options:
                                AvailableValuesBloc().state.email!.keys
                                    .toList(),
                          ),
                          FieldConfig(
                            fieldKey: 'tags',
                            hintText: 'tags',
                            options:
                                AvailableValuesBloc().state.tags!.keys.toList(),
                            multiSelect: true,
                          ),
                          FieldConfig(
                            fieldKey: 'model',
                            hintText: ' camera model',
                            options:
                                AvailableValuesBloc().state.model!.keys
                                    .toList(),
                          ),
                          FieldConfig(
                            fieldKey: 'lens',
                            hintText: 'lens',
                            options:
                                AvailableValuesBloc().state.lens!.keys.toList(),
                          ),
                        ],
                        initialValues: {
                          'email': _record['email'],
                          'tags': _record['tags'],
                          'model': _record['model'],
                          'lens': _record['lens'],
                        },
                        onChanged: (values) {
                          setState(() {
                            _record['email'] = values['email'];
                            _record['tags'] = values['tags'];
                            _record['lens'] = values['lens'];
                          });
                        },
                      ),
                      TextFormField(
                        controller: TextEditingController(
                          text: _record['loc'] ?? '',
                        ),
                        decoration: InputDecoration(
                          labelText: 'GPS location',
                          hintText: 'latitude, longitude',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _record['loc'] = '';
                              });
                            },
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _record['loc'] = value;
                          });
                        },
                      ),
                      CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text('Flash fired'),
                        value: _record['flash'] ?? false,
                        tristate: false,
                        onChanged: (value) {
                          setState(() {
                            _record['flash'] = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
