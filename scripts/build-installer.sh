#!/bin/sh

set -eu

PROJECT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TEMPLATE="$PROJECT_DIR/installer/install-omvi-profile.sh.in"
PROFILE="$PROJECT_DIR/profile/Reolink-OMVI-3i.conf"
OUTPUT="$PROJECT_DIR/install-omvi-profile.sh"
PLACEHOLDER='@@OMVI_PROFILE@@'

if [ ! -f "$TEMPLATE" ]; then
    echo "Missing installer template: $TEMPLATE" >&2
    exit 1
fi

if [ ! -f "$PROFILE" ]; then
    echo "Missing camera profile: $PROFILE" >&2
    exit 1
fi

if [ "$(grep -Fxc '# BEGIN Reolink-OMVI-3i-MostlyBuilds' "$PROFILE" || true)" -ne 1 ] ||
   [ "$(grep -Fxc '[Reolink*OMVI 3i MostlyBuilds]' "$PROFILE" || true)" -ne 1 ] ||
   [ "$(grep -Fxc '# END Reolink-OMVI-3i-MostlyBuilds' "$PROFILE" || true)" -ne 1 ]; then
    echo "Profile must contain exactly one expected BEGIN marker, header, and END marker." >&2
    exit 1
fi

PLACEHOLDER_COUNT=$(grep -Fxc "$PLACEHOLDER" "$TEMPLATE" || true)

if [ "$PLACEHOLDER_COUNT" -ne 1 ]; then
    echo "Expected exactly one $PLACEHOLDER line in $TEMPLATE; found $PLACEHOLDER_COUNT." >&2
    exit 1
fi

TMP=$(mktemp "$PROJECT_DIR/.install-omvi-profile.XXXXXX")

cleanup()
{
    rm -f "$TMP"
}

trap cleanup EXIT HUP INT TERM

awk -v placeholder="$PLACEHOLDER" -v profile="$PROFILE" '
$0 == placeholder {
    while ((getline line < profile) > 0) {
        print line
    }

    if (close(profile) != 0) {
        exit 2
    }

    next
}

{
    print
}
' "$TEMPLATE" > "$TMP"

if grep -Fq "$PLACEHOLDER" "$TMP"; then
    echo "Generated installer still contains the profile placeholder." >&2
    exit 1
fi

chmod 755 "$TMP"
mv -f "$TMP" "$OUTPUT"
trap - EXIT HUP INT TERM

echo "Generated $OUTPUT"
