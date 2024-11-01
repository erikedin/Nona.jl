# Gherkin scenarios
The requirements are written in Gherkin, mainly under the `features` directory.
The `features/details` directory has requirements that are there mainly for test
coverage. These scenarios test the same things as the scenarios in `features`, but
have more details that would prevent readability. In other words, by reading the
scenarios in the `features` directory, one should be able to quickly see all the
features of the package, without necessarily having to go through the detailed
test cases for covering all corner cases.
