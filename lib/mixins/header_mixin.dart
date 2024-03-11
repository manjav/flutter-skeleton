import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../app_export.dart';

mixin HeaderMixin {
  Widget headerBuilder(BuildContext context, ValueNotifier<int> index,
      EdgeInsetsGeometry padding, ParentContent group) {
    var person = (group.children[0] as Talk).personId;
    return Widgets.rect(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [
              0.7,
              1
            ],
            colors: <Color>[
              TColors.primary10,
              TColors.primary10.withOpacity(0)
            ]),
      ),
      child: Row(
        children: [
          Avatar(person, 64.d),
          SizedBox(width: 12.d),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: index,
              builder: (context, value, child) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(person),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    tween: Tween(
                      begin: (value - 1) / group.children.length,
                      end: value / group.children.length,
                    ),
                    builder: (context, value, _) => LinearProgressIndicator(
                      minHeight: 6.d,
                      value: value,
                      color: TColors.green,
                      backgroundColor: TColors.primary20,
                      borderRadius: BorderRadius.all(Radius.circular(6.d)),
                    ),
                  ),
                  Text(
                    "${index.value} / ${group.children.length}",
                    style: TStyles.small.copyWith(color: TColors.primary30),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.d),
          Widgets.button(
            context,
            width: 32.d,
            height: 32.d,
            radius: 32.d,
            padding: EdgeInsets.all(8.d),
            color: TColors.primary20,
            child: Asset.load<SvgPicture>("close"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }
}
