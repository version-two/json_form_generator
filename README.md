# json_form_generator

# Easily Convert Json to Form for Flutter apps.

<p align="center">
  <img src="https://raw.githubusercontent.com/Emex4gman/json_form_generator/master/images/image1.png" width="350"/>
  <img src="https://raw.githubusercontent.com/Emex4gman/json_form_generator/master/images/image2.png" width="350"/>
</p>

## Instalation

- Add this to your package's pubspec.yaml file:

```
dependencies:
  json_form_generator: any
```

- You can install packages from the command line:
  with Flutter:

```
$ flutter packages get
```

- Import it Now in your Dart code, you can use:

```
 import 'package:json_form_generator/json_form_generator.dart';
```

### JsonFormGenerator

```
new JsonFormGenerator(
    form: form,
    onChanged: (dynamic response) {
        this.response = response;
    },
),
```

### Attribute

- form (Type String) Your form in String
- onChanged (Type Function)(1 parameter) call the function every time a change in the form is made

### Form

Create Form String

```
String fro = json.encode([
    {
      "title": "name",
      "label": "what is your name",
      "type": "text",
      "required": "yes"
    },
    {
      "title": "agegroup",
      "label": "tell us your age group",
      "type": "select",
      "items": ["1-20", "21-30", "31-40", "41-50", "51-60"],
      "required": "no"
    }
  ]);
```

### Fields

- All fields has attribute
- Important to set the "required" field to "yes" or "no" for validation

##### Types

- text
- password
- multiline
- integer
- date
- select

##### text, password, multiline, integer

Using the "type":"password"  
obscureText is set to true

Using the "type":"integer"  
keyboardType is set to TextInputType.number

Using the "type":"multiline"  
maxLines is set to 10.0

```

// Example for json string
// to start with a default value you can add the value attribute
  String formString = json.encode([
        {
             'type': 'text',
             'title': 'Name',
             'label': "username",
             'required': 'yes'
        },
        {
             'type': 'password',
             'title': 'password',
             'label': "Password",
             'required': 'yes'
        },
        {
             'type': 'multiline',
             'title': 'biography',
             'label': "Biography",
             'required': 'no'
        },
        {

             'type': 'integer',
             'title': 'phone',
             'label': 'Phone number',
             'required': 'no'
        }
    ]
 );

```

### date

```
 String formString = json.encode([
         {

            "title": "dateOfReg",
            "label": "what is the date of registration",
            "type": "date",
            "required": "no"

        }
    ]);
```

### select

```
 String formString = json.encode([
        {

        "title": "agegroup",
        "label": "Tell us your age group",
        "type": "select",
        "items": ["1-20", "21-30", "31-40", "41-50", "51-60"],
        "required": "no"

        },
        {

            "title": "category",
            "label": "Pick a category",
            "type": "select",
            "items": {"category1":"Cats", "category2":"Dogs", "category3":"Other animals"},
            "required": "no"
        }
    ]);

```

### radio

```
 String formString = json.encode([
        {
          'title': 'needs',
          'type': 'radio',
          'label': 'Which would you like',
          'items': ["Java", "Dart", "All"],
        }
    ]);

```

### switch

```
 String formString = json.encode([
    {
      'title': 'canCode',
      'type': 'switch',
      'label': 'Are you old enough to code',
    },
    ]);

```

### checkbox

```
 String formString = json.encode([
    {
      "title": "checkboxes",
      "label": "Programming languages",
      "type": "checkbox",
      "items": ["Dart", "PHP", "JAVA", "RUBY", "JS"],
      "required": "no"
    },
        {
      "title": "checkboxesWithDefinedKeys",
      "label": "Programming skills",
      "type": "checkbox",
      "items": {"web":"PHP,JS,HTML,CSS", "compiled":"JAVA,C,C#", "esoteric":"Brainf*ck, LOLCODE, Whitespace"},
      "required": "no"
    }
    ]);

```

## Usage

- Example

```
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:json_form_generator/json_form_generator.dart';

class CreatedForm extends StatefulWidget {
  @override
  _CreatedFormState createState() => _CreatedFormState();
}

class _CreatedFormState extends State<CreatedForm> {

   // dynamic response to store your form data that can be sent as  post request
   dynamic response;

   // set the formkey for validation
   var _formkey = GlobalKey<FormState>();

  String formItems = json.encode([
    {
      "title": "name",
      "label": "what is your name",
      "type": "text",
      "required": "yes"
    },
    {
      "title": "dateOfReg",
      "label": "what is the date of registration",
      "type": "date",
      "required": "no"
    },
    {
      "title": "agegroup",
      "label": "tell us your age group",
      "type": "select",
      "items": ["1-20", "21-30", "31-40", "41-50", "51-60"],
      "required": "no"
    }
  ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("JSONFORM"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formkey, // add the formkey here
          child: Column(children: <Widget>[
            JsonFormGenerator(
              form: formItems,
              onChanged: (dynamic value) {
                setState(() {
                  this.response = value;
                });
              },
            ),
            new RaisedButton(
                child: new Text('Send'),
                onPressed: () {
                  if (_formkey.currentState.validate()) {
                    print(this.response.toString());
                  }
                })
          ]),
        ),
      ),
    );
  }
}

```

When there is a change in the form, the (dynamic response;) is updated,

```
               onChanged: (dynamic response) {
                 this.response = response;
               },
```

when text is added to the TextField, add field called response

```
// initial form
[{"title":"name","label":"what is your name","type":"text","required":"yes"},{"title":"dateOfReg","label":"what is the date of registration","type":"date","required":"no"},{"title":"agegroup","label":"tell us your age group","type":"select","items":["1-20","21-30","31-40","41-50","51-60"],"required":"no"}]

// initial response
 null

// when the form is updated ,  dynamic response; is also updated
{name: emeka, dateOfReg: 2020-03-26, agegroup: 31-40}

```

<p align="center">
  <img src="https://raw.githubusercontent.com/Emex4gman/json_form_generator/master/images/image2.png" width="350"/>
</p>

## Getting Started

For help getting started with Flutter, view our online [documentation](https://flutter.io/).

For help on editing package code, view the [documentation](https://flutter.io/developing-packages/).

## TODO

- Refactor code to more object oriented approach
- Add option for json-defined styling
