import 'package:flutter/material.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Guide to Submitting an Effective Claim',
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Follow these steps to increase the chances of finding your lost item:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _GuidePoint(
                title: 'Provide a Detailed Description',
                content:
                    'Clearly describe the lost item, including any unique features or identifiers. This will help in quickly identifying the item if found.',
              ),
              _GuidePoint(
                title: 'Select the Correct Category',
                content:
                    'Ensure that you select the appropriate category from the dropdown. This categorization helps in organizing and processing your claim more efficiently.',
              ),
              _GuidePoint(
                title: 'Choose a Distinct Color',
                content:
                    'If the item has a distinct color, make sure to pick a color that closely matches it. This helps in distinguishing the item from others.',
              ),
              _GuidePoint(
                title: 'Set the Accurate Date',
                content:
                    'Select the date when the item was lost. Accurate timing can aid in narrowing down search efforts.',
              ),
              _GuidePoint(
                title: 'Pin the Correct Location',
                content:
                    'Use the location picker to accurately pin where you lost the item. If you are unsure, try to get as close as possible to the last known location.',
              ),
              _GuidePoint(
                title: 'Upload Clear Photos',
                content:
                    'If you have any photos of the lost item, upload them. Clear images with good lighting can be crucial in identifying your item.',
              ),
              _GuidePoint(
                title: 'Avoid Multiple Submissions',
                content:
                    'Submit only one claim per lost item. Multiple submissions for the same item can slow down the search and recovery process.',
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
