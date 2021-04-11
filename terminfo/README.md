MyTerminal Linux support
========================

MyTerminal has its own character encoding, its own control codes, its own way
of doing things.

Most commands expect an ANSI-compatible terminal with UTF-8 character encoding.

MyTerminal has been designed to be implemented on small FPGA and for small
systems. ANSI code sequences are more complicated to decode and analyze, UTF-8
is also more complicated to decode and mapping Unicode characters to a smaller
set would eat resources. For the small systems which could use MyTerminal,
using ANSI and UTF-8 would also eat more resources. MyTerminal code sequences
are shorter.

For these reasons, MyTerminal cannot be used under Linux without setting things
up.

On the other side, the way Linux and programs supports terminals is not
straightforward: there is no driver and programs may simply ignore others
efforts to introduce compatibility layer like termcap or terminfo.

But first, we need to connect MyTerminal to a Linux host.

Serial port and TTY
-------------------

MyTerminal works natively with the following chipsets:

| Chipset     | Port type | Speed (bps) | Linux device |
| ----------- |:---------:| -----------:| ------------ |
| FTDI FT232L | USB       |   3.000.000 | /dev/ttyUSB* |
| MAX3232     | RS232     |     115.200 | /dev/ttyS*   |

**Notes**

- Speeds are the maximum speeds the chipsets handle, MyTerminal may work
  at higher speeds.
- The Linux devices are the standard ones on Debian, this may vary and are only
  given as an example. 

Once the Linux device has been identifiend or assigned, it needs to be
configured.

Linux does some work on data sent to or received from TTY devices. For example
it can convert line returns (`CR`, `LF`), check parity bits, handles special
characters etc.

This is done using the `stty` command:

```bash
stty --file=/dev/ttyUSB0 \
    3000000 \
    cols 80 \
    rows 51 \
    crtscts \
    raw \
    -iutf8
```

**Notes**

- The command can be written on one line by removing the `\`
- The `3000000` parameter is the speed 
- The dimensions of the dimension (80×51) must be specified because MyTerminal
  has no command to retrieve this information dynamically
- The `crtscts` flag must be set because intensive operations like clearing the
  entire screen cannot be done while keeping a fast bit rate. The `CTS` line is
  a mean for MyTerminal to tell the host “Wait a minute, I’m doing an intensive task”.
- The `-iutf8` tells Linux the data is not UTF-8.

This command must be run **2 times**: the first time before running `agetty`,
the second time in the `.profile` of each user (or at system-level).

Installing MyTerminal terminfo
------------------------------

Having device-independent display on terminals is a long sought quest which
sends us back to the seventies.

At that time, either your program had its own configuration tool allowing you
to specify character sequences to control display (like Turbo Pascal 3 under
CP/M), either you had to select one terminal among others and hopes that yours
would be supported.

`termcap` and `terminfo` are Unix answers to this problem. These are couples of
library and database. They both define device-independent capacities that can
be exploited using their library and the database gives the corresponding 
character sequences for each supported terminal.

The terminfo for MyTerminal is `myterminal.ti`.

To install `myterminal.ti` on your Linux distribution, you need the `tic` (the
terminfo entry-description compiler) program.

There are two ways:

```bash
# Make myterminal.ti available for the current user
tic myterminal.ti

# Make myterminal.ti system-wide
sudo tic myterminal.ti
```

**Note**

- The following message can be ignored: `"myterminal.ti", line 1, col 23, terminal 'myterminal': older tic versions may treat the description field as an alias`
- To make `terminfo`-capable program use our definitions, the `TERM` environment
  variable needs to be set to `myterminal`

Running `agetty`
----------------

`agetty` command will connect to a TTY and run inside it whatever we give it. By
default, it runs the `login` command but it can be overriden.

It is generally run by the `init` process but it can ben executed at anytime.

We need to use `setsid` because MyTerminal won't be identified as a true TTY
otherwise.

If you see the following message, this generally means you forgot `setsid`:

    bash: cannot set terminal process group (XX): Inappropriate ioctl for device
    bash: no job control in this shell

Here's the `agetty` command and its options for MyTerminal:

```bash
setsid agetty \
    --8bits \
    --flow-control \
    --keep-baud \
    --nohints \
    --local-line \
    --login-options "-p -- \\u" \
    /dev/ttyUSB0 \
    3000000 \
    myterminal
```

**Notes**

- `--8bits`: needed because MyTerminal uses an ISO-8859-15 like encoding
- `--flow-control`: MyTerminal requires flow control (CTS line) to ensure no
  character is lost
- `--nohints`: there is no need to display hints about Num, Caps and Scroll
  locks because, at that time, MyTerminal does not handle them
- `--local-line`: MyTerminal is not behind a modem
- `--login-options`: the `-p` option will make `login` keeping the environment
  variables
- `myterminal`: the `TERM` environment variable will be set to `myterminal`

`ls` and `dircolors`
--------------------

`ls` is one of Unix commands which does not take `terminfo` into account when
formatting its output. The code sequences must be defined in an environment
variable called `LS_COLORS`.

The `LS_COLORS` variable is not meant to be edited by hand. Its content should
be generated by the `dircolors` command.

On Debian, the `~/.bashrc` file installed by the system will try to read any
`~/.dircolors` and set the `LS_COLORS` environment variable.

If you have no `~/.dircolors` you can directly copy the `dircolors` file which
comes with MyTerminal. You will have to merge the two files otherwise.

**Note**: This does not interfere with existing `dircolors`.

`readline` and `inputrc`
------------------------

`libreadline` is a library used by many programs. For example, Bash uses it for command line edition.

`libreadline` does not read keys definition from the terminfo database but from
a file called `~/.inputrc`.

There is only one `~/.inputrc` and it can contain keys definitions for only one
terminal type.

You need to resort to the `INPUTRC` environment variable like in this example:

```bash
if [ "$TERM" == "myterminal" ]
then
    export INPUTRC=~/.myterminal_inputrc
fi
```

The `mytermina_inputrc` file which comes with MyTerminal can be used.
