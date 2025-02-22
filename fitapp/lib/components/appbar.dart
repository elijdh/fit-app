import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitapp/components/theme/color_lib.dart';

class MainAppBar extends StatelessWidget {
  const MainAppBar({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: <Widget>[
        SliverPersistentHeader(
          pinned: true,
          delegate: AppBarDelegate(
            text: title,
          ),
        ),
        SliverPersistentHeader(
          delegate: NavBarDelegate(
            text: title,
          ),
        ),
        SliverFillRemaining(
          child: child,
        ),
      ],
    );
  }
}
class AppBarDelegate extends SliverPersistentHeaderDelegate {
  AppBarDelegate({
    required String text,
  }) : title = text;

  final String title;
  @override
  double minExtent = 50;
  @override
  double maxExtent = 50;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    final isReduced = shrinkOffset >= maxExtent * 1;

    return Container(
      color: isReduced
          ? context.theme.appColors.background.withOpacity(0.5)
          : context.theme.appColors.background,
      child: ClipRRect(
        child: BackdropFilter(
          filter: isReduced
              ? ImageFilter.blur(sigmaX: 25, sigmaY: 25)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child:
                        const CupertinoNavigationBarBackButton(),
                    ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AnimatedOpacity(
                            opacity: isReduced ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 250),
                            child: Center(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 17.5,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_) => true;
}

class NavBarDelegate extends SliverPersistentHeaderDelegate {
  NavBarDelegate({
    required String text,
  }) : title = text;

  final String title;
  @override
  double minExtent = 50;
  @override
  double maxExtent = 50;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    final scale = 1 - shrinkOffset / maxExtent;
    final isReduced = shrinkOffset >= maxExtent * 0.001;

    return Container(
      color: isReduced
          ? context.theme.appColors.background.withOpacity(0.5)
          : context.theme.appColors.background,
      child: ClipRRect(
        child: BackdropFilter(
          filter: isReduced
              ? ImageFilter.blur(sigmaX: 15, sigmaY: 15)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isReduced)
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 25 * scale,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_) => true;
}
