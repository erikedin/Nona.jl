Issues
======

- Code comments
- Replace "ny Hamming" with a switch command
- Hamming can keep track of the best words currently known
- Replace `isindictionary` with just `in`
- Replace one NiancatGame constructor with a call to the other

# Fixed
- FileDictionary should take an AbstractString
- Make puzzles uppercase
- Ensure case insensitivity
- Create only 9 letter puzzles
- Simplify use of the REPL
- Put NiancatGame in its own module, instead of in Nona
- Show wrong/remaining letters when making a guess
- Create a simple REPL instead of using the Julia REPL
- Code comments
- Show the number of solutions
- Starting a new game in the REPL
- Change the config path to .config/nonarepl
- Implement commands in the REPL
    + For getting the current puzzle
    + For exiting
- Rename User to Player
- Move non-Niancat-game related functionality to other modules
    + Word can be moved out
    + Dictionaries could probably be moved as well
- Create a simpler Hamming-distance game as well
- Show the solutions to the previous puzzle when starting a new game
- REPL: Handle Ctrl+D, should exit
- Rethink command mode, now that we know that # doesn't work as expected
- More general command parser
- Enable switch back to Niancat
- Hamming guesses must be in the dictionary
- ÅÄÖ does not work with the command parser
- Creating a new Hamming game leads to `implement gameaction!`
- Usage documentation