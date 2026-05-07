import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../applications/models/application_model.dart';
import '../../applications/providers/application_provider.dart';
import '../../../core/widgets/shared_components.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(applicationProvider);
    final apps = state.allApplications;

    if (state.isLoading && apps.isEmpty) {
      return const Scaffold(body: AppLoadingIndicator());
    }

    // --- Analytics Calculations ---
    final total = apps.length;
    final selected = apps.where((a) => a.status == ApplicationStatus.selected).length;
    final rejected = apps.where((a) => a.status == ApplicationStatus.rejected).length;
    final interview = apps.where((a) => a.status == ApplicationStatus.interviewScheduled).length;
    
    // For Bar Chart: Group by Month (Last 6 Months)
    final now = DateTime.now();
    final Map<int, int> monthlyData = {
      for (var i = 5; i >= 0; i--) DateTime(now.year, now.month - i).month: 0
    };
    
    for (var app in apps) {
      final appMonth = app.dateApplied.month;
      if (monthlyData.containsKey(appMonth)) {
        monthlyData[appMonth] = monthlyData[appMonth]! + 1;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        centerTitle: true,
      ),
      body: apps.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.dashboard_customize_outlined, size: 80, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 16),
                  const Text('No Data for Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ).animate().fadeIn(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Stat Cards Grid ---
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.5,
                    children: [
                      DashboardCard(title: 'Total Apps', value: total.toString(), icon: Icons.analytics_outlined, color: Colors.blue),
                      DashboardCard(title: 'Selected', value: selected.toString(), icon: Icons.check_circle_outline, color: Colors.green),
                      DashboardCard(title: 'Interviews', value: interview.toString(), icon: Icons.calendar_month_outlined, color: Colors.purple),
                      DashboardCard(title: 'Rejected', value: rejected.toString(), icon: Icons.cancel_outlined, color: Colors.red),
                    ],
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
                  const SizedBox(height: 32),

                  // --- Pie Chart ---
                  Text(
                    'Application Status Distribution',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: _getPieSections(apps),
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  const SizedBox(height: 32),

                  // --- Bar Chart ---
                  Text(
                    'Monthly Applications (Last 6 Months)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SizedBox(
                        height: 250,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: monthlyData.values.isEmpty ? 10 : (monthlyData.values.reduce((a, b) => a > b ? a : b).toDouble() + 2),
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final monthInt = value.toInt();
                                    final monthStr = DateFormat('MMM').format(DateTime(0, monthInt));
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(monthStr, style: const TextStyle(fontSize: 10)),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: monthlyData.entries.map((entry) {
                              return BarChartGroupData(
                                x: entry.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.value.toDouble(),
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 16,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }


  List<PieChartSectionData> _getPieSections(List<JobApplicationModel> apps) {
    final Map<ApplicationStatus, int> statusCounts = {};
    for (var app in apps) {
      statusCounts[app.status] = (statusCounts[app.status] ?? 0) + 1;
    }

    return statusCounts.entries.map((entry) {
      final isSelected = entry.key == ApplicationStatus.selected;
      final radius = isSelected ? 50.0 : 40.0;
      
      Color color;
      switch (entry.key) {
        case ApplicationStatus.applied: color = Colors.blueGrey; break;
        case ApplicationStatus.shortlisted: color = Colors.orange; break;
        case ApplicationStatus.interviewScheduled: color = Colors.purple; break;
        case ApplicationStatus.rejected: color = Colors.red; break;
        case ApplicationStatus.selected: color = Colors.green; break;
      }

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: radius,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }
}
