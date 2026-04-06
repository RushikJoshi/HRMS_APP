import 'package:flutter/material.dart';

import 'leave_summary_grid.dart';

class LeaveSummaryCollapsedChips extends StatelessWidget {
  final List<LeaveSummaryItem> chips;
  final bool isOtherContainer;
  final int maxLeavesInMonth;
  final EdgeInsetsGeometry? padding;

  const LeaveSummaryCollapsedChips({
    required this.chips,
    super.key,
    this.isOtherContainer = false,
    this.maxLeavesInMonth = 2,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
      padding:
      padding ??
          EdgeInsets.symmetric(
            vertical: height * 0.014,
            horizontal: width * 0.04,
          ),
      child: LeaveSummarySection(
        summaryItems: chips,
        maxLeavesInMonth: maxLeavesInMonth,
        isOtherContainer: isOtherContainer,
        onViewDates: () {},
      ),
    );
  }
}
