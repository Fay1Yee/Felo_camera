import 'package:flutter/material.dart';
import '../config/api_config.dart';

/// 模型选择器组件
class ModelSelector extends StatefulWidget {
  final String? selectedModel;
  final Function(String?) onModelChanged;
  final bool showDescription;

  const ModelSelector({
    Key? key,
    this.selectedModel,
    required this.onModelChanged,
    this.showDescription = true,
  }) : super(key: key);

  @override
  State<ModelSelector> createState() => _ModelSelectorState();
}

class _ModelSelectorState extends State<ModelSelector> {
  @override
  Widget build(BuildContext context) {
    final availableModels = ApiConfig.getAvailableModels();
    final currentModel = widget.selectedModel ?? ApiConfig.defaultModelKey;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'AI 模型选择',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 模型选择下拉菜单
            DropdownButtonFormField<String>(
              value: currentModel,
              decoration: const InputDecoration(
                labelText: '选择模型',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.smart_toy),
              ),
              items: availableModels.map((modelKey) {
                final config = ApiConfig.getModelConfig(modelKey);
                return DropdownMenuItem<String>(
                  value: modelKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        config.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (widget.showDescription && config.description.isNotEmpty)
                        Text(
                          config.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: widget.onModelChanged,
            ),
            
            const SizedBox(height: 12),
            
            // 当前模型详细信息
            if (widget.showDescription) ...[
              const Divider(),
              _buildModelInfo(currentModel),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModelInfo(String modelKey) {
    final config = ApiConfig.getModelConfig(modelKey);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '模型详情',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        _buildInfoRow('模型名称', config.name),
        _buildInfoRow('描述', config.description),
        _buildInfoRow('最大令牌', '${config.maxTokens}'),
        _buildInfoRow('温度参数', '${config.temperature}'),
        
        if (modelKey == ApiConfig.defaultModelKey)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: const Text(
              '默认模型',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 简化的模型选择器（仅显示下拉菜单）
class SimpleModelSelector extends StatelessWidget {
  final String? selectedModel;
  final Function(String?) onModelChanged;

  const SimpleModelSelector({
    Key? key,
    this.selectedModel,
    required this.onModelChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final availableModels = ApiConfig.getAvailableModels();
    final currentModel = selectedModel ?? ApiConfig.defaultModelKey;

    return DropdownButton<String>(
      value: currentModel,
      icon: const Icon(Icons.arrow_drop_down),
      underline: Container(),
      items: availableModels.map((modelKey) {
        final config = ApiConfig.getModelConfig(modelKey);
        return DropdownMenuItem<String>(
          value: modelKey,
          child: Text(config.name),
        );
      }).toList(),
      onChanged: onModelChanged,
    );
  }
}

/// 模型状态指示器
class ModelStatusIndicator extends StatelessWidget {
  final String? currentModel;
  final bool isAnalyzing;

  const ModelStatusIndicator({
    Key? key,
    this.currentModel,
    this.isAnalyzing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final modelKey = currentModel ?? ApiConfig.defaultModelKey;
    final config = ApiConfig.getModelConfig(modelKey);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAnalyzing ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAnalyzing ? Colors.orange.withOpacity(0.3) : Colors.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAnalyzing ? Icons.hourglass_empty : Icons.smart_toy,
            size: 16,
            color: isAnalyzing ? Colors.orange : Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            isAnalyzing ? '分析中...' : config.name,
            style: TextStyle(
              fontSize: 12,
              color: isAnalyzing ? Colors.orange : Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}