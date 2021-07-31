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
          return Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                  decoration: KeeoTheme.borderDecoration,
                  child: Column(
                    children: [
                      Flexible(
                          flex: 1,
                          child: Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 5),
                              child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: FittedBox(
                                    fit: BoxFit.fitHeight,
                                    child: Text(
                                          titles[listIndex] != ''
                                          ? titles[listIndex]
                                          : 'No Title',
                                      style: Theme.of(context).textTheme.headline6,
                                    ),
                                  )))),
                      Flexible(flex: 8, child: children[listIndex])
                    ],
                  )));
        });
    // return PageView.bu(
    //     scrollDirection: Axis.horizontal,
    //     controller: controller,
    //     children: [
    //       for (Widget page in children)
    //           Padding(
    //             padding: const EdgeInsets.all(8),
    //             child: Container(
    //                 decoration: KeeoTheme.borderDecoration,
    //                 child: page),
    //         )
    //     ]);
  }
}
