import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'player.dart';

void main() => runApp(DreamGameStats());

class DreamGameStats extends StatelessWidget {
  final String _title = "Sen - statystyki";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MainPage(title: _title),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isActiveGame = false;
  List<Player> _players = [];
  int _addedScore = 0;

  @override
  initState() {
    super.initState();
    print("Init state");
    _setTestData();
  }

  _setTestData() {
    Player p1 = Player(Colors.green);
    Player p2 = Player(Colors.blue);
    _players = [p1, p2];
  }

  _addPlayer() {
    print("Add player dialog");
    showDialog(context: context, builder: (buildContext) => AddPlayerDialog()).then((selectedColor) {
      if (selectedColor != null) {
        print("Selected color is: " + selectedColor.toString());
        setState(() {
          _players.add(Player(selectedColor));
          _isActiveGame = false;
        });
      }
    });
  }

  _startNewGame() {
    print("Start new game");
    setState(() {
      _isActiveGame = false;
      _players.forEach((player) => player.scores.clear());
    });
  }

  _removePlayers() {
    print("Remove players");
    setState(() {
      _isActiveGame = false;
      _players = [];
    });
  }

  _addNewScore(int score, Player player) {
    if (score == null) return;

    print("add $score to player's ${player.color.toString()} scores");
    setState(() {
      player.scores.add(score);
      _isActiveGame = true;
    });
  }

  Widget _prepareTable() {
    if (_players.isEmpty) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Dodaj gracza używając przycisku"),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: null,
          ),
        ],
      );
    }

    List<TableRow> tableRows = [];

    //Add columns
    List<Widget> cols = [];
    _players.forEach((player) {
      var col = Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
          width: 20,
          height: 40,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: player.color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );
      cols.add(col);
    });
    TableRow tr = TableRow(children: cols);
    tableRows.add(tr);

    int rowsCount = 0;
    _players.forEach((player) {
      int playerScoresCount = player.scores.length;
      if (playerScoresCount > rowsCount) rowsCount = playerScoresCount;
    });

    rowsCount++; //add one more row to see and editor

    //Add rows with cells
    for (int i = 0; i < rowsCount; i++) {
      List<Widget> cells = [];

      _players.forEach((player) {
        Widget cellContent;
        if (player.scores.length > i) {
          cellContent = Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(player.scores[i].toString()),
            ),
          );
        } else {
          cellContent = _prepareDataTableInput(player);
        }
        cells.add(cellContent);
      });

      TableRow tableRow = TableRow(children: cells);
      tableRows.add(tableRow);
    }

    return Table(
      children: tableRows,
      border: TableBorder.all(color: Colors.black12),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
    );
  }

  Widget _prepareDataTable() {
    if (_players.isEmpty) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Dodaj gracza używając przycisku"),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: null,
          ),
        ],
      );
    }

    List<DataColumn> columns = [];
    List<DataRow> rows = [];

    //Add columns
    _players.forEach((player) {
      var col = DataColumn(
        label: SizedBox(
          width: 20,
          height: 20,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: player.color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );
      columns.add(col);
    });

    int rowsCount = 0;
    _players.forEach((player) {
      int playerScoresCount = player.scores.length;
      if (playerScoresCount > rowsCount) rowsCount = playerScoresCount;
    });

    rowsCount++; //add one more row to see and editor

    //Add rows with cells
    for (int i = 0; i < rowsCount; i++) {
      List<DataCell> cells = [];

      _players.forEach((player) {
        Widget cellContent;
        if (player.scores.length > i) {
          cellContent = Text(player.scores[i].toString());
        } else {
          cellContent = _prepareDataTableInput(player);
        }
        var cell = DataCell(cellContent);
        cells.add(cell);
      });

      var row = DataRow(
        cells: cells,
      );
      rows.add(row);
    }

    return Flex(
      mainAxisAlignment: MainAxisAlignment.center,
      direction: Axis.horizontal,
      children: <Widget>[
        DataTable(
          columns: columns,
          rows: rows,
        ),
      ],
    );
  }

  Widget _prepareDataTableInput(Player player) {
    var focusNode = FocusNode();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) _addNewScore(_addedScore, player);
    });

    return TextField(
      keyboardType: TextInputType.number,
      autocorrect: false,
      textAlign: TextAlign.center,
      onChanged: (value) {
        print("value changed to: $value");
        _addedScore = int.parse(value);
      },
      focusNode: focusNode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _isActiveGame ? null : _addPlayer,
          ),
          IconButton(
            icon: Icon(Icons.update),
            onPressed: _startNewGame,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: _removePlayers,
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Card(
            child: Container(
              width: 400,
              height: 120,
              child: StatsChartBar.withData(_players),
            ),
          ),
          Card(
            child: SingleChildScrollView(
              child: _prepareTable(),
            ),
          )
        ],
      ),
    );
  }
}

class AddPlayerDialog extends StatelessWidget {
  final List<Color> _colorsList = [
    Colors.green,
    Colors.red,
    Colors.blue,
    Colors.pink,
    Colors.amber
  ];

  Widget _prepareColorPalette(BuildContext parentContext) {
    return Container(
        constraints: BoxConstraints.tight(
          Size(300, 60),
        ),
        child: Center(
          child: GridView.builder(
            itemCount: _colorsList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
            itemBuilder: (BuildContext context, int index) {
              Color color = _colorsList[index];
              return Container(
                  margin: EdgeInsets.all(2),
                  child: GestureDetector(
                    onTap: () {
                      print("Color selected...");
                      Navigator.pop(context, color);
                    },
                    child: SizedBox(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ));
            },
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    print("Show add player dialog");
    return AlertDialog(
      title: Text(
        "Wybierz kolor nowego gracza",
        textAlign: TextAlign.center,
      ),
      content: _prepareColorPalette(context),
    );
  }
}

class StatsChartBar extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  StatsChartBar(this.seriesList, {this.animate});

  factory StatsChartBar.withData(List<Player> players) {
    return new StatsChartBar(
      _createSeries(players),
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
      domainAxis: charts.OrdinalAxisSpec(
        showAxisLine: false,
        renderSpec: charts.NoneRenderSpec(),
      ),
    );
  }

  static List<charts.Series<PlayerScore, String>> _createSeries(List<Player> players) {
    List<PlayerScore> playersScores = [];
    players.forEach((player) {
      playersScores.add(PlayerScore(player.getSum(), player.name, player.color));
    });

    return [
      new charts.Series<PlayerScore, String>(
        id: 'dreamGameStatsChart',
        colorFn: (PlayerScore ps, __) => ps.color,
        domainFn: (PlayerScore ps, _) => ps.color.toString(),
        measureFn: (PlayerScore ps, _) => ps.score,
        data: playersScores,
      )
    ];
  }
}

class PlayerScore {
  final int score;
  final String name;
  final charts.Color color;

  PlayerScore(this.score, this.name, Color color)
      : this.color = new charts.Color(r: color.red, g: color.green, b: color.blue, a: color.alpha);
}
