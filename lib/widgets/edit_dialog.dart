import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
import '../photo/bloc/photo_bloc.dart';
// import '../bloc/publish.dart';
import '../values/bloc/available_values_bloc.dart';
// import '../widgets/auto_suggest_field.dart';
// import '../widgets/auto_suggest_multi_select.dart';
import '../widgets/datetime_widget.dart';
import '../helpers/read_exif.dart';
import '../photo/models/photo.dart';
// import '../helpers/common.dart';

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
  void initState() {
    super.initState();
    _record = {...widget.editRecord.toMap()};
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final _controllerHeadline = TextEditingController(
      text: _record['headline'],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<PhotoBloc>(create: (context) => PhotoBloc()),
        // BlocProvider<PublishCubit>(create: (context) => PublishCubit()),
      ],
      child: Dialog(
        child: SizedBox(
          // width: width,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Edit'),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      ElevatedButton(
                        child: const Text('Read Exif'),
                        onPressed: () {
                          readExif(_record['filename']);
                        },
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        child: const Text('Save'),
                        onPressed: () {
                          _formKey.currentState!.save();
                          if (_record.containsKey('thumb')) {
                            PhotoBloc().add(PhotoUpdate(_record as Photo));
                          } else {
                            PhotoBloc().add(PhotoAdd(_record as Photo));
                            PhotoBloc().add(
                              PhotoPublish(_record as Photo, true),
                            );
                          }
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
                              decoration: const InputDecoration(
                                labelText: 'ISO',
                              ),
                              controller: TextEditingController(
                                text: _record['iso'].toString(),
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    if (width > 600) SizedBox(width: 16),
                    BlocBuilder<AvailableValuesBloc, AvailableValuesState>(
                      builder: (context, values) {
                        return Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _controllerHeadline,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter Headline.';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Headline',
                                  suffixIcon:
                                      _controllerHeadline.text.isEmpty
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
                              // AutoSuggestField(
                              //   hintText: 'email',
                              //   initialValue: _record['email'],
                              //   options: values.email!.keys.toList(),
                              //   onChanged: (value) {
                              //     setState(() {
                              //       _record['email'] = value!;
                              //     });
                              //   },
                              // ),
                              // AutoSuggestMultiSelect(
                              //   hintText: 'tags',
                              //   initialValues: List<String>.from(
                              //     _record['tags'] as List,
                              //   ),
                              //   options: values.tags!.keys.toList(),
                              //   onChanged: (value) {
                              //     setState(() {
                              //       _record['tags'] = value;
                              //     });
                              //   },
                              // ),
                              // AutoSuggestField(
                              //   hintText: 'by make',
                              //   initialValue: _record['model'],
                              //   options: values.model!.keys.toList(),
                              //   onChanged: (value) {
                              //     setState(() {
                              //       _record['model'] = value;
                              //     });
                              //   },
                              // ),
                              // AutoSuggestField(
                              //   hintText: 'lens',
                              //   initialValue: _record['lens'],
                              //   options: values.lens!.keys.toList(),
                              //   onChanged: (value) {
                              //     setState(() {
                              //       _record['lens'] = value;
                              //     });
                              //   },
                              // ),
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
                                controlAffinity:
                                    ListTileControlAffinity.leading,
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
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
