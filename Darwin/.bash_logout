# This file is part of .dotfiles. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/.dotfiles/master/COPYRIGHT. No part of .dotfiles, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
# Copyright © 2014-2015 The developers of .dotfiles. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/.dotfiles/master/COPYRIGHT.


# This file is executed when an interactive login bash shell exits
if command -v clear 1>/dev/null 2>/dev/null; then
	clear 2>/dev/null || true
elif [ -x /usr/bin/clear ]; then
	clear 2>/dev/null || true
fi

# Generic: Force history file name to that for bash
export HISTFILE="$HOME"/.bash_history

# Generic: Don't preserve history
export HISTFILESIZE=0
