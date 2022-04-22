import 'package:flutter/material.dart';
import 'package:camera_deep_ar/camera_deep_ar.dart';
import 'package:avatar_view/avatar_view.dart';

const apikey = "cfe827da18228fcdcd7e28781492961ff2a5caecc39d39b2e61786acfbe6db4d5a2d8038470f24ad";

class ActivityFeedPage extends StatefulWidget {
  const ActivityFeedPage({Key? key}) : super(key: key);

  @override
  State<ActivityFeedPage> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<ActivityFeedPage> {
  int _count = 0;
  late CameraDeepArController cameraDeepArController;
  int effectCount = 0;

  String _platformVersion = 'Unknown';
  int currentPage = 0;
  final vp = PageController(viewportFraction: .24);
  Effects currentEffect = Effects.none;
  Filters currentFilter = Filters.none;
  Masks currentMask = Masks.none;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraDeepAr(
            cameraDeepArCallback: (c) async {
              cameraDeepArController = c;
              setState(() {});
            },
            onCameraReady: (isReady) {
              _platformVersion = "Camera status $isReady";
              print(_platformVersion);
              setState(() {});
            },
            onImageCaptured: (path) {
              _platformVersion = "Image save at $path";
              setState(() {});
            },
            androidLicenceKey: apikey,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 28, right: 28),
                    child: Expanded(
                      child: TextButton(
                        child: const Icon(Icons.camera_enhance),
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(Colors.white54),
                        ),
                        onPressed: () {
                          if (cameraDeepArController == null) {
                            return;
                          }
                          cameraDeepArController.snapPhoto();
                        },
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(8, (index) {
                        var active = currentPage == index;

                        return GestureDetector(
                          onTap: () {
                            currentPage = index;
                            cameraDeepArController.changeMask(index);
                            setState(() {});
                          },
                          child: AvatarView(
                            radius: active ? 45 : 25,
                            borderColor: Colors.yellow,
                            borderWidth: 2,
                            isOnlyText: false,
                            avatarType: AvatarType.CIRCLE,
                            backgroundColor: Colors.red,
                            imagePath:
                            "assets/images/${index.toString()}.jpg",
                            placeHolder: const Icon(Icons.person, size: 50),
                            errorWidget: const Icon(Icons.error, size: 50),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}