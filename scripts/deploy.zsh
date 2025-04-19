#!/bin/zsh

set -e

SRC_DIR="dist"
DEST_DIR="$HOME/.pimp"
DEST_DIR_CONFIG="$HOME/.pimp/config"
SRC_CONFIG="$SRC_DIR/config/pimp.zshenv"
DEST_CONFIG="$DEST_DIR_CONFIG/pimp.zshenv"
BACKUP_SUFFIX="$(date +%Y%m%d%H%M%S)"

echo "🔁 Syncing files to $DEST_DIR..."
mkdir -p "$DEST_DIR"
cp -R "$SRC_DIR/pimp.zsh" "$DEST_DIR/pimp.zsh"
cp -R "$SRC_DIR/pimp.omp.json" "$DEST_DIR/pimp.omp.json"
cp -R "$SRC_DIR/.version" "$DEST_DIR/.version"

if [[ -f "$DEST_CONFIG" ]]; then
  echo "🔄 Merging configuration..."

  cp "$DEST_CONFIG" "${DEST_CONFIG}.bak.$BACKUP_SUFFIX"
  echo "📋 Backup created: ${DEST_CONFIG}.bak.$BACKUP_SUFFIX"

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

  # Write new merged content
  printf "%s\n" "${new_lines[@]}" > "$DEST_CONFIG"
else
  echo "📦 Copying configuration file..."

  mkdir -p "$DEST_DIR_CONFIG"
  cp -R "$SRC_CONFIG" "$DEST_CONFIG"
fi

# 3. Append Oh My Posh config to .zshrc (if not already present)
ZSHRC="$HOME/.zshrc"
CONFIG_SNIPPET=$(cat << 'EOF'

# pimp-my-shell config
source "$HOME/.pimp/pimp.zsh"
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config $HOME/.pimp/pimp.omp.json)"
fi
EOF
)

if ! grep -q '.pimp/pimp.zsh' "$ZSHRC"; then
  echo "$CONFIG_SNIPPET" >> "$ZSHRC"
  echo "✅ Configuration added to $ZSHRC"
else
  echo "ℹ️ Configuration already exists in $ZSHRC"
fi

echo "✅ Deployment complete."
