-- Exercise 1
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

-- Exercise 2
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

-- Exercise 3
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
