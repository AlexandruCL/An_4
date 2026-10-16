INSERT INTO Student (S_ID, Name, Year_of_study, Faculty, Average_mark)
VALUES ((SELECT NVL(MAX(S_ID), 0) + 1 FROM Student),
        :name, :year_of_study, :faculty, :average_mark);


CREATE OR REPLACE VIEW Borrowed_books AS
SELECT bt.T_ID,
       bt.Title,
       bt.Authors,
       bt.Year,
       bt.Publisher,
       bt.Page_number AS Pg_nr
  FROM Book_title bt
 WHERE EXISTS (SELECT 1
                 FROM Book_copy bc
                WHERE bc.Title_ID = bt.T_ID
                  AND bc.Student_ID IS NOT NULL);


CREATE OR REPLACE VIEW Books_with_students AS
SELECT bc.B_ID,
       bt.T_ID,
       bt.Title,
       bt.Authors,
       bt.Year,
       bt.Publisher,
       bt.Page_number AS Pg_nr,
       bc."Start",
       bc."End",
       s.S_ID,
       NVL(s.Name, 'Not borrowed') AS Student_name,
       s.Year_of_study,
       s.Faculty,
       s.Average_mark
  FROM Book_copy bc
  JOIN Book_title bt   ON bt.T_ID = bc.Title_ID
  LEFT JOIN Student s  ON s.S_ID  = bc.Student_ID;

