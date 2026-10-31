#!/bin/bash
set -euo pipefail

IMAGE_NAME="$1"
NEW_VERSION="$2"

git fetch --tags

# New release first, then the two most recent existing tags.
PREVIOUS_VERSIONS=$(git tag -l 'v*' --sort=-version:refname \
  | grep -vx "$NEW_VERSION" \
  | head -n 2)
VERSIONS=$(printf "%s\n%s\n" "$NEW_VERSION" "$PREVIOUS_VERSIONS")

i=1

while IFS= read -r VERSION; do
    [ -z "$VERSION" ] && continue

    FILE="k8s/deployment-v${i}.yaml"

    if [ ! -f "$FILE" ]; then
        echo "ERROR: $FILE does not exist"
        exit 1
    fi

    # Update only the image for the scaler container.
    sed -i "/- name: scaler/{n;s|image:.*|          image: ${IMAGE_NAME}:${VERSION}|;}" "$FILE"

    echo "Updated $FILE with version $VERSION"
    i=$((i + 1))
done <<< "$VERSIONS"

# If fewer than three releases exist, remove any stale image tag from
# the remaining Deployment file(s) by setting them to the new release.
while [ "$i" -le 3 ]; do
    FILE="k8s/deployment-v${i}.yaml"

    if [ -f "$FILE" ]; then
        sed -i "/- name: scaler/{n;s|image:.*|          image: ${IMAGE_NAME}:${NEW_VERSION}|;}" "$FILE"
        echo "Set $FILE to $NEW_VERSION (not enough older releases yet)"
    fi

    i=$((i + 1))
done

echo "Kubernetes manifests updated successfully."