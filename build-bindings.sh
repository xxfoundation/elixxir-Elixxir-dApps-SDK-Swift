#!/bin/sh

#=======================================
# Configuration
#=======================================

working_dir="$(pwd)"
temp_dir="$(dirname $(realpath $0))/.build-bindings"
client_git_url="https://gitlab.com/elixxir/client.git"
client_git_dir="$temp_dir/client"
client_git_commit="$1"
framework_target="ios"
frameworks_dir="$(dirname $(realpath $0))/Frameworks"

#=======================================
# Helpers
#=======================================

message() { 
  local text=$1
  echo ""
  echo "\033[1;32m▶ ${text}\033[0m"
}

#=======================================
# Main script
#=======================================

set -e

if [ ! -n "$client_git_commit" ]; then
  echo "Invalid option. Usage:"
  echo "  build-bindings.sh COMMIT_HASH - Build Bindings from provided commit"
  exit 1
fi

if [ ! -d "$client_git_dir" ]; then
  message "Cloning client repo..."
  git clone $client_git_url $client_git_dir
else
  message "Updating client repo..."
  cd $client_git_dir
  git reset --hard
  git fetch origin
  cd $working_dir
fi

message "Checkout commit $client_git_commit..."
cd $client_git_dir
git switch --detach $client_git_commit
git reset --hard

message "Build client..."
go mod tidy
rm -rf vendor/
go build ./...

message "Make Bindings.xcframework..."
go get golang.org/x/mobile/bind
go install golang.org/x/mobile/cmd/gomobile@latest
gomobile init
gomobile bind -target $framework_target gitlab.com/elixxir/client/bindings

message "Move framework..."
cd $working_dir
rm -rf "$frameworks_dir/Bindings.xcframework"
mv "$client_git_dir/Bindings.xcframework" "$frameworks_dir/"

message "Summary"
echo "Update Bindings.xcframework"
echo "https://git.xx.network/elixxir/client/-/commit/$client_git_commit"
go version
xcode_version=`xcodebuild -version`
echo "${xcode_version/$'\n'/ }"
echo "gomobile bind target: $framework_target"
