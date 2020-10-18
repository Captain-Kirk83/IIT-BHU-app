import 'dart:ui';

import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:iit_app/external_libraries/spin_kit.dart';
import 'package:iit_app/model/appConstants.dart';
import 'dart:async';
import 'package:iit_app/model/built_post.dart';
import 'package:built_collection/built_collection.dart';
import 'package:iit_app/model/workshopCreator.dart';
import 'package:iit_app/pages/dialogBoxes.dart';
import 'package:iit_app/screens/home/worshop_detail/workshop_detail.dart';

class CreateScreen extends StatefulWidget {
  final ClubListPost club;
  final String clubName;
  final BuiltWorkshopDetailPost workshopData;
  const CreateScreen(
      {Key key,
      @required this.club,
      @required this.clubName,
      this.workshopData})
      : super(key: key);
  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _formKey = GlobalKey<FormState>();
  WorkshopCreater _workshop;

  TextEditingController _titleController;
  TextEditingController _descriptionController;
  TextEditingController _locationController;
  TextEditingController _audienceController;
  TextEditingController _tagController;
  String _editingDate;
  String _editingTime;

  TextEditingController _searchContactsController;
  BuiltProfileSearchPost _searchPost;
  TagSearch _tagSearchPost;
  bool _isSearchingContacts = false;
  bool _isSearchingTags = false;
  bool _tagDataFetched = false;

  final _searchContactFormKey = GlobalKey<FormState>();

  BuiltList<BuiltProfilePost> _searchedProfileresult;
  TagDetail _createdTagResult;
  String _searchByValue = 'name';
  bool _searchedDataFetched = false;

  BuiltList<TagDetail> _searchedTagResult;

  final dropDownButtonTextStyle = TextStyle(fontSize: 12);
  DropdownButton _searchCategoryDropDown() => DropdownButton<String>(
        items: [
          DropdownMenuItem(
            value: "name",
            child: Text('Name', style: dropDownButtonTextStyle),
          ),
          DropdownMenuItem(
            value: "email",
            child: Text('Email', style: dropDownButtonTextStyle),
          ),
        ],
        onChanged: (value) {
          if (value == this._searchByValue) return;
          setState(() {
            if (value != this._searchByValue) {
              this._searchContactsController.text = '';
              this._isSearchingContacts = false;
              this._searchContactFormKey.currentState.reset();
            }
            this._searchByValue = value;
          });
        },
        value: this._searchByValue,
        hint: Text('category'),
      );

  @override
  void initState() {
    this._titleController = TextEditingController();
    this._descriptionController = TextEditingController();
    this._locationController = TextEditingController();
    this._audienceController = TextEditingController();
    this._tagController = TextEditingController();

    this._searchContactsController = TextEditingController();

    if (widget.workshopData != null) {
      this._titleController.text = widget.workshopData.title;
      this._descriptionController.text = widget.workshopData.description;
      this._editingDate = widget.workshopData.date;
      this._editingTime = widget.workshopData.time;
      this._locationController.text = widget.workshopData.location;
      this._audienceController.text = widget.workshopData.audience;
      _workshop = WorkshopCreater(
          editingDate: this._editingDate, editingTime: this._editingTime);
      widget.workshopData.contacts.forEach((contact) {
        this._workshop.contactIds.add(contact.id);
        this._workshop.contactNameofId[contact.id] =
            WorkshopCreater.nameOfContact(contact.name);
      });
      widget.workshopData.tags.forEach((tag) {
        this._workshop.tagNameofId[tag.id] = tag.tag_name;
      });
    } else {
      _workshop = WorkshopCreater();
    }

    super.initState();
  }

  tagAlertDialog(String title, String innerText) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title ?? '(No Title)'),
            content: Text(innerText ?? '(No Inner Text)'),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(2.0),
      child: Scaffold(
        appBar: AppBar(
            title: widget.workshopData == null
                ? Text('Create Workshop')
                : Text('Edit Workshop')),
        body: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Builder(
            builder: (context) => Form(
              key: _formKey,
              child: ListView(
                children: [
                  Text(widget.clubName),
                  TextFormField(
                    autovalidate: true,
                    decoration:
                        InputDecoration(labelText: 'Title of the Workshop'),
                    controller: this._titleController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter the title';
                      }
                      return null;
                    },
                    onSaved: (val) => setState(() => _workshop.title = val),
                  ),
                  TextFormField(
                      autovalidate: true,
                      decoration: InputDecoration(labelText: 'Description'),
                      controller: this._descriptionController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please describe the workshop in detail.';
                        }
                        return null;
                      },
                      onSaved: (val) =>
                          setState(() => _workshop.description = val)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 0, 40, 0),
                        child: Text("Select Date:"),
                      ),
                      RaisedButton(
                        onPressed: () => _selectDate(context),
                        child: Text('${_workshop.date}'),
                      ),
                      // TODO: make time selection optional
                      RaisedButton(
                        onPressed: () => _selectTime(context),
                        child: Text('${_workshop.time}'),
                      ),
                    ],
                  ),
                  TextFormField(
                      autovalidate: true,
                      decoration: InputDecoration(labelText: 'Location'),
                      controller: this._locationController,
                      validator: (value) {
                        return null;
                      },
                      onSaved: (val) =>
                          setState(() => _workshop.location = val)),
                  TextFormField(
                    autovalidate: true,
                    decoration: InputDecoration(labelText: 'Audience'),
                    controller: this._audienceController,
                    validator: (value) {
                      return null;
                    },
                    onSaved: (val) => setState(() => _workshop.audience = val),
                  ),
                  Form(
                    key: this._searchContactFormKey,
                    child: Row(
                      children: <Widget>[
                        _searchCategoryDropDown(),
                        Expanded(
                          child: TextFormField(
                            autovalidate: true,
                            decoration: InputDecoration(
                                labelText:
                                    'Search contacts by ${this._searchByValue}'),
                            onFieldSubmitted: (value) async {
                              if (value.isEmpty) return;

                              if (!this
                                  ._searchContactFormKey
                                  .currentState
                                  .validate()) return;

                              this._searchPost = BuiltProfileSearchPost((b) => b
                                ..search_by = this._searchByValue
                                ..search_string =
                                    this._searchContactsController.text);

                              if (!this.mounted) return;
                              setState(() {
                                this._isSearchingContacts = true;
                                this._searchedDataFetched = false;

                                this._searchedProfileresult = null;
                              });
                              await AppConstants.service
                                  .searchProfile(AppConstants.djangoToken,
                                      this._searchPost)
                                  .catchError((onError) {
                                print(
                                    'Error whlie fetching search results: $onError');
                              }).then((result) {
                                if (result != null)
                                  this._searchedProfileresult = result.body;
                              });

                              if (!this.mounted) return;
                              setState(() {
                                this._searchedDataFetched = true;
                              });
                            },
                            controller: this._searchContactsController,
                            validator: (value) {
                              if (value.isNotEmpty && value.length < 3)
                                return '${this._searchByValue} must contain atleast 3 characters';
                            },
                          ),
                        ),
                        this._isSearchingContacts
                            ? RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50)),
                                onPressed: () {
                                  this._searchContactsController.text = '';
                                  this._isSearchingContacts = false;
                                  if (!this.mounted) return;
                                  setState(() {});
                                },
                                child: Text('X Clear'),
                              )
                            : Container()
                      ],
                    ),
                  ),
                  this._isSearchingContacts
                      ? Column(
                          children: <Widget>[
                            Divider(
                              height: 2,
                              thickness: 2,
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height / 6,
                              child: _buildContactsFromSearchPosts(context),
                            ),
                            Divider(
                              height: 2,
                              thickness: 2,
                            ),
                          ],
                        )
                      : Container(),
                  this._workshop.contactIds.length > 0
                      ? Container(
                          height: 50,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: this._workshop.contactIds.length,
                            itemBuilder: (context, index) {
                              int _id = this._workshop.contactIds[index];
                              return Container(
                                padding: EdgeInsets.all(2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(this._workshop.contactNameofId[_id]),
                                    InkWell(
                                      splashColor: Colors.red,
                                      onTap: () {
                                        setState(() {
                                          this._workshop.contactIds.remove(_id);
                                          this
                                              ._workshop
                                              .contactNameofId
                                              .remove(_id);
                                        });
                                      },
                                      child: Icon(Icons.cancel),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : Container(),
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        controller: this._tagController,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                          labelText: 'Search tags by name',
                          suffix: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              this._tagController.text = '';
                              if (!this.mounted) return;
                            },
                          ),
                        ),
                        onFieldSubmitted: (value) async {
                          print("Submitted");
                          if (value.isEmpty) return;

                          this._tagSearchPost = TagSearch((b) => b
                            ..club = widget.club.id
                            ..tag_name = this._tagController.text);

                          if (!this.mounted) return;
                          setState(() {
                            this._isSearchingTags = true;
                            this._tagDataFetched = false;
                            this._searchedTagResult = null;
                          });
                          await AppConstants.service
                              .searchTag(
                                  AppConstants.djangoToken, this._tagSearchPost)
                              .catchError((onError) {
                            print('Error while fetching tags $onError');
                          }).then((result) {
                            if (result != null)
                              this._searchedTagResult = result.body;
                          });
                          if (!this.mounted) return;
                          setState(() {
                            this._tagDataFetched = true;
                          });
                        },
                      ),
                    ),
                    this._isSearchingTags
                        ? RaisedButton(
                            child: Text('+ Create'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            onPressed: () async {
                              final newTag = TagCreate((b) => b
                                ..tag_name = this._tagController.text
                                ..club = widget.club.id);

                              await AppConstants.service
                                  .createTag(AppConstants.djangoToken, newTag)
                                  .catchError((onError) {
                                final error = onError as Response<dynamic>;
                                print(error.body);
                                if (error.body.toString().contains(
                                    'The tag already exists for this club'))
                                  tagAlertDialog('Tag Exists',
                                      'This tag already exists. Search for it if you wish to add it to the workshop.');
                                print(
                                    'Error while creating Tag: ${onError.toString()} ${onError.runtimeType}');
                              }).then((value) {
                                if (value != null)
                                  this._createdTagResult = value.body;
                                tagAlertDialog('Tag Created',
                                    'The Tag has been created succesfully. Search for it again, and add it to the worshop if you wish.');
                              });
                              setState(() {
                                if (this._createdTagResult != null)
                                  // Uncomment the below lines if the created tag should automatically be added to the worshop.
                                  // this._workshop.tagNameofId[this
                                  //     ._createdTagResult
                                  //     .id] = this._createdTagResult.tag_name;
                                  ;
                              });
                            },
                          )
                        : Container(),
                    this._isSearchingTags
                        ? RaisedButton(
                            child: Text('X Clear'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            onPressed: () {
                              this._tagController.text = '';
                              this._isSearchingTags = false;
                              if (!this.mounted) return;
                              setState(() {});
                            },
                          )
                        : Container(),
                  ]),
                  this._isSearchingTags
                      ? Column(
                          children: <Widget>[
                            Divider(
                              height: 2,
                              thickness: 2,
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height / 6,
                              child: _buildTagsFromSearchPosts(context),
                            ),
                            Divider(
                              height: 2,
                              thickness: 2,
                            ),
                          ],
                        )
                      // TODO: Instead of this being an empty container, make it fetch from clubs/{id}/tags to show all tags
                      : Container(),
                  this._workshop.tagNameofId.keys.length > 0
                      ? Container(
                          height: 50,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: this._workshop.tagNameofId.keys.length,
                            itemBuilder: (context, index) {
                              int _id = this
                                  ._workshop
                                  .tagNameofId
                                  .keys
                                  .toList()[index];
                              print(
                                  '$_id : ${this._workshop.tagNameofId[_id]}');
                              return Container(
                                padding: EdgeInsets.all(2),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(this._workshop.tagNameofId[_id]),
                                    InkWell(
                                      child: Icon(Icons.cancel),
                                      splashColor: Colors.red,
                                      onTap: () {
                                        setState(() {
                                          this
                                              ._workshop
                                              .tagNameofId
                                              .remove(_id);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : Container(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 16.0),
                    child: RaisedButton(
                      onPressed: () async {
                        final form = _formKey.currentState;
                        if (form.validate()) {
                          form.save();
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: widget.workshopData == null
                                  ? Text('Creating Workshop...')
                                  : Text('Editing Workshop...'),
                            ),
                          );

                          bool isconfirmed =
                              await CreatePageDialogBoxes.confirmDialog(
                                  context: context,
                                  isEditing: widget.workshopData == null
                                      ? false
                                      : true);

                          if (isconfirmed == false) return;

                          if (widget.workshopData == null) {
                            await WorkshopCreater.create(
                                context: context,
                                workshop: _workshop,
                                club: widget.club);
                          } else {
                            await WorkshopCreater.edit(
                                context: context,
                                workshop: _workshop,
                                club: widget.club,
                                widgetWorkshopData: widget.workshopData);
                          }
                        }
                      },
                      child: widget.workshopData == null
                          ? Text('Create')
                          : Text('Edit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactsFromSearchPosts(
    BuildContext context,
  ) {
    return this._searchedDataFetched
        ? ListView(
            shrinkWrap: true,
            children: <Widget>[
              Container(
                child: (this._searchedProfileresult == null ||
                        this._searchedProfileresult.isEmpty)
                    ? Center(
                        child: Text(
                          'No such contact found........',
                          textAlign: TextAlign.center,
                          textScaleFactor: 1.5,
                        ),
                      )
                    : ListView.builder(
                        physics: ScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: _searchedProfileresult.length,
                        padding: EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          bool _isAdded = this
                              ._workshop
                              .contactIds
                              .contains(_searchedProfileresult[index].id);

                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 3, vertical: 10),
                            child: Container(
                              // color: Colors.lightBlue.withOpacity(0.3),
                              height: MediaQuery.of(context).size.height / 11,
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                        image: (_searchedProfileresult[index]
                                                        .photo_url ==
                                                    null ||
                                                _searchedProfileresult[index]
                                                    .photo_url
                                                    .isEmpty)
                                            ? Image.asset(
                                                'assets/profile_test.jpg')
                                            : NetworkImage(
                                                _searchedProfileresult[index]
                                                    .photo_url),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 8,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 10.0),
                                      child: Column(
                                        children: <Widget>[
                                          Text(_searchedProfileresult[index]
                                              .name),
                                          Text(_searchedProfileresult[index]
                                              .email),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: OutlineButton(
                                      onPressed: () {
                                        int _id =
                                            _searchedProfileresult[index].id;
                                        String _name =
                                            WorkshopCreater.nameOfContact(
                                                _searchedProfileresult[index]
                                                    .name);

                                        if (_isAdded) {
                                          _isAdded = false;
                                          this._workshop.contactIds.remove(_id);
                                          this
                                              ._workshop
                                              .contactNameofId
                                              .remove(_id);
                                        } else {
                                          _isAdded = true;
                                          this._workshop.contactIds.add(_id);
                                          this._workshop.contactNameofId[_id] =
                                              _name;
                                        }
                                        if (!this.mounted) return;
                                        setState(() {});
                                      },
                                      child: Icon(
                                          _isAdded ? Icons.remove : Icons.add),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          )
        : Center(
            child: LoadingCircle,
          );
  }

  Widget _buildTagsFromSearchPosts(
    BuildContext context,
  ) {
    return this._tagDataFetched
        ? Container(
            child: (this._searchedTagResult == null ||
                    this._searchedTagResult.isEmpty)
                ? Center(
                    child: Text(
                      'No such Tags',
                      textAlign: TextAlign.center,
                      textScaleFactor: 1.5,
                    ),
                  )
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, childAspectRatio: 4),
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: this._searchedTagResult.length,
                    padding: EdgeInsets.all(2),
                    itemBuilder: (context, index) {
                      int _id = this._searchedTagResult[index].id;
                      return Container(
                        padding: EdgeInsets.all(2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(this._searchedTagResult[index].tag_name),
                            InkWell(
                              child: (this
                                      ._workshop
                                      .tagNameofId
                                      .keys
                                      .contains(_id))
                                  ? Icon(Icons.highlight_remove_rounded)
                                  : Icon(Icons.add_box_rounded),
                              splashColor: Colors.green,
                              onTap: () {
                                setState(() {
                                  if (this
                                      ._workshop
                                      .tagNameofId
                                      .keys
                                      .contains(_id))
                                    this._workshop.tagNameofId.remove(_id);
                                  else
                                    this._workshop.tagNameofId[_id] =
                                        this._searchedTagResult[index].tag_name;
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ))
        : Container();
  }

  Future<Null> _selectDate(BuildContext context) async {
    if (this._editingDate == null) {
      this._editingDate = DateTime.now().toString();
    }
    int _editingyear = int.parse(this._editingDate.substring(0, 4));
    int _editingmonth = int.parse(this._editingDate.substring(5, 7));
    int _editingday = int.parse(this._editingDate.substring(8, 10));
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: widget.workshopData == null
            ? DateTime.now()
            : DateTime(_editingyear, _editingmonth, _editingday),
        firstDate: new DateTime(2018),
        lastDate: new DateTime(2022));

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _workshop.date = _workshop.convertDate(picked);
      });
    }
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && picked != TimeOfDay.now()) {
      setState(() {
        _workshop.time = _workshop.converTime(picked);
      });
    }
  }
}
