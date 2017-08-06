import config/config, tiling/tiling
import tables, os, ospaths

# C Imports and linking
{.passL: "-framework ApplicationServices"}
{.passL: "-framework Carbon"}

{.compile: "appservices.c"}
proc isAuthorized: cint {.importc}
proc createAndRunEventLoop: cint {.importc}

var pConfig: Config

proc doAction(action: string) =
  let gap = pConfig.gap
  let displayEdgeGap = pConfig.displayEdgeGap

  case action:
    of "TopLeft":
      tileWindow(-1, -1, gap, displayEdgeGap)
    of "Top":
      tileWindow(0, -1, gap, displayEdgeGap)
    of "TopRight":
      tileWindow(1, -1, gap, displayEdgeGap)

    of "Left":
      tileWindow(-1, 0, gap, displayEdgeGap)
    of "Middle":
      tileWindow(0, 0, gap, displayEdgeGap)
    of "Right":
      tileWindow(1, 0, gap, displayEdgeGap)

    of "BottomLeft":
      tileWindow(-1, 1, gap, displayEdgeGap)
    of "Bottom":
      tileWindow(0, 1, gap, displayEdgeGap)
    of "BottomRight":
      tileWindow(1, 1, gap, displayEdgeGap)

# Handler for when keys are pressed, called from C.
# Return 1 to override, 0 to let the event pass
proc nimLandHandler(keyCode: int, repeated: int, modifiers: int): int {.exportc.} =
  let keyEvent = KeyEvent(
    modifiers: modifiers,
    keyCode: keyCode)

  if pConfig.hasBinding(keyEvent):
    # We don't want to do an action on keyrepeat, but we still want to snuff the event
    if repeated == 0:
      doAction(pConfig.getBinding(keyEvent))
    else:
      return 1
  
  return 0

proc main() =
  let configPath = getHomeDir() / ".darwintiler.json"

  if isAuthorized() == 0:
    echo "Need accessibility API authorizaton to use this :~)"
    quit()

  try:
    pConfig = loadConfig(configPath)

  except:
    echo "Couldn't read config file at ", configPath, " please create a config file"
    quit(QuitFailure)

  # Create and run the Quartz event tap loop
  let err = createAndRunEventLoop()

  if err != 0:
    echo "Failed to initialize Quartz event loop"
    quit(QuitFailure)

main()
