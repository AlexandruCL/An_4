DROP TABLE Book_copy;
DROP TABLE Book_title;
DROP TABLE Student;

CREATE TABLE Book_title (
    T_ID         NUMBER(5)        PRIMARY KEY,
    Title        VARCHAR2(100)    NOT NULL,
    Authors      VARCHAR2(100),
    Year         NUMBER(4),
    Publisher    VARCHAR2(60),
    Page_number  NUMBER(5)
);

CREATE TABLE Student (
    S_ID           NUMBER(5)      PRIMARY KEY,
    Name           VARCHAR2(60)   NOT NULL,
    Year_of_study  NUMBER(1),
    Faculty        VARCHAR2(60),
    Average_mark   NUMBER(4,2)
);

CREATE TABLE Book_copy (
    B_ID        NUMBER(6)     PRIMARY KEY,
    Title_ID    NUMBER(5)     NOT NULL,
    Student_ID  NUMBER(5),
    "Start"       DATE,
    "End"       DATE,
    CONSTRAINT fk_copy_title   FOREIGN KEY (Title_ID)   REFERENCES Book_title(T_ID),
    CONSTRAINT fk_copy_student FOREIGN KEY (Student_ID) REFERENCES Student(S_ID)
);

INSERT INTO Student VALUES (1, 'Cristea Alexandru',       4, 'AC', 9.25);
INSERT INTO Student VALUES (2, 'Toma Ionut',    3, 'AC', 10);
INSERT INTO Student VALUES (3, 'Pop Patric',   2, 'AC', 9.60);
INSERT INTO Student VALUES (4, 'Boros Fabian',      4, 'AC', 7.60);
INSERT INTO Student VALUES (5, 'Bujanca Cristian',    1, 'AC',   8.90);
INSERT INTO Student VALUES (6, 'Shehab Abedalrahman',     3, 'AC', 8.10);
INSERT INTO Student VALUES (7, 'Vlad Capalnasan',     2, 'AC', 7.40);

INSERT INTO Book_title VALUES (10, 'Introduction to Algorithms', 'T. Cormen, C. Leiserson, R. Rivest, C. Stein', 2009, 'MIT Press',      1312);
INSERT INTO Book_title VALUES (20, 'Database System Concepts',   'A. Silberschatz, H. Korth, S. Sudarshan',      2019, 'McGraw-Hill',     1376);
INSERT INTO Book_title VALUES (30, 'Clean Code',                 'R. Martin',                                    2008, 'Prentice Hall',    464);
INSERT INTO Book_title VALUES (40, 'The C Programming Language',  'B. Kernighan, D. Ritchie',                     1988, 'Prentice Hall',    272);
INSERT INTO Book_title VALUES (50, 'Operating System Concepts',  'A. Silberschatz, P. Galvin, G. Gagne',         2018, 'Wiley',            976);

INSERT INTO Book_copy VALUES (101, 10, 1,    DATE '2026-09-01', DATE '2026-09-21');
INSERT INTO Book_copy VALUES (102, 10, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (103, 10, 3,    DATE '2026-09-10', NULL);

INSERT INTO Book_copy VALUES (201, 20, 2,    DATE '2026-09-05', DATE '2026-09-25');
INSERT INTO Book_copy VALUES (202, 20, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (203, 20, 4,    DATE '2026-09-15', NULL);

INSERT INTO Book_copy VALUES (301, 30, 5,    DATE '2026-09-02', DATE '2026-09-16');
INSERT INTO Book_copy VALUES (302, 30, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (303, 30, 6,    DATE '2026-09-11', NULL);
INSERT INTO Book_copy VALUES (304, 30, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (305, 30, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (306, 30, NULL, NULL,              NULL);

INSERT INTO Book_copy VALUES (401, 40, 7,    DATE '2026-09-03', NULL);
INSERT INTO Book_copy VALUES (402, 40, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (403, 40, 1,    DATE '2026-09-12', DATE '2026-09-26');

INSERT INTO Book_copy VALUES (501, 50, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (502, 50, 2,    DATE '2026-09-08', NULL);
INSERT INTO Book_copy VALUES (503, 50, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (504, 50, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (505, 50, NULL, NULL,              NULL);

COMMIT;

UPDATE Book_copy
   SET Student_ID = NULL
 WHERE Student_ID IN (SELECT S_ID
                        FROM (SELECT S_ID
                                FROM Student
                               ORDER BY S_ID DESC)
                       WHERE ROWNUM <= 2);

DELETE FROM Student
 WHERE S_ID IN (SELECT S_ID
                  FROM (SELECT S_ID
                          FROM Student
                         ORDER BY S_ID DESC)
                 WHERE ROWNUM <= 2);


UPDATE Student SET Average_mark = 9.75 WHERE S_ID = 1;
UPDATE Student SET Average_mark = 8.90 WHERE S_ID = 2;


SELECT bt.T_ID,
       bt.Title,
       COUNT(bc.B_ID) AS Number_of_copies
  FROM Book_title bt
  LEFT JOIN Book_copy bc ON bc.Title_ID = bt.T_ID
 GROUP BY bt.T_ID, bt.Title
 ORDER BY bt.T_ID;
