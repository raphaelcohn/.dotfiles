# This file is part of .dotfiles. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/.dotfiles/master/COPYRIGHT. No part of .dotfiles, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
# Copyright © 2014-2015 The developers of .dotfiles. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/.dotfiles/master/COPYRIGHT.


# bash only reads .bashrc if the shell is both interactive and non-login
# This is is different to most other shells, like, say, zsh, which reads .zshrc for all interactive shells, login or not
# Hence we source .bashrc from .bash_profile
# We should be sensitive to being re-read (re-sourced)

# This file is read if using a login interactive SSH session.
# However, it may or may not be read otherwise when using ssh: "Bash has a special compile time option that will cause it to source the .bashrc file on non-login, non-interactive ssh sessions. This feature is only enabled by certain OS vendors (mostly Linux distributions). It is not enabled in a default upstream Bash build, and (empirically) not on OpenBSD either." (from http://mywiki.wooledge.org/DotFiles)
case "$-" in
	
	*i*)
		# Non-login, Interactive shell (bash builtin behaviour)
		# Login, Interactive shell (sourced via .bash_profile)
		
		# History: Suppress duplicates
		# History: Suppress the history command
		# History: Suppress the exit command (prevents accidents)
		HISTIGNORE="&:history:exit"
	;;
	
	*)
		# Non-login, Non-interactive shell (sshd, bash stdin to socket detection, etc)
		:
	;;
	
esac
