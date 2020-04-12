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

  Map<String, dynamic> radioValueMap = {};
  Map<String, dynamic> dropDownMap = {};
  Map<String, String> _dateValueMap = {};
  Map<String, bool> switchValueMap = {};

  void updateSwitchValue(dynamic item, bool value) {
    setState(() {
      switchValueMap[item] = value;
    });
  }

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

  Widget dateField(itemDefinition) {
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
        setState(() => _dateValueMap[itemDefinition["title"]] =
            picked.toString().substring(0, 10));
      //print(_dateValueMap[itemDefinition['title']]);
    }

    return Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        child: TextFormField(
          autofocus: false,
          readOnly: true,
          controller: TextEditingController(
              text: _dateValueMap[itemDefinition["title"]]),
          validator: (String value) {
            if (value.isEmpty) {
              return 'Please  cannot be empty';
            }
            return null;
          },
          onChanged: (String value) {
            //print("object");
          },
          onTap: () async {
            await _selectDate();
            formResults[itemDefinition["title"]] =
                _dateValueMap[itemDefinition["title"]].trim();
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            labelText: itemDefinition["label"],
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
    if(inputDefinition['items'] is Map) {
      //print('Type: map');
      var items = Map<dynamic, dynamic>.from(inputDefinition['items']);

      items.forEach((k, v) {
        castItems.add(DropdownMenuItem<String>(
          value: k,
          child: Text(v),
        ));
      });
    }else{
      //print('Type: list');
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
          value: dropDownMap[inputDefinition["title"]],
          isExpanded: true,
          style: Theme.of(context).textTheme.subhead,
          onChanged: (String newValue) {
            //print("New value: " + newValue);
            setState(() {
              dropDownMap[inputDefinition["title"]] = newValue;
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

  List<Widget> radioField(item) {
    radioValueMap["${item["title"]}"] =
        radioValueMap["${item["title"]}"] == null
            ? 'lost'
            : radioValueMap["${item["title"]}"];
    List<Widget> radioList;
    radioList.add(new Container(
        margin: new EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: new Text(item['label'],
            style:
                new TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0))));

    for (var i = 0; i < item['items'].length; i++) {
      radioList.add(
        new Row(
          children: <Widget>[
            new Expanded(child: new Text(item['items'][i])),
            new Radio<dynamic>(
                hoverColor: Colors.red,
                value: item['items'][i],
                groupValue: radioValueMap["${item["title"]}"],
                onChanged: (dynamic value) {
                  print(value);
                  setState(() {
                    radioValueMap["${item["title"]}"] = value;
                  });
                  formResults[item["title"]] = value;

                  _handleChanged();
                })
          ],
        ),
      );
    }
    return radioList;
  }

  Widget switchField(item) {
    if (switchValueMap["${item["title"]}"] == null) {
      formResults[item["title"]] = false;
      setState(() {
        switchValueMap["${item["title"]}"] = false;
      });
    }
    return Row(
      children: <Widget>[
        new Expanded(child: new Text(item["label"])),
        Switch(
            value: switchValueMap["${item["title"]}"],
            onChanged: (bool value) {
              updateSwitchValue(item["title"], value);
              formResults[item["title"]] = value;
              _handleChanged();
            }),
      ],
    );
  }
}
