              value: _member!.status == 1, onChanged: _changeVisibility),
          Asset.load<Image>("tribe_visibility", width: 44.d),
          SizedBox(width: 12.d),
          Text("tribe_visibility".l()),
          const Expanded(child: SizedBox()),
          _indicator(
              "icon_population", "${tribe.population}/${tribe.capacity}", 40.d),
        ]),
        SizedBox(height: 20.d),
        Widgets.skinnedButton(
            color: ButtonColor.teal,
            label: "tribe_invite".l(),
            icon: "tribe_invite",
            onPressed: () => Navigator.of(context)
                .pushNamed(Routes.popupTribeInvite.routeName)),
        SizedBox(height: 20.d),
      ],
    );

  Widget _indicator(String icon, String label, double iconSize,
      [EdgeInsetsGeometry? padding]) {
    return Widgets.rect(
        height: 64.d,
        padding: padding ?? EdgeInsets.only(left: 16.d, right: 16.d),
        decoration:
            Widgets.imageDecore("ui_frame_inside", ImageCenterSliceData(42)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Asset.load<Image>(icon, height: iconSize),
          SizedBox(width: 12.d),
          SkinnedText(label)
        ]));
  }

  void _changeVisibility(bool value) {
    var newStatus = value ? 1 : 3;
    try {
      BlocProvider.of<ServicesBloc>(context).get<HttpConnection>().rpc(
          RpcId.tribeVisibility,
          params: {RpcParams.status.name: newStatus});
      setState(() => _member!.status = newStatus);
    } finally {}
  }
  }
