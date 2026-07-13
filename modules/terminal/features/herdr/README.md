# Herdr sessions and remote access

Herdr runs panes in a background server. Closing or detaching the terminal UI
does not stop those panes.

## Quick answers

| Goal | Command |
| --- | --- |
| Open or reattach to the default local session | `herdr` |
| Create or attach to a second independent session | `herdr session attach side-project` |
| Do the same with the top-level option | `herdr --session side-project` |
| List local sessions | `herdr session list` |
| Detach while leaving everything running | `Ctrl-b`, then `q` |
| Reattach to the named session | `herdr session attach side-project` |
| Attach directly to a remote host | `herdr --remote workbox` |
| Attach to a named session on a remote host | `herdr --remote workbox --session agents` |

A **workspace** is normally the right way to separate repos or tasks inside one
Herdr UI. Use a **named session** only when you want a fully separate server,
including separate panes, tabs, workspaces, sockets, and runtime state.

## Make a second local session

Choose a memorable session name and attach to it:

```bash
herdr session attach side-project
```

The command creates the named session when it does not exist and attaches when
it does. The equivalent shorter form is:

```bash
herdr --session side-project
```

Detach without stopping its agents by pressing `Ctrl-b`, then `q`. Later, list
and reattach:

```bash
herdr session list
herdr session attach side-project
```

Session lifecycle commands:

```bash
# Stop the named server and its running panes.
herdr session stop side-project

# Delete the named session's persisted state.
herdr session delete side-project
```

`stop` is not the same as detach: detaching leaves the server and panes running;
stopping ends them.

## Connect to a remote Herdr session

There are two useful workflows.

### Option 1: attach directly from the local machine

This is the most integrated workflow. Herdr runs a thin client locally, uses
normal OpenSSH authentication, and starts or attaches to Herdr on the remote
host:

```bash
# First verify that ordinary SSH works.
ssh workbox

# Then attach to the remote default Herdr session.
herdr --remote workbox
```

`workbox` can be any host alias from `~/.ssh/config`. A complete target also
works:

```bash
herdr --remote ssh://you@server.example.com:2222
```

To create or attach to a separate named session on that host:

```bash
herdr --remote workbox --session agents
```

By default, direct remote attach uses the local Herdr keybindings. To use the
remote server's keybindings instead:

```bash
herdr --remote workbox --remote-keybindings server
```

Direct attach can also bridge supported local desktop features, such as image
clipboard paste, into the remote session. If a compatible Herdr binary is not
available remotely, an interactive attach may offer to install it in
`~/.local/bin/herdr`.

### Option 2: SSH first, then run Herdr remotely

This is the simpler tmux-style workflow:

```bash
ssh workbox
herdr
```

For a named session on that host:

```bash
ssh workbox
herdr session attach agents
```

In this mode both Herdr's server and UI run on the remote host. It works well,
but it cannot bridge local desktop clipboard features beyond ordinary terminal
text paste.

## SSH troubleshooting

Herdr uses the same authentication as `ssh`. Check that first:

```bash
ssh workbox
```

If a passphrase-protected key is unavailable to a non-interactive terminal,
load it into the SSH agent and retry:

```bash
ssh-add
herdr --remote workbox
```

A remote attach connects to the remote host's Herdr state; it does not move or
copy the local session to that machine.

## Upstream references

- [Persistence and remote access](https://herdr.dev/docs/persistence-remote/)
- [Herdr concepts](https://herdr.dev/docs/concepts/)
- [Keyboard reference](https://herdr.dev/docs/keyboard/)

This repo installs the package in [`../herdr.nix`](../herdr.nix).
