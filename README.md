# Nona.jl
Word games.

# How to play NiancatREPL
`NonaREPL` is a single-player command line version of Niancat, with an additional word game "Hamming".
The game starts with a randomly generated puzzle printed to the terminal, followed by a prompt.

## Starting
To start the game, from any directory

```bash
$ /path/to/Nona/cmd/nonarepl.jl
```

```bash
$ /path/to/Nona/cmd/nonarepl.jl
Pussel: PUSSGUKRA
Niancat>
```

## Guessing
```bash
Niancat> PUSSGAKUR
PUSSGAKUR är inte korrekt.
Niancat> PUSSGURKA
PUSSGURKA är rätt!
```

## Showing the current puzzle
```bash
Niancat> !visa
Pussel: PUSSGUKRA
```

## Starting a new game
```bash
Niancat> !nytt
Pusslet hade lösningar
  PUSSGURKA

Pussel: DATORSPLE
Niancat>
```

## Starting a Hamming game
```bash
Niancat> !nytt Hamming
Pusslet hade lösningar
  DATORSPEL
  LEDARPOST

Pusslet är 8 tecken långt.
Hamming>
```

The objective is to guess the secret word. At start, it shows the length of the word.
The only allowed guesses are words of that length, for instance 8 characters in the above example.
The guesses must be words in the dictionary.
When a guess is entered, the game replies with the Hamming distance to the puzzle. That is, it shows
how many characters do not match the corresponding character in the puzzle.

```bash
Hamming> STORMADE
8
```

In this case, no characters are in the right place.

```bash
Hamming> ARMARNAS
7
```

In the above case, 7 characters do not match. That means that one character is in the right place.
No information is given about which one.

# Cloning and installing prerequisities
A dictionary is required. No dictionary is provided with this code.
The dictionary should be a file with one word on each line.

## Getting the code
Clone to the code.

```bash
$ git clone https://github.com/erikedin/Nona.jl Nona
```

The first time the player runs the `cmd/nonarepl.jl` script, the required
packages will be installed.

## Configuring the dictionary
In the below instructions the dictionary is expected to be in `/home/user/Documents/dictionary.txt`.
Adjust this path to your dictionary below.

The file `~/.config/nonarepl/dictionarypath.txt` is a configuration file that
should contain _the path_ to the dictionary file. This means that the path does
not have to be supplied to the start script every time.

```bash
$ mkdir -p ~/.config/nonarepl
# Adjust the path to `dictionary.txt` below...
$ echo "/home/user/Documents/dictionary.txt" > ~/.config/nonarepl/dictionarypath.txt
```

