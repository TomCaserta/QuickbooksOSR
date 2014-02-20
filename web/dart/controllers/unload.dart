part of QuickbooksOSR;

@NgController(
  selector: "[unload]",
  publishAs: "hide"
)
class UnloadViewer {
  bool doHide = true;
  UnloadViewer()
  {
    print("Loaded unloader >.>");
  }
}