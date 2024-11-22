#!/bin/sh

usage() {
    echo "hw2.sh -p TASK_ID -t TASK_TYPE [-h]" >&2
    echo ""                                >&2
    echo "Available Options:"              >&2
    echo ""                                >&2
    echo "-p: Task id"                     >&2
    echo "-t JOIN_NYCU_CSIT|MATH_SOLVER|CRACK_PASSWORD: Task type" >&2
    echo "-h: Show the script usage"       >&2
}

# 2>&1 Merge stdout with stderr

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

TASK_ID=""
TASK_TYPE=""

# first  ":" means silent error
# second ":" means 'p' required argument
# third  ":" means 't' required argument
while getopts ":p:t:h" opt; do
    case $opt in
        p) TASK_ID=$OPTARG ;;
        t) 
            if [ "$OPTARG" = "JOIN_NYCU_CSIT" ] || [ "$OPTARG" = "MATH_SOLVER" ] || [ "$OPTARG" = "CRACK_PASSWORD" ]; then
                TASK_TYPE=$OPTARG
            else
                echo "Invalid task type" >&2
                exit 1
            fi
            ;;
        h)
            usage
            exit 0
            ;;
        ?)
            usage
            exit 1
            ;;
    esac
done

# Check if required arguments are empty
if [ -z "$TASK_ID" ] || [ -z "$TASK_TYPE" ]; then
    usage
    exit 1
fi

ID=""
TYPE=""
PROB=""
STATUS=""

res1=$(curl -s -X GET "http://10.113.0.253/tasks/$TASK_ID")
if echo "$res1" | jq '.id, .type, .problem, .status' > /dev/null; then
    ID=$(echo "$res1"     | jq '.id')
    TYPE=$(echo "$res1"   | jq '.type')
    PROB=$(echo "$res1"   | jq '.problem')
    STATUS=$(echo "$res1" | jq '.status')
else
    echo 'FORMAT ERROR' >&2
    exit 1
fi

ID=${ID#?}
ID=${ID%?}

TYPE=${TYPE#?}
TYPE=${TYPE%?}

PROB=${PROB#?}
PROB=${PROB%?}

STATUS=${STATUS#?}
STATUS=${STATUS%?}

if [ "$TYPE" != "$TASK_TYPE" ]; then
    echo "Task type not match" >&2
    exit 1
fi

if [ "$TYPE" = "MATH_SOLVER" ] ; then
    num1=$(echo "$PROB" | awk '{print $1}')
    optr=$(echo "$PROB" | awk '{print $2}')
    num2=$(echo "$PROB" | awk '{print $3}')

    if [ "$num1" -lt -10000 ] || [ "$num1" -gt 10000 ] || [ "$num2" -lt -10000 ] || [ "$num2" -gt 10000 ] ; then
        curl -s -X POST -H "Content-Type: application/json" -d '{"answer": "Invalid problem"}' "http://10.113.0.253/tasks/$TASK_ID/submit"
        exit 0
    elif [ "$optr" != "+" ] && [ "$optr" != "-" ] ; then
        curl -s -X POST -H "Content-Type: application/json" -d '{"answer": "Invalid problem"}' "http://10.113.0.253/tasks/$TASK_ID/submit"
        exit 0
    fi

    case "$optr" in
        "+")
            sum=$((num1 + num2))
            ;;
        "-")
            sum=$((num1 - num2))
            ;;
    esac
    
    if [ "$sum" -lt -20000 ] || [ "$sum" -gt 20000 ] ; then
        curl -s -X POST -H "Content-Type: application/json" -d '{"answer": "Invalid problem"}' "http://10.113.0.253/tasks/$TASK_ID/submit"
        exit 0
    fi

    curl -s -X POST -H "Content-Type: application/json" -d "{\"answer\": \"$sum\"}" "http://10.113.0.253/tasks/$TASK_ID/submit"
    exit 0
elif [ "$TYPE" = "CRACK_PASSWORD" ] ; then
    ./hw2_crack.sh "$PROB" > /dev/null
    exit_code=$?

    if [ $exit_code -eq 0 ]; then
        ANS=$(./hw2_crack.sh "$PROB")
        # echo "$ANS"
        curl -s -X POST -H "Content-Type: application/json" -d "{\"answer\": \"$ANS\"}" "http://10.113.0.253/tasks/$TASK_ID/submit"
    else
        curl -s -X POST -H "Content-Type: application/json" -d '{"answer": "Invalid problem"}' "http://10.113.0.253/tasks/$TASK_ID/submit"
    fi
    exit 0
elif [ "$TYPE" = "JOIN_NYCU_CSIT" ] ; then
    curl -s -X POST -H "Content-Type: application/json" -d '{"answer": "I Love NYCU CSIT"}' "http://10.113.0.253/tasks/$TASK_ID/submit"
    exit 0
else 
    echo "Invalid task type" >&2
    exit 1
fi