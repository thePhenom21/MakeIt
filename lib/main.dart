import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:envied/envied.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:scroll_loop_auto_scroll/scroll_loop_auto_scroll.dart';
part 'main.g.dart';

void main() {
  runApp(const HomePage());
  OpenAI.apiKey = "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";
}

@Envied()
abstract class Env {
  @EnviedField(varName: 'API_KEY')
  static const String key = _Env.key;
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController thingController = TextEditingController();
  Widget b = Text("");
  String t = "";
  ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: thingController,
            decoration:
                InputDecoration(helperText: "What do you want to create?"),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                b = CircularProgressIndicator();
                Future.delayed(Duration(seconds: 1));
              });
              t = "";
              Stream<OpenAIStreamChatCompletionModel> r =
                  OpenAI.instance.chat.createStream(
                model: "gpt-3.5-turbo",
                messages: [
                  OpenAIChatCompletionChoiceMessageModel(
                    content: "How to create ${thingController.value.text}?",
                    role: OpenAIChatMessageRole.user,
                  ),
                ],
              );
              setState(() {
                b = SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                  child: StreamBuilder(
                    stream: r,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        t += snapshot.data!.choices.first.delta.content!;
                        return SingleChildScrollView(child: Text(t));
                      }
                      return CircularProgressIndicator();
                    },
                  ),
                );
              });
              thingController.clear();
            },
            child: Icon(Icons.send),
          ),
          b
        ],
      )),
    );
  }
}
