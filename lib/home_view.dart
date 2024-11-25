import 'package:flutter/material.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  TextEditingController textEditingController = TextEditingController();
  String result = 'النص المترجم';

  dynamic modelManager;
  bool isEnDownloaded = false;
  bool isArabicDownloaded = false;
  dynamic onDeviceTranslator;
  dynamic languageIdentifier;

  @override
  void initState() {
    super.initState();
    languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
    modelManager = OnDeviceTranslatorModelManager();
    checkAndDownloadModel();
  }

  checkAndDownloadModel() async {
    isEnDownloaded =
        await modelManager.isModelDownloaded(TranslateLanguage.english.bcpCode);

    isArabicDownloaded =
        await modelManager.isModelDownloaded(TranslateLanguage.arabic.bcpCode);

    if (!isEnDownloaded) {
      isEnDownloaded =
          await modelManager.downloadModel(TranslateLanguage.english.bcpCode);
    }

    if (!isArabicDownloaded) {
      isArabicDownloaded =
          await modelManager.downloadModel(TranslateLanguage.arabic.bcpCode);
    }

    if (isEnDownloaded && isArabicDownloaded) {
      onDeviceTranslator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: TranslateLanguage.arabic,
      );
    }
  }

  translateText(String text) async {
    if (isEnDownloaded && isArabicDownloaded) {
      final String response = await onDeviceTranslator.translateText(text);
      setState(() {
        result = response;
      });
    }
    identifyLanguages(text);
  }

  identifyLanguages(String text) async {
    final String response = await languageIdentifier.identifyLanguage(text);
    textEditingController.text += " ($response)";

    final String response2 = await languageIdentifier.identifyLanguage(result);
    setState(() {
      result += " ($response2)";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          color: Colors.black12,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
                height: 50,
                child: Card(
                  color: const Color.fromARGB(255, 55, 57, 207),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                        'English',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        height: 48,
                        width: 1,
                        color: Colors.white,
                      ),
                      const Text(
                        'Arabic',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20, left: 2, right: 2),
                width: double.infinity,
                height: 250,
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: textEditingController,
                      decoration: const InputDecoration(
                          fillColor: Colors.white,
                          hintText: 'Type text here...',
                          filled: true,
                          border: InputBorder.none),
                      style: const TextStyle(color: Colors.black),
                      maxLines: 100,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 15, left: 13, right: 13),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(color: Colors.white),
                      backgroundColor: const Color.fromARGB(255, 9, 2, 48)),
                  child: const Text(
                    'Translate',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    translateText(textEditingController.text);
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 15, left: 10, right: 10),
                width: double.infinity,
                height: 250,
                child: Card(
                  color: Colors.white,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      textDirection: TextDirection.rtl,
                      result,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
