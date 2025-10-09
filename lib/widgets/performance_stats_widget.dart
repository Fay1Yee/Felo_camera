import 'package:flutter/material.dart';
import '../services/performance_monitor.dart';
import '../config/nothing_theme.dart';

/// 性能统计显示组件
class PerformanceStatsWidget extends StatefulWidget {
  const PerformanceStatsWidget({super.key});

  @override
  State<PerformanceStatsWidget> createState() => _PerformanceStatsWidgetState();
}

class _PerformanceStatsWidgetState extends State<PerformanceStatsWidget> {
  final PerformanceMonitor _performanceMonitor = PerformanceMonitor.instance;
  PerformanceStats? _stats;
  Map<String, EndpointStats>? _endpointStats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _performanceMonitor.getPerformanceStats();
      final endpointStats = _performanceMonitor.getEndpointStats();
      
      if (mounted) {
        setState(() {
          _stats = stats;
          _endpointStats = endpointStats;
        });
      }
    } catch (e) {
      debugPrint('❌ 加载性能统计失败: $e');
      if (mounted) {
        setState(() {
          _stats = null;
          _endpointStats = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '性能统计',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadStats,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildOverallStats(),
          const SizedBox(height: 16),
          _buildEndpointStats(),
        ],
      ),
    );
  }

  Widget _buildOverallStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '总体统计',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Flexible(
              child: _buildStatCard(
                '总请求数',
                '${_stats!.totalApiCalls}',
                Icons.api,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: _buildStatCard(
                '成功率',
                '${_stats!.successRate.toStringAsFixed(1)}%',
                Icons.check_circle,
                _stats!.successRate > 90 ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Flexible(
              child: _buildStatCard(
                '平均响应时间',
                '${_stats!.averageResponseTime.toStringAsFixed(0)}ms',
                Icons.timer,
                _getResponseTimeColor(_stats!.averageResponseTime.toInt()),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: _buildStatCard(
                '失败数',
                '${_stats!.failedApiCalls}',
                Icons.error,
                _stats!.failedApiCalls == 0 ? Colors.green : NothingTheme.warningOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Flexible(
              child: _buildStatCard(
                '最近1小时',
                '${_stats!.recent1hCalls}次',
                Icons.schedule,
                Colors.cyan,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: _buildStatCard(
                '最近24小时',
                '${_stats!.recent24hCalls}次',
                Icons.today,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEndpointStats() {
    if (_endpointStats == null || _endpointStats!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'API端点统计',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ..._endpointStats!.entries.map((entry) {
          final endpoint = entry.key;
          final stats = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  endpoint,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '请求: ${stats.totalCalls}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '成功率: ${(stats.successRate * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: stats.successRate > 0.9 ? Colors.green : Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '平均: ${stats.averageResponseTime.toStringAsFixed(0)}ms',
                      style: TextStyle(
                        color: _getResponseTimeColor(stats.averageResponseTime.toInt()),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getResponseTimeColor(int milliseconds) {
    if (milliseconds < 1000) return Colors.green;
    if (milliseconds < 3000) return Colors.orange;
    return NothingTheme.warningOrange;
  }
}