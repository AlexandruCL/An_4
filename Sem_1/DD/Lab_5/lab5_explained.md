# Lab 5 explained

## First: what is a record?

In lab 4 you kept one student in three separate variables: `v_name`, `v_mark`, `v_year`. A record is one variable that holds all of those values together, each in a named slot called a field.

Think of it as one row of a table kept in memory. If `r` is a student record, then `r.Name` is the name, `r.Faculty` is the faculty, and so on. You read and write a field with a dot, the same way you wrote `r.Title` inside the `FOR` loop in lab 4 (that `r` was a record too, Oracle made it for you).

There are two ways to get a record:

| Way | Code | When to use it |
|---|---|---|
| Define the type yourself | `TYPE t_student IS RECORD (S_ID ..., Name ...);` then `r t_student;` | You choose the fields. Exercises 1 and 2 do this. |
| Copy the shape of a table row | `r Student%ROWTYPE;` | You want exactly the columns of the table. Exercise 3 does this. |

A record type is only a description. `TYPE ... IS RECORD` says what the fields are, and `r t_student;` creates the actual variable.

## Second: what is a collection?

A record holds one row. A collection holds many values of the same type, like an array. Exercise 3 uses an "index-by table", which is a list where each element has an integer position: `v_students(1)`, `v_students(2)`, and so on. Each element there is a whole student record, so `v_students(2).Name` is the name of the second student.

---

## Exercise 1: build a student record and insert it

```sql
DECLARE
    TYPE t_student IS RECORD (
        S_ID           Student.S_ID%TYPE,
        Name           Student.Name%TYPE,
        Year_of_study  Student.Year_of_study%TYPE,
        Faculty        Student.Faculty%TYPE,
        Average_mark   Student.Average_mark%TYPE
    );
    r t_student;
BEGIN
    SELECT NVL(MAX(S_ID), 0) + 1 INTO r.S_ID FROM Student;
    r.Name          := 'Ionescu Maria';
    r.Year_of_study := 2;
    r.Faculty       := 'AC';
    r.Average_mark  := 8.50;

    INSERT INTO Student VALUES r;

    DBMS_OUTPUT.PUT_LINE('Inserted student ' || r.S_ID || ' ' || r.Name);
END;
```

**Goal:** make a record with the same five columns as `Student`, fill it, and insert it as a new row.

### Step 1: define the record type

- `TYPE t_student IS RECORD (...)` creates a new type named `t_student` with five fields.
- Each field uses `%TYPE`, so it has the same type as the matching column in `Student`.
- The fields are in the same order as the table columns. That order matters in step 3.
- `r t_student;` creates one variable of that type. All its fields start as NULL.

### Step 2: fill the fields

- `SELECT NVL(MAX(S_ID), 0) + 1 INTO r.S_ID` finds the biggest ID in the table and adds 1. With the lab data the biggest ID is 5, so `r.S_ID` becomes **6**.
- `NVL(..., 0)` covers an empty table: `MAX` would return NULL there, and `NVL` turns it into 0, so the first ID would be 1.
- The other four fields get their values with `:=`, one field at a time.

### Step 3: insert the whole record

- `INSERT INTO Student VALUES r;` inserts all five fields in one go. Note there are no parentheses around `r`.
- Oracle matches fields to columns by position, not by name. Field 1 goes to column 1, field 2 to column 2, and so on. That is why the record lists the fields in table order.

Output:

```
Inserted student 6 Ionescu Maria
```

Run it again and you get student 7, because the ID is calculated each time.

---

## Exercise 2: first title with more than two copies

```sql
DECLARE
    TYPE t_title IS RECORD (
        T_ID    Book_title.T_ID%TYPE,
        Title   Book_title.Title%TYPE,
        Copies  NUMBER
    );
    r t_title;
BEGIN
    SELECT bt.T_ID, bt.Title, COUNT(*)
      INTO r
      FROM Book_title bt
      JOIN Book_copy bc ON bc.Title_ID = bt.T_ID
     GROUP BY bt.T_ID, bt.Title
    HAVING COUNT(*) > 2
     ORDER BY bt.T_ID
     FETCH FIRST 1 ROW ONLY;

    DBMS_OUTPUT.PUT_LINE(r.T_ID || ' ' || r.Title || ' copies: ' || r.Copies);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No book title has more than two copies');
END;
```

**Goal:** find the first book title that has more than two copies, store it in a record, and print it.

### Step 1: the record type

- `Book_title` has no "number of copies" column. The copies are rows in `Book_copy`, so the number has to be counted.
- That is why the record is defined by hand: two fields come from `Book_title`, and the third, `Copies`, is a plain `NUMBER` for the count. `%ROWTYPE` could not do this, because no table has this exact shape.

### Step 2: the query

| Part | What it does |
|---|---|
| `JOIN Book_copy bc ON bc.Title_ID = bt.T_ID` | pairs each title with its copies, one row per copy |
| `GROUP BY bt.T_ID, bt.Title` | folds those rows into one row per title |
| `COUNT(*)` | number of copies in each group |
| `HAVING COUNT(*) > 2` | keeps only titles with more than two copies |
| `ORDER BY bt.T_ID` | puts them in a fixed order, so "first" means the smallest ID |
| `FETCH FIRST 1 ROW ONLY` | keeps only the first row |

`HAVING` is `WHERE` for groups. `WHERE` runs before the counting, so it cannot test a count.

### Step 3: `INTO r`

- In lab 4 you wrote `INTO v_name, v_mark, v_year`, one variable per column.
- Here `INTO r` fills the whole record at once: column 1 goes to `r.T_ID`, column 2 to `r.Title`, column 3 to `r.Copies`. Again matched by position.

### Step 4: `EXCEPTION`

With the lab 3 data, no title has more than two copies (titles 10, 50 and 60 have two each, the rest have one). The query returns no row, `SELECT INTO` raises `NO_DATA_FOUND`, and the block prints:

```
No book title has more than two copies
```

To see a real result, add a third copy of title 10 first:

```sql
INSERT INTO Book_copy VALUES (103, 10, NULL, NULL, NULL);
```

Then the output is:

```
10 Introduction to Algorithms copies: 3
```

---

## Exercise 3: load all students into a collection and change them

```sql
DECLARE
    CURSOR c IS SELECT * FROM Student ORDER BY S_ID;
    TYPE t_students IS TABLE OF Student%ROWTYPE INDEX BY PLS_INTEGER;
    v_students t_students;
    r Student%ROWTYPE;
    i PLS_INTEGER;
BEGIN
    OPEN c;
    LOOP
        FETCH c INTO r;
        EXIT WHEN c%NOTFOUND;
        v_students(v_students.COUNT + 1) := r;
    END LOOP;
    CLOSE c;

    -- a)
    FOR j IN 1 .. v_students.COUNT LOOP
        v_students(j).Faculty := 'ETC';
    END LOOP;

    -- b)
    FOR j IN 1 .. v_students.COUNT LOOP
        IF v_students(j).Average_mark > 5 THEN
            IF v_students(j).Year_of_study = 4 THEN
                v_students.DELETE(j);
            ELSE
                v_students(j).Year_of_study := v_students(j).Year_of_study + 1;
            END IF;
        END IF;
    END LOOP;

    -- c) FIRST/NEXT because the deletes left gaps in the index
    i := v_students.FIRST;
    WHILE i IS NOT NULL LOOP
        DBMS_OUTPUT.PUT_LINE(
            v_students(i).S_ID || ' ' || v_students(i).Name || ' ' ||
            v_students(i).Year_of_study || ' ' || v_students(i).Faculty || ' ' ||
            v_students(i).Average_mark);
        i := v_students.NEXT(i);
    END LOOP;
END;
```

**Goal:** copy every student into memory, change the copies, and print them.

Everything here happens in the collection. The `Student` table itself is not changed.

### Step 1: `DECLARE`

- `CURSOR c IS SELECT ...`: a cursor is a named query. Declaring it does not run it yet.
- `TYPE t_students IS TABLE OF Student%ROWTYPE INDEX BY PLS_INTEGER`: the collection type. Each element is a full student row, and the position is an integer.
- `v_students t_students;`: the collection itself. It starts empty.
- `r Student%ROWTYPE;`: one record that holds the row being read.
- `i`: a position in the collection, used for printing at the end.

### Step 2: read the rows with the cursor

In lab 4 the `FOR r IN (...)` loop opened, fetched and closed for you. Here the same three things are written out:

- `OPEN c` runs the query.
- `FETCH c INTO r` copies the next row into the record `r`.
- `EXIT WHEN c%NOTFOUND` leaves the loop when the last fetch found no more rows. It comes right after the fetch, so the leftover row is not stored twice.
- `v_students(v_students.COUNT + 1) := r` stores the row at the next free position. `COUNT` is how many elements exist: 0 at the start, so the first row goes to position 1, the next to 2, and so on.
- `CLOSE c` releases the cursor.

After this step, assuming exercise 1 added student 6:

| Position | S_ID | Name | Year | Faculty | Mark |
|---|---|---|---|---|---|
| 1 | 1 | Cristea Alexandru | 4 | AC | 9.75 |
| 2 | 2 | Toma Ionut | 3 | AC | 8.90 |
| 3 | 3 | Pop Patric | 2 | AC | 9.60 |
| 4 | 4 | Boros Fabian | 4 | AC | 7.60 |
| 5 | 5 | Bujanca Cristian | 1 | AC | 8.90 |
| 6 | 6 | Ionescu Maria | 2 | AC | 8.50 |

### Step 3: a) change the faculty

- `FOR j IN 1 .. v_students.COUNT` walks through positions 1 to 6.
- `v_students(j).Faculty := 'ETC'` reads as: element `j` of the collection, field `Faculty`. Every student now has `ETC`.

### Step 4: b) delete or promote

For each student with a mark above 5:

- year 4: `v_students.DELETE(j)` removes that element from the collection.
- any other year: the year goes up by 1.

A student with a mark of 5 or less is left alone.

`1 .. v_students.COUNT` is calculated once, when the loop starts, so the loop still visits all 6 positions even though elements are deleted along the way.

| Position | Student | Mark > 5? | Year | What happens |
|---|---|---|---|---|
| 1 | Cristea Alexandru | yes | 4 | deleted |
| 2 | Toma Ionut | yes | 3 | year becomes 4 |
| 3 | Pop Patric | yes | 2 | year becomes 3 |
| 4 | Boros Fabian | yes | 4 | deleted |
| 5 | Bujanca Cristian | yes | 1 | year becomes 2 |
| 6 | Ionescu Maria | yes | 2 | year becomes 3 |

Toma Ionut reaches year 4 but is not deleted. The delete check ran on his old year, 3.

### Step 5: c) print the collection

After the deletes, positions 1 and 4 are gone. The collection has holes: 2, 3, 5, 6. A plain `FOR j IN 1 .. COUNT` loop would fail here, because `COUNT` is now 4 and reading the missing position 1 raises `NO_DATA_FOUND`.

So the loop jumps from one existing element to the next:

- `v_students.FIRST` gives the smallest existing position, **2**.
- `v_students.NEXT(i)` gives the next existing position after `i`: 2 → 3 → 5 → 6.
- After the last element, `NEXT` returns NULL, and `WHILE i IS NOT NULL` stops the loop.

Output:

```
2 Toma Ionut 4 ETC 8.9
3 Pop Patric 3 ETC 9.6
5 Bujanca Cristian 2 ETC 8.9
6 Ionescu Maria 3 ETC 8.5
```

The marks print as `8.9` and not `8.90` because a number joined with `||` drops its trailing zeros, the same as `TO_CHAR` in lab 4.

---

## Summary of the PL/SQL used

- Exercise 1: a record type defined with `TYPE ... IS RECORD`, fields filled with `:=`, and `INSERT ... VALUES r` to insert the whole record.
- Exercise 2: a record with a calculated field, filled by one `SELECT ... INTO r`, with `GROUP BY` and `HAVING` to count copies.
- Exercise 3: an explicit cursor (`OPEN`, `FETCH`, `CLOSE`), a collection of `%ROWTYPE` records, `DELETE` on a collection, and `FIRST` / `NEXT` to walk a collection with holes.
