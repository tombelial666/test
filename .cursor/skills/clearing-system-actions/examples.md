# Clearing system actions examples

## Run atomic INT2 tests

```bash
cd D:/DevReps/qa/Tools/ClearingTester
python run_volant_easy_to_borrow_int2.py
```

## Enable mutating PUT test

```bash
set RUN_MUTATING_CLEARING_TESTS=1
python run_volant_easy_to_borrow_int2.py
```

## Override payload path

```bash
set CLEARING_TESTER_PAYLOAD=D:/local/volant_easy_to_borrow_int2.local.json
python run_volant_easy_to_borrow_int2.py
```
