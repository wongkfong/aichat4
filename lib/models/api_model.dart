class ApiModel {
  final String id;
  final String name;
  final String modelName;
  final String description;

  const ApiModel({
    required this.id,
    required this.name,
    required this.modelName,
    required this.description,
  });
}

class ApiConfig {
  static String apiKey = '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';
  static const String baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static double temperature = 0.7;

  static const List<ApiModel> availableApis = [
    ApiModel(
      id: 'deepseek-chat',
      name: 'Deepseek Chat',
      modelName: 'deepseek/deepseek-chat-v3-0324:free',
      description: '適合一般對話的AI模型',
    ),
    ApiModel(
      id: 'deepseek-coder',
      name: 'Deepseek Coder',
      modelName: 'deepseek/deepseek-coder-33b-instruct:free',
      description: '專門用於程式開發的AI模型',
    ),
    ApiModel(
      id: 'solar',
      name: 'Solar',
      modelName: 'upstage/solar-0-70b-16bit:free',
      description: '強大的通用AI模型',
    ),
    ApiModel(
      id: 'mistral',
      name: 'Mistral',
      modelName: 'mistralai/mistral-7b-instruct:free',
      description: '快速且準確的AI模型',
    ),
  ];

  static ApiModel getDefaultApi() => availableApis[0];

  static void updateApiKey(String newKey) {
    apiKey = newKey;
  }

  static void updateTemperature(double newTemp) {
    temperature = newTemp;
  }
} 