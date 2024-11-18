# Version-controlled Git Hooks

Clone this repo into `.git/hooks` to use the hooks defined in this repository.

## Interface for the commit message hook

The hook [`commit-msg`](commit-msg) calls the shell script [`scripts/commit-msg-hook`](./scripts/commit-msg-hook) and
passes the commit message as the first command line argument.
The shell script returns `0` if the commit message is valid and `1` otherwise.

## Requirements for the assignment

You must use Java (version 21) to implement the commit message validation.
You might have to update the path to the Java binary in the [shell script](./scripts/commit-msg-hook).
For the submission, you are expected to use the single file source code approach as suggested
(see [JEP 330](https://openjdk.org/jeps/330)).
To ease debugging, you can create a separate file `CommitMsgHook.java` and use the input strings from the
test cases in [`./scripts/commit-msg-hook-test`](./scripts/commit-msg-hook-test) to test your program. Example:

```shell
cd ./scripts
java CommitMsgHook.java $(printf "feat: short description\n\nadditional details in body")
```

## Running the tests

You can use the tests cases to check your implementation.
To do that, you have to install [Bats Core](https://bats-core.readthedocs.io/en/stable/) first and potentially
update the path to the binary. 
Don't worry if not all tests pass; you should nevertheless submit your code.
We will consider the complexity of the specification during the grading.

```shell
cd ./scripts
./commit-msg-hook-test
```
# ase24-assignment02-andrew-new-02
# ase24-assignment02-andrew-new-02
