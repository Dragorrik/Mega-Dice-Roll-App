import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Game Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.russoOneTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GamePage(title: 'Flutter Game Page'),
    );
  }
}

enum GameStatus{
  running,
  over,
  none
}

class GamePage extends StatefulWidget {
  const GamePage({super.key, required this.title});
  final String title;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {

  static const win="You Win!!!";
  static const lost="You Lost!!!";

  GameStatus gameStatus=GameStatus.none;

  final diceList=[
    "images/d1.png",
    "images/d2.png",
    "images/d3.png",
    "images/d4.png",
    "images/d5.png",
    "images/d6.png",
  ];

  int index1=0, index2=0, diceSum=0, target=0;
  bool hasTarget=false,shouldShowBoard=false;
  String result="";
  final random=Random.secure();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mega Roll"),
      ),
      body: Center(
        child: shouldShowBoard
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(diceList[index1],height: 100,width: 100,),
                const SizedBox(width: 15,),
                Image.asset(diceList[index2],height: 100,width: 100,),
              ],
            ),
            const SizedBox(height: 15,),
            Text("Dice Sum: $diceSum",style:const TextStyle(fontSize: 50)),
            const SizedBox(height: 20,),
            if(hasTarget)Text("    Your Target: $target\nKeep rolling until $target",style:const TextStyle(fontSize: 20)),
            const SizedBox(height: 20,),
            if(gameStatus==GameStatus.over)Text("$result",style:const TextStyle(fontSize: 50)),
            if(gameStatus==GameStatus.running)ElevatedButton(
                onPressed: rollTheDice,
                child: const Text("Roll It",style: TextStyle(fontSize: 20),)
            ),
            const SizedBox(height: 10,),
            if(gameStatus==GameStatus.over)ElevatedButton(
                onPressed: reset,
                child: const Text("Reset",style: TextStyle(fontSize: 20),)
            )
          ],
        )
            : StartPage(
          onStart: startGame,
        ),
      ),
    );
  }

  Future<void> rollTheDice() async {
    final player=AudioPlayer();
    await player.setAsset("musics/dicesound.mp3");
    await player.play();
    setState(() {
      index1=random.nextInt(6);
      index2=random.nextInt(6);
      diceSum=index1+index2+2;

      if(!hasTarget){
        checkFirstRoll();
      }
      else{
        checkTarget();
      }
    });
  }

  void checkTarget() {
    if(diceSum==7){
      result=lost;
      gameStatus=GameStatus.over;
    }
    else if(diceSum==target){
      result=win;
      gameStatus=GameStatus.over;
    }
  }

  void checkFirstRoll() {
    if(diceSum==7 || diceSum==11){
      result=win;
      gameStatus=GameStatus.over;
    }
    else if(diceSum==2 || diceSum==3 || diceSum==12){
      result=lost;
      gameStatus=GameStatus.over;
    }
    else{
      hasTarget=true;
      target=diceSum;
    }
  }

  void reset() {
    setState(() {
      index1=0;
      index2=0;
      diceSum=0;
      target=0;
      result="";
      hasTarget=false;
      shouldShowBoard=false;
      gameStatus=GameStatus.none;
    });
  }

  void startGame() {
    setState(() {
      shouldShowBoard=true;
      gameStatus=GameStatus.running;
    });
  }
}

class StartPage extends StatelessWidget {
  final VoidCallback onStart;
  const StartPage({super.key,required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset("images/dicelogo.png",width: 250,height: 250,),
        Text("Mega Roll",style: GoogleFonts.russoOne().copyWith(fontSize: 40,color: Colors.black),),
        const Spacer(),
        DiceButton(label: "START", onPressed: onStart),
        DiceButton(label: "HOW TO PLAY", onPressed: (){
          showInstruction(context);
        })
      ],
    );
  }

  void showInstruction(BuildContext context) {
    showDialog(context: context, builder: (context)=>AlertDialog(
      title: const Center(child: Text("INSTRUCTION")),
      content: const Text(gameRules),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(context), child: const Text("CLOSE"))
      ],
    )
    );
  }
}

class DiceButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const DiceButton({super.key,required this.label,required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 200,
        height: 60,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black
          ),
          child: Text(label,style: const TextStyle(fontSize: 20,color: Colors.white),),
        ),
      ),
    );
  }
}

const gameRules='''
* AT THE FIRST ROLL, IF THE DICE SUM IS 7 OR 11, YOU WIN!
* AT THE FIRST ROLL, IF THE DICE SUM IS 2, 3 OR 12, YOU LOST!!
* AT THE FIRST ROLL, IF THE DICE SUM IS 4, 5, 6, 8, 9, 10, THEN THIS DICE SUM IS YOUR TARGET
* IF THE DICE SUM MATCHES YOUR TARGET POINT, YOU WIN!
* IF THE DICE SUM IS 7, YOU LOST!!
''';