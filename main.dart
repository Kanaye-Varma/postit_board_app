import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

double max(double a, double b) {
  return a > b ? a : b;
}
double min(double a, double b) => a < b ? a : b;

class BoardViewModel extends ChangeNotifier {
  var messages = [];
  String title;

  BoardViewModel({required this.title});

  void addMessage(String msg) {
    messages.add(msg);
    notifyListeners();
  }

  void removeMessage(String msg) {
    if (messages.contains(msg)) {
      messages.remove(msg);
      notifyListeners();
    }
  }

  void clearMessages() {
    messages = [];
    notifyListeners();
  }

  void prioritize(String msg) {
    messages.remove(msg);
    messages.insert(0, msg);
    notifyListeners();
  }

}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Postit board",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue
        )
      ),
      home: HomePage()
    );
  }
}

class Message extends StatelessWidget {
  const Message({super.key, required this.msg});

  final String? msg;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Card(
        color: theme.primaryColorLight,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("$msg")
        )
      );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int idx = 0; 
  List<BoardPage> pages = [
    BoardPage(board: BoardViewModel(title: "Untitled")), 
    BoardPage(board: BoardViewModel(title: "Untitled"))
  ];
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xaa99f7b4),
        title: Text("Post-it App"),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              SafeArea(
                child: ColoredBox(
                  color: Colors.cyanAccent,
                  child: Column(
                    spacing: 20,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: NavigationRail(
                          selectedIndex: idx,
                          backgroundColor: Colors.cyanAccent,
                          minExtendedWidth: 300,
                          extended: constraints.maxWidth > 700, 
                          destinations: [
                            for (var i = 0; i < pages.length; i++)
                              NavigationRailDestination(
                                icon: Icon(Icons.book),
                                label: Text(pages[i].board.title)
                              )
                          ],
                          scrollable: true,
                          onDestinationSelected: (value) {
                            setState(() {idx = value;});
                          },
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context, 
                            builder: (context) {
                              var controller = TextEditingController();
                              return AlertDialog(
                                icon: Icon(Icons.info),
                                constraints: BoxConstraints(maxHeight: 200, minWidth: 300),
                                content: Column(children: [
                                  TextField(
                                    controller: controller,
                                    decoration: InputDecoration(hintText: "Enter board title"),
                                    maxLength: 30
                                  ),
                                  ElevatedButton(
                                    child: Text("Confirm"),
                                    onPressed: () {
                                      setState(() {
                                          pages.add(BoardPage(board: BoardViewModel(
                                            title: controller.text.isEmpty ? "Untitled" : controller.text)));
                                      });
                                      Navigator.pop(context);
                                    }
                                  )
                                ])
                              );
                            }
                          );
                        },
                        child: Text("Add board")
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: pages.length == 1 ? null : () {
                            showDialog(
                              context: context, 
                              builder: (context) {
                                return AlertDialog(
                                  icon: Icon(Icons.warning),
                                  title: Text("Sure to delete ${pages[idx].board.title}? This action cannot be undone"),
                                  content: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        pages.removeAt(idx);
                                        idx = 0; 
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Text("Confirm")
                                  )
                                );
                              }
                            );
                          },
                          child: Text("Delete board")
                        ),
                      ),
                    ],
                  ),
                )
              ), 
              Expanded(
                child: pages[idx],
              )
            ]
          );
        }
      ),
    );
  }
}

class BoardPage extends StatelessWidget {
  const BoardPage({
    super.key,
    required this.board,
  });

  final BoardViewModel board;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListenableBuilder(
        listenable: board,
        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: max(0, constraints.maxHeight-100),
                    child: ListView (
                      children: [
                        for (var msg in board.messages) 
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 10,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: msg == board.messages[0] ? null : () {
                                board.removeMessage(msg);
                              },
                              iconSize: msg == board.messages[0] ? 0 : 30
                            ),
                            IconButton(
                              onPressed: () {
                                if (msg == board.messages[0]) {board.removeMessage(msg);}
                                else {board.prioritize(msg);}
                              },
                              icon: msg == board.messages[0] ? Icon(Icons.delete) : Icon(Icons.priority_high),
                              iconSize: 30
                            ),
                            SizedBox(
                              width: min(constraints.maxWidth-150, 400),
                              child: Message(msg: "$msg")
                            )
                          ])
                      ]
                    )
                  ), 
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 20,
                      children: [
                        ElevatedButton(
                          onPressed: (){
                            var myController = TextEditingController();
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  constraints: BoxConstraints(maxHeight: 200, minWidth: 400),
                                  content: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextField(
                                        controller: myController,
                                        maxLines: 1,
                                        maxLength: 50
                                      ),
                                      ElevatedButton(
                                        child: Text("Confirm"),
                                        onPressed : () {
                                          if (myController.text.isNotEmpty) {
                                            var msg = myController.text;
                                            if (board.messages.contains(msg)) {
                                              // Navigator.pop(context);
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  content: Text("This message is already on the board."),
                                                  icon: Icon(Icons.warning),
                                                  semanticLabel: "This is a semantic label",
                                                )
                                              );
                                            } else {
                                              board.addMessage(myController.text);
                                              Navigator.pop(context);
                                            }
                                          }
                                        }
                                      )
                                    ]
                                  )
                                );
                              });
                          }, 
                          child: Text("Add message")
                        ),
                        ElevatedButton(
                          onPressed: board.messages.isEmpty ? null : () {
                            showDialog(
                              context: context, 
                              builder: (context) => AlertDialog(
                                icon: Icon(Icons.warning),
                                title: Text("Sure to clear board? This action cannot be undone"),
                                content: ElevatedButton(
                                  onPressed: () {
                                    board.clearMessages();
                                    Navigator.pop(context);
                                  },
                                  child: Text("Confirm")
                                )
                              )
                            );
                          }, 
                          child: Text("Clear board")
                        ),
                      ],
                    ),
                  )
                ],
              );
            }
          );
        }
      )
    );
  }
}