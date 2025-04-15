import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/before_after_record.dart';

class BeforeAfterWidget extends StatelessWidget {
  final BeforeAfterRecord record;
  final bool isDetailed;

  const BeforeAfterWidget({
    Key? key,
    required this.record,
    this.isDetailed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isDetailed) {
      return _buildDetailedView(context);
    } else {
      return _buildCompactView(context);
    }
  }

  Widget _buildCompactView(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Önce / Sonra Karşılaştırması',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Önce', 
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildNetworkImage(record.beforeImage, 
                        height: MediaQuery.of(context).size.width * 0.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Sonra', 
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildNetworkImage(record.afterImage, 
                        height: MediaQuery.of(context).size.width * 0.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedView(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Önce / Sonra Karşılaştırması',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Öncesi', 
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.red.shade700
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildNetworkImage(record.beforeImage, 
                  height: MediaQuery.of(context).size.width * 0.6,
                  width: double.infinity,
                ),
              ),
              if (record.beforeDescription != null && record.beforeDescription!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(record.beforeDescription!),
                ),
              const SizedBox(height: 24),
              Text('Sonrası', 
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.green.shade700
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildNetworkImage(record.afterImage, 
                  height: MediaQuery.of(context).size.width * 0.6,
                  width: double.infinity,
                ),
              ),
              if (record.afterDescription != null && record.afterDescription!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(record.afterDescription!),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkImage(String imageUrl, {double? height, double? width}) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: width,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.error_outline, color: Colors.red),
        ),
      ),
    );
  }
}