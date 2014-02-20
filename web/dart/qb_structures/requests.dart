part of QuickbooksOSR;

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

