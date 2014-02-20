part of QuickbooksOSR;

@NgComponent (
  selector: "sidebar",
  templateUrl: "./views/sidebar.html",
  publishAs: "sidebar",
  applyAuthorStyles: true
)
class SidebarComponent implements NgAttachAware {
  List<int> versions = [1,2,3,4,5,6,7,8,9,10,11,12,13];
  List<QBCountryVersion> countries;
  

  List<String> messages = new List<String>();
  List<String> subscriptions = new List<String>();
  bool isLoading = false;
  
  String _version = "13";
  String get version => _version;
  set version (String version) {
    _version = version;
    refreshResults();
  }
  
  bool _qbXML = true;
  String get qbFC => !_qbXML ? "on": "off";
  String get qbXML => _qbXML ? "on": "off";
  set qbFC (use) {
    print(use);
    _qbXML = false;
    refreshResults();
  }

  set qbXML (use) {
    _qbXML = true;
    refreshResults();
  }
  
  String _activeMessage;
  String get activeMessage => _activeMessage;
  set activeMessage (String activeMessage) {
    _activeMessage = activeMessage;
    refreshResults();
  }
  
  OsrState state;
 
  SidebarComponent(OsrState this.state, Scope current, RouteProvider routedVals) {
    countries = [
                 new QBCountryVersion(this, "US", true),
                 new QBCountryVersion(this, "UK"),
                 new QBCountryVersion(this, "OE"),
                 new QBCountryVersion(this, "AU"),
                 new QBCountryVersion(this, "CA")
                 ];
    if (routedVals.routeName == "view") {
      log.info("Loading from view");
      //:type/:sdkType/:maxSDKVersion/:countries
      _version = routedVals.parameters["maxSDKVersion"];
      _activeMessage = routedVals.parameters["type"];
      if (routedVals.parameters["sdkType"] == "qbXML") {
        _qbXML = true;
      }
      else {
        _qbXML = false;
      }
      String countryValS = routedVals.parameters["countries"];
      
      Map<String, bool> countryValues = new Map<String, bool>();
      countryValS.split("|").forEach((String countryCodeBool) { 
        List<String> splitCCB = countryCodeBool.split(":");
        countryValues[splitCCB[0]] = splitCCB[1] == "true";
      });
      countries.forEach((QBCountryVersion qbcv) { 
        if (countryValues.containsKey(qbcv.country)) {
          qbcv._use = countryValues[qbcv.country];
        }
      });
    }
    refreshResults(false);
  }
  String getType (String val) {
    return val.substring(0,val.length-2);
  }
  void attach () { //  ng-change="sidebar.refreshResults()"
    
  }
  
  void refreshResults ([bool updateURL = true]) {
    log.info("REFRESHED VIEW");
    StringBuffer buffer = new StringBuffer();
    countries.forEach((QBCountryVersion qbcv)  {
      if (buffer.length > 0) buffer.write("|");
      buffer.write(qbcv.country);
      buffer.write(":");
      buffer.write(qbcv.use);
    });
    
    this.state.getRequestsJsonReader().then((QBRequestsJsonReader rjr) { 
      this.subscriptions.clear();
      num ver = num.parse(version);
      rjr.subscriptions.forEach((QBMessageSubscription ms)  {
        if (ms.isUseAndGreaterThan(ver, UK: countries[1].use , CA: countries[4].use, US: countries[0].use, AU: countries[3].use, OE: countries[4].use)) {
          this.subscriptions.add(ms.name);
        } 
      });
      this.messages.clear();
      rjr.messages.forEach((QBMessageSubscription ms)  {
        if (ms.isUseAndGreaterThan(ver, UK: countries[1].use , CA: countries[4].use, US: countries[0].use, AU: countries[3].use, OE: countries[4].use)) {
          this.messages.add(ms.name);
        }
      });
    });
    
    log.info("view/$activeMessage/${(_qbXML ? "qbXML" : "qbFC")}/$version/${buffer.toString()}");
    if (updateURL) window.location.hash = "view/$activeMessage/${(_qbXML ? "qbXML" : "qbFC")}/$version/${buffer.toString()}";
  }
}