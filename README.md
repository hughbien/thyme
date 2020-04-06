# Thyme

Thyme is a pomodoro timer for tmux.

## Installation

Download the thyme binary and place it in your `$PATH`.

## Usage

Start thyme with:

```
thyme
```

You'll have 25 minutes by default. Other useful commands:

```
thyme       # run again to pause/unpause
thyme -s    # to stop
thyme -r    # repeats timer until manually stopped; default break of 5 minutes
thyme -r10  # repeat timer 10 times
```

## Configuration

Configure via the `~/.thymerc` file:

```toml
timer = 1500           # 25 minutes per pomodoro (in seconds)
timer_break = 300      # 5 minutes per break (in seconds)
warning = 300          # show warning color at 5 minutes left (in seconds), set to 0 to disable
status_align = "left"  # use tmux's left status line instead, defaults to "right"
```

Custom options can be added via the `[options]` section. The example below adds a `-t` option for
opening a todo today file.

```toml
[options]
  [today]
  flag = "-t"
  flag_long = "--today"
  description = "Open TODO today file"
  command = "vim ~/path/to/todo.md"
```

Hooks can be added to run `before`/`after` a pomodoro, `before_break`/`after_break` for breaks,
and `before_all`/`after_all` for the entire session.

```toml
[hooks]
  [after]
  command = "terminal-notifier -message \"Pomodoro finished!\" -title \"Thyme\""

  [after_break]
  command = "terminal-notifier -message \"Break finished!\" -title \"Thyme\""
```

## Development

Use `make` for common tasks:

```
make spec                   # to run all tests
make spec ARGS=path/to/spec # to run a single test
make build                  # to create a release binary in the target directory
make install                # to copy release binary into system bin (uses $INSTALL_BIN)
make clean                  # to remove build artifacts and target directory
make run                    # to run locally
make run ARGS=-h            # to run with local arguments
```

## TODO

* add basic timer
* add Options class to keep track of options
* add reading thymerc file and setting options
* add running as daemon
* add stopping
* add pause/unpause
* add repeating
* add warning (or other way to distinguish normal vs break timer)
* reset tmux status at end of session
* add options extension
* add hooks extension
* determine which option for tmux status setting:
  1. call `tmux set-option ...` directly from thyme process
  2. have tmux poll thyme process
  3. have tmux poll intermediate `~/.thyme-tmux` file
* add tmux status theming
* add notification (terminal-notifier, osascript, growl, or handle via hooks)
* add notification customization, eg custom command/text/title
* options extension, passing arguments to flags
* hooks extension, passing arguments (eg repeat current/total)
* optimize timer, store in single label string

## License

Copyright 2020 Hugh Bien.

Released under BSD License, see LICENSE for details.
