# This file is part of .dotfiles. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/.dotfiles/master/COPYRIGHT. No part of .dotfiles, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
# Copyright © 2014-2015 The developers of .dotfiles. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/.dotfiles/master/COPYRIGHT.


# The GNU Bash Reference Manual version 4.1: Bash Startup Files (http://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html) says:-
# "looks for ~/.bash_profile, ~/.bash_login, and ~/.profile, in that order, and reads and executes commands from the first one that exists and is readable."
# Hence we source ~/.bash_login if it exists (and assume it sources ~/.profile), otherwise we then source ~/.profile, and then apply bash-specific logic (if any) *after* sourcing it
if [ -f ~/.bash_login -a -r ~/.bash_login -a  -s ~/.bash_login ]; then
	. ~/.bash_login
elif [ -f ~/.profile -a -r ~/.profile -a  -s ~/.profile ]; then
	. ~/.profile
fi

# Setting BASH_ENV tells bash which file to read when starting non-interactively

# A reasonable explanation of why we do this: http://mywiki.wooledge.org/DotFiles
# In essence, .bash_profile/.bash_login/.profile executes only for an interactive login shell, which can be thought of as the super parent of all subsequent interactive shells
# .bashrc executes per interactive child shell, and so should NEVER use 'export VARIABLE' syntax; it should be restricted to aliases, functions, etc
if [ -f ~/.bashrc -a -r ~/.bashrc -a  -s ~/.bashrc ]; then
	. ~/.bashrc
fi
