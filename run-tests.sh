#!/bin/sh
set -e

echo "\n\033[1;32m▶ Xcode version\033[0m"
xcodebuild -version

if [ ! -n "$1" ]; then

  echo "\n\033[1;32m▶ Running package tests on iOS Simulator...\033[0m"
  set -o pipefail && xcodebuild -scheme 'elixxir-dapps-sdk-swift-Package' -sdk iphonesimulator -destination 'platform=iOS Simulator,OS=15.5,name=iPhone 13' test | ./xcbeautify

elif [ "$1" = "examples" ]; then

  echo "\n\033[1;32m▶ Running XXMessenger example tests on iOS Simulator...\033[0m"
  set -o pipefail && xcodebuild -workspace 'Examples/xx-messenger/XXMessenger.xcworkspace' -scheme 'XXMessenger' -sdk iphonesimulator -destination 'platform=iOS Simulator,OS=15.5,name=iPhone 13' test | ./xcbeautify

else

  echo "\n\033[1;31m▶ Invalid option.\033[0m Usage:"
  echo "  run-tests.sh          - Run package tests"
  echo "  run-tests.sh examples - Run examples tests"
  exit 1

fi
