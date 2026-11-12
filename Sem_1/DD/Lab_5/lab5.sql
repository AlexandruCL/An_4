-- Exercise 1
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


-- Exercise 2
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


-- Exercise 3
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
