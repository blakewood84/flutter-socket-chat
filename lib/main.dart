import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({ Key? key }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  IO.Socket? socket;
  String myMessage = '';
  List messages = [];

  @override
  void initState() {  
    super.initState();
    connectToServer();
  }

  void connectToServer() {
    try {
      socket = IO.io('http://127.0.0.1:3000', IO.OptionBuilder().setTransports(['websocket']).build());
      socket!.connect();
      socket!.on('connect', (data) => print('connect: ${socket!.id}'));
      socket!.on('typing', handleTyping);
      socket!.on('message', handleMessage);
      socket!.on('disconnect', (data) => print('disconnect'));
      socket!.on('fromServer', (data) => print(data));

    } catch (e) {
      print(e.toString());
    }
  }

  // send update of user's typing status
  sendTyping(bool typing) {
    socket!.emit('typing', {
      'id': socket!.id,
      'typing': typing,
    });
  }

  // Listen to update of typing status from connected users
  void handleTyping(data) {
    print(data);
  }

  // Send a Message to the Server
  sendMessage(String message) {
    socket!.emit('message', {
      'id': socket!.id,
      'message': message,
      'timestamp': DateTime.now().microsecondsSinceEpoch
    });
  }

  void handleMessage(data) {
    print(data);
    setState(() => messages.add(data));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.red,
                    width: 1
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            child: Text(messages[index]['message'])
                          );
                        }
                      ),
                    )
                  ],
                )
              )
            ),
            TextFormField(
              initialValue: myMessage,
              onChanged: (val) {
                myMessage = val;
                sendTyping(true);
              },
            ),
            ElevatedButton(
              child: Text('Send Message'),
              onPressed: () {
                sendMessage(myMessage);
              },
            )
          ],
        )
      )
    );
  }
}