tell application "System Events"
  set activeApp to name of first application process whose frontmost is true
end tell

tell application "Safari"
  set windowTitle to name of front document
end tell

tell application "System Events"
  tell process activeApp
    click menu item windowTitle of menu 1 of menu bar item "Fenster" of menu bar 1
  end tell
end tell
