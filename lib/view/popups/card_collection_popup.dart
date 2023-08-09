
class CollectionPopup extends AbstractPopup {
  const CollectionPopup({super.key, required super.args})
      : super(Routes.popupCollection);

  @override
  createState() => _CollectionPopupState();
}

class _CollectionPopupState extends AbstractPopupState<CollectionPopup>
    with KeyProvider {
}
