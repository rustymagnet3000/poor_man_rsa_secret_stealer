osascript -e 'tell application "Terminal"' -e 'delay 0.5' -e "set currentTab to do script (\"$TARGET_BUILD_DIR/$PRODUCT_NAME --debug-in-terminal\")" -e 'end tell' &
