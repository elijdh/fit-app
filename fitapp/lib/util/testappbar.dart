import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nested_scroll_view_plus/nested_scroll_view_plus.dart';
import 'package:snap_scroll_physics/snap_scroll_physics.dart';
import 'package:super_cupertino_navigation_bar/models/super_appbar.model.dart';
import 'package:super_cupertino_navigation_bar/models/super_search_bar.model.dart';
import 'package:super_cupertino_navigation_bar/models/super_search_bar_action.model.dart';
import 'package:super_cupertino_navigation_bar/utils/hero_tag.dart';
import 'package:super_cupertino_navigation_bar/utils/hero_things.dart';
import 'package:super_cupertino_navigation_bar/utils/measures.dart';
import 'package:super_cupertino_navigation_bar/utils/navigation_bar_static_components.dart';
import 'package:super_cupertino_navigation_bar/utils/persistent_nav_bar.dart';
import 'package:super_cupertino_navigation_bar/utils/store.dart';
import 'package:super_cupertino_navigation_bar/utils/transitionable_navigation_bar.dart';
import 'dart:ui' show ImageFilter;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';


class EliteScaffold extends StatefulWidget {
  EliteScaffold({
    Key? key,
    required this.appBar,
    this.stretch = true,
    this.body = const SizedBox(),
    this.onCollapsed,
    this.brightness,
    this.scrollController,
    this.transitionBetweenRoutes = true,
  }) : super(key: key) {
    measures = Measures(
      searchTextFieldHeight: appBar.searchBar!.height,
      largeTitleContainerHeight: appBar.largeTitle!.height,
      primaryToolbarHeight: appBar.height,
      bottomToolbarHeight: appBar.bottom!.height,
      searchBarAnimationDurationx: appBar.searchBar!.animationDuration,
    );
  }

  /// Whether the nav bar should stretch to fill the over-scroll area.
  ///
  /// The nav bar can still expand and contract as the user scrolls, but it will
  /// also stretch when the user over-scrolls if the [stretch] value is `true`.
  ///
  /// When set to `true`, the nav bar will prevent subsequent slivers from
  /// accessing overscrolls. This may be undesirable for using overscroll-based
  /// widgets like the [CupertinoSliverRefreshControl].
  ///
  /// Defaults to `true`.
  final bool stretch;

  /// {@template flutter.cupertino.CupertinoNavigationBar.transitionBetweenRoutes}
  /// Whether to transition between navigation bars.
  ///
  /// When [transitionBetweenRoutes] is true, this navigation bar will transition
  /// on top of the routes instead of inside it if the route being transitioned
  /// to also has a [CupertinoNavigationBar] or a [CupertinoSliverNavigationBar]
  /// with [transitionBetweenRoutes] set to true.
  ///
  /// This transition will also occur on edge back swipe gestures like on iOS
  /// but only if the previous page below has `maintainState` set to true on the
  /// [PageRoute].
  ///
  /// When set to true, only one navigation bar can be present per route unless
  /// [heroTag] is also set.
  ///
  /// This value defaults to true.
  /// {@endtemplate}
  final bool transitionBetweenRoutes;

  /// {@template flutter.cupertino.CupertinoNavigationBar.brightness}
  /// The brightness of the specified [backgroundColor].
  ///
  /// Setting this value changes the style of the system status bar. Typically
  /// used to increase the contrast ratio of the system status bar over
  /// [backgroundColor].
  ///
  /// If set to null, the value of the property will be inferred from the relative
  /// luminance of [backgroundColor].
  /// {@endtemplate}
  final Brightness? brightness;

  /// This value defaults to [Measures].
  late final Measures measures;

  /// Required.
  final SuperAppBar appBar;

  /// Can be any widget.
  /// Defaults to SizedBox()
  final Widget body;

  final Function(bool)? onCollapsed;
  late final ScrollController? scrollController;

  @override
  State<EliteScaffold> createState() => _SuperScaffoldState();
}

class _SuperScaffoldState extends State<EliteScaffold> {
  double _scrollOffset = 0;
  bool _collapsed = false;
  bool isSubmitted = false;
  late TextEditingController _editingController;
  late FocusNode _focusNode;
  late ScrollController _scrollController;
  late NavigationBarStaticComponentsKeys keys;

  @override
  void initState() {
    super.initState();
    keys = NavigationBarStaticComponentsKeys();
    _editingController =
        widget.appBar.searchBar!.searchController ?? TextEditingController();
    _focusNode = widget.appBar.searchBar!.searchFocusNode ?? FocusNode();
    _scrollController = widget.scrollController ?? ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollController.addListener(() {
        _scrollOffset = _scrollController.offset;
        Store.instance.scrollOffset.value = _scrollController.offset;

        // Check if the user is scrolling down
        if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
          // If the scroll position is greater than 100, set it to 100
          if (_scrollController.offset > 0) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut,
            );
          }
        }


        checkIfCollapsed();
      });
    });
  }

  checkIfCollapsed() {
    if (widget.appBar.searchBar!.scrollBehavior ==
        SearchBarScrollBehavior.floated) {
      if (_scrollOffset >=
          widget.measures.largeTitleContainerHeight +
              widget.measures.searchContainerHeight) {
        if (!_collapsed) {
          if (widget.onCollapsed != null) {
            widget.onCollapsed!(true);
          }
          _collapsed = true;
        }
      } else {
        if (_collapsed) {
          if (widget.onCollapsed != null) {
            widget.onCollapsed!(false);
          }
          _collapsed = false;
        }
      }
    } else {
      if (_scrollOffset >= widget.measures.largeTitleContainerHeight) {
        if (!_collapsed) {
          if (widget.onCollapsed != null) {
            widget.onCollapsed!(true);
          }
          _collapsed = true;
        }
      } else {
        if (_collapsed) {
          if (widget.onCollapsed != null) {
            widget.onCollapsed!(false);
          }
          _collapsed = false;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final NavigationBarStaticComponents components =
    NavigationBarStaticComponents(
      keys: keys,
      route: ModalRoute.of(context),
      userLeading: widget.appBar.leading,
      automaticallyImplyLeading: widget.appBar.automaticallyImplyLeading,
      automaticallyImplyTitle: true,
      previousPageTitle: widget.appBar.previousPageTitle,
      userMiddle: widget.appBar.title,
      userTrailing: widget.appBar.actions,
      largeTitleActions: Row(children: [...?widget.appBar.largeTitle!.actions]),
      userLargeTitle: Text(
        widget.appBar.largeTitle!.largeTitle,
        style: widget.appBar.largeTitle!.textStyle.copyWith(
          color: widget.appBar.largeTitle!.textStyle.color ??
              Theme.of(context).textTheme.bodyMedium!.color,
        ),
      ),
      appbarBottom: widget.appBar.bottom!.child,
      padding: null,
      large: true,
    );

    double topPadding = MediaQuery.of(context).padding.top;

    return PopScope(
      canPop: !Store.instance.searchBarHasFocus.value,
      // shouldAddCallback: Store.instance.searchBarHasFocus.value,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            NestedScrollViewPlus(
              physics: const NeverScrollableScrollPhysics(),/*SnapScrollPhysics(
                parent: const NeverScrollableScrollPhysics(),
                snaps: [
                  if (widget.appBar.searchBar!.scrollBehavior ==
                      SearchBarScrollBehavior.floated)
                    Snap.avoidZone(0, widget.measures.searchContainerHeight),
                  if (widget.appBar.searchBar!.scrollBehavior ==
                      SearchBarScrollBehavior.floated)
                    Snap.avoidZone(
                        widget.measures.searchContainerHeight,
                        widget.measures.largeTitleContainerHeight +
                            widget.measures.searchContainerHeight),
                  if (widget.appBar.searchBar!.scrollBehavior ==
                      SearchBarScrollBehavior.pinned)
                    Snap.avoidZone(
                        0, widget.measures.largeTitleContainerHeight),
                ],
              ),*/
              //controller: _scrollController,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) => [
                OverlapAbsorberPlus(
                  sliver: SliverToBoxAdapter(
                    child: ValueListenableBuilder(
                        valueListenable:
                        Store.instance.searchBarAnimationStatus,
                        builder: (context, animationStatus, child) {
                          return AnimatedContainer(
                            duration: animationStatus ==
                                SearchBarAnimationStatus.paused
                                ? Duration.zero
                                : widget.measures.searchBarAnimationDuration,
                            height: Store.instance.searchBarHasFocus.value
                                ? (widget.appBar.searchBar!.animationBehavior ==
                                SearchBarAnimationBehavior.top
                                ? topPadding +
                                widget.measures.searchContainerHeight +
                                widget.measures.bottomToolbarHeight
                                    .toDouble()
                                : topPadding + widget.measures.appbarHeight)
                                : topPadding + widget.measures.appbarHeight,
                          );
                        }),
                  ),
                )
              ],
              body: widget.body,
            ),
            ValueListenableBuilder(
                valueListenable: Store.instance.searchBarResultVisible,
                builder: (context, searchBarResultVisible, child) {
                  return IgnorePointer(
                    ignoring: !searchBarResultVisible,
                    child: AnimatedOpacity(
                      duration: widget.measures.searchBarAnimationDuration,
                      opacity: searchBarResultVisible ? 1 : 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: CupertinoDynamicColor.maybeResolve(
                            widget.appBar.searchBar!.resultColor,
                            context) ??
                            CupertinoTheme.of(context).scaffoldBackgroundColor,
                        padding: EdgeInsets.only(
                          top: topPadding +
                              widget.measures.searchContainerHeight.toDouble() +
                              widget.measures.bottomToolbarHeight.toDouble(),
                        ),
                        child: Stack(
                          children: [
                            const Text(
                              ".",
                              style: TextStyle(color: Colors.transparent),
                            ),
                            widget.appBar.searchBar!.searchResult,
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ValueListenableBuilder(
              valueListenable: Store.instance.scrollOffset,
              builder: (context, scrollOffset, child) {
                // full appbar height
                double fullappbarheight =
                widget.appBar.searchBar!.scrollBehavior ==
                    SearchBarScrollBehavior.floated
                    ? clampDouble(
                    topPadding +
                        widget.measures.appbarHeight -
                        _scrollOffset,
                    topPadding +
                        widget.measures.primaryToolbarHeight +
                        widget.appBar.bottom!.height,
                    widget.stretch
                        ? 3000
                        : topPadding + widget.measures.appbarHeight)
                    : clampDouble(
                    topPadding +
                        widget.measures.appbarHeight -
                        _scrollOffset,
                    topPadding +
                        widget.measures.appbarHeight -
                        widget.measures.largeTitleContainerHeight,
                    widget.stretch
                        ? 3000
                        : topPadding + widget.measures.appbarHeight);

                // large title height
                double largeTitleHeight =
                widget.appBar.searchBar!.scrollBehavior ==
                    SearchBarScrollBehavior.floated
                    ? (_scrollOffset > widget.measures.searchContainerHeight
                    ? clampDouble(
                    widget.measures.largeTitleContainerHeight -
                        (_scrollOffset -
                            widget.measures.searchContainerHeight),
                    0,
                    widget.measures.largeTitleContainerHeight)
                    : widget.measures.largeTitleContainerHeight)
                    : clampDouble(
                    widget.measures.largeTitleContainerHeight -
                        _scrollOffset,
                    0,
                    widget.measures.largeTitleContainerHeight);

                // searchbar height
                double searchBarHeight =
                widget.appBar.searchBar!.scrollBehavior ==
                    SearchBarScrollBehavior.floated
                    ? (Store.instance.searchBarHasFocus.value
                    ? widget.measures.searchContainerHeight
                    : clampDouble(
                    widget.measures.searchContainerHeight -
                        _scrollOffset,
                    0,
                    widget.measures.searchContainerHeight))
                    : widget.measures.searchContainerHeight;

                double opacity = widget.appBar.searchBar!.scrollBehavior ==
                    SearchBarScrollBehavior.floated
                    ? (Store.instance.searchBarHasFocus.value
                    ? 1
                    : clampDouble(1 - _scrollOffset / 10, 0, 1))
                    : 1;

                double titleOpacity = widget.appBar.searchBar!.scrollBehavior ==
                    SearchBarScrollBehavior.floated
                    ? (_scrollOffset >=
                    (widget.measures.appbarHeightExceptPrimaryToolbar -
                        widget.appBar.bottom!.height)
                    ? 1
                    : (widget.measures.largeTitleContainerHeight > 0
                    ? 0
                    : 1))
                    : (_scrollOffset >=
                    (widget.measures.largeTitleContainerHeight)
                    ? 1
                    : (widget.measures.largeTitleContainerHeight > 0
                    ? 0
                    : 1));

                double focussedToolbar = topPadding +
                    widget.measures.searchContainerHeight +
                    widget.appBar.bottom!.height;

                double scaleTitle = _scrollOffset < 0
                    ? clampDouble((1 - _scrollOffset / 1500), 1, 1.12)
                    : 1;

                if (widget.appBar.searchBar!.animationBehavior ==
                    SearchBarAnimationBehavior.steady &&
                    Store.instance.searchBarHasFocus.value) {
                  fullappbarheight = topPadding + widget.measures.appbarHeight;
                  largeTitleHeight = widget.measures.largeTitleContainerHeight;
                  scaleTitle = 1;
                  titleOpacity = 0;
                }
                if (!widget.stretch) scaleTitle = 1;
                if (widget.appBar.alwaysShowTitle) titleOpacity = 1;
                if (!widget.appBar.searchBar!.enabled) opacity = 0;

                return ValueListenableBuilder(
                    valueListenable: Store.instance.searchBarAnimationStatus,
                    builder: (context, animationStatus, child) {
                      return AnimatedPositioned(
                        duration:
                        animationStatus == SearchBarAnimationStatus.paused
                            ? Duration.zero
                            : widget.measures.searchBarAnimationDuration,
                        top: 0,
                        left: 0,
                        right: 0,
                        height: Store.instance.searchBarHasFocus.value
                            ? (widget.appBar.searchBar!.animationBehavior ==
                            SearchBarAnimationBehavior.top
                            ? focussedToolbar
                            : fullappbarheight)
                            : fullappbarheight,
                        child: wrapWithBackground(
                          border: widget.appBar.border,
                          backgroundColor: CupertinoDynamicColor.maybeResolve(
                              widget.appBar.backgroundColor, context) ??
                              CupertinoTheme.of(context).barBackgroundColor,
                          brightness: widget.brightness,
                          child: Builder(builder: (context) {
                            Widget childd = Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AnimatedContainer(
                                  height: Store.instance.searchBarHasFocus.value
                                      ? (widget.appBar.searchBar!
                                      .animationBehavior ==
                                      SearchBarAnimationBehavior.top
                                      ? MediaQuery.paddingOf(context).top
                                      : widget.measures
                                      .primaryToolbarHeight +
                                      MediaQuery.paddingOf(context).top)
                                      : widget.measures.primaryToolbarHeight +
                                      MediaQuery.paddingOf(context).top,
                                  duration: animationStatus ==
                                      SearchBarAnimationStatus.paused
                                      ? Duration.zero
                                      : widget
                                      .measures.searchBarAnimationDuration,
                                  child: AnimatedOpacity(
                                    duration: animationStatus ==
                                        SearchBarAnimationStatus.paused
                                        ? Duration.zero
                                        : widget.measures
                                        .titleOpacityAnimationDuration,
                                    opacity: Store
                                        .instance.searchBarHasFocus.value
                                        ? (widget.appBar.searchBar!
                                        .animationBehavior ==
                                        SearchBarAnimationBehavior.top
                                        ? 0
                                        : 1)
                                        : 1,
                                    child: PersistentNavigationBar(
                                      components: components,
                                      middleVisible:
                                      widget.appBar.alwaysShowTitle
                                          ? null
                                          : titleOpacity != 0,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Padding(
                                  padding: widget.appBar.largeTitle!.padding,
                                  child: AnimatedOpacity(
                                    duration: animationStatus ==
                                        SearchBarAnimationStatus.paused
                                        ? Duration.zero
                                        : widget.measures
                                        .titleOpacityAnimationDuration,
                                    opacity: Store
                                        .instance.searchBarHasFocus.value
                                        ? (widget.appBar.searchBar!
                                        .animationBehavior ==
                                        SearchBarAnimationBehavior.top
                                        ? 0
                                        : 1)
                                        : 1,
                                    child: AnimatedContainer(
                                      height: Store
                                          .instance.searchBarHasFocus.value
                                          ? (widget.appBar.searchBar!
                                          .animationBehavior ==
                                          SearchBarAnimationBehavior.top
                                          ? 0
                                          : largeTitleHeight)
                                          : largeTitleHeight,
                                      duration: animationStatus ==
                                          SearchBarAnimationStatus.paused
                                          ? Duration.zero
                                          : widget.measures
                                          .searchBarAnimationDuration,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            bottom: widget.measures
                                                .largeTitleContainerHeight >
                                                0
                                                ? 8.0
                                                : 0),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: Row(
                                                children: [
                                                  Transform.scale(
                                                    scale: scaleTitle,
                                                    filterQuality:
                                                    FilterQuality.high,
                                                    alignment:
                                                    Alignment.bottomLeft,
                                                    child:
                                                    components.largeTitle,
                                                  ),
                                                  const Spacer(),
                                                  components.largeTitleActions!,
                                                  /*...?widget
                                                                  .appBar!
                                                                  .largeTitle!
                                                                  .actions*/
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: widget.appBar.searchBar!.padding,
                                  child: SizedBox(
                                    height: searchBarHeight,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          bottom: Measures
                                              .instance.searchBarBottomPadding),
                                      child: Stack(
                                        children: [
                                          KeyedSubtree(
                                            key: keys.searchBarKey,
                                            child: IgnorePointer(
                                              ignoring: true,
                                              child: Row(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                                children: [
                                                  Flexible(
                                                    child:
                                                    CupertinoSearchTextField(
                                                      prefixIcon: Opacity(
                                                        opacity: Store
                                                            .instance
                                                            .searchBarHasFocus
                                                            .value
                                                            ? 0
                                                            : opacity,
                                                        child: widget
                                                            .appBar
                                                            .searchBar!
                                                            .prefixIcon,
                                                      ),
                                                      placeholder: Store
                                                          .instance
                                                          .searchBarHasFocus
                                                          .value
                                                          ? ""
                                                          : widget
                                                          .appBar
                                                          .searchBar!
                                                          .placeholderText,
                                                      placeholderStyle: widget
                                                          .appBar
                                                          .searchBar!
                                                          .placeholderTextStyle
                                                          .copyWith(
                                                        color: widget
                                                            .appBar
                                                            .searchBar!
                                                            .placeholderTextStyle
                                                            .color!
                                                            .withOpacity(
                                                            opacity),
                                                      ),
                                                      style: widget.appBar
                                                          .searchBar!.textStyle
                                                          .copyWith(
                                                        color: widget
                                                            .appBar
                                                            .searchBar!
                                                            .textStyle
                                                            .color ??
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodyMedium!
                                                                .color,
                                                      ),
                                                      backgroundColor: widget
                                                          .appBar
                                                          .searchBar!
                                                          .backgroundColor,
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                    children: [
                                                      for (SuperAction searchAction
                                                      in widget
                                                          .appBar
                                                          .searchBar!
                                                          .actions)
                                                        searchAction.behavior ==
                                                            SuperActionBehavior
                                                                .alwaysVisible
                                                            ? searchAction
                                                            : const SizedBox(),
                                                      AnimatedCrossFade(
                                                          firstChild: Center(
                                                            child: Row(
                                                              children: widget
                                                                  .appBar
                                                                  .searchBar!
                                                                  .actions
                                                                  .where((e) =>
                                                              e.behavior ==
                                                                  SuperActionBehavior
                                                                      .visibleOnFocus)
                                                                  .toList(),
                                                            ),
                                                          ),
                                                          secondChild:
                                                          const SizedBox(),
                                                          crossFadeState: Store
                                                              .instance
                                                              .searchBarHasFocus
                                                              .value
                                                              ? CrossFadeState
                                                              .showFirst
                                                              : CrossFadeState
                                                              .showSecond,
                                                          duration: widget
                                                              .measures
                                                              .standartAnimationDuration),
                                                      AnimatedCrossFade(
                                                          firstChild: Center(
                                                            child: Row(
                                                              children: widget
                                                                  .appBar
                                                                  .searchBar!
                                                                  .actions
                                                                  .where((e) =>
                                                              e.behavior ==
                                                                  SuperActionBehavior
                                                                      .visibleOnUnFocus)
                                                                  .toList(),
                                                            ),
                                                          ),
                                                          secondChild:
                                                          const SizedBox(),
                                                          crossFadeState: Store
                                                              .instance
                                                              .searchBarHasFocus
                                                              .value
                                                              ? CrossFadeState
                                                              .showSecond
                                                              : CrossFadeState
                                                              .showFirst,
                                                          duration: widget
                                                              .measures
                                                              .standartAnimationDuration),
                                                      Center(
                                                        child: CupertinoButton(
                                                          minSize: 0,
                                                          padding:
                                                          EdgeInsets.zero,
                                                          color: Colors
                                                              .transparent,
                                                          onPressed: () {
                                                            searchBarFocusThings(
                                                                false);
                                                            _focusNode
                                                                .unfocus();
                                                            _editingController
                                                                .clear();
                                                          },
                                                          child:
                                                          AnimatedContainer(
                                                            duration: widget
                                                                .measures
                                                                .standartAnimationDuration,
                                                            width: Store
                                                                .instance
                                                                .searchBarHasFocus
                                                                .value
                                                                ? textSize(
                                                                widget
                                                                    .appBar
                                                                    .searchBar!
                                                                    .cancelButtonText,
                                                                widget
                                                                    .appBar
                                                                    .searchBar!
                                                                    .cancelTextStyle)
                                                                : 0,
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child: Text(
                                                                  widget
                                                                      .appBar
                                                                      .searchBar!
                                                                      .cancelButtonText,
                                                                  style: widget
                                                                      .appBar
                                                                      .searchBar!
                                                                      .cancelTextStyle,
                                                                  maxLines: 1),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                            children: [
                                              Flexible(
                                                child: Focus(
                                                  onFocusChange: (hasFocus) {
                                                    if (isSubmitted) {
                                                      isSubmitted = false;
                                                      return;
                                                    }
                                                    searchBarFocusThings(
                                                        hasFocus);
                                                    setState(() {});
                                                  },
                                                  child:
                                                  CupertinoSearchTextField(
                                                    onSubmitted: (s) {
                                                      isSubmitted = true;
                                                      widget.appBar.searchBar!
                                                          .onSubmitted
                                                          ?.call(s);
                                                    },
                                                    onChanged: (v) {
                                                      if (v.isNotEmpty) {
                                                        if (widget
                                                            .appBar
                                                            .searchBar!
                                                            .resultBehavior ==
                                                            SearchBarResultBehavior
                                                                .visibleOnInput) {
                                                          Store
                                                              .instance
                                                              .searchBarResultVisible
                                                              .value = true;
                                                        }
                                                      } else {
                                                        if (widget
                                                            .appBar
                                                            .searchBar!
                                                            .resultBehavior ==
                                                            SearchBarResultBehavior
                                                                .visibleOnInput) {
                                                          Store
                                                              .instance
                                                              .searchBarResultVisible
                                                              .value = false;
                                                        }
                                                      }
                                                      widget.appBar.searchBar!
                                                          .onChanged
                                                          ?.call(v);
                                                    },
                                                    prefixIcon: Opacity(
                                                      opacity: opacity,
                                                      child: widget
                                                          .appBar
                                                          .searchBar!
                                                          .prefixIcon,
                                                    ),
                                                    placeholder: widget
                                                        .appBar
                                                        .searchBar!
                                                        .placeholderText,
                                                    placeholderStyle: widget
                                                        .appBar
                                                        .searchBar!
                                                        .placeholderTextStyle
                                                        .copyWith(
                                                      color: widget
                                                          .appBar
                                                          .searchBar!
                                                          .placeholderTextStyle
                                                          .color!
                                                          .withOpacity(opacity),
                                                    ),
                                                    style: widget.appBar
                                                        .searchBar!.textStyle
                                                        .copyWith(
                                                      color: widget
                                                          .appBar
                                                          .searchBar!
                                                          .textStyle
                                                          .color ??
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .color,
                                                    ),
                                                    controller:
                                                    _editingController,
                                                    focusNode: _focusNode,
                                                    backgroundColor:
                                                    Colors.transparent,
                                                    autocorrect: false,
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                children: [
                                                  for (SuperAction searchAction
                                                  in widget.appBar
                                                      .searchBar!.actions)
                                                    searchAction.behavior ==
                                                        SuperActionBehavior
                                                            .alwaysVisible
                                                        ? searchAction
                                                        : const SizedBox(),
                                                  AnimatedCrossFade(
                                                      firstChild: Center(
                                                        child: Row(
                                                          children: widget
                                                              .appBar
                                                              .searchBar!
                                                              .actions
                                                              .where((e) =>
                                                          e.behavior ==
                                                              SuperActionBehavior
                                                                  .visibleOnFocus)
                                                              .toList(),
                                                        ),
                                                      ),
                                                      secondChild:
                                                      const SizedBox(),
                                                      crossFadeState: Store
                                                          .instance
                                                          .searchBarHasFocus
                                                          .value
                                                          ? CrossFadeState
                                                          .showFirst
                                                          : CrossFadeState
                                                          .showSecond,
                                                      duration: widget.measures
                                                          .standartAnimationDuration),
                                                  AnimatedCrossFade(
                                                      firstChild: Center(
                                                        child: Row(
                                                          children: widget
                                                              .appBar
                                                              .searchBar!
                                                              .actions
                                                              .where((e) =>
                                                          e.behavior ==
                                                              SuperActionBehavior
                                                                  .visibleOnUnFocus)
                                                              .toList(),
                                                        ),
                                                      ),
                                                      secondChild:
                                                      const SizedBox(),
                                                      crossFadeState: Store
                                                          .instance
                                                          .searchBarHasFocus
                                                          .value
                                                          ? CrossFadeState
                                                          .showSecond
                                                          : CrossFadeState
                                                          .showFirst,
                                                      duration: widget.measures
                                                          .standartAnimationDuration),
                                                  Center(
                                                    child: CupertinoButton(
                                                      minSize: 0,
                                                      padding: EdgeInsets.zero,
                                                      color: Colors.transparent,
                                                      onPressed: () {
                                                        searchBarFocusThings(
                                                            false);
                                                        _focusNode.unfocus();
                                                        _editingController
                                                            .clear();
                                                      },
                                                      child: AnimatedContainer(
                                                        duration: widget
                                                            .measures
                                                            .standartAnimationDuration,
                                                        width: Store
                                                            .instance
                                                            .searchBarHasFocus
                                                            .value
                                                            ? textSize(
                                                            widget
                                                                .appBar
                                                                .searchBar!
                                                                .cancelButtonText,
                                                            widget
                                                                .appBar
                                                                .searchBar!
                                                                .cancelTextStyle)
                                                            : 0,
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                              widget
                                                                  .appBar
                                                                  .searchBar!
                                                                  .cancelButtonText,
                                                              style: widget
                                                                  .appBar
                                                                  .searchBar!
                                                                  .cancelTextStyle,
                                                              maxLines: 1),
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
                                ),
                                AnimatedContainer(
                                  duration: widget
                                      .measures.searchBarAnimationDuration,
                                  height: widget.measures.bottomToolbarHeight,
                                  color: widget.appBar.bottom!.color,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        height:
                                        widget.measures.bottomToolbarHeight,
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: components.appbarBottom!,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );

                            if (!widget.transitionBetweenRoutes ||
                                !isTransitionable(context)) {
                              return childd;
                            }

                            return Hero(
                              tag: HeroTag(Navigator.of(context)),
                              createRectTween:
                              linearTranslateWithLargestRectSizeTween,
                              flightShuttleBuilder:
                              navBarHeroFlightShuttleBuilder,
                              placeholderBuilder: navBarHeroLaunchPadBuilder,
                              transitionOnUserGestures: true,
                              child: TransitionableNavigationBar(
                                componentsKeys: keys,
                                backgroundColor:
                                CupertinoDynamicColor.maybeResolve(
                                    widget.appBar.backgroundColor,
                                    context) ??
                                    CupertinoTheme.of(context)
                                        .barBackgroundColor,
                                backButtonTextStyle: CupertinoTheme.of(context)
                                    .textTheme
                                    .navActionTextStyle,
                                titleTextStyle: CupertinoTheme.of(context)
                                    .textTheme
                                    .navTitleTextStyle,
                                largeTitleTextStyle:
                                widget.appBar.largeTitle!.textStyle,
                                border: const Border(),
                                hasUserMiddle: _collapsed,
                                largeExpanded: !_collapsed &&
                                    widget.appBar.largeTitle!.enabled,
                                searchBarHasFocus:
                                Store.instance.searchBarHasFocus.value,
                                child: childd,
                              ),
                            );
                          }),
                        ),
                      );
                    });
              },
            ),
          ],
        ),
      ),
    );
  }

  void searchBarFocusThings(bool hasFocus) {
    Store.instance.searchBarHasFocus.value = hasFocus;

    Store.instance.searchBarAnimationStatus.value = hasFocus
        ? SearchBarAnimationStatus.started
        : SearchBarAnimationStatus.onGoing;
    if (hasFocus) {
      if (widget.appBar.searchBar!.resultBehavior ==
          SearchBarResultBehavior.visibleOnFocus) {
        Store.instance.searchBarResultVisible.value = true;
      }
    } else {
      Store.instance.searchBarResultVisible.value = false;
    }
    if (!hasFocus) {
      Future.delayed(widget.measures.searchBarAnimationDuration, () {
        Store.instance.searchBarAnimationStatus.value =
            SearchBarAnimationStatus.paused;
      });
    }
    widget.appBar.searchBar!.onFocused?.call(hasFocus);
  }
}

// Here it is!
double textSize(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size.width * 1.4;
}

// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


// Standard iOS 10 tab bar height.
const double _kTabBarHeight = 50.0;

const Color _kDefaultTabBarBorderColor = CupertinoDynamicColor.withBrightness(
  color: Color(0x4D000000),
  darkColor: Color(0x29000000),
);
const Color _kDefaultTabBarInactiveColor = CupertinoColors.inactiveGray;

/// An iOS-styled bottom navigation tab bar.
///
/// Displays multiple tabs using [BottomNavigationBarItem] with one tab being
/// active, the first tab by default.
///
/// This [StatelessWidget] doesn't store the active tab itself. You must
/// listen to the [onTap] callbacks and call `setState` with a new [currentIndex]
/// for the new selection to reflect. This can also be done automatically
/// by wrapping this with a [CupertinoTabScaffold].
///
/// Tab changes typically trigger a switch between [Navigator]s, each with its
/// own navigation stack, per standard iOS design. This can be done by using
/// [CupertinoTabView]s inside each tab builder in [CupertinoTabScaffold].
///
/// If the given [backgroundColor]'s opacity is not 1.0 (which is the case by
/// default), it will produce a blurring effect to the content behind it.
///
/// When used as [CupertinoTabScaffold.tabBar], by default [CupertinoTabBar]
/// disables text scaling to match the native iOS behavior. To override
/// this behavior, wrap each of the `navigationBar`'s components inside a
/// [MediaQuery] with the desired [TextScaler].
///
/// {@tool dartpad}
/// This example shows a [CupertinoTabBar] placed in a [CupertinoTabScaffold].
///
/// ** See code in examples/api/lib/cupertino/bottom_tab_bar/cupertino_tab_bar.0.dart **
/// {@end-tool}
///
/// See also:
///
///  * [CupertinoTabScaffold], which hosts the [CupertinoTabBar] at the bottom.
///  * [BottomNavigationBarItem], an item in a [CupertinoTabBar].
///  * <https://developer.apple.com/design/human-interface-guidelines/ios/bars/tab-bars/>
class EliteTabBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a tab bar in the iOS style.
  const EliteTabBar({
    super.key,
    required this.items,
    this.onTap,
    this.currentIndex = 0,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor = _kDefaultTabBarInactiveColor,
    this.iconSize = 30.0,
    this.height = _kTabBarHeight,
    this.border = const Border(
      top: BorderSide(
        color: _kDefaultTabBarBorderColor,
        width: 0.0, // 0.0 means one physical pixel
      ),
    ),
  }) : assert(
  items.length >= 2,
  "Tabs need at least 2 items to conform to Apple's HIG",
  ),
        assert(0 <= currentIndex && currentIndex < items.length),
        assert(height >= 0.0);

  /// The interactive items laid out within the bottom navigation bar.
  final List<BottomNavigationBarItem> items;

  /// The callback that is called when a item is tapped.
  ///
  /// The widget creating the bottom navigation bar needs to keep track of the
  /// current index and call `setState` to rebuild it with the newly provided
  /// index.
  final ValueChanged<int>? onTap;

  /// The index into [items] of the current active item.
  ///
  /// Must be between 0 and the number of tabs minus 1, inclusive.
  final int currentIndex;

  /// The background color of the tab bar. If it contains transparency, the
  /// tab bar will automatically produce a blurring effect to the content
  /// behind it.
  ///
  /// Defaults to [CupertinoTheme]'s `barBackgroundColor` when null.
  final Color? backgroundColor;

  /// The foreground color of the icon and title for the [BottomNavigationBarItem]
  /// of the selected tab.
  ///
  /// Defaults to [CupertinoTheme]'s `primaryColor` if null.
  final Color? activeColor;

  /// The foreground color of the icon and title for the [BottomNavigationBarItem]s
  /// in the unselected state.
  ///
  /// Defaults to a [CupertinoDynamicColor] that matches the disabled foreground
  /// color of the native `UITabBar` component.
  final Color inactiveColor;

  /// The size of all of the [BottomNavigationBarItem] icons.
  ///
  /// This value is used to configure the [IconTheme] for the navigation bar.
  /// When a [BottomNavigationBarItem.icon] widget is not an [Icon] the widget
  /// should configure itself to match the icon theme's size and color.
  final double iconSize;

  /// The height of the [CupertinoTabBar].
  ///
  /// Defaults to 50.
  final double height;

  /// The border of the [CupertinoTabBar].
  ///
  /// The default value is a one physical pixel top border with grey color.
  final Border? border;

  @override
  Size get preferredSize => Size.fromHeight(height);

  /// Indicates whether the tab bar is fully opaque or can have contents behind
  /// it show through it.
  bool opaque(BuildContext context) {
    final Color backgroundColor =
        this.backgroundColor ?? CupertinoTheme.of(context).barBackgroundColor;
    return CupertinoDynamicColor.resolve(backgroundColor, context).alpha == 0xFF;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final double bottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    final Color backgroundColor = CupertinoDynamicColor.resolve(
      this.backgroundColor ?? CupertinoTheme.of(context).barBackgroundColor,
      context,
    );

    BorderSide resolveBorderSide(BorderSide side) {
      return side == BorderSide.none
          ? side
          : side.copyWith(color: CupertinoDynamicColor.resolve(side.color, context));
    }

    // Return the border as is when it's a subclass.
    final Border? resolvedBorder = border == null || border.runtimeType != Border
        ? border
        : Border(
      top: resolveBorderSide(border!.top),
      left: resolveBorderSide(border!.left),
      bottom: resolveBorderSide(border!.bottom),
      right: resolveBorderSide(border!.right),
    );

    final Color inactive = CupertinoDynamicColor.resolve(inactiveColor, context);
    Widget result = DecoratedBox(
      decoration: BoxDecoration(
        border: resolvedBorder,
        color: backgroundColor,
      ),
      child: SizedBox(
        height: height + bottomPadding,
        child: IconTheme.merge( // Default with the inactive state.
          data: IconThemeData(color: inactive, size: iconSize),
          child: DefaultTextStyle( // Default with the inactive state.
            style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(color: inactive),
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: Semantics(
                explicitChildNodes: true,
                child: Row(
                  // Align bottom since we want the labels to be aligned.
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _buildTabItems(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (!opaque(context)) {
      // For non-opaque backgrounds, apply a blur effect.
      result = ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
          child: result,
        ),
      );
    }

    return result;
  }

  List<Widget> _buildTabItems(BuildContext context) {
    final List<Widget> result = <Widget>[];
    final CupertinoLocalizations localizations = CupertinoLocalizations.of(context);

    for (int index = 0; index < items.length; index += 1) {
      final bool active = index == currentIndex;
      result.add(
        _wrapActiveItem(
          context,
          Expanded(
            // Make tab items part of the EditableText tap region so that
            // switching tabs doesn't unfocus text fields.
            child: TextFieldTapRegion(
              child: Semantics(
                selected: active,
                hint: localizations.tabSemanticsLabel(
                  tabIndex: index + 1,
                  tabCount: items.length,
                ),
                child: MouseRegion(
                  cursor:  kIsWeb ? SystemMouseCursors.click : MouseCursor.defer,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onTap == null ? null : () { onTap!(index); },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: _buildSingleTabItem(items[index], active),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          active: active,
        ),
      );
    }

    return result;
  }

  List<Widget> _buildSingleTabItem(BottomNavigationBarItem item, bool active) {
    return <Widget>[
      Expanded(
        child: Center(child: active ? item.activeIcon : item.icon),
      ),
      if (item.label != null) Text(item.label!),
    ];
  }

  /// Change the active tab item's icon and title colors to active.
  Widget _wrapActiveItem(BuildContext context, Widget item, { required bool active }) {
    if (!active) {
      return item;
    }

    final Color activeColor = CupertinoDynamicColor.resolve(
      this.activeColor ?? CupertinoTheme.of(context).primaryColor,
      context,
    );
    return IconTheme.merge(
      data: IconThemeData(color: activeColor),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: activeColor),
        child: item,
      ),
    );
  }

  /// Create a clone of the current [CupertinoTabBar] but with provided
  /// parameters overridden.
  CupertinoTabBar copyWith({
    Key? key,
    List<BottomNavigationBarItem>? items,
    Color? backgroundColor,
    Color? activeColor,
    Color? inactiveColor,
    double? iconSize,
    double? height,
    Border? border,
    int? currentIndex,
    ValueChanged<int>? onTap,
  }) {
    return CupertinoTabBar(
      key: key ?? this.key,
      items: items ?? this.items,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      iconSize: iconSize ?? this.iconSize,
      height: height ?? this.height,
      border: border ?? this.border,
      currentIndex: currentIndex ?? this.currentIndex,
      onTap: onTap ?? this.onTap,
    );
  }
}

// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Coordinates tab selection between a [CupertinoTabBar] and a [CupertinoTabScaffold].
///
/// The [index] property is the index of the selected tab. Changing its value
/// updates the actively displayed tab of the [CupertinoTabScaffold] the
/// [CupertinoTabController] controls, as well as the currently selected tab item of
/// its [CupertinoTabBar].
///
/// {@tool snippet}
/// This samples shows how [CupertinoTabController] can be used to switch tabs in
/// [CupertinoTabScaffold].
///
/// ** See code in examples/api/lib/cupertino/tab_scaffold/cupertino_tab_controller.0.dart **
/// {@end-tool}
///
/// See also:
///
///  * [CupertinoTabScaffold], a tabbed application root layout that can be
///    controlled by a [CupertinoTabController].
///  * [RestorableCupertinoTabController], which is a restorable version
///    of this controller.
class CupertinoTabController extends ChangeNotifier {
  /// Creates a [CupertinoTabController] to control the tab index of [CupertinoTabScaffold]
  /// and [CupertinoTabBar].
  ///
  /// The [initialIndex] defaults to 0. The value must be greater than or equal
  /// to 0, and less than the total number of tabs.
  CupertinoTabController({ int initialIndex = 0 })
      : _index = initialIndex,
        assert(initialIndex >= 0);

  bool _isDisposed = false;

  /// The index of the currently selected tab.
  ///
  /// Changing the value of [index] updates the actively displayed tab of the
  /// [CupertinoTabScaffold] controlled by this [CupertinoTabController], as well
  /// as the currently selected tab item of its [CupertinoTabScaffold.tabBar].
  ///
  /// The value must be greater than or equal to 0, and less than the total
  /// number of tabs.
  int get index => _index;
  int _index;
  set index(int value) {
    assert(value >= 0);
    if (_index == value) {
      return;
    }
    _index = value;
    notifyListeners();
  }

  @mustCallSuper
  @override
  void dispose() {
    super.dispose();
    _isDisposed = true;
  }
}

/// Implements a tabbed iOS application's root layout and behavior structure.
///
/// The scaffold lays out the tab bar at the bottom and the content between or
/// behind the tab bar.
///
/// A [tabBar] and a [tabBuilder] are required. The [CupertinoTabScaffold]
/// will automatically listen to the provided [CupertinoTabBar]'s tap callbacks
/// to change the active tab.
///
/// A [controller] can be used to provide an initially selected tab index and manage
/// subsequent tab changes. If a controller is not specified, the scaffold will
/// create its own [CupertinoTabController] and manage it internally. Otherwise
/// it's up to the owner of [controller] to call `dispose` on it after finish
/// using it.
///
/// Tabs' contents are built with the provided [tabBuilder] at the active
/// tab index. The [tabBuilder] must be able to build the same number of
/// pages as there are [tabBar] items. Inactive tabs will be moved [Offstage]
/// and their animations disabled.
///
/// Adding/removing tabs, or changing the order of tabs is supported but not
/// recommended. Doing so is against the iOS human interface guidelines, and
/// [CupertinoTabScaffold] may lose some tabs' state in the process.
///
/// Use [CupertinoTabView] as the root widget of each tab to support tabs with
/// parallel navigation state and history. Since each [CupertinoTabView] contains
/// a [Navigator], rebuilding the [CupertinoTabView] with a different
/// [WidgetBuilder] instance in [CupertinoTabView.builder] will not recreate
/// the [CupertinoTabView]'s navigation stack or update its UI. To update the
/// contents of the [CupertinoTabView] after it's built, trigger a rebuild
/// (via [State.setState], for instance) from its descendant rather than from
/// its ancestor.
///
/// {@tool dartpad}
/// A sample code implementing a typical iOS information architecture with tabs.
///
/// ** See code in examples/api/lib/cupertino/tab_scaffold/cupertino_tab_scaffold.0.dart **
/// {@end-tool}
///
/// To push a route above all tabs instead of inside the currently selected one
/// (such as when showing a dialog on top of this scaffold), use
/// `Navigator.of(rootNavigator: true)` from inside the [BuildContext] of a
/// [CupertinoTabView].
///
/// See also:
///
///  * [CupertinoTabBar], the bottom tab bar inserted in the scaffold.
///  * [CupertinoTabController], the selection state of this widget.
///  * [CupertinoTabView], the typical root content of each tab that holds its own
///    [Navigator] stack.
///  * [CupertinoPageRoute], a route hosting modal pages with iOS style transitions.
///  * [CupertinoPageScaffold], typical contents of an iOS modal page implementing
///    layout with a navigation bar on top.
///  * [iOS human interface guidelines](https://developer.apple.com/design/human-interface-guidelines/ios/bars/tab-bars/).
class EliteTabScaffold extends StatefulWidget {
  /// Creates a layout for applications with a tab bar at the bottom.
  EliteTabScaffold({
    super.key,
    required this.tabBar,
    required this.tabBuilder,
    this.controller,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.restorationId,
  }) : assert(
  controller == null || controller.index < tabBar.items.length,
  "The CupertinoTabController's current index ${controller.index} is "
      'out of bounds for the tab bar with ${tabBar.items.length} tabs',
  );

  /// The [tabBar] is a [CupertinoTabBar] drawn at the bottom of the screen
  /// that lets the user switch between different tabs in the main content area
  /// when present.
  ///
  /// The [CupertinoTabBar.currentIndex] is only used to initialize a
  /// [CupertinoTabController] when no [controller] is provided. Subsequently
  /// providing a different [CupertinoTabBar.currentIndex] does not affect the
  /// scaffold or the tab bar's active tab index. To programmatically change
  /// the active tab index, use a [CupertinoTabController].
  ///
  /// If [CupertinoTabBar.onTap] is provided, it will still be called.
  /// [CupertinoTabScaffold] automatically also listen to the
  /// [CupertinoTabBar]'s `onTap` to change the [controller]'s `index`
  /// and change the actively displayed tab in [CupertinoTabScaffold]'s own
  /// main content area.
  ///
  /// If translucent, the main content may slide behind it.
  /// Otherwise, the main content's bottom margin will be offset by its height.
  ///
  /// By default [tabBar] disables text scaling to match the native iOS behavior.
  /// To override this behavior, wrap each of the [tabBar]'s items inside a
  /// [MediaQuery] with the desired [TextScaler].
  final EliteTabBar tabBar;

  /// Controls the currently selected tab index of the [tabBar], as well as the
  /// active tab index of the [tabBuilder]. Providing a different [controller]
  /// will also update the scaffold's current active index to the new controller's
  /// index value.
  ///
  /// Defaults to null.
  final CupertinoTabController? controller;

  /// An [IndexedWidgetBuilder] that's called when tabs become active.
  ///
  /// The widgets built by [IndexedWidgetBuilder] are typically a
  /// [CupertinoTabView] in order to achieve the parallel hierarchical
  /// information architecture seen on iOS apps with tab bars.
  ///
  /// When the tab becomes inactive, its content is cached in the widget tree
  /// [Offstage] and its animations disabled.
  ///
  /// Content can slide under the [tabBar] when they're translucent.
  /// In that case, the child's [BuildContext]'s [MediaQuery] will have a
  /// bottom padding indicating the area of obstructing overlap from the
  /// [tabBar].
  final IndexedWidgetBuilder tabBuilder;

  /// The color of the widget that underlies the entire scaffold.
  ///
  /// By default uses [CupertinoTheme]'s `scaffoldBackgroundColor` when null.
  final Color? backgroundColor;

  /// Whether the body should size itself to avoid the window's bottom inset.
  ///
  /// For example, if there is an onscreen keyboard displayed above the
  /// scaffold, the body can be resized to avoid overlapping the keyboard, which
  /// prevents widgets inside the body from being obscured by the keyboard.
  ///
  /// Defaults to true.
  final bool resizeToAvoidBottomInset;

  /// Restoration ID to save and restore the state of the [CupertinoTabScaffold].
  ///
  /// This property only has an effect when no [controller] has been provided:
  /// If it is non-null (and no [controller] has been provided), the scaffold
  /// will persist and restore the currently selected tab index. If a
  /// [controller] has been provided, it is the responsibility of the owner of
  /// that controller to persist and restore it, e.g. by using a
  /// [RestorableCupertinoTabController].
  ///
  /// The state of this widget is persisted in a [RestorationBucket] claimed
  /// from the surrounding [RestorationScope] using the provided restoration ID.
  ///
  /// See also:
  ///
  ///  * [RestorationManager], which explains how state restoration works in
  ///    Flutter.
  final String? restorationId;

  @override
  State<EliteTabScaffold> createState() => _CupertinoTabScaffoldState();
}

class _CupertinoTabScaffoldState extends State<EliteTabScaffold> with RestorationMixin {
  RestorableCupertinoTabController? _internalController;
  CupertinoTabController get _controller =>  widget.controller ?? _internalController!.value;

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    _restoreInternalController();
  }

  void _restoreInternalController() {
    if (_internalController != null) {
      registerForRestoration(_internalController!, 'controller');
      _internalController!.value.addListener(_onCurrentIndexChange);
    }
  }

  @override
  void initState() {
    super.initState();
    _updateTabController();
  }

  void _updateTabController([CupertinoTabController? oldWidgetController]) {
    if (widget.controller == null && _internalController == null) {
      // No widget-provided controller: create an internal controller.
      _internalController = RestorableCupertinoTabController(initialIndex: widget.tabBar.currentIndex);
      if (!restorePending) {
        _restoreInternalController(); // Also adds the listener to the controller.
      }
    }
    if (widget.controller != null && _internalController != null) {
      // Use the widget-provided controller.
      unregisterFromRestoration(_internalController!);
      _internalController!.dispose();
      _internalController = null;
    }
    if (oldWidgetController != widget.controller) {
      // The widget-provided controller has changed: move listeners.
      if (oldWidgetController?._isDisposed == false) {
        oldWidgetController!.removeListener(_onCurrentIndexChange);
      }
      widget.controller?.addListener(_onCurrentIndexChange);
    }
  }

  void _onCurrentIndexChange() {
    assert(
    _controller.index >= 0 && _controller.index < widget.tabBar.items.length,
    "The $runtimeType's current index ${_controller.index} is "
        'out of bounds for the tab bar with ${widget.tabBar.items.length} tabs',
    );

    // The value of `_controller.index` has already been updated at this point.
    // Calling `setState` to rebuild using `_controller.index`.
    setState(() {});
  }

  @override
  void didUpdateWidget(EliteTabScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _updateTabController(oldWidget.controller);
    } else if (_controller.index >= widget.tabBar.items.length) {
      // If a new [tabBar] with less than (_controller.index + 1) items is provided,
      // clamp the current index.
      _controller.index = widget.tabBar.items.length - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData existingMediaQuery = MediaQuery.of(context);
    MediaQueryData newMediaQuery = MediaQuery.of(context);

    Widget content = _TabSwitchingView(
      currentTabIndex: _controller.index,
      tabCount: widget.tabBar.items.length,
      tabBuilder: widget.tabBuilder,
    );
    EdgeInsets contentPadding = EdgeInsets.zero;

    if (widget.resizeToAvoidBottomInset) {
      // Remove the view inset and add it back as a padding in the inner content.
      newMediaQuery = newMediaQuery.removeViewInsets(removeBottom: true);
      contentPadding = EdgeInsets.only(bottom: existingMediaQuery.viewInsets.bottom);
    }

    // Only pad the content with the height of the tab bar if the tab
    // isn't already entirely obstructed by a keyboard or other view insets.
    // Don't double pad.
    if (!widget.resizeToAvoidBottomInset || widget.tabBar.preferredSize.height > existingMediaQuery.viewInsets.bottom) {
      // TODO(xster): Use real size after partial layout instead of preferred size.
      // https://github.com/flutter/flutter/issues/12912
      final double bottomPadding =
          widget.tabBar.preferredSize.height + existingMediaQuery.padding.bottom;

      // If tab bar opaque, directly stop the main content higher. If
      // translucent, let main content draw behind the tab bar but hint the
      // obstructed area.
      if (widget.tabBar.opaque(context)) {
        contentPadding = EdgeInsets.only(bottom: bottomPadding);
        newMediaQuery = newMediaQuery.removePadding(removeBottom: true);
      } else {
        newMediaQuery = newMediaQuery.copyWith(
          padding: newMediaQuery.padding.copyWith(
            bottom: bottomPadding,
          ),
        );
      }
    }

    content = MediaQuery(
      data: newMediaQuery,
      child: Padding(
        padding: contentPadding,
        child: content,
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.maybeResolve(widget.backgroundColor, context)
            ?? CupertinoTheme.of(context).scaffoldBackgroundColor,
      ),
      child: Stack(
        children: <Widget>[
          // The main content being at the bottom is added to the stack first.
          content,
          MediaQuery.withNoTextScaling(
            child: Align(
              alignment: Alignment.bottomCenter,
              // Override the tab bar's currentIndex to the current tab and hook in
              // our own listener to update the [_controller.currentIndex] on top of a possibly user
              // provided callback.
              child: widget.tabBar.copyWith(
                currentIndex: _controller.index,
                onTap: (int newIndex) {
                  _controller.index = newIndex;
                  // Chain the user's original callback.
                  widget.tabBar.onTap?.call(newIndex);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (widget.controller?._isDisposed == false) {
      _controller.removeListener(_onCurrentIndexChange);
    }
    _internalController?.dispose();
    super.dispose();
  }
}

/// A widget laying out multiple tabs with only one active tab being built
/// at a time and on stage. Off stage tabs' animations are stopped.
class _TabSwitchingView extends StatefulWidget {
  const _TabSwitchingView({
    required this.currentTabIndex,
    required this.tabCount,
    required this.tabBuilder,
  }) : assert(tabCount > 0);

  final int currentTabIndex;
  final int tabCount;
  final IndexedWidgetBuilder tabBuilder;

  @override
  _TabSwitchingViewState createState() => _TabSwitchingViewState();
}

class _TabSwitchingViewState extends State<_TabSwitchingView> {
  final List<bool> shouldBuildTab = <bool>[];
  final List<FocusScopeNode> tabFocusNodes = <FocusScopeNode>[];

  // When focus nodes are no longer needed, we need to dispose of them, but we
  // can't be sure that nothing else is listening to them until this widget is
  // disposed of, so when they are no longer needed, we move them to this list,
  // and dispose of them when we dispose of this widget.
  final List<FocusScopeNode> discardedNodes = <FocusScopeNode>[];

  @override
  void initState() {
    super.initState();
    shouldBuildTab.addAll(List<bool>.filled(widget.tabCount, false));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _focusActiveTab();
  }

  @override
  void didUpdateWidget(_TabSwitchingView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only partially invalidate the tabs cache to avoid breaking the current
    // behavior. We assume that the only possible change is either:
    // - new tabs are appended to the tab list, or
    // - some trailing tabs are removed.
    // If the above assumption is not true, some tabs may lose their state.
    final int lengthDiff = widget.tabCount - shouldBuildTab.length;
    if (lengthDiff > 0) {
      shouldBuildTab.addAll(List<bool>.filled(lengthDiff, false));
    } else if (lengthDiff < 0) {
      shouldBuildTab.removeRange(widget.tabCount, shouldBuildTab.length);
    }
    _focusActiveTab();
  }

  // Will focus the active tab if the FocusScope above it has focus already. If
  // not, then it will just mark it as the preferred focus for that scope.
  void _focusActiveTab() {
    if (tabFocusNodes.length != widget.tabCount) {
      if (tabFocusNodes.length > widget.tabCount) {
        discardedNodes.addAll(tabFocusNodes.sublist(widget.tabCount));
        tabFocusNodes.removeRange(widget.tabCount, tabFocusNodes.length);
      } else {
        tabFocusNodes.addAll(
          List<FocusScopeNode>.generate(
            widget.tabCount - tabFocusNodes.length,
                (int index) => FocusScopeNode(debugLabel: '$CupertinoTabScaffold Tab ${index + tabFocusNodes.length}'),
          ),
        );
      }
    }
    FocusScope.of(context).setFirstFocus(tabFocusNodes[widget.currentTabIndex]);
  }

  @override
  void dispose() {
    for (final FocusScopeNode focusScopeNode in tabFocusNodes) {
      focusScopeNode.dispose();
    }
    for (final FocusScopeNode focusScopeNode in discardedNodes) {
      focusScopeNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: List<Widget>.generate(widget.tabCount, (int index) {
        final bool active = index == widget.currentTabIndex;
        shouldBuildTab[index] = active || shouldBuildTab[index];

        return HeroMode(
          enabled: active,
          child: Offstage(
            offstage: !active,
            child: TickerMode(
              enabled: active,
              child: FocusScope(
                node: tabFocusNodes[index],
                child: Builder(builder: (BuildContext context) {
                  return shouldBuildTab[index] ? widget.tabBuilder(context, index) : const SizedBox.shrink();
                }),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// A [RestorableProperty] that knows how to store and restore a
/// [CupertinoTabController].
///
/// The [CupertinoTabController] is accessible via the [value] getter. During
/// state restoration, the property will restore [CupertinoTabController.index]
/// to the value it had when the restoration data it is getting restored from
/// was collected.
class RestorableCupertinoTabController extends RestorableChangeNotifier<CupertinoTabController> {
  /// Creates a [RestorableCupertinoTabController] to control the tab index of
  /// [CupertinoTabScaffold] and [CupertinoTabBar].
  ///
  /// The `initialIndex` defaults to zero. The value must be greater than or
  /// equal to zero, and less than the total number of tabs.
  RestorableCupertinoTabController({ int initialIndex = 0 })
      : assert(initialIndex >= 0),
        _initialIndex = initialIndex;

  final int _initialIndex;

  @override
  CupertinoTabController createDefaultValue() {
    return CupertinoTabController(initialIndex: _initialIndex);
  }

  @override
  CupertinoTabController fromPrimitives(Object? data) {
    assert(data != null);
    return CupertinoTabController(initialIndex: data! as int);
  }

  @override
  Object? toPrimitives() {
    return value.index;
  }
}
// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
