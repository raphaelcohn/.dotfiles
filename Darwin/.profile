# This file is part of .dotfiles. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/.dotfiles/master/COPYRIGHT. No part of .dotfiles, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
# Copyright © 2014-2015 The developers of .dotfiles. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/.dotfiles/master/COPYRIGHT.



# Essential: Ensure PATH is set (usually set via getty or PAM)
if [ -z "${PATH+unset}" ]; then
	# Default Mac OS X PATH
	export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
fi

# Essential: Ensure HOME is set (usually set via getty or PAM or login)
if [ -z "${HOME+unset}" ]; then
	export HOME="$(cd ~; pwd -P)"
fi

# Security: Run a logout script (bash shells will also run .bash_logout; this happens before .sh_logout)
trap '. ~/.sh_logout' EXIT

# Security: Ensure CDPATH is unset
if [ -n "${CDPATH+set}" ]; then
	unset CDPATH
fi

# Permissions: Ensure new files created by users are, say, 0600 rather than 0644
umask 022

# Permissions: Make sure ~/.netrc is locked down
# Consider making this file owned by root but readable by the user
if [ -f ~/.netrc ]; then
	chmod 0400 ~/.netrc || true
fi

# Permissions/SSH: Make sure ~/.ssh is locked down
# See https://en.wikibooks.org/wiki/OpenSSH/Client_Configuration_Files for details
# Consider making these files owned by root but readable by the user
if [ -d ~/.ssh ]; then
	chmod 0700 ~/.ssh || true
	
	# config and known_hosts are considered 'client-side'; everything else is considered 'server-side'
	
	for _local_sshConfigFile in authorized_keys authorized_principals config environment rc known_hosts identity identity.pub id_dsa id_dsa.pub id_rsa id_rsa.pub id_ecdsa id_ecdsa.pub id_ed25519 id_ed25519.pub
	do
		if [ -f ~/.ssh/"$_local_sshConfigFile" ]; then
			chmod 0400 ~/.ssh/"$_local_sshConfigFile" || true
		fi
	done
	unset _local_sshConfigFile
	
	if [ -f ~/.ssh/known_hosts ]; then
		chmod 0600 ~/.ssh/known_hosts || true
	fi
fi

# ? TODO: Make sure legacy .ssh/identity and .ssh/identity.pub are useless

# Security/SSH: Make sure legacy .rhosts and .shosts are useless
# Consider making these files owned by root but readable by the user
for _local_legacyFile in .rhosts .shosts
do
	if [ ! -e ~/"$_local_legacyFile" ]; then
		continue
	fi
	
	if [ -c ~/"$_local_legacyFile" ]; then
		continue
	fi
	
	ln -sf /dev/null ~/"$_local_legacyFile" || true
done
unset _local_legacyFile

# Mail: Get rid of legacy mail checking
if [ -n "${MAIL+set}" ]; then
	unset MAIL
fi
if [ -n "${MAILCHECK+set}" ]; then
	unset MAILCHECK
fi
if [ -n "${MAILPATH+set}" ]; then
	unset MAILPATH
fi


# History: Ensure FCEDIT is unset (important for ksh88, pdksh, yash)
if [ -n "${FCEDIT+set}" ]; then
	unset FCEDIT
fi

# History: Don't preserve history on exit
export HISTFILESIZE=0

# History: make all shells use bash's default for history size in-memory
export HISTSIZE=500

# History: Force history file name to be a blackhole; unsetting it makes shells uses their default:-
# - bash uses .bash_history
# - ash derivatives (dash, BusyBox ash) use .ash_history
# - ksh88 (at least on Solaris) uses .sh_history
# - MySQL, although not a shell, also creates a potentially dangerous .mysql_history file
# - Likewise, PostgreSQL
for _local_historyFile in .bash_history .ash_history .sh_history .mysql_history .psql_history
do
	if [ ! -e ~/"$_local_historyFile" ]; then
		continue
	fi
	
	if [ -c ~/"$_local_historyFile" ]; then
		continue
	fi
	
	ln -sf /dev/null ~/"$_local_historyFile" || true
done
unset _local_historyFile
export HISTFILE=/dev/null

# Locale: Make it sane; US is possibly preferable
export LC_ALL=en_GB.UTF-8
export LC_COLLATE=en_GB.UTF-8
export LC_CTYPE=en_GB.UTF-8
export LC_MESSAGES=en_GB.UTF-8
export LC_MONETARY=en_GB.UTF-8
export LC_NUMERIC=en_GB.UTF-8
export LC_TIME=en_GB.UTF-8
export LANG=en_GB.UTF-8

# Note also that shells are sensitive to PWD and HOSTNAME

# Generic: Setting ENV tells the shell which file to read when starting non-interactively (dash and the BusyBox ash shell will use this post-processing .profile)
if [ -z "${ENV+unset}" ]; then
	# .shinit is an alternative
	export ENV="$HOME"/.shinit
fi

# Generic: TMOUT

# Generic:ksh
# Cares about FCEDIT, FPATH, NLSPATH, VISUAL

# Generic:COLUMNS/LINES
# Can we set this to a maximum?

# Generic/Git: Use textmate (fallback to vim, vi or nano); absolute path so always works even if we later much with PATH
if command -v mate 1>/dev/null 2>/dev/null; then
	export EDITOR="$(command -v mate) --wait"
elif command -v vim 1>/dev/null 2>/dev/null; then
	export EDITOR="$(command -v vim)"
elif command -v vi 1>/dev/null 2>/dev/null; then
	export EDITOR="$(command -v vi)"
elif command -v nano 1>/dev/null 2>/dev/null; then
	export EDITOR="$(command -v nano)"
fi

# Rust: rustup / multirust support
if [ -d "$HOME"/.cargo/bin ]; then
	export PATH="$HOME"/.cargo/bin:"$PATH"
fi

# Rust: Required to build bindgen on Mac OS X
if [ -z "${DYLD_LIBRARY_PATH+unset}" ]; then
	export DYLD_LIBRARY_PATH=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib
else
	export DYLD_LIBRARY_PATH=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib:"$DYLD_LIBRARY_PATH"
fi

# Android on Mac OS X
if [ -z "${ANDROID_HOME+unset}" ]; then
	if [ -d /usr/local/opt/android-sdk ]; then
		export ANDROID_HOME=/usr/local/opt/android-sdk
	fi
fi

# Homebrew: analytics opt-out (These guys are very naive)
if [ -z "${HOMEBREW_NO_ANALYTICS+unset}" ]; then
	export HOMEBREW_NO_ANALYTICS=1
fi

# Homebrew: sbin support (bin is included by OS X by default)
if [ -d /usr/local/sbin ]; then
	export PATH=/usr/local/sbin:"$PATH"
fi

# Homebrew: bash-completions package
if command -v brew 1>/dev/null 2>/dev/null; then
	_local_bashCompletions="$(brew --prefix)"/etc/bash_completion
	if [ -f "$_local_bashCompletions" ]; then
		. "$_local_bashCompletions"
	fi
	unset _local_bashCompletions
fi

# Homebrew: CPAN integration (uses ~/perl5 for cpan -i MODULE)
# Requires cpan -i to have been run once (subsequent runs fail otherwise)
# cpan is probably preferable
if command -v brew 1>/dev/null 2>/dev/null; then
	if command -v perl 1>/dev/null 2>/dev/null; then
		if [ -d ~/perl5 ]; then
			eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)
		fi
	fi
fi

# perlbrew (not part of homebrew)
# if [ -s ~/perl5/perlbrew/etc/bashrc ]; then
# 	. ~/perl5/perlbrew/etc/bashrc
# fi


# Homebrew openssh package
# Modify /System/Library/LaunchAgents/org.openbsd.ssh-agent.plist, change path of ssh-agent to that in /usr/local/bin
# Then launchctl unload <path>; launchctl load path
# eval $(ssh-agent)
# cleanup()
# {
# echo "Killing ssh-agent"
# kill -9 "$SSH_AGENT_PID"
# }
# trap cleanup EXIT

# Homebrew gpg-agent package
#  --enable-ssh-support removed, and from gpg-agent.conf, too.
# if command -V gpg-agent 1>/dev/null; then
#
# 	if command -V tty 1>/dev/null; then
# 		export GPG_TTY="$(tty)"
# 	fi
#
# 	if [ -s ~/.gpg-agent-info ]; then
#
# 		unset GPG_AGENT_INFO
# 		unset SSH_AUTH_SOCK
# 		unset SSH_AGENT_PID
# 		. ~/.gpg-agent-info
#
# 		IFS=':' read -r _local_socketPath _local_pid _local_instanceCount <<<"$GPG_AGENT_INFO"
#
# 		# gpg-agent not running, clean up and start
# 		if ! kill -0 "$_local_pid" 2>/dev/null; then
# 			rm -f ~/.gpg-agent-info
# 			rm -rf "${_local_socketPath%/*}"
# 			rm -rf "${SSH_AUTH_SOCK%/*}"
# 			gpg-agent --quiet --daemon --sh --write-env-file ~/.gpg-agent-info 1>/dev/null
# 			. ~/.gpg-agent-info
# 		fi
#
# 		unset _local_socketPath
# 		unset _local_pid
# 		unset _local_instanceCount
#
# 		export GPG_AGENT_INFO
# 		export SSH_AUTH_SOCK
# 		export SSH_AGENT_PID
# 	else
# 		gpg-agent --quiet --daemon --sh --write-env-file ~/.gpg-agent-info 1>/dev/null
# 		. ~/.gpg-agent-info
#
# 		export GPG_AGENT_INFO
# 		export SSH_AUTH_SOCK
# 		export SSH_AGENT_PID
# 	fi
# elif [ -f ~/.gpg-agent-info ]; then
# 	rm -f ~/.gpg-agent-info
# fi
