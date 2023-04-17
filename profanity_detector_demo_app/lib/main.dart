import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:profanity_detector_demo_app/controller/image_url_controller.dart';

import 'package:profanity_detector_demo_app/services/base_client.dart';
import 'package:profanity_filter/profanity_filter.dart';

import 'controller/image_controller.dart';
import 'controller/storage.dart';
import 'firebase_options.dart';
import 'services/check_image_nudity.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Profanity Detector App',
      theme: ThemeData(
          primarySwatch: Colors.purple,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
            ),
          )),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Profanity Detector Demo App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  var imgUrl = '';

  final TextEditingController textEditingController = TextEditingController();

  final contentModeratorController = Get.put(ContentModerationController());

  final filter = ProfanityFilter();

  final controller = Get.put(BaseClient());

  final imageController = Get.put(ImageController());
  final ImageUrlController imageUrlController = Get.put(ImageUrlController());

  final storageController = Get.put(Storage());

  bool showloader = false;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void dispose() {
    widget.textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: widget.showloader == false
            ? GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.1,
                        vertical: size.height * 0.1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: size.width * 0.8,
                          child: TextFormField(
                            controller: widget.textEditingController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: size.height * 0.01,
                                  vertical: size.height * 0.01),
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                              labelText: 'Enter Text',
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () {
                                if (widget.textEditingController.text.isEmpty) {
                                  Get.snackbar('Error', 'Please enter text',
                                      snackPosition: SnackPosition.BOTTOM);
                                  return;
                                }
                                if (widget.filter.hasProfanity(
                                    widget.textEditingController.text)) {
                                  Get.snackbar(
                                    'Profanity Found',
                                    'Profanity found in the text',
                                    overlayBlur: 0.5,
                                    colorText: Colors.black87,
                                    backgroundColor: Colors.red,
                                  );
                                } else {
                                  Get.snackbar(
                                    'No Profanity Found',
                                    'No profanity found in the text',
                                    backgroundColor: Colors.green,
                                  );
                                }
                              },
                              child: const Text('Check for profanity')),
                        ),
                        const SizedBox(height: 20),
                        Obx(
                          () => Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: widget.imageController.imagePath == ''
                                ? Center(
                                    child: TextButton(
                                      onPressed:
                                          widget.imageController.pickImage,
                                      child: const Text('Pick Image'),
                                    ),
                                  )
                                : Stack(children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.file(
                                        File(widget
                                            .imageController.imagePath.value),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        onPressed: () {
                                          widget.imageController.imagePath
                                              .value = '';
                                        },
                                        icon: const Icon(
                                          Icons.cancel_outlined,
                                          color: Colors.purple,
                                        ),
                                      ),
                                    )
                                  ]),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (widget.imageController.imagePath.value ==
                                  '') {
                                Get.snackbar('Error', 'Please pick an image',
                                    snackPosition: SnackPosition.BOTTOM);
                                return;
                              }

                              setState(() {
                                widget.showloader = true;
                              });

                              if (widget.imgUrl == '') {
                                widget.imgUrl = await widget.storageController
                                        .uploadFile(File(widget.imageController
                                            .imagePath.value)) ??
                                    '';
                                if (widget.imgUrl == '') {
                                  Get.snackbar('Error', 'Error uploading image',
                                      snackPosition: SnackPosition.BOTTOM);

                                  setState(() {
                                    widget.showloader = false;
                                  });
                                  return;
                                }
                                print(
                                    'Image url is ${widget.imgUrl} and image path is ${widget.imageController.imagePath.value}');
                              }

                              widget.imageUrlController
                                  .classifyImage(widget.imgUrl);
                              setState(() {
                                widget.showloader = false;
                              });
                            },
                            child: const Text('Check for in Image'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator()));
  }
}
