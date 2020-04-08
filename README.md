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
timer = 1500               # 25 minutes per pomodoro (in seconds)
timer_break = 300          # 5 minutes per break (in seconds)
timer_warning = 300        # show warning color at 5 minutes left (in seconds)
repeat = 4                 # set default for -r flag, otherwise repeat indefinitely
color_default = "default"  # set default timer color for tmux
color_warning = "red"      # set warning color for tmux, set to "default" to disable
color_break = "default"    # set break color for tmux
status_align = "left"      # use tmux's left status line instead, defaults to "right"
```

If you prefer to set the status yourself (or need to combine it with other statuses), you can have
thyme write the timer to a file instead:

```toml
status_file = "/path/to/thyme-status"
```

Then set tmux to read from it:

```
set -g status-right '#(cat /path/to/thyme-status)'
```

Custom options can be added via the `[options.*]` group. The example below adds a `-t` option for
opening a todo today file.

```toml
[options.today]
flag = "-t"
flag_long = "--today"
description = "Open TODO today file"
command = "vim ~/path/to/todo.md"

[options.hello]
flag = "-H"
flag_long = "--hello name"
description = "Say hello!"
command = "echo \"Hello #{flag}! #{args}.\"" # eg `thyme -H John "How are you?"`
```

The following placeholders are available for options:

* `#{flag}` - the argument passed to your flag
* `#{args}` - any additional arguments passed to the thyme binary

Custom hooks can be added via the `[hooks.*]` group. Valid events are: `before`/`after` a pomodoro, `before_break`/`after_break` for breaks, and `before_all`/`after_all` for the entire session.

```toml
[hooks.notify]
events = ["after"]
command = "terminal-notifier -message \"Pomodoro finished #{repeat_suffix}\" -title \"thyme\""

[hooks.notify_break]
events = ["after_break"]
command = "terminal-notifier -message \"Break finished #{repeat_suffix}\" -title \"thyme\""
```

The following placeholders are available for hooks:

* `#{repeat_index}` - current repeat index
* `#{repeat_total}` - total repeat count for this session
* `#{repeat_suffix}` - if repeating is on, will return `(index/total)` eg `(3/5)`. Otherwise empty string.

## Development

Use `make` for common tasks:

```
make spec                    # to run all tests
make spec ARGS=path/to/spec  # to run a single test
make build                   # to create a release binary in the target directory
make install                 # to copy release binary into system bin (uses $INSTALL_BIN)
make clean                   # to remove build artifacts and target directory
make run                     # to run locally
make run ARGS=-h             # to run with local arguments
```

## TODO

* handle `status_file` configs
* reset tmux status at end of session
* optimize timer label, store in single update-able string

## License

Copyright 2020 Hugh Bien.

Released under BSD License, see LICENSE for details.
