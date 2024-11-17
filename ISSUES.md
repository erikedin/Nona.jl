Issues
======

- Documentation
- Usage documentation
- Replace "ny Hamming" with a switch command
- Enable switch back to Niancat
- More general command parser
- Rethink command mode, now that we know that # doesn't work as expected
- Split NonaREPL.feature into smaller parts, because it's getting big

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