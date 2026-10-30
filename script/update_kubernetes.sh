
#!/bin/bash
set -euo pipefail

IMAGE_NAME="$1"
NEW_VERSION="$2"

# Get the previous two release versions
git fetch --tags

PREVIOUS_VERSIONS=$(git tag -l 'v*' --sort=-version:refname | head -n 2)

# Add the new version first
VERSIONS=$(printf "%s\n%s\n" "$NEW_VERSION" "$PREVIOUS_VERSIONS")

# Update the three Deployment files
i=1

while IFS= read -r VERSION; do
    [ -z "$VERSION" ] && continue

    FILE="k8s/deployment-v${i}.yaml"

    if [ ! -f "$FILE" ]; then
        echo "ERROR: $FILE does not exist"
        exit 1
    fi

    sed -i "s|image:.*|image: ${IMAGE_NAME}:${VERSION}|" "$FILE"

    echo "Updated $FILE with version $VERSION"

    i=$((i + 1))
done <<< "$VERSIONS"

echo "Kubernetes manifests updated successfully."
