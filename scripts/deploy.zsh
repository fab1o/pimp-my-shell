#!/bin/zsh

set -e

SRC_DIR="dist"
DEST_DIR="$HOME/.pimp"
SRC_CONFIG="dist/config/pimp.zshenv"
DEST_CONFIG="$DEST_DIR/config/pimp.zshenv"
BACKUP_SUFFIX="$(date +%Y%m%d%H%M%S)"

echo "🔁 Syncing files to $DEST_DIR..."
mkdir -p "$DEST_DIR"
cp -R ./dist/pimp.zsh "$DEST_DIR/pimp.zsh"
cp -R ./dist/pimp.omp.json "$DEST_DIR/pimp.omp.json"
cp -R ./dist/.version "$DEST_DIR/.version"

echo "🔄 Merging configuration..."
echo "📦 Source: $SRC_CONFIG"
echo "🏠 Destination: $DEST_CONFIG"

# Create associative arrays for lookups
typeset -A src_keys dest_keys

# Helper function to extract key from a line
extract_key() {
  echo "$1" | sed -n 's/^\([A-Z_0-9]*\)=.*$/\1/p'
}

# Read source keys
while IFS= read -r line || [[ -n "$line" ]]; do
  [[ -z "$line" || "$line" =~ "^#" ]] && continue
  key=$(extract_key "$line")
  [[ -n "$key" ]] && src_keys[$key]="$line"
done < "$SRC_CONFIG"

# Read destination values
while IFS= read -r line || [[ -n "$line" ]]; do
  [[ -z "$line" || "$line" =~ "^#" ]] && continue
  key=$(extract_key "$line")
  [[ -n "$key" ]] && dest_keys[$key]="$line"
done < "$DEST_CONFIG"

# Build the new file
new_lines=()

while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ -z "$line" || "$line" =~ "^#" ]]; then
    new_lines+=("$line")
    continue
  fi

  key=$(extract_key "$line")
  if [[ -n "$key" ]]; then
    if [[ -v dest_keys[$key] ]]; then
      new_lines+=("${dest_keys[$key]}")
    else
      new_lines+=("$line")
    fi
  else
    new_lines+=("$line")
  fi
done < "$SRC_CONFIG"

# Append remaining keys in dest that are NOT in source
for key in "${(@k)dest_keys}"; do
  if [[ -z "${src_keys[$key]}" ]]; then
    echo "🗑️  Removing orphan key: $key"
    continue
  fi
done

if [[ -f "$DEST_CONFIG" ]]; then
  cp "$DEST_CONFIG" "${DEST_CONFIG}.bak.$BACKUP_SUFFIX"
  echo "📋 Backup created: ${DEST_CONFIG}.bak.$BACKUP_SUFFIX"
fi

# Write new merged content
printf "%s\n" "${new_lines[@]}" > "$DEST_CONFIG"

echo "✅ Merge complete. Destination updated."
