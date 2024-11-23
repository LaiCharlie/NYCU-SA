## HW2

- [x] Usage (20%)
    - [x] Invalid options (10%)
        - [x] Exit Code (5%) 
        - [x] Help Message (5%) 
    - [x] Invalid type (5%) 
    - [x] Task type validation (5%) 
- [x] Arbitrary argument position (15%) 
- [x] Shellcheck (10%) 
- [x] Tasks
    - [x] Join NYCU CSIT (15%) 
    - [x] Math Solver (20%) 
        - [x] Invalid problem check is included 
    - [x] Crack Password (20%) 
        - [x] Invalid problem check is included 
- [x] Bonus: Easter egg collection (5%)

####  Example
##### MATH_SOLVER
```bash
root@sa2024-108:/home/judge# curl -s -X POST -H "Content-Type: application/json" -d '{"type": "MATH_SOLVER"}' "http://10.113.0.253/tasks"
{
    "id":"04f0cd75-7e2d-4b61-83c2-8bca5f320d3c",
    "type":"MATH_SOLVER",
    "problem":"3172 - 5396 = ?",
    "status":"PENDING"
}

root@sa2024-108:/home/judge# curl -s -X POST -H "Content-Type: application/json" -d '{"answer": "-2224"}' "http://10.113.0.253/tasks/04f0cd75-7e2d-4b61-83c2-8bca5f320d3c/submit"

root@sa2024-108:/home/judge# curl -s -X GET "http://10.113.0.253/tasks/04f0cd75-7e2d-4b61-83c2-8bca5f320d3c"
{
    "id":"04f0cd75-7e2d-4b61-83c2-8bca5f320d3c",
    "type":"MATH_SOLVER",
    "problem":"3172 - 5396 = ?",
    "status":"TIMEOUT"
}
```

> Note:
> **Problem** : a (+/-) b = c
> ```cpp
> -10000 <= a <= 10000
> -10000 <= b <= 10000
> -20000 <= c <= 20000
> ```
> **Add and subtract only**, you don’t need to consider other conditions. 
> If you get a problem not obey the above definition, just send **“Invalid problem”** to the task server.

##### JOIN_NYCU_CSIT
```bash
root@sa2024-108:/home/judge# curl -s -X POST -H "Content-Type: application/json" -d '{"type": "JOIN_NYCU_CSIT"}' "http://10.113.0.253/tasks"
{
    “id”: “4a9c99f4-0241-4f3d-a003-7b2f6bb455db”,
    “type”: “JOIN_NYCU_CSIT”,
    “status”: “PENDING”,
    “problem”: “https://i.imgur.com/wP3ST2x.jpeg”
}

root@sa2024-108:/home/judge# curl -s -X POST -H "Content-Type: application/json" -d '{"answer": "I Love NYCU CSIT"}' "http://10.113.0.253/tasks/4a9c99f4-0241-4f3d-a003-7b2f6bb455db/submit"
```

##### CRACK_PASSWORD
```bash
root@sa2024-108:/home/judge# curl -s -X POST -H "Content-Type: application/json" -d '{"type": "CRACK_PASSWORD"}' "http://10.113.0.253/tasks"
{
    “id”: “9d2cde78-837c-4e72-bc9d-4f7204b5520e”,
    “type”: “CRACK_PASSWORD”,
    “status”: “PENDING”,
    “problem”: “ALPHANFN{QfLWrLExdqgSufIi}”
}

root@sa2024-108:/home/judge# curl -s -X POST -H "Content-Type: application/json" -d '{“answer”: “NYCUNASA{DsYJeYRkqdtFhsVv}”}' "http://10.113.0.253/tasks/9d2cde78-837c-4e72-bc9d-4f7204b5520e/submit"
```
