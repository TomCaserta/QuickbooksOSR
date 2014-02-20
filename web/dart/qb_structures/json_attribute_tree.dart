part of QuickbooksOSR;


class QBJsonReader {
  int Height;
  int Width;
  int TopLeftX;
  int TopLeftY;
  String masterImage;
  List<String> supportedVersions = new List<String>();
  Map<String, int> minVerCountry = new Map<String, int>();
  
  bool required = false;
  String count;
  
  // QBXML
  String xmlName;
  String xmlType;
  String xmlNameHtml;
  List<String> xmlEnumValues;
  
  
  // QBFC
  num minVerUS = 0;
  String fcName;
  String fcNameHtml;
  String fcType;
  List<String> fcEnumValues;
  
  
  bool get isOrGroup => xmlName == "OR";
  bool get isSkipXML => xmlName == "nothing";
  bool get isSkipQBFC => fcName == "skip";
  bool get isAggregate => xmlType == "Aggregate";
  
  List<QBJsonReader> attributes = new List<QBJsonReader>();
  List<QBJsonReader> elements = new List<QBJsonReader>();
  
  String toXML (int maxVer, List<String> countries, [String indent = ""]) {
    bool isSupported = true;
    countries.forEach((String countryCode) { 
      if (!supportedVersions.contains(countryCode)) isSupported = false;
    });
    if (minVerUS < maxVer && isSupported) {
      String supported = supportedVersions.join(", ");
      StringBuffer builder = new StringBuffer();
      if (xmlName != null) {
      if (!isSkipXML) { 
        if (isOrGroup) {
          builder..write(indent)..write("<!-- BEGIN OR -->\n");
        }
        else {
          if (this.xmlType == "ENUMTYPE") {
            builder..write(indent)..write("<!-- ")
                   ..write(xmlName)
                   ..write(" may have one of the following values: ")
                   ..write(this.xmlEnumValues)
                   ..write(" -->\n");
          }
          StringBuffer attributesString = new StringBuffer();
          attributes.forEach((QBJsonReader attrib) {
            attributesString.write(" ");
            attributesString.write(attrib.xmlName);
            attributesString.write("=\"");
            attributesString.write(attrib.xmlType);
            attributesString.write("\"");
          });
          if (isAggregate) { 
            if (required) builder..write(indent)..write("<!-- REQUIRED SUPPORT:[$supported]-->\n");
            else builder..write(indent)..write("<!-- OPTIONAL SUPPORT:[$supported] -->\n");
          }
          builder..write(indent)
                 ..write("<")
                 ..write(this.xmlName)
                 ..write(attributesString);       
          builder..write(">");
          if (!isAggregate) builder.write(xmlType);
          else builder.write("\n");
        }
      }
      int x = 0;
      elements.forEach((QBJsonReader child)  { 
  
        if (isOrGroup && x != 0) {
          builder..write(indent)..write("<!-- OR: -->\n");
        }
        x++;
        builder.write(child.toXML(maxVer, countries, "${!isSkipXML ? indent : ""}    "));
      });
      if (!isSkipXML) { 
        if (isOrGroup) {
          builder..write(indent)..write("<!-- END OR -->\n");
        }
        else {
          if (isAggregate) builder.write(indent);
          builder..write("</")..write(xmlName);
          if (!isAggregate) { 
            if (required) builder.write("> <!-- REQUIRED SUPPORT:[$supported] -->\n");
            else builder.write("> <!-- OPTIONAL SUPPORT:[$supported] -->\n");
          }
          else builder.write(">\n");
          
        }
      }
      return builder.toString();
      }
      else return "";
    }
    else return "";
  }
  
  QBJsonReader.fromJson (dynamic jsonDat) {
    if (jsonDat is String) { 
      jsonDat = JSON.decode(jsonDat);
    }
    if (jsonDat == null) return;
    
    this.Height = jsonDat["Height"];
    this.Width = jsonDat["Width"];
    this.TopLeftX = jsonDat["TopLeftX"];
    this.TopLeftY = jsonDat["TopLeftY"];
    this.masterImage = jsonDat["masterImage"];
    this.required = (jsonDat["required"] != null ? jsonDat["required"] : false);
    if (jsonDat["count"] != null) {
    this.count = jsonDat["count"].toString();
    }
    this.xmlName = jsonDat["xmlName"];
    this.xmlType = jsonDat["xmlType"];
    this.xmlNameHtml = jsonDat["xmlNameHtml"];
    this.xmlEnumValues = jsonDat["xmlEnumValues"];
    this.fcName = jsonDat["fcName"];
    if (jsonDat["minVerUS"] is num) {
      this.minVerUS = jsonDat["minVerUS"];
    }
    else {
      this.minVerUS = 0;
    }
    this.fcNameHtml = jsonDat["fcNameHtml"];
    this.fcType = jsonDat["fcType"];
    this.fcEnumValues = jsonDat["fcEnumValues"];
    
    
    
    if (jsonDat["supports"] is Map) {
      jsonDat["supports"].forEach((String support, bool val) { 
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
