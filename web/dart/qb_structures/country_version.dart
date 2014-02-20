part of QuickbooksOSR;


class QBCountryVersion {
  String country;
  bool _use = false;
  bool isDefault;
  SidebarComponent parent;
  bool get use => _use;
  set use (bool use) {
    this._use = use;
    parent.refreshResults();
  }
  QBCountryVersion(this.parent, this.country, [this._use = false]);
}