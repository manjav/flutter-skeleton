
  @override
  Widget navigatorBuilder(double paddingTop, String title) {
    return ValueListenableBuilder(
      valueListenable: controller.contentIndex,
      builder: (context, value, child) {
        return Align(
          alignment: const Alignment(0, 1),
          child: FractionallySizedBox(
            heightFactor: 0.25,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _slidination(
                    controller.topicIndex.value, controller.topics.length),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _navigationButton(
                      name: "footer_prev",
                      isEnable: controller.topicIndex.value > 0,
                      onPress: () => controller.changeTopic(-1),
                    ),
                    _navigationButton(
                      name: "footer_pause",
                    ),
                    _navigationButton(
                      name: "footer_next",
                      isEnable: value < controller.topics.length &&
                          controller.contentIndex.value ==
                              controller.contents.length - 1,
                      onPress: () => controller.changeTopic(1),
                    ),
                  ],
                ),
                SizedBox(height: 32.d)
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _slidination(int value, int length) {
    final margin = 3.d;
    final width = (DeviceInfo.size.width - margin * 12) / length - margin * 2;
    return SizedBox(
      height: 10.d,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: margin * 6),
        scrollDirection: Axis.horizontal,
        itemCount: length,
        itemBuilder: (context, index) {
          return Widgets.rect(
            radius: 4.d,
            width: width,
            height: margin,
            margin: EdgeInsets.all(margin),
            color: index <= value ? TColors.white : TColors.primary20,
          );
        },
      ),
    );
  }

  Widget _navigationButton({
    required name,
    bool isEnable = true,
    Function()? onPress,
  }) {
    return Opacity(
      opacity: isEnable ? 1 : 0.4,
      child: Widgets.button(
        context,
        padding: EdgeInsets.all(32.d),
        child: Asset.load<Image>(name),
        onPressed: () {
          if (isEnable) {
            onPress?.call();
          }
        },
      ),
    );
  }
