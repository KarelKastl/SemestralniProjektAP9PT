#!/bin/zsh
# Spustí build a testy na simulátoru iPhone 12 mini. Použití: ./test.sh [unit|ui|all]
cd "$(dirname "$0")/Vlajkar"
SIM=CBAC7EA9-2478-4723-ADBD-2BEC3E01353B
ARGS=(-project Vlajkar.xcodeproj -scheme Vlajkar -destination "platform=iOS Simulator,id=$SIM" -derivedDataPath ../build/dd -parallel-testing-enabled NO)
case "${1:-all}" in
  unit) ARGS+=(-only-testing:VlajkarTests) ;;
  ui) ARGS+=(-only-testing:VlajkarUITests) ;;
esac
rm -rf ../build/result.xcresult
xcodebuild "${ARGS[@]}" -resultBundlePath ../build/result.xcresult test 2>&1 | grep -E 'warning:|error:|^Test Case .*(failed)|Test case .*failed|\*\* (TEST|BUILD)|Executed [0-9]+ test|Test run with|✘|failed -' | grep -v 'appintentsmetadataprocessor' | tail -${2:-40}
