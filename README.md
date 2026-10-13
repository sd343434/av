# ci-gate-probe — a disposable CI experiment repository

**This repository is a throwaway test rig. It is not a project, it is not
maintained, and nothing here should be reused.** Delete it once the experiment
results have been recorded.

## Why it exists

It verifies two things about GitHub Actions and branch protection that cannot
be established on a developer machine:

1. whether a `ci-gate` job declared with `if: always()` actually runs and fails
   when its dependencies fail, are skipped, or are cancelled; and
2. whether GitHub treats a **skipped** check run as *satisfying* a required
   status check — which, if true, means a required-check list made of
   skippable jobs can read as green on a run where nothing was tested.

Those questions came out of a real observation in another repository: when the
root validation job failed, the six jobs depending on it concluded `skipped`,
not `failure`.

## What is in here

- `.github/workflows/probe.yml` — a synthetic workflow that reproduces the
  **job IDs, displayed check names, dependency graph and concurrency settings**
  of the real workflow under study, and embeds the real `ci-gate` job
  byte-for-byte. The validation job *bodies* are stubs.
- `scripts/stub.sh` — decides each stub's exit status from `variant`.
- `variant` — one line naming the active experiment (`T1`, `T2`, `T3a`, `T3b`,
  `T4`, `T5a`, `T5b`, `T6`). Changing this one word switches experiments.

## What is deliberately NOT in here

No production source code. No dependencies, lockfile, package manifest or
build tooling. No database, schema or migrations. No secrets, tokens,
credentials or environment variables. No copied commit history. No
proprietary, confidential or customer information of any kind.

**Never add a secret or an Actions variable to this repository, and never give
its workflow `write` permissions.** The whole point of the rig is that it has
nothing worth protecting.

## Why it is public

Branch protection is free on public repositories and gated behind a paid plan
on private ones. Two of the experiments need protection. Because this
repository contains only the stub files listed above, being public exposes
nothing — which is precisely why a disposable rig was used instead of testing
against a real repository.

## Safety

Nothing here reads from, writes to, or refers to any other repository. The
workflow makes no network calls beyond `actions/checkout`. Runs cost seconds.
# second push to trigger concurrency cancellation
