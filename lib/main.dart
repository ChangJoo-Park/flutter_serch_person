import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app_search_delegate/get_mock_json.dart';

void main() => runApp(MyApp());

class Person {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String avatar;

  String get fullName {
    return '$firstName $lastName';
  }

  Person({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.avatar,
  });
}

List<Person> getMockPeople() {
  return getMockJson().map((json) {
    Random _rand = Random();
    int bR = _rand.nextInt(255);
    int bG = _rand.nextInt(255);
    int bB = _rand.nextInt(255);
    int fR = _rand.nextInt(255);
    int fG = _rand.nextInt(255);
    int fB = _rand.nextInt(255);
    String background = '$bR$bG$bB';
    String foreground = '$fR$fG$fB';
    String avatar =
        'https://dummyimage.com/50x50/$background/$foreground.png&text=${json['first_name'].toString()[0]}';
    return Person(
      email: json['email'],
      avatar: avatar,
      lastName: json['first_name'],
      firstName: json['last_name'],
    );
  }).toList();
}

ListTile _buildPersonListTile(Person person) {
  Random _rand = Random();
  int bR = _rand.nextInt(255);
  int bG = _rand.nextInt(255);
  int bB = _rand.nextInt(255);
  int fR = _rand.nextInt(255);
  int fG = _rand.nextInt(255);
  int fB = _rand.nextInt(255);
  String background = '$bR$bG$bB';
  String foreground = '$fR$fG$fB';
  String avatarUrl =
      'https://dummyimage.com/50x50/$background/$foreground.png&text=${person.firstName[0]}';
  return ListTile(
    onTap: () => {},
    key: Key(person.id.toString()),
    leading: CircleAvatar(
      key: Key(person.id.toString()),
      backgroundImage: NetworkImage(avatarUrl),
    ),
    title: Text(person.fullName),
    subtitle: Text(person.email),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SearchPeople(),
    );
  }
}

class SearchPeople extends StatefulWidget {
  @override
  _SearchPeopleState createState() {
    return _SearchPeopleState();
  }
}

class _SearchPeopleState extends State<SearchPeople> {
  List<Person> _list = [];
  final _SearchPeopleSearchDelegate _searchDelegate =
      _SearchPeopleSearchDelegate();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _lastIntegerSelected;

  @override
  void initState() {
    setState(() {
      _list = getMockPeople();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow,
            progress: _searchDelegate.transitionAnimation,
            color: Colors.white,
          ),
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: '검색',
            onPressed: () async {
              final int selected =
                  await showSearch(context: context, delegate: _searchDelegate);
              if (selected != null && selected != _lastIntegerSelected) {
                setState(() {
                  _lastIntegerSelected = selected;
                });
              }
            },
          ),
          IconButton(
            tooltip: 'More (not implemented',
            icon: Icon(
              Theme.of(context).platform == TargetPlatform.iOS
                  ? Icons.more_horiz
                  : Icons.more_vert,
            ),
            onPressed: () {},
          )
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            const UserAccountsDrawerHeader(
              margin: EdgeInsets.zero,
              accountName: Text('ChangJoo Park'),
              accountEmail: Text('pcjpcj2@gmail.com'),
              currentAccountPicture: CircleAvatar(
                child: Text("CJ"),
              ),
            ),
            MediaQuery.removePadding(
              context: context,
              child: ListTile(
                leading: Icon(Icons.payment),
                title: Text('placeholder'),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        tooltip: 'Back',
        icon: Icon(Icons.add),
        label: const Text('Close Demo'),
      ),
      body: ListView.builder(
        itemCount: _list.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildPersonListTile(_list[index]);
        },
      ),
    );
  }
}

class _SearchPeopleSearchDelegate extends SearchDelegate<int> {
  final List<Person> _data = getMockPeople();

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
//    final Iterable<int> suggestions = query.isEmpty
//        ? _history
//        : _data.where((int i) => '$i'.startsWith(query));
    final Iterable<Person> suggestions = query.isEmpty
        ? [_data[0], _data[23]]
        : _data.where((Person person) => person.fullName.startsWith(query));
    return _SuggestionList(
      query: query,
      suggestions: suggestions.map((person) => person).toList(),
      onSelected: (Person suggestion) {
        query = suggestion.fullName;
        showResults(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final String searched = query;
    final Iterable<Person> person =
        _data.where((Person person) => person.fullName == query);
    if (searched == null ||
        _data.where((Person person) => person.fullName == query).isEmpty) {
      return Center(
        child: Text(
          '"$query"\n is not a valid integer between 0 and 100,000.\nTry again.',
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView(
      children: <Widget>[
        _buildPersonListTile(person.toList().first),
      ],
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      )
    ];
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({this.integer, this.title, this.searchDelegate});

  final int integer;
  final String title;
  final SearchDelegate<int> searchDelegate;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        searchDelegate.close(context, integer);
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(title),
              Text(
                '$integer',
                style: theme.textTheme.headline.copyWith(fontSize: 72.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({this.suggestions, this.query, this.onSelected});

  final List<Person> suggestions;
  final String query;
  final ValueChanged<Person> onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int i) {
        final Person suggestion = suggestions[i];
        return ListTile(
          leading: query.isEmpty ? const Icon(Icons.history) : const Icon(null),
          title: RichText(
            text: TextSpan(
              text: suggestion.fullName.substring(0, query.length),
              style:
                  theme.textTheme.subhead.copyWith(fontWeight: FontWeight.bold),
              children: <TextSpan>[
                TextSpan(
                  text: suggestion.fullName.substring(query.length),
                  style: theme.textTheme.subhead,
                ),
              ],
            ),
          ),
          onTap: () {
            onSelected(suggestion);
          },
        );
      },
    );
  }
}
