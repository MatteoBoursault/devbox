complete -c sk -l min-query-length -d 'Minimum query length to start showing results' -r
complete -c sk -s t -l tiebreak -d 'Comma-separated list of sort criteria to apply when the scores are tied.' -r -f -a "score\t''
-score\t''
begin\t''
-begin\t''
end\t''
-end\t''
length\t''
-length\t''
index\t''
-index\t''
pathname\t''
-pathname\t''"
complete -c sk -s n -l nth -d 'Fields to be matched' -r
complete -c sk -l with-nth -d 'Fields to be transformed' -r
complete -c sk -l hide-nth -d 'Fields to hide from display while keeping them searchable' -r
complete -c sk -s d -l delimiter -d 'Delimiter between fields' -r
complete -c sk -l algo -d 'Fuzzy matching algorithm' -r -f -a "arinae\t'Arinae: typo-resistant & natural algorithm, default'
clangd\t'Clangd fuzzy matching algorithm'
fzy\t'Fzy matching algorithm (https://github.com/jhawthorn/fzy)'
skim_v2\t'Previous skim fuzzy matching algorithm (v2)'"
complete -c sk -l case -d 'Case sensitivity' -r -f -a "respect\t'Case-sensitive matching'
ignore\t'Case-insensitive matching'
smart\t'Smart case: case-insensitive unless query contains uppercase'"
complete -c sk -l typos -d 'Enable typo-tolerant matching' -r
complete -c sk -l split-match -d 'Enable split matching and set delimiter' -r
complete -c sk -l scheme -r -f -a "default\t'Default scheme, no modifications to the options'
path\t'Path scheme: will find the furthest match in the item and set pathname as the main tiebreak'
history\t'History scheme: will force index as the first tiebreak'"
complete -c sk -s b -l bind -d 'Comma-separated key, event, and action bindings' -r
complete -c sk -s c -l cmd -d 'Command to invoke dynamically in interactive mode' -r
complete -c sk -s I -d 'Replace replstr with the selected item in commands' -r
complete -c sk -l color -d 'Set color theme' -r
complete -c sk -l skip-to-pattern -d 'Show the matched pattern at the line start' -r
complete -c sk -l disable-pattern -d 'Disable items based on this regex pattern' -r
complete -c sk -l layout -d 'Set layout' -r -f -a "default\t'Display from the bottom of the screen'
reverse\t'Display from the top of the screen'
reverse-list\t'Display from the top of the screen, prompt at the bottom'"
complete -c sk -l height -d 'Height of skim\'s window' -r
complete -c sk -l min-height -d 'Minimum height of skim\'s window' -r
complete -c sk -l margin -d 'Screen margin' -r
complete -c sk -s p -l prompt -d 'Set prompt' -r
complete -c sk -l cmd-prompt -d 'Set prompt in command mode' -r
complete -c sk -l selector -d 'Set selected item icon' -r
complete -c sk -l multi-selector -d 'Set multi-selected item icon' -r
complete -c sk -l tabstop -d 'Number of spaces that make up a tab' -r
complete -c sk -l ellipsis -d 'The characters used to display truncated lines' -r
complete -c sk -l info -d 'Set matching result count display position' -r
complete -c sk -l header -d 'Set header, displayed next to the info' -r
complete -c sk -l header-lines -d 'Number of lines of the input treated as header' -r
complete -c sk -l border -d 'Draw borders around the UI components' -r -f -a "force-off\t'ForceOff disables borders around popups too set with no_border'
none\t''
plain\t''
rounded\t''
double\t''
thick\t''
light-double-dashed\t''
heavy-double-dashed\t''
light-triple-dashed\t''
heavy-triple-dashed\t''
light-quadruple-dashed\t''
heavy-quadruple-dashed\t''
quadrant-inside\t''
quadrant-outside\t''"
complete -c sk -l multiline -d 'Split item text into multiple display lines at the given separator character defaults to \\n if read0 is set, and \\\\n if not (matching literal \\n in text)' -r
complete -c sk -l scrollbar -d 'Set scrollbar style for the item list' -r
complete -c sk -l history -d 'History file' -r
complete -c sk -l history-size -d 'Maximum number of query history entries to keep' -r
complete -c sk -l cmd-history -d 'Command history file' -r
complete -c sk -l cmd-history-size -d 'Maximum number of query history entries to keep' -r
complete -c sk -l preview -d 'Preview command' -r
complete -c sk -l preview-window -d 'Preview window layout' -r
complete -c sk -s q -l query -d 'Initial query' -r
complete -c sk -l cmd-query -d 'Initial query in interactive mode' -r
complete -c sk -l output-format -d 'Set the output format If set, overrides all print_ options Will be expanded the same way as preview or commands' -r
complete -c sk -l pre-select-n -d 'Pre-select the first n items in multi-selection mode' -r
complete -c sk -l pre-select-pat -d 'Pre-select the matched items in multi-selection mode' -r
complete -c sk -l pre-select-items -d 'Pre-select the items separated by newline character' -r
complete -c sk -l pre-select-file -d 'Pre-select the items read from this file' -r
complete -c sk -s f -l filter -d 'Query for filter mode' -r
complete -c sk -l shell -d 'Generate shell completion script' -r -f -a "bash\t'Bourne Again SHell'
elvish\t'Elvish shell'
fish\t'Friendly Interactive SHell'
nushell\t'Nushell (nu)'
power-shell\t'PowerShell'
zsh\t'Zsh'"
complete -c sk -l popup -d 'Run in a tmux or zellij popup' -r
complete -c sk -l log-level -d 'Set the log level' -r
complete -c sk -l log-file -d 'Pipe log output to a file' -r
complete -c sk -l flags -d 'Feature flags' -r -f -a "no-preview-pty\t'Disable preview PTY on Linux'
show-score\t'Display the item\'s match score before its value in the item list (for matcher debugging)'
show-index\t'Display the item\'s index before its value in the item list'
single-reader\t'Limit the reader thread pool to a single thread'
single-matcher\t'Limit the matcher thread pool to a single thread'"
complete -c sk -l hscroll-off -r
complete -c sk -l jump-labels -r
complete -c sk -l tail -r
complete -c sk -l style -r
complete -c sk -l padding -r
complete -c sk -l border-label -r
complete -c sk -l border-label-pos -r
complete -c sk -l wrap-sign -r
complete -c sk -l gap -r
complete -c sk -l gap-line -r
complete -c sk -l freeze-left -r
complete -c sk -l freeze-right -r
complete -c sk -l scroll-off -r
complete -c sk -l gutter -r
complete -c sk -l gutter-raw -r
complete -c sk -l marker-multi-line -r
complete -c sk -l list-border -r
complete -c sk -l list-label -r
complete -c sk -l list-label-pos -r
complete -c sk -l info-command -r
complete -c sk -l separator -r
complete -c sk -l ghost -r
complete -c sk -l input-border -r
complete -c sk -l input-label -r
complete -c sk -l input-label-pos -r
complete -c sk -l preview-label -r
complete -c sk -l preview-label-pos -r
complete -c sk -l header-border -r
complete -c sk -l header-lines-border -r
complete -c sk -l footer -r
complete -c sk -l footer-border -r
complete -c sk -l footer-label -r
complete -c sk -l footer-label-pos -r
complete -c sk -l with-shell -r
complete -c sk -l expect -d 'Deprecated, kept for compatibility purposes. See accept() bind instead' -r
complete -c sk -l tac -d 'Show results in reverse order'
complete -c sk -l no-sort -d 'Do not sort the results'
complete -c sk -s e -l exact -d 'Run in exact mode'
complete -c sk -l regex -d 'Start in regex mode instead of fuzzy-match'
complete -c sk -l no-typos -d 'Disable typo-tolerant matching'
complete -c sk -l normalize -d 'Normalize unicode characters'
complete -c sk -l last-match -d 'Highlight the last match found, not the first one This makes tiebreak more pertinent on path items where we want to prioritize a match on the last parts'
complete -c sk -s m -l multi -d 'Enable multiple selection'
complete -c sk -l no-multi -d 'Disable multiple selection'
complete -c sk -l no-mouse -d 'Disable mouse'
complete -c sk -s i -l interactive -d 'Start skim in interactive mode'
complete -c sk -l highlight-line -d 'Highlight the entire current line, not just the text'
complete -c sk -l no-hscroll -d 'Disable horizontal scroll'
complete -c sk -l keep-right -d 'Keep the right end of the line visible on overflow'
complete -c sk -l no-clear-if-empty -d 'Do not clear previous line if the command returns an empty result'
complete -c sk -l no-clear-start -d 'Do not clear items on start'
complete -c sk -l no-clear -d 'Do not clear screen on exit'
complete -c sk -l show-cmd-error -d 'Show error message if command fails'
complete -c sk -l cycle -d 'Cycle the results by wrapping around when scrolling'
complete -c sk -l disabled -d 'Disable matching entirely'
complete -c sk -l reverse -d 'Shorthand for reverse layout'
complete -c sk -l no-height -d 'Disable height (force full screen)'
complete -c sk -l ansi -d 'Parse ANSI color codes in input strings'
complete -c sk -l no-info -d 'Alias for --info=hidden'
complete -c sk -l inline-info -d 'Alias for --info=inline'
complete -c sk -l border-no-collapse -d 'Do not collapse adjacent borders into a shared row or column'
complete -c sk -l no-border -d 'Disables all borders, including in tmux/zellij popups'
complete -c sk -l wrap -d 'Wrap items in the item list'
complete -c sk -l no-scrollbar -d 'Disable the scrollbar in the item list'
complete -c sk -l read0 -d 'Read input delimited by ASCII NUL(\\0) characters'
complete -c sk -l print0 -d 'Print output delimited by ASCII NUL(\\0) characters'
complete -c sk -l print-query -d 'Print the query as the first line'
complete -c sk -l print-cmd -d 'Print the command as the first line (after print-query)'
complete -c sk -l print-score -d 'Print the score after each item'
complete -c sk -l print-header -d 'Print the header as the first line (after print-score)'
complete -c sk -l print-current -d 'Print the current (highlighted) item as the first line (after print-header)'
complete -c sk -l no-strip-ansi -d 'Print the ANSI codes, making the output exactly match the input even when --ansi is on'
complete -c sk -s 1 -l select-1 -d 'Do not enter the TUI if the query passed in -q matches only one item and return it'
complete -c sk -s 0 -l exit-0 -d 'Do not enter the TUI if the query passed in -q does not match any item'
complete -c sk -l sync -d 'Synchronous search for multi-staged filtering'
complete -c sk -l shell-bindings -d 'Generate shell key bindings - only for bash, zsh and fish'
complete -c sk -l man -d 'Generate man page and output it to stdout'
complete -c sk -s x -l extended
complete -c sk -l literal
complete -c sk -l filepath-word
complete -c sk -l no-bold
complete -c sk -l phony
complete -c sk -l no-color
complete -c sk -l no-multi-line
complete -c sk -l raw
complete -c sk -l track
complete -c sk -l no-input
complete -c sk -l no-separator
complete -c sk -l header-first
complete -c sk -s h -l help -d 'Print help (see more with \'--help\')'
complete -c sk -s V -l version -d 'Print version'
#!/bin/fish
# skim key bindings for fish
#
# - $SKIM_TMUX_OPTS
# - $SKIM_CTRL_T_COMMAND
# - $SKIM_CTRL_T_OPTS
# - $SKIM_CTRL_R_OPTS
# - $SKIM_ALT_C_COMMAND
# - $SKIM_ALT_C_OPTS
# - $SKIM_COMPLETION_TRIGGER (default: '**')
# - $SKIM_COMPLETION_OPTS    (default: empty)

# Key bindings
# ------------
# Store current token in $dir as root for the 'find' command
function skim-file-widget -d "List files and folders"
  set -l commandline (__skim_parse_commandline)
  set -l dir $commandline[1]
  set -l skim_query $commandline[2]

  # "-path \$dir'*/\\.*'" matches hidden files/folders inside $dir but not
  # $dir itself, even if hidden.
  test -n "$SKIM_CTRL_T_COMMAND"; or set -l SKIM_CTRL_T_COMMAND "
  command find -L \$dir -mindepth 1 \\( -path \$dir'*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' \\) -prune \
  -o -type f -print \
  -o -type d -print \
  -o -type l -print 2> /dev/null | sed 's@^\./@@'"

  begin
    set -lx SKIM_DEFAULT_OPTIONS "--reverse $SKIM_DEFAULT_OPTIONS $SKIM_CTRL_T_OPTS"
    eval "$SKIM_CTRL_T_COMMAND | "(__skimcmd)' -m --query "'$skim_query'"' | while read -l r; set result $result $r; end
  end
  if [ -z "$result" ]
    commandline -f repaint
    return
  else
    # Remove last token from commandline.
    commandline -t ""
  end
  for i in $result
    commandline -it -- (string escape $i)
    commandline -it -- ' '
  end
  commandline -f repaint
end

function skim-history-widget -d "Show command history"
  begin
    set -lx SKIM_DEFAULT_OPTIONS "$SKIM_DEFAULT_OPTIONS --bind=ctrl-r:toggle-sort $SKIM_CTRL_R_OPTS --no-multi"

    set -l FISH_MAJOR (echo $version | cut -f1 -d.)
    set -l FISH_MINOR (echo $version | cut -f2 -d.)

    # history's -z flag is needed for multi-line support.
    # history's -z flag was added in fish 2.4.0, so don't use it for versions
    # before 2.4.0.
    if [ "$FISH_MAJOR" -gt 2 -o \( "$FISH_MAJOR" -eq 2 -a "$FISH_MINOR" -ge 4 \) ];
      history -z | eval (__skimcmd) --read0 --multiline --print0 -q '(commandline)' | read -lz result
      and commandline -- $result
    else
      history | eval (__skimcmd) -q '(commandline)' | read -l result
      and commandline -- $result
    end
  end
  commandline -f repaint
end

function skim-cd-widget -d "Change directory"
  set -l commandline (__skim_parse_commandline)
  set -l dir $commandline[1]
  set -l skim_query $commandline[2]

  test -n "$SKIM_ALT_C_COMMAND"; or set -l SKIM_ALT_C_COMMAND "
  command find -L \$dir -mindepth 1 \\( -path \$dir'*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' \\) -prune \
  -o -type d -print 2> /dev/null | sed 's@^\./@@'"
  begin
    set -lx SKIM_DEFAULT_OPTIONS "--reverse $SKIM_DEFAULT_OPTIONS $SKIM_ALT_C_OPTS"
    eval "$SKIM_ALT_C_COMMAND | "(__skimcmd)' --no-multi --query "'$skim_query'"' | read -l result

    if [ -n "$result" ]
      cd $result

      # Remove last token from commandline.
      commandline -t ""
    end
  end

  commandline -f repaint
end

function __skimcmd
  test -n "$SKIM_TMUX"; or set SKIM_TMUX 0
  test -n "$SKIM_TMUX_HEIGHT"; or set SKIM_TMUX_HEIGHT 40%
  if [ -n "$SKIM_TMUX_OPTS" ]
    echo "sk --tmux=$SKIM_TMUX_OPTS "
  else if [ $SKIM_TMUX -eq 1 ]
    echo "sk --tmux=center,$SKIM_TMUX_HEIGHT"
  else
    echo "sk"
  end
end

function __skim_parse_commandline -d 'Parse the current command line token and return split of existing filepath and rest of token'
  # eval is used to do shell expansion on paths
  set -l commandline (eval "printf '%s' "(commandline -t))

  if [ -z $commandline ]
    # Default to current directory with no --query
    set dir '.'
    set skim_query ''
  else
    set dir (__skim_get_dir $commandline)

    if [ "$dir" = "." -a (string sub -l 1 -- $commandline) != '.' ]
      # if $dir is "." but commandline is not a relative path, this means no file path found
      set skim_query $commandline
    else
      # Also remove trailing slash after dir, to "split" input properly
      set skim_query (string replace -r "^$dir/?" -- '' "$commandline")
    end
  end

  echo $dir
  echo $skim_query
end

function __skim_get_dir -d 'Find the longest existing filepath from input string'
  set dir $argv

  # Strip all trailing slashes. Ignore if $dir is root dir (/)
  if [ (string length -- $dir) -gt 1 ]
    set dir (string replace -r '/*$' -- '' $dir)
  end

  # Iteratively check if dir exists and strip tail end of path
  while [ ! -d "$dir" ]
    # If path is absolute, this can keep going until ends up at /
    # If path is relative, this can keep going until entire input is consumed, dirname returns "."
    set dir (dirname -- "$dir")
  end

  echo $dir
end
