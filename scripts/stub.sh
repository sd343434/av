#!/usr/bin/env bash
#
# Synthetic validation stub for the CI-Gate probe repository.
#
# Each of the seven validation jobs calls this with its own job ID. The exit
# status is chosen from the single-line `variant` file at the repository root,
# so switching experiments is a one-word commit rather than a workflow edit.
#
# This script contains no project logic and performs no network access.
#
set -euo pipefail

JOB="${1:?usage: stub.sh <job-id>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VARIANT="$(tr -d '[:space:]' < "$ROOT/variant")"

echo "variant=${VARIANT}  job=${JOB}"

# A stub must never "pass by accident". An unrecognised variant is an error,
# not a success, so a typo in the variant file cannot produce a green run that
# is then misread as experiment evidence.
case "$VARIANT" in

  # T1  — every validation job succeeds.
  # T3b — every job succeeds; `build` is skipped via `if: false` in the
  #       workflow, not via an exit status.
  # T6  — every job succeeds; the point of T6 is that the renamed gate never
  #       reports a check of the required name.
  T1|T3b|T6)
    echo "ok"
    exit 0
    ;;

  # T2 — exactly one LEAF fails. The root still succeeds, so the other five
  #      leaves run and succeed: the gate must fail on one `failure`.
  T2)
    if [ "$JOB" = "unit-tests" ]; then
      echo "deliberate failure for T2"
      exit 1
    fi
    exit 0
    ;;

  # T3a — the ROOT fails, so all six leaves conclude `skipped`. This is the
  #       shape of production run 38117063684.
  # T5a — same shape, read under protection that requires only the six leaves.
  # T5b — same shape, read under protection that requires only `CI Gate`.
  T3a|T5a|T5b)
    if [ "$JOB" = "lint-and-typecheck" ]; then
      echo "deliberate root failure for ${VARIANT}"
      exit 1
    fi
    exit 0
    ;;

  # T4 — the root runs long enough to be cancelled by a second push, which
  #      `cancel-in-progress: true` turns into a cancellation of this run.
  T4)
    if [ "$JOB" = "lint-and-typecheck" ]; then
      echo "sleeping 180s so this run can be cancelled by a second push"
      sleep 180
    fi
    exit 0
    ;;

  *)
    echo "ERROR: unrecognised variant '${VARIANT}'" >&2
    echo "Expected one of: T1 T2 T3a T3b T4 T5a T5b T6" >&2
    exit 1
    ;;
esac
