#!/usr/bin/env bats

setup() {
    # Create a temporary directory for test repo
    TEST_DIR="$(mktemp -d)"
    cd "$TEST_DIR"
    
    # Initialize test repo
    git init
    git config --local user.email "test@example.com"
    git config --local user.name "Test User"
    
    # Create initial commit
    touch README.md
    git add README.md
    git commit -m "Initial commit"
    
    # Store script path
    SCRIPT_PATH="$BATS_TEST_DIRNAME/../git-branch-status"
}

teardown() {
    # Clean up test directory
    rm -rf "$TEST_DIR"
}

@test "script exists and is executable" {
    [ -x "$SCRIPT_PATH" ]
}

@test "shows help message with -h flag" {
    run "$SCRIPT_PATH" -h
    echo "STATUS: $status"
    echo "OUTPUT: $output"
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ "USAGE:" ]]
}

@test "fails gracefully in non-git directory" {
    cd /tmp
    run "$SCRIPT_PATH"
    echo "STATUS: $status"
    echo "OUTPUT: $output"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "fatal: Not a git repo" ]]
}

@test "shows current branch status" {
    # Create and switch to test branch
    git checkout -b test-branch
    
    # Create a change
    echo "test" > test.txt
    git add test.txt
    git commit -m "Test commit"
    
    run "$SCRIPT_PATH" -b
    echo "STATUS: $status"
    echo "OUTPUT: $output"
    [ "$status" -eq 1 ]  # NOTE: Is this intentional?
    [[ "$output" =~ "test-branch" ]]
    [[ "$output" =~ "no upstream" ]]
}

@test "shows correct ahead/behind status" {
    # Setup remote
    git clone "$TEST_DIR" "${TEST_DIR}_remote"
    cd "${TEST_DIR}_remote"
    
    # Create divergent changes in remote
    echo "remote change" > remote.txt
    git add remote.txt
    git commit -m "Remote commit"
    
    # Go back to original repo
    cd "$TEST_DIR"
    git remote add origin "${TEST_DIR}_remote"
    git fetch origin
    
    # Set up tracking relationship
    git branch --set-upstream-to=origin/main main
    
    # Create local change
    echo "local change" > local.txt
    git add local.txt
    git commit -m "Local commit"
    
    run "$SCRIPT_PATH"
    echo "STATUS: $status"
    echo "OUTPUT: $output"
    [ "$status" -eq 1 ]  # NOTE: Is this intentional?
    [[ "$output" =~ "ahead" ]]
    [[ "$output" =~ "behind" ]]
}

@test "shows all branches with -a flag" {
    # Create multiple branches
    git branch branch1
    git branch branch2
    
    run "$SCRIPT_PATH" -a
    echo "STATUS: $status"
    echo "OUTPUT: $output"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "branch1" ]]
    [[ "$output" =~ "branch2" ]]
}

@test "shows dates with -d flag" {
    run "$SCRIPT_PATH" -d
    echo "STATUS: $status"
    echo "OUTPUT: $output"
    [ "$status" -eq 1 ]  # NOTE: Is this intentional?
    # Check for date format YYYY-MM-DD
    [[ "$output" =~ [0-9]{4}-[0-9]{2}-[0-9]{2} ]]
}

@test "handles comparison of two specific branches" {
    # Create two branches with different changes
    git checkout -b branch1
    echo "branch1" > branch1.txt
    git add branch1.txt
    git commit -m "Branch1 commit"
    
    git checkout -b branch2
    echo "branch2" > branch2.txt
    git add branch2.txt
    git commit -m "Branch2 commit"
    
    run "$SCRIPT_PATH" branch1 branch2
    [ "$status" -eq 0 ]
    [[ "$output" =~ "branch1" ]]
    [[ "$output" =~ "branch2" ]]
}

@test "fails gracefully with invalid branch name" {
    run "$SCRIPT_PATH" non-existent-branch
    [ "$status" -eq 1 ]
    [[ "$output" =~ "No such branch" ]]
}

@test "shows local branches with -l flag" {
    git branch branch1
    git branch branch2
    
    run "$SCRIPT_PATH" -l
    echo "STATUS: $status"
    echo "OUTPUT: $output"
    [ "$status" -eq 1 ]  # NOTE: Is this intentional?
    [[ "$output" =~ "branch1" ]]
    [[ "$output" =~ "branch2" ]]
}

@test "handles bare repository gracefully" {
    # Create bare repo
    cd /tmp
    git init --bare bare-repo
    cd bare-repo
    
    run "$SCRIPT_PATH"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Bare repo" ]]
} 