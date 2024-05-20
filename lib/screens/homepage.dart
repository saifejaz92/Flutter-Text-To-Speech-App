import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:text_to_speech/screens/purchases.dart';
import 'package:text_to_speech/utils/colors/colors.dart';

int wordCount = 0;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController textEditingController = TextEditingController();
  FlutterTts flutterTts = FlutterTts();
  double volume = 1.0;
  double pitch = 1.0;
  double speechRate = 0.5;
  late List<String> languages = ["en-US", "ur-PK"];
  String langCode = "en-US";
  bool isValidate = false;
  List<Map> _voices = [];
  Map? _currentVoice;

  bool isSpeaking = false;
  @override
  void initState() {
    super.initState();
    init();
    initsettings();
    saveUserData();
  }

  Future<void> saveUserData() async {
    try {
      // Get the current user
      User? firebaseUser = FirebaseAuth.instance.currentUser;

      // Check if the user document already exists
      DocumentSnapshot<Map<String, dynamic>> userDocSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser!.uid)
              .get();
      setState(() {
        wordCount = userDocSnapshot.data()?['CharacterCount'] ?? 0;
      });

      // If the user document doesn't exist, create it
      if (!userDocSnapshot.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .set({
          'CharacterCount': 0,
          "uid": firebaseUser.uid,
          // Add other user data as needed
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error saving user data: $e");
    }
  }

  Future<void> updateWordCount(int newWordCount) async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Add new word count to the current word count
      int updatedWordCount = wordCount + newWordCount;
      // Update word count in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {
          'CharacterCount': updatedWordCount,
        },
      );
      // Update the state
      setState(() {
        wordCount = updatedWordCount;
      });
    }
  }

  void init() async {
    languages = List<String>.from(await flutterTts.getLanguages);
    flutterTts.getVoices.then((data) {
      try {
        List<Map> voices = List<Map>.from(data);
        setState(() {
          _voices =
              voices.where((voice) => voice["name"].contains("en")).toList();
          _currentVoice = _voices.isNotEmpty ? _voices.first : null;
          if (_currentVoice == null) {
            // Show toast message if no voice is available
            Fluttertoast.showToast(msg: "Voice is not available at this time");
          }
        });
      } catch (e) {
        FlutterError("Something Went Wrong");
      }
    });
  }

// Function to count the number of words in the text
  void countWords(String text) {
    int newWordCount = text.length;
    updateWordCount(newWordCount);
    setState(() {
      wordCount = newWordCount;
    });
  }

  play() {
    initsettings();
    if (_currentVoice != null) {
      setVoice(_currentVoice!);
    }
    setState(() {
      isSpeaking = true;
    });

    // ignore: unrelated_type_equality_checks
    if (flutterTts.speak(textEditingController.text) == false) {
      FlutterError("Something Went Wrong!");
    } else {
      flutterTts.speak(textEditingController.text).then((_) {
        setState(() {
          isSpeaking = false;
        });
      }).catchError((error) {
        setState(() {
          isSpeaking = false;
        });
        FlutterError("Something Went Wrong: $error");
      });
    }
  }

  stop() async {
    await flutterTts.stop();
    setState(() {
      isSpeaking = false;
    });
  }

  void initsettings() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setPitch(pitch);
    await flutterTts.setSpeechRate(speechRate);
    await flutterTts.setLanguage(langCode);
  }

  Future<void> saveAudio() async {
    // Check for permission to write to external storage
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
      status = await Permission.storage.status;
    }

    if (status.isGranted) {
      // Generate audio
      final Map<String, String> voiceMap = _currentVoice!
          .map((key, value) => MapEntry(key.toString(), value.toString()));

      // Set the selected voice
      await flutterTts.setVoice(voiceMap);
      var filename = "/Speecho${DateTime.now().millisecondsSinceEpoch}.mp3";
      var downloadDirectory = Directory('/storage/emulated/0/Download');
      String filePath = "${downloadDirectory.path}$filename";

      if (wordCount > freeUserWordslimit) {
        // Show alert dialog when word count exceeds 100
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Character Limit Exceeded"),
              content: const Text(
                  "The free version is expired. Please pay to continue."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Purchase(),
                      ),
                    );
                  },
                  child: const Text("Pay Now"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
        // Exit the function to prevent further actions
        return;
      }
      if (PurchaseStatus.purchased == testID[0]) {
        if (wordCount > basicUserWordLimit) {
          // Show alert dialog when word count exceeds 100
          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Character Limit Exceeded"),
                content: const Text(
                    "The free version is expired. Please pay to continue."),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Purchase(),
                        ),
                      );
                    },
                    child: const Text("Pay Now"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
          // Exit the function to prevent further actions
          return;
        }
      }
      if (PurchaseStatus.purchased == testID[1]) {
        if (wordCount > standardUserWordsLimit) {
          // Show alert dialog when word count exceeds 100
          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Character Limit Exceeded"),
                content: const Text(
                    "The free version is expired. Please pay to continue."),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Purchase(),
                        ),
                      );
                    },
                    child: const Text("Pay Now"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
          // Exit the function to prevent further actions
          return;
        }
      }

      // Proceed with saving the audio file
      await flutterTts.synthesizeToFile(
        textEditingController.text,
        filePath,
      );
      // Show a snackbar with download link
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Audio saved: $filename'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () {
              // Open file when user taps on "Open"
              OpenFile.open(filePath);
            },
          ),
        ),
      );
      countWords(textEditingController.text);
    } else {
      // Show error if permission is not granted
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission denied to save audio.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff6C9BD8),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Speecho",
          style: TextStyle(
            color: Color(0xff5B4EC4),
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      "Language:\t\t",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      height: 70,
                      width: 120,
                      child: DropdownButton<String>(
                        dropdownColor: const Color(0xff6C9BD8),
                        focusColor: Colors.white,
                        value: langCode,
                        style: const TextStyle(color: Colors.white),
                        iconEnabledColor: Colors.white,
                        items: languages
                            .map<DropdownMenuItem<String>>((String? value) {
                          return DropdownMenuItem<String>(
                            value: value!,
                            child: Text(
                              value,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            langCode = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Voices:\t\t",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    speakerSelector(),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  maxLines: 10,
                  minLines: 1,
                  controller: textEditingController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 25.0, horizontal: 10.0),
                    hintText: "Paste text here..",
                    errorText: isValidate ? "Field cannot be empty" : null,
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 2,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(const Color(0xff5B4EC4)),
                      ),
                      onPressed: () {
                        setState(() {
                          textEditingController.text.isEmpty
                              ? isValidate = true
                              : isValidate = false;
                        });
                        play();
                      },
                      child: isSpeaking
                          ? const SizedBox(
                              width: 24.0,
                              height: 24.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Speech!',
                              style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(const Color(0xff5B4EC4)),
                      ),
                      onPressed: () {
                        stop();
                      },
                      child: const Text(
                        "Stop!",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: saveAudio,
                      child: const Text('Save Audio'),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const Text('Your Characters Count:',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    SizedBox(
                        width: 10,
                        child: Text(wordCount.toString(),
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void setVoice(Map voice) {
    flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
  }

  speakerSelector() {
    return DropdownButton(
      dropdownColor: const Color(0xff6C9BD8),
      focusColor: Colors.white,
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white,
      value: _currentVoice,
      items: _voices
          .map(
            (voice) => DropdownMenuItem(
              value: voice,
              child: Text(
                voiceNames.length > _voices.indexOf(voice)
                    ? voiceNames[_voices.indexOf(voice)]
                    : "Default Voice",
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _currentVoice = value;
          setVoice(_currentVoice!);
        });
      },
    );
  }
}
