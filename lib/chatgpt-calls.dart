import 'dart:convert';
import 'package:crop_prediction_system/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<String> predict_soil_health(String userMessage, String locale) async {
  const apiKey = AppConstants.openAIKey; 
  const url = 'https://api.openai.com/v1/chat/completions';

  print("app locale = $locale");

  if(locale == "ta") {
    locale = ", reply in tamil language.";
  }else if(locale == "hi") {
    locale = ", reply in hindi language.";
  }else {
    locale = ", reply in english language.";
  }

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  };

  final body = jsonEncode({
    "model": "gpt-3.5-turbo",  // or "gpt-4" if you have access
    "messages": [
      {
        "role": "user",
        "content": [
          {"type": "text",
            "text": "Please provide me the soil Health  for the city their Nutrients and Soil Name $userMessage, also suggest me the fertilizer we need to use $locale"
          }
        ]
      }
    ],
    "temperature": 0.7,
  });

  final response = await http.post(Uri.parse(url), headers: headers, body: body);

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
    final reply = jsonResponse['choices'][0]['message']['content'];
    return reply;
  } else {
    print("Failed: ${response.statusCode} - ${response.body}");
    throw Exception('Failed to get response from ChatGPT');
  }
}

Future<String> predict_with_chatgpt(String base64_image, String locale) async {
  const apiKey = AppConstants.openAIKey;  // 🔐 Store securely in production
  const url = 'https://api.openai.com/v1/chat/completions';
  print("app locale = $locale");

  if(locale == "ta") {
    locale = ", reply in tamil language.";
  }else if(locale == "hi") {
    locale = ", reply in hindi language.";
  }else {
    locale = ", reply in english language.";
  }
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  };

  final body = jsonEncode({
    "model": "gpt-4-turbo",  // or "gpt-4" if you have access
    "messages": [
      {
        "role": "user",
        "content": [
          {"type": "text",
            "text": "You are an expert in agriculture and plant nutrition. Analyze the uploaded leaf image to estimate nitrogen levels and diseases based on leaf color using the Leaf Color Chart (LCC). Identify the closest color match from this list: #006400, #228B22, #7CFC00, #A4C639, #FFFF00, #8B4513. Based on this color, determine if the plant is nitrogen-deficient, healthy, or excessive. Also suggest appropriate fertilizer usage and dosage if needed. $locale"},
          {
            "type": "image_url",
            "image_url": {
              "url": "data:image/jpeg;base64, $base64_image"
            }
          }
        ]
      }
    ],
    "temperature": 0.7,
  });

  final response = await http.post(Uri.parse(url), headers: headers, body: body);

  if (response.statusCode == 200) {
    print(response.body);
    final jsonResponse =  json.decode(utf8.decode(response.bodyBytes));
    print(jsonResponse);

    final reply = jsonResponse['choices'][0]['message']['content'];
    return (reply);
  } else {
    print("Failed: ${response.statusCode} - ${response.body}");
    throw Exception('Failed to get response from ChatGPT');
  }
}

Future<String> get_image_colorcode_with_chatgpt(String base64_image, String locale) async {
  const apiKey = AppConstants.openAIKey;  // 🔐 Store securely in production
  const url = 'https://api.openai.com/v1/chat/completions';
  print("app locale = $locale");

  if(locale == "ta") {
    locale = "tamil language.";
  }else if(locale == "hi") {
    locale = "hindi language.";
  }else {
    locale = "english language.";
  }
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  };

  final body = jsonEncode({
    "model": "gpt-4-turbo",  // or "gpt-4" if you have access
    "messages": [
      {
        "role": "user",
        "content": [
          {"type": "text",
            "text": """You are a leaf health analysis expert. \n\n Analyze the uploaded leaf image and return a JSON object with keys in English and values in $locale. \n\n Use the following keys (in English only):
                - dominant_color (any one matched color code from my list (#006400, #228B22, #7CFC00, #A4C639, #FFFF00, #8B4513) )
                - color_name
                - health_status
                - description
                The values can be in the user's preferred language (e.g., $locale).
               Do not include any explanation or text outside the JSON. Respond based on the image content."""},
          {
            "type": "image_url",
            "image_url": {
              "url": "data:image/jpeg;base64, $base64_image"
            }
          }
        ]
      }
    ],
    "temperature": 0.7,
  });

  final response = await http.post(Uri.parse(url), headers: headers, body: body);

  if (response.statusCode == 200) {
    print(response.body);
    final jsonResponse =  json.decode(utf8.decode(response.bodyBytes));
    print(jsonResponse);

    final reply = jsonResponse['choices'][0]['message']['content'];
    return (reply);
  } else {
    print("Failed: ${response.statusCode} - ${response.body}");
    throw Exception('Failed to get response from ChatGPT');
  }
}

Future<String> chat_with_gpt(String userMessage, String locale) async {
  const apiKey = AppConstants.openAIKey;  // 🔐 Store securely in production
  const url = 'https://api.openai.com/v1/chat/completions';

  print("app locale = $locale");

  if(locale == "ta") {
    locale = ", reply in tamil language.";
  }else if(locale == "hi") {
    locale = ", reply in hindi language.";
  }else {
    locale = ", reply in english language.";
  }

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  };

  final body = jsonEncode({
    "model": "gpt-3.5-turbo",  // or "gpt-4" if you have access
    "messages": [
      {
        "role": "user",
        "content": [
          {"type": "text",
            "text": "you are an expert in agriculture, answer the following questions\n\n $userMessage \n\n $locale"
          }
        ]
      }
    ],
    "temperature": 0.7,
  });

  final response = await http.post(Uri.parse(url), headers: headers, body: body);

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
    final reply = jsonResponse['choices'][0]['message']['content'];
    return reply;
  } else {
    print("Failed: ${response.statusCode} - ${response.body}");
    throw Exception('Failed to get response from ChatGPT');
  }
}

