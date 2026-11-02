# Building your own Shell Proxy bastion

The bastion is a small Alpine container running OpenSSH, Mosh and
`shell-proxy-ctl`. Machines behind NAT keep a reverse tunnel open to it with
`shell-proxy-agent`; the Shell Proxy app (or `ssh`) then jumps to them by name.

The files here are generic: nothing in them is specific to any one deployment.

| File | Purpose |
|---|---|
| `Dockerfile` | Builds the image; downloads `shell-proxy-ctl` from a release |
| `entrypoint.sh` | Creates host keys, runs the `shell-proxy-ctl serve` daemon, execs `sshd` |
| `sshd_config` | `sshd` on port 2222, key-only, with keepalives tuned for presence tracking |
| `install-agent.sh` | Installs `shell-proxy-agent` on a Mac or Linux machine |

## 1. Build and run the bastion

```sh
docker build --build-arg VERSION=0.11.7 -t shell-proxy-bastion bastion/
docker run -d --name shell-proxy-bastion -p 2222:2222 \
  -v shell-proxy-config:/config shell-proxy-bastion
```

`VERSION` is a release tag without the `v`. Use `--platform` with `buildx` for
amd64 or arm64. The account that sshd sessions run as defaults to
`shellproxy`; change it with `--build-arg SHELL_PROXY_USER=<name>`.

The `/config` volume holds the SSH host keys (generated on first start) and
`authorized_keys`. Keep it, or clients will see a changed host key.

Put your own login key in `/config/.ssh/authorized_keys` (an unrestricted key
can run `shell-proxy-ctl list` and `connect`). Port 2222 needs to be reachable
from wherever your clients are, for example by forwarding it on your router.

## 2. Expose a machine through it

On each machine to reach (its own `sshd` must be running on port 22):

```sh
curl -fsSL https://github.com/tpmullan/shell-proxy/raw/main/bastion/install-agent.sh | sh
shell-proxy-agent run --bastion shellproxy@bastion.example.com --bastion-port 2222
```

The agent registers under `hostname -s` and your `$USER` (`--name` and `--user`
override) and reconnects if the tunnel drops. It prints `tunnel up.` when ready.
Check from the bastion with `shell-proxy-ctl list`.

For a dedicated restricted key instead of your personal one, run
`shell-proxy-agent bootstrap` with the same `--bastion` flags first. It adds a
line to the bastion's `authorized_keys` that permits only the tunnel.

The agent's defaults point at the author's own bastion, so always pass
`--bastion user@host` (and `--bastion-port` if you don't use 2222).

## 3. Jump from a client

```sh
shell-proxy-agent ssh-config --user <login-on-target> \
  --bastion shellproxy@bastion.example.com --suffix tun.example.com >> ~/.ssh/config
ssh <name>.tun.example.com
```

The suffix is only a local naming convention in your ssh config; it does not
need to exist in DNS.

## Notes

- **Mosh through the tunnel:** Mosh can't ride an SSH reverse tunnel, so a Mosh
  session goes client to bastion, and the bastion makes an SSH hop to the
  target. That hop is encrypted separately and the bastion terminates the Mosh
  side.
- **Upgrade order:** when the agent starts sending something new, rebuild the
  bastion first; an older `shell-proxy-ctl` rejects arguments it doesn't know.
- This bundle has not been run end to end from a clean checkout. If a step
  doesn't work, please open an issue.
