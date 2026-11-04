#!/bin/zsh
# Pořídí screenshoty ve světlém, tmavém režimu a s velkým písmem. Použití: ./screenshots.sh [test]
cd "$(dirname "$0")"
SIM=CBAC7EA9-2478-4723-ADBD-2BEC3E01353B
DIR="$PWD/docs/screenshots"
xcrun simctl boot $SIM 2>/dev/null
xcrun simctl bootstatus $SIM -b >/dev/null
run() {
  xcrun simctl ui $SIM appearance $1
  xcrun simctl ui $SIM content_size $2
  TEST_RUNNER_SCREENSHOT_DIR="$DIR" TEST_RUNNER_SCREENSHOT_SUFFIX="$3" xcodebuild -project Vlajkar/Vlajkar.xcodeproj -scheme Vlajkar \
    -destination "platform=iOS Simulator,id=$SIM" -derivedDataPath build/dd -parallel-testing-enabled NO \
    -only-testing:VlajkarUITests/ScreenshotTests${4:+/$4} test 2>&1 | grep -E 'error:|\*\* TEST|Executed [0-9]+ test' | tail -3
}
[[ -z "$ONLY" || "$ONLY" == svetly ]] && run light large svetly $1
[[ -z "$ONLY" || "$ONLY" == tmavy ]] && run dark large tmavy $1
[[ -z "$ONLY" || "$ONLY" == velke ]] && run light accessibility-large velke $1
xcrun simctl ui $SIM appearance light
xcrun simctl ui $SIM content_size large
