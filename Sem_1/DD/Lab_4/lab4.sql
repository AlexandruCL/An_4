-- Exercise 1
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


-- Exercise 2
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

