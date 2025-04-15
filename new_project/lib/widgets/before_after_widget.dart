import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/before_after_record.dart';

class BeforeAfterWidget extends StatelessWidget {
  final BeforeAfterRecord record;
  
  const BeforeAfterWidget({
    Key? key,
    required this.record,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        _buildBeforeAfterImages(context),
        if (record.beforeDescription != null || record.afterDescription != null)
          const SizedBox(height: 8),
        if (record.beforeDescription != null || record.afterDescription != null)
          _buildDescriptions(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.compare_arrows,
          color: Colors.green[700],
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          'Önce / Sonra Karşılaştırması',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.green[700],
          ),
        ),
      ],
    );
  }

  Widget _buildBeforeAfterImages(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageWidth = (size.width - 48) / 2;
    final imageHeight = imageWidth * 0.75;
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildImageWithLabel(
              'Önce', 
              record.beforeImage, 
              imageHeight,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildImageWithLabel(
              'Sonra', 
              record.afterImage, 
              imageHeight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWithLabel(String label, String imageUrl, double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: label == 'Önce' ? Colors.red[100] : Colors.green[100],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: label == 'Önce' ? Colors.red[800] : Colors.green[800],
            ),
          ),
        ),
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: height,
              color: Colors.grey[300],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: height,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.error),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (record.beforeDescription != null) ...[
          Text(
            'Önceki Durum:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.red[700],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              record.beforeDescription!,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
        if (record.afterDescription != null) ...[
          Text(
            'Sonraki Durum:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.green[700],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              record.afterDescription!,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ],
    );
  }
}