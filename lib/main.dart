import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RPN Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'RPN Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}
abstract class Command {
  void execute();
  void undo(Stack<int> stack);
}

class AddCommand implements Command {
  Stack<int> stack;
  int result = 0;

  AddCommand(this.stack) {
    int num1 = stack.pop();
    int num2 = stack.pop();
    result = num2 + num1;
  }

  @override
  void execute() {
    stack.push(result);
  }

  @override
  void undo(Stack<int> stack) {
    stack.pop();
    stack.push(result - (stack.peek() ?? 0));
  }
}

class SubtractCommand implements Command {
  Stack<int> stack;
  int result = 0;

  SubtractCommand(this.stack) {
    int num1 = stack.pop();
    int num2 = stack.pop();
    result = num2 - num1;
  }

  @override
  void execute() {
    stack.push(result);
  }

  @override
  void undo(Stack<int> stack) {
    stack.pop();
    stack.push(result + (stack.peek() ?? 0));
  }
}

class MultiplyCommand implements Command {
  Stack<int> stack;
  int result = 0;

  MultiplyCommand(this.stack) {
    int num1 = stack.pop();
    int num2 = stack.pop();
    result = num2 * num1;
  }

  @override
  void execute() {
    stack.push(result);
  }

  @override
  void undo(Stack<int> stack) {
    double num1 = stack.pop() as double;
    stack.pop();
    stack.push(((stack.peek() ?? 1) * num1) as int);
  }
}

class DivideCommand implements Command {
  Stack<int> stack;
  int result = 0;

  DivideCommand(this.stack) {
    int num1 = stack.pop();
    int num2 = stack.pop();
    result = num2 ~/ num1;
  }

  @override
  void execute() {
    stack.push(result);
  }

  @override
  void undo(Stack<int> stack) {
    double num1 = stack.pop() as double;
    stack.pop();
    stack.push(((stack.peek() ?? 1) * num1) as int);
  }
}

class ClearCommand implements Command {
  Stack<int> stack;
  List<int> values = [];

  ClearCommand(this.stack) {
    while (!stack.isEmpty()) {
      values.add(stack.pop());
    }
  }

  @override
  void execute() {
    // Do nothing, since the command is just clearing the stack
  }

  @override
  void undo(Stack<int> stack) {
    for (int value in values.reversed) {
      stack.push(value);
    }
  }
}

class UndoCommand implements Command {
  Stack<int> stack;
  Command lastCommand;

  UndoCommand(this.stack, this.lastCommand);

  @override
  void execute() {
    lastCommand.undo(stack);
  }

  @override
  void undo(Stack<int> stack) {
    // Do nothing, since undoing an undo command does not make sense
  }
}

class NumberCommand implements Command {
  Stack<int> stack;
  int number;

  NumberCommand(this.stack, this.number);

  @override
  void execute() {
    stack.push(number);
  }

  @override
  void undo(Stack<int> stack) {
    stack.pop();
  }
}

class Stack<T> {
  List<T> _stack = [];

  void push(T value) {
    _stack.add(value);
  }

  T pop() {
    return _stack.removeLast();
  }

  T peek() {
    return _stack.last;
  }

  int size() {
    return _stack.length;
  }

  bool isEmpty() {
    return _stack.isEmpty;
  }

  void clear() {
    _stack.clear();
  }
}
class _MyHomePageState extends State<MyHomePage> {
  Stack<int> myStack = Stack<int>();
  List<Command> commands = [];
  String output = "0";

    void buttonPressed(String buttonText) {
      setState(() {
        Command? command = null;
        switch (buttonText) {
          case "+":
            command = AddCommand(myStack);
            break;
          case "-":
            command = SubtractCommand(myStack);
            break;
          case "*":
            command = MultiplyCommand(myStack);
            break;
          case "/":
            command = DivideCommand(myStack);
            break;
          case "Clear":
            command = ClearCommand(myStack);
            break;
          case "undo":
            if (commands.isNotEmpty) {
              Command lastCommand = commands.removeLast();
              command = UndoCommand(myStack, lastCommand);
            }
            break;
          default:
            int? number = int.tryParse(buttonText);
            if (number != null) {
              command = NumberCommand(myStack, number);
            }
            break;
        }

        if (command != null) {
          command.execute();
          commands.add(command);
        }

        if (myStack.isEmpty()) {
          output = "0";
        } else {
          output = myStack.peek().toString();
        }
      });
  }

  Widget buildButton(String buttonText) {
    return Expanded(
      child: SizedBox(
        height: 70.0,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: OutlinedButton(
            child: Text(
              buttonText,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => buttonPressed(buttonText),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
              child: Text(
                '0',
                style: TextStyle(fontSize: 48.0),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
              child: Text(
                myStack._stack.toString(),
                style: TextStyle(fontSize: 48.0),
              ),
            ),
            const Expanded(
              child: Divider(),
            ),
            Column(children: [
              Row(
                children: [
                  buildButton('7'),
                  buildButton('8'),
                  buildButton('9'),
                  buildButton('/'),
                ],
              ),
              Row(
                children: [
                  buildButton('4'),
                  buildButton('5'),
                  buildButton('6'),
                  buildButton('*'),
                ],
              ),
              Row(
                children: [
                  buildButton('1'),
                  buildButton('2'),
                  buildButton('3'),
                  buildButton('-'),
                ],
              ),
              Row(
                children: [
                  buildButton('.'),
                  buildButton('0'),
                  buildButton('Clear'),
                  buildButton('+'),
                ],
              ),
              Row(
                children: [buildButton('Enter'), buildButton("undo")],
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
