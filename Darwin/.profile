# This file is part of .dotfiles. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/.dotfiles/master/COPYRIGHT. No part of .dotfiles, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
# Copyright © 2014-2015 The developers of .dotfiles. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/.dotfiles/master/COPYRIGHT.


# Generic: Ensure CDPATH is unset
if [ -n "${CDPATH+set}" ]; then
	unset CDPATH
fi

# Generic: Get rid of legacy mail checking
if [ -n "${MAIL+set}" ]; then
	unset MAIL
fi
if [ -n "${MAILCHECK+set}" ]; then
	unset MAILCHECK
fi
if [ -n "${MAILPATH+set}" ]; then
	unset MAILPATH
fi

# Generic: Ensure PATH is set (usually set via getty or PAM)
if [ -z "${PATH+unset}" ]; then
	# Default Mac OS X PATH
	export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
fi

# Generic: Ensure HOME is set (usually set via getty or PAM)
if [ -z "${HOME+unset}" ]; then
	export HOME="$(cd ~; pwd -P)"
fi

# Generic: Don't preserve history on exit
export HISTFILESIZE=0

# Generic: make all shells use bash's default for history size in-memory
export HISTSIZE=500

# Generic: Force history file name to that for bash (by default, the ash shell, eg in BusyBox, uses .ash_history)
export HISTFILE="$HOME"/.bash_history

# Note also that shells are sensitive to PWD and HOSTNAME

# Generic: Setting ENV tells the shell which file to read when starting non-interactively (dash and the BusyBox ash shell will use this post-processing .profile)
if [ -z "${ENV+unset}" ]; then
	# .shinit is an alternative
	export ENV="$HOME"/.shinit
fi

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
