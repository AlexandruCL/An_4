# Lab 4 explained

## Exercise 1: print one student's data

```sql
DECLARE
    v_sid   Student.S_ID%TYPE := :s_id;
    v_name  Student.Name%TYPE;
    v_mark  Student.Average_mark%TYPE;
    v_year  Student.Year_of_study%TYPE;
BEGIN
    SELECT Name, Average_mark, Year_of_study
      INTO v_name, v_mark, v_year
      FROM Student
     WHERE S_ID = v_sid;

    DBMS_OUTPUT.PUT_LINE(
        SUBSTR(v_name, 1, 1) || '.' || SUBSTR(v_name, INSTR(v_name, ' ') + 1) || ' ' ||
        CASE WHEN v_mark > 9 THEN 'Excelent' ELSE 'Good' END || ' ' ||
        TO_CHAR(v_mark) || ' ' ||
        CASE WHEN v_year = 4 THEN 'SeniorStudent' ELSE 'Student' END || ' ' ||
        TO_CHAR(v_year));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No student with S_ID = ' || v_sid);
END;
```

**Goal:** given a student ID, print a line like `C.Alexandru Excelent 9.75 SeniorStudent 4`.

### Step 1: `DECLARE`

- `v_sid := :s_id`: APEX asks you for the ID and stores it in `v_sid`.
- `v_name`, `v_mark` and `v_year` start empty and will hold the student's data.
- `%TYPE` means "same type as this column", so the variables always match the table.

### Step 2: `SELECT ... INTO`

- This finds the row in `Student` where `S_ID` equals your ID.
- `INTO` copies the 3 columns into the 3 variables, matched by position: Name → `v_name`, Average_mark → `v_mark`, Year_of_study → `v_year`.
- `SELECT INTO` must return exactly one row. Here the ID is a primary key, so there is never more than one.

### Step 3: build the line

`||` joins strings together. Here is how student 1 (`'Cristea Alexandru'`, 9.75, 4) is built:

| Piece | How it works | Result |
|---|---|---|
| `SUBSTR(v_name, 1, 1)` | start at position 1, take 1 character | `C` |
| `'.'` | literal dot | `.` |
| `INSTR(v_name, ' ')` | position of the space | `8` |
| `SUBSTR(v_name, 8 + 1)` | everything from position 9 to the end | `Alexandru` |
| `CASE WHEN v_mark > 9 ...` | 9.75 > 9 → `'Excelent'`, otherwise `'Good'` | `Excelent` |
| `TO_CHAR(v_mark)` | number → text | `9.75` |
| `CASE WHEN v_year = 4 ...` | 4 = 4 → `'SeniorStudent'`, otherwise `'Student'` | `SeniorStudent` |
| `TO_CHAR(v_year)` | number → text | `4` |

`DBMS_OUTPUT.PUT_LINE` prints the finished line in the output pane.

### Step 4: `EXCEPTION`

- If you type an ID that doesn't exist (for example 99), `SELECT INTO` finds nothing and Oracle raises `NO_DATA_FOUND`.
- Instead of failing with an error, the block prints `No student with S_ID = 99`.

### More examples with the lab data

- ID 2 (`Toma Ionut`, 8.90, year 3) → `T.Ionut Good 8.9 Student 3`
- ID 4 (`Boros Fabian`, 7.60, year 4) → `B.Fabian Good 7.6 SeniorStudent 4`

`TO_CHAR` drops trailing zeros, so 8.90 prints as `8.9`.

---

## Exercise 2: all titles, then the percentage of available books

```sql
DECLARE
    v_total      NUMBER;
    v_available  NUMBER;
BEGIN
    FOR r IN (SELECT Title FROM Book_title ORDER BY T_ID) LOOP
        DBMS_OUTPUT.PUT_LINE(r.Title);
    END LOOP;

    SELECT COUNT(*), COUNT(CASE WHEN Student_ID IS NULL THEN 1 END)
      INTO v_total, v_available
      FROM Book_copy;

    DBMS_OUTPUT.PUT_LINE('Available books: ' ||
        TO_CHAR(ROUND(100 * v_available / NULLIF(v_total, 0), 2)) || '%');
END;
```

**Goal:** print every book title, then what percentage of the book copies are currently not borrowed.

### Step 1: `DECLARE`

- `v_total` will hold the number of copies in the library.
- `v_available` will hold the number of copies nobody has borrowed.

### Step 2: the `FOR` loop prints the titles

- `SELECT Title FROM Book_title ORDER BY T_ID` returns 6 rows, one per title.
- `FOR r IN (...) LOOP` runs the body once per row. Each time, `r` holds the current row, so `r.Title` is that row's title.
- Oracle opens the query, fetches the rows and closes it for you. You don't need `OPEN`, `FETCH` or `CLOSE`.

Output:

```
Introduction to Algorithms
Database System Concepts
Clean Code
The C Programming Language
SQL Pocket Guide
Oracle Cheat Sheet
```

### Step 3: count the copies

"Available" means a copy in `Book_copy` that no student has, so its `Student_ID IS NULL`.

- `COUNT(*)` counts all rows in `Book_copy`, giving **9**.
- `COUNT(CASE WHEN Student_ID IS NULL THEN 1 END)`: the `CASE` gives `1` for a free copy and `NULL` for a borrowed one. `COUNT(expression)` skips NULLs, so only free copies are counted. Copies 102 and 602 are free, so this gives **2**.
- Both counts come from one query and go into the two variables with `INTO`.

### Step 4: calculate and print the percentage

| Part | Meaning | Value |
|---|---|---|
| `100 * v_available / v_total` | percentage | 100 × 2 / 9 = 22.2222… |
| `NULLIF(v_total, 0)` | if `v_total` is 0, use NULL instead, so an empty table gives a blank result instead of a "divide by zero" error | 9 |
| `ROUND(..., 2)` | keep 2 decimals | 22.22 |
| `TO_CHAR(...) \|\| '%'` | turn it into text and add `%` | `22.22%` |

Final line:

```
Available books: 22.22%
```

---

## Summary of the PL/SQL used

- Exercise 1: `SELECT INTO` for exactly one row, `CASE` for the if/else labels, and `EXCEPTION` for a missing ID.
- Exercise 2: a `FOR` loop over a query for many rows, plus one `SELECT INTO` that gets two counts at once.
