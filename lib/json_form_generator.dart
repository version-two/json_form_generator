library json_form_generator;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JsonFormGenerator extends StatefulWidget {
  final String form;
  final ValueChanged<dynamic> onChanged;

  JsonFormGenerator({
    @required this.form,
    @required this.onChanged,
  });

  @override
  _JsonFormGeneratorState createState() =>
      _JsonFormGeneratorState(json.decode(form));
}

class _JsonFormGeneratorState extends State<JsonFormGenerator> {
  final dynamic formItems;

  _JsonFormGeneratorState(this.formItems);

  void _handleChanged() {
    widget.onChanged(formResults);
  }

  final Map<String, dynamic> formResults = {};

  List<Widget> jsonToForm() {
    List<Widget> listWidget = new List<Widget>();

    for (var item in formItems) {
      switch (item['type']) {
        case 'text':
        case 'integer':
        case 'password':
        case 'multiline':
          listWidget.add(inputField(item));
          break;
        case 'select':
          listWidget.add(selectField(item));
          break;
        case 'radio':
          listWidget.addAll(radioField(item));
          break;
        case 'checkbox':
          listWidget.addAll(checkboxField(item));
          break;
        case 'switch':
          listWidget.add(switchField(item));
          break;
        case 'date':
          listWidget.add(dateField(item));
          break;
      }
    }
    return listWidget;
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: EdgeInsets.all(30),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: jsonToForm(),
      ),
    );
  }

  Widget dateField(inputDefinition) {
    Future _selectDate() async {
      DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1880),
        lastDate: DateTime(2021),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.light(),
            child: child,
          );
        },
      );
      if (picked != null)
        setState(() => formResults[inputDefinition["title"]] =
            picked.toString().substring(0, 10));
    }

    return Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        child: TextFormField(
          autofocus: false,
          readOnly: true,
          controller: TextEditingController(
              text: formResults[inputDefinition["title"]]),
          validator: (String value) {
            if (value.isEmpty) {
              return 'Please  ${inputDefinition['title']} cannot be empty';
            }
            return null;
          },
          onChanged: (String value) {},
          onTap: () async {
            await _selectDate();
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            labelText: inputDefinition["label"],
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
            suffixIcon: Icon(
              Icons.calendar_today,
            ),
          ),
        ));
  }

  Widget selectField(Map<String, dynamic> inputDefinition) {
    List<DropdownMenuItem<String>> castItems = [];
    if (inputDefinition['items'] is Map) {
      var items = Map<dynamic, dynamic>.from(inputDefinition['items']);

      items.forEach((k, v) {
        castItems.add(DropdownMenuItem<String>(
          value: k,
          child: Text(v),
        ));
      });
    } else {
      var items = List.from(inputDefinition['items']);
      items.forEach((v) {
        castItems.add(DropdownMenuItem<String>(
          value: v,
          child: Text(v),
        ));
      });
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          ),
          hint: Text('Select ${inputDefinition['title']}'),
          validator: (String value) {
            if (inputDefinition['required'] == 'no') {
              return null;
            }
            if (value == null) {
              return 'Please ${inputDefinition['title']} cannot be empty';
            }
            return null;
          },
          value: formResults[inputDefinition["title"]],
          isExpanded: true,
          style: Theme.of(context).textTheme.subhead,
          onChanged: (String newValue) {
            setState(() {
              formResults[inputDefinition["title"]] = newValue;
              _handleChanged();
            });
          },
          items: castItems),
    );
  }

  Widget inputField(Map<String, dynamic> inputDefinition) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        autofocus: false,
        onChanged: (String value) {
          formResults[inputDefinition["title"]] = value;
          _handleChanged();
        },
        inputFormatters: inputDefinition['type'] == 'integer'
            ? [WhitelistingTextInputFormatter(RegExp('[0-9]'))]
            : null,
        keyboardType:
            inputDefinition['type'] == 'integer' ? TextInputType.number : null,
        validator: (String value) {
          if (inputDefinition['required'] == 'no') {
            return null;
          }
          if (value.isEmpty) {
            return 'Please ${inputDefinition['title']} cannot be empty';
          }
          return null;
        },
        maxLines: inputDefinition['type'] == "multiline" ? 10 : 1,
        obscureText: inputDefinition['type'] == "password" ? true : false,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          labelText: inputDefinition['label'],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
      ),
    );
  }

  List<Widget> radioField(inputDefinition) {
    formResults["${inputDefinition["title"]}"] =
        formResults["${inputDefinition["title"]}"] == null
            ? ''
            : formResults["${inputDefinition["title"]}"];
    List<Widget> radioList = [];
    radioList.add(new Container(
        margin: new EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: new Text(inputDefinition['label'],
            style:
                new TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0))));

    for (var i = 0; i < inputDefinition['items'].length; i++) {
      radioList.add(
        new Row(
          children: <Widget>[
            new Expanded(child: new Text(inputDefinition['items'][i])),
            new Radio<dynamic>(
                hoverColor: Colors.red,
                value: inputDefinition['items'][i],
                groupValue: formResults["${inputDefinition["title"]}"],
                onChanged: (dynamic value) {
                  setState(() {
                    formResults[inputDefinition["title"]] = value;
                  });

                  _handleChanged();
                })
          ],
        ),
      );
    }
    return radioList;
  }

  Widget switchField(inputDefinition) {
    if (formResults["${inputDefinition["title"]}"] == null) {
      setState(() {
        formResults["${inputDefinition["title"]}"] = false;
      });
    }
    return Row(
      children: <Widget>[
        new Expanded(child: new Text(inputDefinition["label"])),
        Switch(
            value: formResults[inputDefinition["title"]],
            onChanged: (bool value) {
              setState(() {
                formResults[inputDefinition["title"]] = value;
                _handleChanged();
              });
            }),
      ],
    );
  }

  Iterable<Widget> checkboxField(inputDefinition) {
    List<Widget> checkboxList = [];

    if (!formResults.containsKey(inputDefinition["title"])) {
      setState(() {
        formResults[inputDefinition["title"]] = new Map<String, bool>();
      });
    }

    checkboxList.add(new Container(
        margin: new EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: new Text(inputDefinition['label'],
            style:
                new TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0))));

    if (inputDefinition['items'] is Map) {
      var items = Map<dynamic, dynamic>.from(inputDefinition['items']);

      items.forEach((k, v) {
        checkboxList.add(CheckboxListTile(
          title: Text(v),
          value: formResults[inputDefinition["title"]][k.toString()] ?? false,
          onChanged: (newValue) {
            setState(() {
              formResults[inputDefinition["title"]][k.toString()] = newValue;
              _handleChanged();
            });
          },
          //controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
        ));
      });
    } else {
      var items = List.from(inputDefinition['items']);
      items.forEach((v) {
        checkboxList.add(CheckboxListTile(
          title: Text(v),
          value: formResults[inputDefinition["title"]][v.toString()] ?? false,
          onChanged: (newValue) {
            setState(() {
              formResults[inputDefinition["title"]][v.toString()] = newValue;
              _handleChanged();
            });
          },
          //controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
        ));
      });
    }

    return checkboxList;
  }
}
