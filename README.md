# Nona.jl
Word games.

# Cloning and installing prerequisities
A dictionary is required. No dictionary is provided with this code.
The dictionary should be a file with one word on each line.

## Getting the code
Clone to the code.

```bash
$ git clone https://github.com/erikedin/Nona.jl Nona
```

The first time the player runs the `cmd/niancatrepl.jl` script, the required
packages will be installed.

## Configuring the dictionary
Here the dictionary is expected to be in `/home/user/Documents/dictionary.txt`.
Adjust this path to your dictionary below.

The file `~/.config/niancatrepl/dictionarypath.txt` is a configuration file that
should contain _the path_ to the dictionary file. This means that the path does
not have to be supplied to the start script every time.

```bash
$ mkdir -p ~/.config/niancatrepl
# Adjust the path to `dictionary.txt` below...
$ echo "/home/user/Documents/dictionary.txt" > ~/.config/niancatrepl/dictionarypath.txt
```

## Starting
To start the game, from any directory

```bash
$ /path/to/Nona/cmd/niancatrepl.jl
```

# How to play NiancatREPL
`NiancatREPL` is a single-player command line version of Niancat.
The game starts with a randomly generated puzzle printed to the terminal, followed by a prompt.

```bash
$ /path/to/Nona/cmd/niancatrepl.jl
PUSSGUKRA
>
```

At the time of writing, the only thing the player can do is input a guess.

```bash
$ /path/to/Nona/cmd/niancatrepl.jl
PUSSGUKRA
> PUSSGAKUR
PUSSGAKUR är inte korrekt.
> PUSSGURKA
PUSSGURKA är rätt!
```
