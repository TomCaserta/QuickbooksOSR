part of QuickbooksOSR;

@NgController (
    selector: "[view]",
    publishAs: "view"
)
class MessageViewController {
  String messageName;
  bool isQBXml = false;
  num maxVersion = 13;
  bool loaded = false;
  String xml = "";
  MessageViewController (OsrState state, RouteProvider provider) {
    messageName = provider.parameters["type"];
    isQBXml = provider.parameters["sdkType"] == "qbXML";
    maxVersion = num.parse(provider.parameters["maxSDKVersion"]);
    String countryValS = provider.parameters["countries"];
    List<String> countryValues = new List<String>();
    countryValS.split("|").forEach((String countryCodeBool) { 
      List<String> splitCCB = countryCodeBool.split(":");
      if (splitCCB[1] == "true") {
        countryValues.add(splitCCB[0]);
      }
    });
    
    Future.wait([state.getQBJsonReader ("${messageName}Rq"),state.getQBJsonReader ("${messageName}Rs")]).then((List<QBJsonReader> ret) {
      QBJsonReader request = ret[0];
      QBJsonReader response = ret[1];
      Element elem = querySelectorAll("#requestData").first;
      elem.text= request.toXML(maxVersion, countryValues);
      Element elem2 = querySelectorAll("#responseData").first;
      elem2.text= response.toXML(maxVersion, countryValues);
      context.callMethod("recomputeStyles", []);//.color();
      this.loaded = true;
    });
  }
}