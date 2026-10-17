#!/bin/bash
# Puts your edits live on laasyaraagyni.com.
#
# Double-click this file in Finder (or run ./Publish.command in a terminal).
# It checks your changes, saves them to GitHub, and GitHub rebuilds the site.

cd "$(dirname "$0")" || exit 1

# Every commit made from here is credited to the laasya-14 GitHub account,
# whatever this computer's own Git settings say.
git config user.name "laasya-14"
git config user.email "laasya-14@users.noreply.github.com"

finish() {
  echo
  read -r -p "Press Enter to close this window. "
  close_window "$1"
}

close_window() {
  # Close this script's own Terminal window (found by its tty, so other windows
  # are left alone), and quit Terminal if that was the only one. Runs in the
  # background, a moment after this script has exited, so Terminal doesn't ask
  # "terminate running process?".
  if [ "$TERM_PROGRAM" = "Apple_Terminal" ]; then
    (sleep 0.5; osascript \
      -e 'tell application "Terminal"' \
      -e "  if (count windows) is 1 then" \
      -e "    quit" \
      -e "  else" \
      -e "    close (every window whose tty of selected tab is \"$(tty)\")" \
      -e "  end if" \
      -e 'end tell' >/dev/null 2>&1 &)
  fi
  exit "$1"
}

echo "== Publishing laasyaraagyni.com"
echo

git fetch -q origin 2>/dev/null
edited=$(git status --porcelain)
unsent=$(git log --oneline '@{u}..HEAD' 2>/dev/null)

if [ -z "$edited" ] && [ -z "$unsent" ]; then
  echo "Nothing has changed since the last publish. Save your file first?"
  finish 0
fi

if [ -n "$edited" ]; then
  echo "Changed files:"
  git status --short | sed 's/^/  /'
  echo
fi

if [ -n "$unsent" ]; then
  echo "Saved earlier but not yet published:"
  echo "$unsent" | sed 's/^[0-9a-f]* /  /'
  echo
fi

# If Node is installed, build the site here first so a mistake (like a book
# with no author) is caught now, with a clear message, instead of on GitHub.
if command -v npm >/dev/null 2>&1; then
  echo "Checking the site builds..."
  [ -d node_modules ] || npm install --silent
  if ! npm run build --silent >/tmp/laasya-publish.log 2>&1; then
    echo
    echo "Something in your edits needs fixing. Nothing was published."
    echo "Here's what the builder said:"
    echo
    grep -vE '^\s+at |node_modules' /tmp/laasya-publish.log | tail -20
    finish 1
  fi
  echo "Looks good."
  echo
fi

if [ -n "$edited" ]; then
  # The commit message is the line of history GitHub shows for this change.
  # Type your own, or press Enter to use one built from the file names.
  changed=$(git status --porcelain | awk '{print $NF}' | xargs -n1 basename | sort -u | paste -sd, - | sed 's/,/, /g')
  default="Update ${changed}"
  echo "Describe this change in a few words (for the site's history),"
  read -r -p "or just press Enter to use \"${default}\": " message
  echo
  git add -A && git commit -q -m "${message:-$default}" || finish 1
fi

if ! { git pull -q --rebase && git push -q; }; then
  echo
  echo "Couldn't send the changes to GitHub (see the message above)."
  finish 1
fi

echo "Published. The site updates in about a minute or two."
echo
echo "Press Enter to close this window,"
read -r -p "or type w then Enter to also watch the update in your browser: " watch
[[ "$watch" == [wW]* ]] && open "https://github.com/laasya-14/laasyaraagyni.com/actions"
close_window 0
