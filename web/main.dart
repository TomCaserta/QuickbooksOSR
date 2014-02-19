import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:angular/angular.dart';
import 'package:path/path.dart' as path;


import 'dart/utils/fse_tree.dart';

Logger log = new Logger("QuickbooksOSR");
void main() {
  log.onRecord.listen((LogRecord r) { 
    print("[${new DateFormat("hh:mm:ss").format(r.time)}][${r.level}][${r.loggerName != "" ? r.loggerName : "ROOT"}]: ${r.message}");
  });
  ngBootstrap(module: new QuickbooksOsrModule());
}

@NgController (
    selector: "view",
    publishAs: "view"
)
class MessageViewController {
  String messageName;
  bool isQBXml = false;
  MessageViewController (OsrState state, RouteProvider provider) {
    messageName = provider.parameters["type"];
    isQBXml = provider.parameters["sdkType"] == "qbXML";
  }
}

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
                 new QBCountryVersion(this, "AU")
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
      refreshResults(false);
    }
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
      rjr.subscriptions.forEach((QBMessageSubscription ms)  {
        this.subscriptions.add(ms.name);
      });
      this.messages.clear();
      rjr.messages.forEach((QBMessageSubscription ms)  {
        this.messages.add(ms.name);
      });
    });
    
    log.info("view/$activeMessage/${(_qbXML ? "qbXML" : "qbFC")}/$version/${buffer.toString()}");
    if (updateURL) window.location.hash = "view/$activeMessage/${(_qbXML ? "qbXML" : "qbFC")}/$version/${buffer.toString()}";
  }
}

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

quickbooksOsrRouteInitializer(Router router, ViewFactory views) {
  return views.configure({
       'view': ngRoute(
          path: 'view/:type/:sdkType/:maxSDKVersion/:countries',
          view: 'views/tableview.html'),
       'index': ngRoute (
           defaultRoute: true,
          path: "index",
          view: "views/index.html"
       )
  });
}

class QuickbooksOsrModule extends Module {
  
  QuickbooksOsrModule () {
    
    type(OsrState);
    type(SidebarComponent);
    type(MessageViewController);
    value(RouteInitializerFn, quickbooksOsrRouteInitializer);
    factory(NgRoutingUsePushState,
        (_) => new NgRoutingUsePushState.value(false));
  }
}
class QBMessageSubscription {
  String name = "";
  String minVerText = "";
  num minVerUS;
  num minVerCA;
  num minVerUK;
  num minVerAU;
  num minVerOE;
  QBMessageSubscription.fromJson (Map<String, dynamic> jsonData) {
    this.name = jsonData["name"];
    this.minVerText = jsonData["minVerText"];
    this.minVerUS = jsonData["minVerUS"];
    this.minVerCA = jsonData["minVerCA"];
    this.minVerUK = jsonData["minVerUK"];
    this.minVerAU = jsonData["minVerAU"];
    this.minVerOE = jsonData["minVerOE"];
  }
}
class QBRequestsJsonReader {
  List<QBMessageSubscription> messages = new List<QBMessageSubscription>();
  List<QBMessageSubscription> subscriptions = new List<QBMessageSubscription>();
  QBRequestsJsonReader (Map<String, dynamic> jsonData) {
    List<Map> messageList = jsonData["messages"];
    messageList.forEach((Map m)  {
      messages.add(new QBMessageSubscription.fromJson(m));
    });
    List<Map> subscriptionList = jsonData["subscriptions"];
    subscriptionList.forEach((Map m)  {
      subscriptions.add(new QBMessageSubscription.fromJson(m));
    });
  }
}

class QBJsonReader {
  int Height;
  int Width;
  int TopLeftX;
  int TopLeftY;
  String masterImage;
  List<String> supportedVersions = new List<String>();
  Map<String, int> minVerCountry = new Map<String, int>();
  
  bool required;
  String count;
  
  // QBXML
  String xmlName;
  String xmlType;
  String xmlNameHtml;
  List<String> xmlEnumValues;
  
  
  // QBFC
  String minVerUS;
  String fcName;
  String fcNameHtml;
  String fcType;
  List<String> fcEnumValues;
  
  
  bool get isOrGroup => xmlName == "OR";
  
  List<QBJsonReader> attributes = new List<QBJsonReader>();
  List<QBJsonReader> elements = new List<QBJsonReader>();
  
  QBJsonReader.fromJson (dynamic jsonDat) {
    if (jsonDat is String) { 
      jsonDat = JSON.decode(jsonDat);
    }
    this.Height = jsonDat["Height"];
    this.Width = jsonDat["Width"];
    this.TopLeftX = jsonDat["TopLeftX"];
    this.TopLeftY = jsonDat["TopLeftY"];
    this.masterImage = jsonDat["masterImage"];
    this.required = jsonDat["required"];
    this.count = jsonDat["count"];
    this.xmlName = jsonDat["xmlName"];
    this.xmlType = jsonDat["xmlType"];
    this.xmlNameHtml = jsonDat["xmlNameHtml"];
    this.xmlEnumValues = jsonDat["xmlEnumValues"];
    this.fcName = jsonDat["fcName"];
    this.minVerUS = jsonDat["minVerUS"];
    this.fcNameHtml = jsonDat["fcNameHtml"];
    this.fcType = jsonDat["fcType"];
    this.fcEnumValues = jsonDat["fcEnumValues"];
    
    
    
    if (jsonDat["supports"] is Map) {
      jsonDat.forEach((String support, bool val) { 
        if (val == true) {
          supportedVersions.add(support);
        }
      });
    }
    if (jsonDat["attributes"] is List) {
      jsonDat["attributes"].forEach((dynamic attribData) { 
         attributes.add(new QBJsonReader.fromJson(attribData));
      });
    }
    if (jsonDat["elements"] is List) {
      jsonDat["elements"].forEach((dynamic elemData) {
         elements.add(new QBJsonReader.fromJson(elemData));
      });
    }
  }
  
}


class OsrState {
  FSETree _rootTree;
  QBRequestsJsonReader _requestFile;
  
  Future<QBRequestsJsonReader> getRequestsJsonReader () {
    if (_requestFile == null) {
      return this.simpleGet("osr_docs/json/requests.json").then((String response) { 
        _requestFile = new QBRequestsJsonReader(JSON.decode(response));
        return _requestFile;
      });
    }
    else {
      Completer c = new Completer();
      c.complete(_requestFile);
      return c.future;
    }
  }
  
  Future<FSETree> getDirectoryContents () {
   if (_rootTree == null) {
     return this.simpleGet( "fileList.json").then((String response)  {
       _rootTree = new FSETree.fromJson(response);
       return _rootTree;
     });
   }
   else {
     Completer c = new Completer();
     c.complete(_rootTree);
     return c.future;
   }
   
  }
  
  Future<String> simpleGet(String url) {
    log.info("Retreiving response from server for $url");
    Completer f = new Completer();
    HttpRequest http = new HttpRequest();
    http.open("GET", url);
    http.send();
    http.onReadyStateChange.listen((ProgressEvent ev) { 
      if (http.readyState == 4) {
        FSETree rootDir = new FSETree.fromJson(http.responseText);
        if (http.status == 200) {
          log.fine("Got response from server for $url");
          f.complete(http.responseText);
        }
        else {
          log.severe("Error retreiving $url: ${http.status}", new Exception("Could not retreive $url: ${http.status}"));
        }
      }
    });
    return f.future;
  }
  
  
}