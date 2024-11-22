#!/bin/sh

get_task_id() {
    problem_type="$1"
    response=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"type\": \"$problem_type\"}" "http://10.113.0.253/tasks")
    
    if echo "$response" | jq -e '.id' > /dev/null; then
        TASK_ID=$(echo "$response" | jq -r '.id')
        echo "$TASK_ID"
    else
        echo "Failed to get task ID. Response: $response" >&2
        exit 1
    fi
}

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <PROBLEM_TYPE>" >&2
    exit 1
fi

PROBLEM_TYPE="$1"

TASK_ID=$(get_task_id "$PROBLEM_TYPE")

# ./hw2.sh -p "$TASK_ID" -t "$PROBLEM_TYPE"
./hw2.sh -p "$TASK_ID" -t "$PROBLEM_TYPE" > /dev/null

res=$(curl -s -X GET "http://10.113.0.253/tasks/$TASK_ID")
if echo "$res" | jq '.id, .type, .problem, .status' > /dev/null; then
    res2=$(echo "$res" | jq '.status')
    if [ "$PROBLEM_TYPE" != "JOIN_NYCU_CSIT" ] ; then 
        echo "$res" | jq '.problem'
        echo "$res" | jq '.status'
    elif [ "$res2" = \""ACCEPT"\" ] ; then 
        echo "$res" | jq '.problem'
    fi
fi

# ./hw2_test.sh JOIN_NYCU_CSIT
# ./hw2_test.sh MATH_SOLVER
# ./hw2_test.sh CRACK_PASSWORD













