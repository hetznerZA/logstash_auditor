#!/bin/bash

# Retries a command on failure.
# $1 - the max number of attempts
# $2... - the command to run
retry() {
    local -r -i max_attempts="$1"; shift
    local -r cmd="$@"
    local -i attempt_num=1
    local -i cmd_exit_code=0
    until eval $cmd
    do
        cmd_exit_code=$?
        if (( attempt_num == max_attempts ))
        then
            echo "Attempt $attempt_num failed with code $cmd_exit_code and there are no more attempts left!"
            exit $cmd_exit_code
        else
            echo "Attempt $attempt_num failed with code $cmd_exit_code! Trying again in $attempt_num seconds..."
            sleep $(( attempt_num++ ))
        fi
    done
}
