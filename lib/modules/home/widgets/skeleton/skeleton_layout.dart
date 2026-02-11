import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'home_skeleton.dart';
import 'history_skeleton.dart';
import 'learn_skeleton.dart';
import 'settings_skeleton.dart';

class SkeletonLayout extends StatelessWidget {
  final int pageIndex;
  const SkeletonLayout({super.key, required this.pageIndex});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: _buildSkeletonContent(),
      ),
    );
  }

  Widget _buildSkeletonContent() {
    switch (pageIndex) {
      case 1:
        return const HistorySkeleton();
      case 2:
        return const LearnSkeleton();
      case 3:
        return const SettingsSkeleton();
      default:
        return const HomeSkeleton();
    }
  }
}