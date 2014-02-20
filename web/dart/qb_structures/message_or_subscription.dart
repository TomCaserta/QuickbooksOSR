part of QuickbooksOSR;

class QBMessageSubscription {
  String name = "";
  String minVerText = "";
  num minVerUS;
  num minVerCA;
  num minVerUK;
  num minVerAU;
  num minVerOE;
  bool isUseAndGreaterThan (num ver, { bool UK, bool CA, bool US, bool AU, bool OE }) {
     List<num> chkVer = new List<num>();
     if (UK) chkVer.add(minVerUK);
     if (US) chkVer.add(minVerUS);
     if (CA) chkVer.add(minVerCA);
     if (AU) chkVer.add(minVerAU);
     if (OE) chkVer.add(minVerOE);
     
     bool use = true;
     if (chkVer.length == 0) use = false;
     chkVer.forEach((num vers) { 
       if (vers > ver || vers == 0) {
         use = false;
       }
     });
     return use;
  }
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
