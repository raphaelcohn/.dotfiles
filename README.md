# .dotfiles

This provides a sane set of `.` files suitable for Mac OS X and, as required, other platforms. The various files, when sourced, are intended to be idempotent but not re-entrant (eg sourcing .bashrc from .bashrc won't work).


## Installing

At the terminal, type:-

```bash
cd ~
git clone https://github.com/raphaelcohn/.dotfiles.git
.dotfiles/install
```

Changes will take effect as soon new login and interactive shells are launched. For consistency, you should restart all shells; logging out and in again (or restarting) is a good way to do this.


## Other files for consideration

* `~/.pam_environment`
* `~/.inputrc`
* `~/.xsession`
