#!/bin/sh
# Switch the migration spike to schema version 1 or 2 and regenerate code.
# Usage (from spikes/isar_spike): sh mig_versions/use.sh 1
set -e
case "$1" in
  1|2) ;;
  *) echo "usage: sh mig_versions/use.sh <1|2>" >&2; exit 64 ;;
esac
cp "mig_versions/v$1.dart.txt" lib/mig_record.dart
dart run build_runner build --delete-conflicting-outputs >/dev/null
dart format lib/mig_record.dart lib/mig_record.g.dart >/dev/null
echo "lib/mig_record.dart is now schema v$1"
