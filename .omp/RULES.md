# nix-config workflow rules

- Work on `main` for all tracked changes in this repository.
- Before editing, ensure the repository is on `main`. If it is not on `main`, move to `main` only when doing so is safe; if local changes or branch state make that unsafe, ask the user what to do.
- After completing and verifying a requested tracked change, run `git add`, create a commit with a meaningful title, and `git push`.
- Exception: if the user explicitly asks for a temporary/local-only development change, such as changing Nova's URL or branch for local development, do not commit or push that change unless the user explicitly asks.
- Do not run expensive or noisy Nix commands unless the user explicitly asks. Avoid commands such as `nixos-rebuild`, `home-manager switch`, `nix build`, `nix flake check`, or other evaluations/builds that produce large output, consume substantial time, or use many credits. Lightweight lookups are allowed, such as searching whether a package exists. Use discretion: if a command could be annoying, costly, or disruptive for the user, do not run it; explain what the user can run locally instead.
- Treat pre-existing local changes as user work: do not discard, overwrite, or hide them.
