#!/bin/sh

script_dir=$(dirname $(realpath $0))
project_dir="$script_dir/Project"
repo_dir="$script_dir/../../"

if [ -n "$(git -C $repo_dir status --porcelain)" ]; then 
  echo "Repository has uncommitted changes!"
  exit 1
fi

cd $project_dir
xcrun agvtool next-version
build_number=$(xcrun agvtool what-version -terse)

cd $repo_dir
git commit -a -m "Bump xx-messenger example app build number to $build_number"
