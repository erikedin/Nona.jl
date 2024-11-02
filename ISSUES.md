Issues
======

- Move non-Niancat-game related functionality to other modules
    + Word can be moved out
    + Dictionaries could probably be moved as well
- Create a simple REPL instead of using the Julia REPL
- Create a simpler Hamming-distance game as well
- Code comments and documentation

# Fixed
- FileDictionary should take an AbstractString
- Make puzzles uppercase
- Ensure case insensitivity
- Create only 9 letter puzzles
- Simplify use of the REPL
- Put NiancatGame in its own module, instead of in Nona
- Show wrong/remaining letters when making a guess