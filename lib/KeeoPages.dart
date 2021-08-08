import 'package:flutter/material.dart';
import 'package:keeo_app/KeeoTheme.dart';

/*
 * Takes two lists as input:
 * 1. titles: List of titles for pages
 * 2. children: List of widgets to show as a page
 * The indexes of the titles and pages must tally i.e. for page 1 showing to-do list,
 * title[0] = 'To-Dos', children[0]: To-Do List Widget
 */
class KeeoPages extends StatelessWidget {
  final List<String> titles;
  final List<Widget> children;

  const KeeoPages({Key? key, required this.titles, required this.children})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: 0);
    return PageView.builder(
        controller: controller,
        itemBuilder: (context, index) {
          int listIndex = index % children.length;
          return Stack(children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: KeeoTheme.borderDecoration,
                  child: children[listIndex]),
            ),
            Positioned(
                left: 35,
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    color: Colors.white,
                    child: Text(
                      titles[listIndex] != '' ? titles[listIndex] : 'No Title',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    )))
          ]);
        });
  }
}

class OpenPageRoute<T> extends MaterialPageRoute<T> {
  OpenPageRoute(
      {required WidgetBuilder builder,
      RouteSettings? settings,
      required bool fullScreenDialog})
      : super(
            builder: builder,
            settings: settings,
            fullscreenDialog: fullScreenDialog);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return new FadeTransition(opacity: animation, child: child);
  }
}
