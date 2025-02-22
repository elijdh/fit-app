import 'dart:ui';

import 'package:animate_gradient/animate_gradient.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fitapp/components/theme/color_lib.dart';
class Format extends StatelessWidget {
  final List<Widget> children;

  const Format({
    Key? key,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(left:25.0,right:25.0, top: 25.0),
      children: children,
    );
  }
}

class DefBackground extends StatelessWidget {
  final Key? key;
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final List<Widget>? persistentFooterButtons;
  final AlignmentDirectional persistentFooterAlignment;
  final Widget? drawer;
  final void Function(bool)? onDrawerChanged;
  final Widget? endDrawer;
  final void Function(bool)? onEndDrawerChanged;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final bool primary;
  final DragStartBehavior drawerDragStartBehavior;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Color? drawerScrimColor;
  final double? drawerEdgeDragWidth;
  final bool drawerEnableOpenDragGesture;
  final bool endDrawerEnableOpenDragGesture;
  final String? restorationId;

  const DefBackground({
    required this.body,
    this.key,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.persistentFooterButtons,
    this.persistentFooterAlignment = AlignmentDirectional.centerEnd,
    this.drawer,
    this.onDrawerChanged,
    this.endDrawer,
    this.onEndDrawerChanged,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.drawerScrimColor,
    this.drawerEdgeDragWidth,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.restorationId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.1, 1],
          colors: [
            Colors.red,
            Colors.black87,
          ],
        ),
      ),
      child: Scaffold(
        key: key,
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        floatingActionButtonAnimator: floatingActionButtonAnimator,
        persistentFooterButtons: persistentFooterButtons,
        persistentFooterAlignment: persistentFooterAlignment,
        drawer: drawer,
        onDrawerChanged: onDrawerChanged,
        endDrawer: endDrawer,
        onEndDrawerChanged: onEndDrawerChanged,
        bottomNavigationBar: bottomNavigationBar,
        bottomSheet: bottomSheet,
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        primary: primary,
        drawerDragStartBehavior: drawerDragStartBehavior,
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        drawerScrimColor: drawerScrimColor,
        drawerEdgeDragWidth: drawerEdgeDragWidth,
        drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
        endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
        restorationId: restorationId,
      ),
    );
  }
}
/* Animated Gradient:
AnimateGradient(
      primaryBegin: Alignment.topLeft,
      primaryEnd: Alignment.bottomLeft,
      secondaryBegin: Alignment.bottomLeft,
      secondaryEnd: Alignment.topRight,
      duration: const Duration(seconds: 20),
      primaryColors: [
        Colors.red.shade600,
        Colors.red.shade900,
        Colors.grey.shade900,
      ],
      secondaryColors: [
        Colors.grey.shade900,
        Colors.red.shade900,
        Colors.red.shade600,
      ],
      child:


Non-Animated Gradient:
Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          stops: [0.1, 1],
          colors: [
            Colors.teal,
            Colors.grey.shade900,
          ],
        ),
      ),
      child:
 */

class DefBlur extends StatelessWidget {
  final Widget child;
  final double sigmaX;
  final double sigmaY;

  const DefBlur({
    Key? key,
    required this.child,
    this.sigmaX = 200,
    this.sigmaY = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: child,
      ),
    );
  }
}

class Subtitle extends StatelessWidget {
  final String text;
  final double? upperPadding;
  final double? lowerPadding;

  const Subtitle({
    Key? key,
    this.upperPadding = 15,
    this.lowerPadding = 10,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          children: [
            SizedBox(height: upperPadding),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: context.theme.appColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: lowerPadding),
          ],
        ),
      ),
    );
  }
}

class PageTitle extends StatelessWidget {
  final String text;

  const PageTitle({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                color: context.theme.appColors.onSurface,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class DefBackButton extends StatelessWidget{
  const DefBackButton({super.key});

  @override
  Widget build(BuildContext context){
    return IconButton(
      iconSize: 25,
      color: context.theme.appColors.onSurface,
      onPressed: () {
        Navigator.pop(context);
      }, icon: const Icon(Icons.arrow_back_ios_new_rounded),
    );
  }
}
class DefButton extends StatelessWidget {
  final Widget route;
  final String title;

  const DefButton({
    Key? key,
    required this.route,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8.0,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: context.theme.appColors.onSurface,
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute<Widget>(
              builder: (context) {
                return route;
              },
            ),
          );
        },
      ),
    );
  }
}

class StackedButtons extends StatelessWidget {
  final List<String> titles;
  final List<Widget> routes;

  const StackedButtons({
    Key? key,
    required this.titles,
    required this.routes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(titles.length, (index) {
        return Column(
          children: [
            index == 0 ? SizedBox.shrink() : Divider(
              height: 0,
              thickness: 0.75,
              color: context.theme.appColors.onSecondaryContainer.withOpacity(0.4),
            ),
            StackButton(
              title: titles[index],
              route: routes[index],
              isFirst: index == 0,
              isLast: index == titles.length - 1,
            ),
          ],
        );
      }),
    );
  }
}

class StackButton extends StatelessWidget {
  final String title;
  final Widget route;
  final bool isFirst;
  final bool isLast;

  const StackButton({
    Key? key,
    required this.title,
    required this.route,
    required this.isFirst,
    required this.isLast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(12) : Radius.zero,
        bottom: isLast ? const Radius.circular(12) : Radius.zero,
      ),
      child: Material(
        color: Colors.black.withOpacity(0.3),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute<Widget>(
                builder: (context) {
                  return route;
                },
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: context.theme.appColors.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class FormContainerWidget extends StatefulWidget {
  final TextEditingController? controller;
  final Key? fieldKey;
  final bool? isPasswordField;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? inputType;
  final String? errorText;

  const FormContainerWidget(
      {super.key,
        this.controller,
        this.fieldKey,
        this.isPasswordField,
        this.hintText,
        this.labelText,
        this.helperText,
        this.onSaved,
        this.validator,
        this.onFieldSubmitted,
        this.errorText,
        this.inputType});

  @override
  State<FormContainerWidget> createState() => _FormContainerWidgetState();
}

class _FormContainerWidgetState extends State<FormContainerWidget> {
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          style: const TextStyle(color: Colors.white),
          controller: widget.controller,
          keyboardType: widget.inputType,
          key: widget.fieldKey,
          obscureText: widget.isPasswordField == true? _obscureText : false,
          onSaved: widget.onSaved,
          validator: widget.validator,
          onFieldSubmitted: widget.onFieldSubmitted,
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 13,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(12),
              ),
              fillColor: Colors.transparent.withOpacity(0.5),
              filled: true,
              hintText: widget.hintText,
              hintStyle: const TextStyle(color: Colors.white),
              suffixIcon: GestureDetector(
                onTap: (){
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child:
                widget.isPasswordField == true ?
                Icon(
                    _obscureText
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: _obscureText == false
                        ? Colors.white
                        : Colors.grey.shade400)
                    : const Text(""),
              )
          ),
        ),
        if (widget.errorText != null)
          Container(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                widget.errorText!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
      ],
    );
  }
}

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmBtnText;
  final String cancelBtnText;
  final Function()? onCancel;
  final Function() onConfirm;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmBtnText = "OK",
    this.cancelBtnText = "Cancel",
    this.onCancel,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.transparent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    title,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 20),
                Text(message),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: (onCancel != null) ? onCancel : () => Navigator.of(context).pop(),
                      child: Text(
                        cancelBtnText, style: const TextStyle(color: Colors.white),),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: onConfirm,
                      child: Text(
                        confirmBtnText, style: const TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => this, // Use the ConfirmationDialog widget
    );
  }
}

