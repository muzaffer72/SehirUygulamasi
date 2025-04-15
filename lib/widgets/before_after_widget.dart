import 'package:flutter/material.dart';
import 'package:sikayet_var/models/before_after_record.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class BeforeAfterWidget extends StatefulWidget {
  final Post post;
  final bool compact;

  const BeforeAfterWidget({
    Key? key,
    required this.post,
    this.compact = false,
  }) : super(key: key);

  @override
  State<BeforeAfterWidget> createState() => _BeforeAfterWidgetState();
}

class _BeforeAfterWidgetState extends State<BeforeAfterWidget> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<BeforeAfterRecord> _records = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    if (!widget.post.isSolved) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final records = await _apiService.getBeforeAfterRecords(postId: widget.post.id);
      
      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Öncesi/sonrası kayıtları yüklenirken bir hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.post.isSolved || (_records.isEmpty && !_isLoading && _errorMessage == null)) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Öncesi ve Sonrası',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              )
            else
              ..._records.map((record) => _buildBeforeAfterRecord(record)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBeforeAfterRecord(BeforeAfterRecord record) {
    if (widget.compact) {
      return ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(record.afterImageUrl),
        ),
        title: Text('Kayıt: ${DateFormat('dd.MM.yyyy').format(record.recordDate)}'),
        onTap: () => _showDetailDialog(record),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (record.description != null && record.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              record.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Öncesi',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: CachedNetworkImage(
                        imageUrl: record.beforeImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Sonrası',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: CachedNetworkImage(
                        imageUrl: record.afterImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'Kayıt tarihi: ${DateFormat('dd.MM.yyyy').format(record.recordDate)}',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        const Divider(height: 32),
      ],
    );
  }

  void _showDetailDialog(BeforeAfterRecord record) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Öncesi ve Sonrası',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (record.description != null && record.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    record.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              Column(
                children: [
                  Text(
                    'Öncesi',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: record.beforeImageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  Text(
                    'Sonrası',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: record.afterImageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Kayıt tarihi: ${DateFormat('dd.MM.yyyy').format(record.recordDate)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kapat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}