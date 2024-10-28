import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const apiKey = "AIzaSyCxkmBNOvOPDhoQwUJM2SVURys1wmorGN0";

Future<String> getImageDescription(String imageUrl) async {
  final url = Uri.parse('https://describe-image-izihs7djlq-uc.a.run.app/');

  final Map<String, dynamic> requestBody = {
    "data": {"imageUrl": imageUrl}
  };

  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      return response.body;
    }
  } catch (e) {
    //error
  }
  return '';
}

Future<String> areMatchedDescriptions(
  String claimDescription,
  String itemDescription,
) async {
  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: apiKey,
  );
  final prompt =
      '''I will provide two descriptions for an item that is lost so the description may not be 100% the same but if there is a high percentage of the description to be for the same item please say Match if not say noMatch, they might be typed in different languages, or might use different terms to describe the same item.
   you have to fully understand and analyze the prompt and decide whether they are matching or not,
   the first one is: $claimDescription,
   the second one is $itemDescription,
  response with one single word "Match" or "NoMatch"''';
  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);
  print('inside function');
  print(response.text);
  return response.text ?? '';
}

Future<String> getImagesDescriptions(List<String> imageUrls) async {
  String imageDescriptions = '';
  for(String url in imageUrls) {
    String description = await getImageDescription(url);
    imageDescriptions += description;
  }
  return imageDescriptions;
}