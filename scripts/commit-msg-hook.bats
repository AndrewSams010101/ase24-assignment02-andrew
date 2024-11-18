#!/usr/bin/env bats

# Path to the compiled CommitMsgHook Java program
COMMIT_MSG_HOOK="java CommitMsgHook"

# Test helper: Create a temporary file for the commit message
setup() {
  COMMIT_MSG_FILE=$(mktemp)
}

teardown() {
  rm -f "$COMMIT_MSG_FILE"
}

# Group 1: General validations
@test "reject empty commit message" {
  echo -n "" > "$COMMIT_MSG_FILE"
  run $COMMIT_MSG_HOOK "$COMMIT_MSG_FILE"
  [ "$status" -eq 1 ]
  [[ "${output}" == *"Commit message is empty."* ]]
}

@test "reject commit message without type" {
  echo "add feature without type" > "$COMMIT_MSG_FILE"
  run $COMMIT_MSG_HOOK "$COMMIT_MSG_FILE"
  [ "$status" -eq 1 ]
  [[ "${output}" == *"Invalid commit message header: add feature without type"* ]]
}

@test "reject commit message with invalid type" {
  echo "invalid: add invalid type" > "$COMMIT_MSG_FILE"
  run $COMMIT_MSG_HOOK "$COMMIT_MSG_FILE"
  [ "$status" -eq 1 ]
  [[ "${output}" == *"Invalid commit message header: invalid:"* ]]
}

@test "reject commit message without colon after type" {
  echo "feat add feature without colon" > "$COMMIT_MSG_FILE"
  run $COMMIT_MSG_HOOK "$COMMIT_MSG_FILE"
  [ "$status" -eq 1 ]
  [[ "${output}" == *"Invalid commit message header: feat add feature without colon"* ]]
}

@test "reject commit message without description" {
  echo "feat: " > "$COMMIT_MSG_FILE"
  run $COMMIT_MSG_HOOK "$COMMIT_MSG_FILE"
  [ "$status" -eq 1 ]
  [[ "${output}" == *"Invalid commit message header: feat: "* ]]
}

# Group 2: Type and scope validations
@test "reject commit message with invalid scope" {
  echo "feat(scope@123): invalid scope format" > "$COMMIT_MSG_FILE"
  run $COMMIT_MSG_HOOK "$COMMIT_MSG_FILE"
  [ "$status" -eq 1 ]
  [[ "${output}" == *"Invalid commit message header: feat(scope@123): invalid scope format"* ]]
}

@test "reject commit message with invalid characters in scope (e.g., #)" {
  echo "feat(scope#123): invalid scope format" > "$COMMIT_MSG_FILE"
  run $COMMIT_MSG_HOOK "$COMMIT_MSG_FILE"
  [ "$status" -eq 1 ]
  [[ "${output}" == *"Invalid commit message header: feat(scope#123): invalid scope format"* ]]
}

@test "accept commit message with valid scope" {
  echo "feat(api): description" > "$COMMIT_MSG_FILE"
  run $COMMIT_MSG_HOOK "$COMMIT_MSG_FILE"
  [ "$status" -eq 0 ]
  [[ "${output}" == *"Commit message is valid."* ]]
}

@test "accept commit message with case-insensitive type and scope" {
  echo "Feat(API): case-insensitive type and scope" > "$COMMIT_MSG_FILE"
  run $COMMIT_MSG_HOOK "$COMMIT_MSG_FILE"
  [ "$status" -eq 0 ]
  [[ "${output}" == *"Commit message is valid."* ]]
}

# Group 3: Body validations
@test "reject commit message with body starting immediately after description" {
  echo -e "feat: short description\nbody starts immediately" > "$COMMIT_MSG_FILE"
  run $COMMIT_MSG_HOOK "$COMMIT_MSG_FILE"
  [ "$status" -eq 1 ]
  [[ "${output}" == *"Commit body must start with a blank line."* ]]
}

@test "accept commit message with body starting with blank line" {
  echo -e "feat: short description\n\nBody starts here." > "$COMMIT_MSG_FILE"
  run $COMMIT_MSG_HOOK "$COMMIT_MSG_FILE"
  [ "$status" -eq 0 ]
  [[ "${output}" == *"Commit message is valid."* ]]
}

@test "reject commit message with body starting with multiple blank lines" {
  echo -e "feat: description\n\n\nBody starts after multiple blank lines." > "$COMMIT_MSG_FILE"
  run $COMMIT_MSG_HOOK "$COMMIT_MSG_FILE"
  [ "$status" -eq 0 ]
  [[ "${output}" == *"Commit message is valid."* ]]
}

# Group 4: Footer validations
@test "accept commit message with valid footer" {
  echo -e "feat: short description\n\nReviewed-by: Contributor" > "$COMMIT_MSG_FILE"
  run $COMMIT_MSG_HOOK "$COMMIT_MSG_FILE"
  [ "$status" -eq 0 ]
  [[ "${output}" == *"Commit message is valid."* ]]
}

@test "reject commit message with invalid footer" {
  echo -e "feat: short description\n\nInvalid-Footer by: Contributor" > "$COMMIT_MSG_FILE"
  run $COMMIT_MSG_HOOK "$COMMIT_MSG_FILE"
  [ "$status" -eq 1 ]
  [[ "${output}" == *"Invalid footer format or missing required footer."* ]]
}

@test "accept commit message with BREAKING CHANGE in footer" {
  echo -e "feat: description\n\nBREAKING CHANGE: modifies behavior" > "$COMMIT_MSG_FILE"
  run $COMMIT_MSG_HOOK "$COMMIT_MSG_FILE"
  [ "$status" -eq 0 ]
  [[ "${output}" == *"Commit message is valid."* ]]
}

@test "reject commit message with invalid BREAKING CHANGE footer" {
  echo -e "feat: description\n\nbreaking change: modifies behavior" > "$COMMIT_MSG_FILE"
  run $COMMIT_MSG_HOOK "$COMMIT_MSG_FILE"
  [ "$status" -eq 1 ]
  [[ "${output}" == *"Invalid footer format or missing required footer."* ]]
}

@test "reject commit message with invalid 'BREAKING Change' capitalization" {
  echo -e "feat: breaking change footer invalid capitalization\n\nBREAKING Change: modifies behavior" > "$COMMIT_MSG_FILE"
  run $COMMIT_MSG_HOOK "$COMMIT_MSG_FILE"
  [ "$status" -eq 1 ]
  [[ "${output}" == *"Invalid footer format or missing required footer."* ]]
}

@test "reject commit message with 'BREAKING CHANGE:' but no description" {
  echo -e "feat: breaking change footer without description\n\nBREAKING CHANGE:" > "$COMMIT_MSG_FILE"
  run $COMMIT_MSG_HOOK "$COMMIT_MSG_FILE"
  [ "$status" -eq 1 ]
  [[ "${output}" == *"Invalid footer format or missing required footer."* ]]
}

@test "accept commit message with multiple valid footers" {
  echo -e "feat: add multiple footers\n\nReviewed-by: Contributor\nFixes #42" > "$COMMIT_MSG_FILE"
  run $COMMIT_MSG_HOOK "$COMMIT_MSG_FILE"
  [ "$status" -eq 0 ]
  [[ "${output}" == *"Commit message is valid."* ]]
}

@test "reject commit message with ! but no description" {
  echo "feat!:" > "$COMMIT_MSG_FILE"
  run $COMMIT_MSG_HOOK "$COMMIT_MSG_FILE"
  [ "$status" -eq 1 ]
  [[ "${output}" == *"Invalid commit message header: feat!*"* ]]
}