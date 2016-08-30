# This file is part of .dotfiles. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/.dotfiles/master/COPYRIGHT. No part of .dotfiles, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
# Copyright © 2014-2015 The developers of .dotfiles. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/.dotfiles/master/COPYRIGHT.


# Security: Ensure CDPATH is unset
if [ -n "${CDPATH+set}" ]; then
	unset CDPATH
fi

# Essential: Ensure HOME is set (usually set via getty or PAM or login)
if [ -z "${HOME+unset}" ]; then
	export HOME="$(cd ~; pwd -P)"
fi

# Essential: Ensure PATH is set (usually set via getty or PAM; we want to control it here)
# Default Mac OS X PATH is /usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin (We do not use /etc/paths and /etc/paths.d)
# We want to make it include homebrew's sbin and rustup's / multirusts's cargo bin
export PATH="$HOME"/.cargo/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin

# Security: Run a logout script (bash shells will also run .bash_logout; this happens before .sh_logout)
trap '. ~/.sh_logout' EXIT

# Permissions: Ensure new files created by users are unreadable, unwritable and unexecutable by either group or others
umask 0077

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

# Security: Make less more 'secure' (eg unable to edit or launch shell commands)
export LESSSECURE=1

# History: Ensure FCEDIT is unset (important for ksh88, pdksh, yash)
if [ -n "${FCEDIT+set}" ]; then
	unset FCEDIT
fi

# History: Don't preserve history on exit
export HISTFILESIZE=0

# History: make all shells use bash's default for history size in-memory
export HISTSIZE=500

# History: disable for less
export LESSHISTSIZE=0

# History: Force history file name to be a blackhole; unsetting it makes shells uses their default:-
# - bash uses .bash_history
# - ash derivatives (dash, BusyBox ash) use .ash_history
# - ksh88 (at least on Solaris) uses .sh_history
# - MySQL, although not a shell, also creates a potentially dangerous .mysql_history file
# - Likewise, PostgreSQL
# - Likewise, less
for _local_historyFile in .bash_history .ash_history .sh_history .mysql_history .psql_history .lesshst
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
export MYSQL_HISTFILE=/dev/null
export LESSHISTFILE=/dev/null

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

# Editor: Use textmate (fallback to vim, vi or nano); absolute path so always works even if we later much with PATH
if command -v mate 1>/dev/null 2>/dev/null; then
	export EDITOR="$(command -v mate) --wait"
elif command -v vim 1>/dev/null 2>/dev/null; then
	export EDITOR="$(command -v vim)"
elif command -v vi 1>/dev/null 2>/dev/null; then
	export EDITOR="$(command -v vi)"
elif command -v nano 1>/dev/null 2>/dev/null; then
	export EDITOR="$(command -v nano)"
elif command -v ed 1>/dev/null 2>/dev/null; then
	export EDITOR="$(command -v ed)"
fi
export VISUAL="$EDITOR"

# Homebrew: analytics opt-out (These guys are very naive)
if [ -z "${HOMEBREW_NO_ANALYTICS+unset}" ]; then
	export HOMEBREW_NO_ANALYTICS=1
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

# Rust: Required to build bindgen on Mac OS X
if [ -z "${DYLD_LIBRARY_PATH+unset}" ]; then
	export DYLD_LIBRARY_PATH='/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib'
else

	_local_IFS="$IFS"
	IFS=:
	_local_needsPathFragment=true
	for _local_pathFragment in $DYLD_LIBRARY_PATH
	do
		if [ "$_local_pathFragment" = '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib' ]; then
			_local_needsPathFragment=false
			break
		fi
	done
	IFS="$_local_IFS"
	if $_local_needsPathFragment; then
		export DYLD_LIBRARY_PATH='/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib':"$DYLD_LIBRARY_PATH"
	fi
	unset _local_pathFragment
	unset _local_needsPathFragment
	unset _local_IFS
fi

# Android on Mac OS X
if [ -z "${ANDROID_HOME+unset}" ]; then
	if [ -d /usr/local/opt/android-sdk ]; then
		export ANDROID_HOME=/usr/local/opt/android-sdk
	fi
fi
