#!/bin/bash

TESTCASE_ROOT="./testcase"
TESTCASE_ANSWER_ROOT="./testcase_answer"
STUDENT_ANSWER_ROOT="./student_answer"

problems=(
    "factorial" 
    "prime" 
    "calculator" 
    "triangle" 
    "fibonacci"
)

test_problem() {
    local prolbem=$1
    local source_c_file="./${problem}.c"
    local source_asm_file="./${problem}.s"
    local executable_file="./$problem"
    
    echo "Testing Problem: $problem"

    if [ ! -f "$source_c_file" ]; then
        echo "Source c file not found: $source_c_file"
        return
    fi

    if [ ! -f "$source_asm_file" ]; then
        echo "Source asm file not found: $source_asm_file"
        return
    fi

    gcc "$source_c_file" -o "$executable_file"
    
    testcase_files=($(ls $TESTCASE_ROOT | grep $problem))
    for file in "${testcase_files[@]}"; do
        local testcase_path="$TESTCASE_ROOT/$file"
        local testcase_answer_path="$TESTCASE_ANSWER_ROOT/$file"
        local student_answer_path="$STUDENT_ANSWER_ROOT/$file"

        "$executable_file" < "$testcase_path" > "$testcase_answer_path"
        spim -file "$source_asm_file" < "$testcase_path" | tail -n $(awk 'END {print NR}' $testcase_answer_path) > "$student_answer_path"

        diff_output=$(diff $testcase_answer_path $student_answer_path)
        if [ -z "$diff_output" ]; then
            echo "$file PASS"
        else
            echo "$file FAIL"
            echo "$diff_output"
        fi
    done

    rm "$executable_file"
}

mkdir -p "$TESTCASE_ANSWER_ROOT"
mkdir -p "$STUDENT_ANSWER_ROOT"

for problem in "${problems[@]}"; do
    test_problem "$problem"
    echo "------------------------------------"
done
