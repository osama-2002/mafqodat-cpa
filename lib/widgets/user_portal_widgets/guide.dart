import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(
          translate("Guide"),
          style:const TextStyle(fontSize: 18),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              Text(
                translate("FollowSteps"),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _GuidePoint(
                title: translate("FirstTitle"),
                content:
                    translate("FirstStep"),
              ),
              _GuidePoint(
                title: translate("SecondTitle"),
                content:
                    translate("SecondStep"),
              ),
              _GuidePoint(
                title: translate("ThirdTitle"),
                content:
                    translate("ThirdStep"),
              ),
              _GuidePoint(
                title: translate("FourthTitle"),
                content:
                    translate("FourthStep"),
              ),
              _GuidePoint(
                title: translate("FifthTitle"),
                content:
                    translate("FifthStep"),
              ),
              _GuidePoint(
                title: translate("SixthTitle"),
                content:
                    translate("SixthStep"),
              ),
              _GuidePoint(
                title: translate("SeventhTitle"),
                content:
                    translate("SeventhStep"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuidePoint extends StatelessWidget {
  final String title;
  final String content;

  const _GuidePoint({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
