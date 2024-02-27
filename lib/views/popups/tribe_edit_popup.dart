import '../../app_export.dart';

class TribeEditPopup extends AbstractPopup {
  const TribeEditPopup({super.key}) : super(Routes.popupTribeEdit);

  @override
  createState() => _TribeEditPopupState();
}

class _TribeEditPopupState extends AbstractPopupState<TribeEditPopup> {

  @override
  String titleBuilder() =>
      accountProvider.account.tribe == null ? "tribe_new".l() : "tribe_edit".l();

  @override
  contentFactory() {
    return const EditTribe();
  }
}
