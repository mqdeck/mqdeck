#!/usr/bin/env bash

set -euo pipefail

latest_tag="$(
  git tag \
    --list 'v[0-9]*.[0-9]*.[0-9]*' \
    --sort=-v:refname \
  | head -n 1
)"

if [[ -z "${latest_tag}" ]]; then
  next_version="1.0.0"
else
  version="${latest_tag#v}"

  IFS='.' read -r major minor patch <<< "${version}"

  patch=$((patch + 1))

  next_version="${major}.${minor}.${patch}"
fi

next_tag="v${next_version}"

git add --all

if ! git diff --cached --quiet; then
  git commit -m "Release ${next_tag}"
  git push
fi

git tag -a "${next_tag}" -m "Release ${next_tag}"
git push origin "${next_tag}"

echo "Released ${next_tag}"