import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/fasting_session.dart';

class HistoryDetailPage extends StatelessWidget {
  final FastingSession session;

  const HistoryDetailPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final fullFormat = DateFormat('EEEE, MMMM d, y - h:mm a');

    return Scaffold(
      appBar: AppBar(title: const Text("Session Details")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer, size: 48, color: AppColors.primary),
                  const SizedBox(height: 10),
                  Text(
                    "${session.duration.inHours}h ${session.duration.inMinutes % 60}m",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Text("Total Fasted"),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildInfoRow(context, "Started", fullFormat.format(session.startTime)),
            const Divider(height: 30),
            _buildInfoRow(context, "Ended", session.endTime != null ? fullFormat.format(session.endTime!) : "Ongoing"),
            const Divider(height: 30),
            _buildInfoRow(context, "Status", session.endTime != null ? "Completed" : "Active", 
              color: session.endTime != null ? AppColors.success : AppColors.warning),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Flexible(
          child: Text(
            value, 
            style: TextStyle(
              fontSize: 16, 
              color: color ?? Theme.of(context).textTheme.bodyMedium?.color
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
