# Lab 6 explained

## How to run it in Oracle APEX

The file holds three separate PL/SQL blocks. Each one ends with a `/` on its own line, which tells APEX where one block stops and the next one starts.

- **SQL Workshop > SQL Scripts:** upload or paste the whole file and press Run. The `/` lines split it into three blocks and each one runs in turn. Open the run results to see the output of each block.
- **SQL Workshop > SQL Commands:** this screen runs one statement at a time. Select one block (from `DECLARE` to `END;`, without the `/`) and press Run. The output shows up in the Results tab.

You don't need `SET SERVEROUTPUT ON` in APEX. It shows `DBMS_OUTPUT` on its own.

The blocks use the tables and data from lab 3 (`Student`, `Book_title`, `Book_copy`). The outputs below come from that data.

## What is a cursor?

When a `SELECT` returns many rows, PL/SQL can't put them all into one variable. A cursor is a pointer that walks through the result one row at a time. You work with it in four steps:

| Step | Code | What happens |
|---|---|---|
| Declare | `CURSOR c IS SELECT ...;` | You name the query. Nothing runs yet. |
| Open | `OPEN c;` | Oracle runs the query and puts the pointer before the first row. |
| Fetch | `FETCH c INTO ...;` | Moves to the next row and copies its values into your variables. |
| Close | `CLOSE c;` | Frees the cursor. |

A cursor also has attributes you can read at any time:

| Attribute | Meaning |
|---|---|
| `c%FOUND` | TRUE if the last `FETCH` returned a row |
| `c%NOTFOUND` | the opposite: TRUE when there was nothing left to fetch |
| `c%ROWCOUNT` | how many rows have been fetched so far |

---

## Exercise 1: the first five students with a WHILE loop

```sql
DECLARE
    CURSOR c IS SELECT S_ID, Name, Year_of_study, Faculty, Average_mark
                  FROM Student ORDER BY S_ID;
    v_id      Student.S_ID%TYPE;
    v_name    Student.Name%TYPE;
    v_year    Student.Year_of_study%TYPE;
    v_faculty Student.Faculty%TYPE;
    v_mark    Student.Average_mark%TYPE;
BEGIN
    OPEN c;
    FETCH c INTO v_id, v_name, v_year, v_faculty, v_mark;
    WHILE c%FOUND AND c%ROWCOUNT <= 5 LOOP
        DBMS_OUTPUT.PUT_LINE(c%ROWCOUNT || ': ' || v_id || ' ' || v_name || ' ' ||
                             v_year || ' ' || v_faculty || ' ' || v_mark);
        FETCH c INTO v_id, v_name, v_year, v_faculty, v_mark;
    END LOOP;
    CLOSE c;
END;
/
```

**Goal:** read students one at a time with a cursor, stop after five, and print each one.

### Step 1: declare the cursor and the variables

- The cursor selects the five columns of `Student`, sorted by ID. Without `ORDER BY`, "the first five" could be any five rows.
- There is one variable per column. `%TYPE` gives each variable the same type as its column.

### Step 2: the first FETCH happens before the loop

A `WHILE` loop checks its condition **before** each pass. The condition uses `c%FOUND`, and `c%FOUND` only has a value after a `FETCH`. So the block fetches row 1 first, then enters the loop.

Inside the loop the order is: print the current row, then fetch the next one. The condition is checked again with the new row.

### Step 3: the stop condition

`WHILE c%FOUND AND c%ROWCOUNT <= 5` keeps going while both are true:

- `c%FOUND`: the last fetch returned a row. This stops the loop if the table has fewer than five students.
- `c%ROWCOUNT <= 5`: we have fetched at most five rows. After the sixth fetch `%ROWCOUNT` becomes 6 and the loop ends, so the sixth row is never printed.

Walking through it:

| Fetch | `%ROWCOUNT` after it | Loop runs? |
|---|---|---|
| before the loop | 1 | yes, prints student 1 |
| 2nd | 2 | yes, prints student 2 |
| ... | ... | ... |
| 5th | 5 | yes, prints student 5 |
| 6th | 6 | no, loop ends |

### Step 4: close the cursor

`CLOSE c;` releases it. An open cursor left behind uses memory until the session ends.

Output:

```
1: 1 Cristea Alexandru 4 AC 9.75
2: 2 Toma Ionut 3 AC 8.9
3: 3 Pop Patric 2 AC 9.6
4: 4 Boros Fabian 4 AC 7.6
5: 5 Bujanca Cristian 1 AC 8.9
```

`8.90` prints as `8.9` because Oracle drops trailing zeros when it turns a number into text.

---

## Exercise 2: every title with its copies, using a FOR loop and a record

```sql
DECLARE
    CURSOR c IS SELECT bt.T_ID, bt.Title, bc.B_ID, bc.Student_ID
                  FROM Book_title bt
                  LEFT JOIN Book_copy bc ON bc.Title_ID = bt.T_ID
                 ORDER BY bt.T_ID, bc.B_ID;
    TYPE t_book IS RECORD (
        T_ID        Book_title.T_ID%TYPE,
        Title       Book_title.Title%TYPE,
        B_ID        Book_copy.B_ID%TYPE,
        Student_ID  Book_copy.Student_ID%TYPE
    );
    v t_book;
BEGIN
    FOR r IN c LOOP
        v.T_ID       := r.T_ID;
        v.Title      := r.Title;
        v.B_ID       := r.B_ID;
        v.Student_ID := r.Student_ID;

        DBMS_OUTPUT.PUT_LINE(v.T_ID || ' ' || v.Title ||
            ' | copy: ' || NVL(TO_CHAR(v.B_ID), 'none') ||
            ' | borrowed by: ' || NVL(TO_CHAR(v.Student_ID), 'available'));
    END LOOP;
END;
/
```

**Goal:** print each book title together with each of its copies, and say who has each copy.

### Step 1: the cursor joins the two tables

- `LEFT JOIN Book_copy bc ON bc.Title_ID = bt.T_ID` pairs each title with each of its copies. A title with 3 copies gives 3 rows.
- It is a `LEFT` join so a title with no copies still shows up once, with `B_ID` and `Student_ID` as NULL. A plain `JOIN` would drop it.
- `ORDER BY bt.T_ID, bc.B_ID` groups the copies under their title.

### Step 2: the record type

`TYPE t_book IS RECORD (...)` describes a row with four fields, and `v t_book;` creates one variable of that type. This is the record the exercise asks for: each row from the cursor is copied into `v` before it is printed.

### Step 3: the cursor FOR loop

`FOR r IN c LOOP` does the open, fetch and close for you:

- it opens `c` before the first pass,
- each pass fetches the next row into `r`,
- it stops when there are no rows left and closes `c`.

Compare that with exercise 1, where you wrote `OPEN`, `FETCH`, `%FOUND` and `CLOSE` yourself. You don't declare `r` either. Oracle creates it as a record with the cursor's columns.

### Step 4: copy and print

- The four assignments copy `r` into `v` field by field.
- `NVL(TO_CHAR(v.Student_ID), 'available')`: a copy with no student is free, so we print `available` instead of an empty value. `TO_CHAR` is needed because `NVL` needs both values to be the same type, and `'available'` is text.
- `NVL(TO_CHAR(v.B_ID), 'none')` only matters for a title with no copies.

Output:

```
10 Introduction to Algorithms | copy: 101 | borrowed by: 1
10 Introduction to Algorithms | copy: 102 | borrowed by: available
20 Database System Concepts | copy: 201 | borrowed by: 2
30 Clean Code | copy: 301 | borrowed by: 5
40 The C Programming Language | copy: 401 | borrowed by: 4
50 SQL Pocket Guide | copy: 501 | borrowed by: 3
50 SQL Pocket Guide | copy: 502 | borrowed by: 1
60 Oracle Cheat Sheet | copy: 601 | borrowed by: 2
60 Oracle Cheat Sheet | copy: 602 | borrowed by: available
```

---

## Exercise 3: change the publisher through a collection

```sql
DECLARE
    TYPE t_book IS RECORD (
        T_ID       Book_title.T_ID%TYPE,
        Publisher  Book_title.Publisher%TYPE
    );
    TYPE t_books IS TABLE OF t_book INDEX BY PLS_INTEGER;
    v_books t_books;
    n PLS_INTEGER;
BEGIN
    -- available = copy with no student (same rule as lab 4)
    FOR r IN (SELECT bt.T_ID, bt.Publisher
                FROM Book_title bt
               WHERE (SELECT COUNT(*) FROM Book_copy bc
                       WHERE bc.Title_ID = bt.T_ID
                         AND bc.Student_ID IS NULL) < 3
               ORDER BY bt.T_ID) LOOP
        n := v_books.COUNT + 1;
        v_books(n).T_ID      := r.T_ID;
        v_books(n).Publisher := r.Publisher;
    END LOOP;

    -- FIRST/LAST are NULL on an empty collection, and a FOR over NULL bounds fails
    IF v_books.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No book has fewer than 3 available copies');
        RETURN;
    END IF;

    FOR i IN v_books.FIRST .. v_books.LAST LOOP
        v_books(i).Publisher := 'UPT_ORACLE';
    END LOOP;

    FOR i IN v_books.FIRST .. v_books.LAST LOOP
        UPDATE Book_title
           SET Publisher = v_books(i).Publisher
         WHERE T_ID = v_books(i).T_ID;
        DBMS_OUTPUT.PUT_LINE('Book ' || v_books(i).T_ID || ' publisher -> ' || v_books(i).Publisher);
    END LOOP;
END;
/
```

**Goal:** find the titles with fewer than 3 free copies, load them into a collection, change the publisher in the collection, then write the change back to `Book_title`.

### Step 1: the types

- `t_book` is a record with the two fields we need: the ID (to know which row to update) and the publisher (the value we change).
- `t_books` is an index-by table of those records, the same kind of collection as in lab 5. `v_books(1).Publisher` is the publisher of the first book in it.

### Step 2: which titles qualify

"Available" means a copy no student has, so `Student_ID IS NULL`. This is the same rule as lab 4.

The subquery `(SELECT COUNT(*) FROM Book_copy bc WHERE bc.Title_ID = bt.T_ID AND bc.Student_ID IS NULL)` runs once per title and counts its free copies. The outer `WHERE ... < 3` keeps titles where that count is 0, 1 or 2. A title with no copies at all counts 0, so it is included too.

With the lab data:

| T_ID | Free copies | Kept? |
|---|---|---|
| 10 | 1 (copy 102) | yes |
| 20 | 0 | yes |
| 30 | 0 | yes |
| 40 | 0 | yes |
| 50 | 0 | yes |
| 60 | 1 (copy 602) | yes |

Every title has fewer than 3 free copies, so all six get the new publisher. Add three free copies to one title and that title would be skipped.

### Step 3: load the collection with FOR IN

`FOR r IN (SELECT ...) LOOP` is a cursor FOR loop with the query written inline instead of declared as a named cursor. Each pass puts the row at position `v_books.COUNT + 1`, so the positions are 1, 2, 3, ... with no gaps.

### Step 4: guard against an empty collection

`FIRST` and `LAST` return the lowest and highest position in the collection. If no title qualified, the collection is empty and both return NULL. A `FOR i IN NULL .. NULL` loop raises an error, so the block prints a message and stops with `RETURN` before it gets there.

### Step 5: change the publisher in the collection

`FOR i IN v_books.FIRST .. v_books.LAST` goes from position 1 to position 6. Each pass sets `Publisher` to `'UPT_ORACLE'`. Up to here only the collection in memory has changed. The table still has the old publishers.

### Step 6: write the collection back to the table

The second loop goes over the same positions and runs one `UPDATE` per element. `WHERE T_ID = v_books(i).T_ID` picks the matching row, and `SET Publisher = v_books(i).Publisher` copies the value from the collection.

`FIRST .. LAST` works here because the collection has no gaps. In lab 5, exercise 3 deleted elements, so it had to walk with `FIRST` and `NEXT` instead.

Output:

```
Book 10 publisher -> UPT_ORACLE
Book 20 publisher -> UPT_ORACLE
Book 30 publisher -> UPT_ORACLE
Book 40 publisher -> UPT_ORACLE
Book 50 publisher -> UPT_ORACLE
Book 60 publisher -> UPT_ORACLE
```

To check the table afterwards:

```sql
SELECT T_ID, Title, Publisher FROM Book_title ORDER BY T_ID;
```

APEX commits each statement on its own (the Autocommit box in SQL Commands is ticked by default), so the change stays. To undo it, run the lab 3 script again.
