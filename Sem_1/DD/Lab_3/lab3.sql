DROP TABLE Book_copy;
DROP TABLE Book_title;
DROP TABLE Student;
DROP SEQUENCE borrow_seq;

CREATE TABLE Book_title (
    T_ID         NUMBER(5),
    Title        VARCHAR2(100),
    Authors      VARCHAR2(100),
    Year         NUMBER(4),
    Publisher    VARCHAR2(60),
    Page_number  NUMBER(5)
);

CREATE TABLE Student (
    S_ID           NUMBER(5),
    Name           VARCHAR2(60),
    Year_of_study  NUMBER(1),
    Faculty        VARCHAR2(60),
    Average_mark   NUMBER(4,2)
);

CREATE TABLE Book_copy (
    B_ID        NUMBER(6),
    Title_ID    NUMBER(5),
    Student_ID  NUMBER(5),
    "Start"     DATE,
    "End"       DATE
);

ALTER TABLE Book_title ADD CONSTRAINT pk_book_title PRIMARY KEY (T_ID);
ALTER TABLE Student    ADD CONSTRAINT pk_student    PRIMARY KEY (S_ID);
ALTER TABLE Book_copy  ADD CONSTRAINT pk_book_copy  PRIMARY KEY (B_ID);

ALTER TABLE Book_copy ADD CONSTRAINT fk_copy_title
    FOREIGN KEY (Title_ID) REFERENCES Book_title(T_ID);
ALTER TABLE Book_copy ADD CONSTRAINT fk_copy_student
    FOREIGN KEY (Student_ID) REFERENCES Student(S_ID);

ALTER TABLE Book_copy MODIFY (Title_ID NOT NULL);

ALTER TABLE Book_title MODIFY (Title     NOT NULL);
ALTER TABLE Book_title MODIFY (Authors   NOT NULL);
ALTER TABLE Book_title MODIFY (Year      NOT NULL);
ALTER TABLE Book_title MODIFY (Publisher NOT NULL);

ALTER TABLE Book_title ADD CONSTRAINT ck_title_year
    CHECK (Year <= 2026);
ALTER TABLE Book_title ADD CONSTRAINT ck_title_pages
    CHECK (Page_number BETWEEN 0 AND 1500);

ALTER TABLE Book_copy ADD CONSTRAINT ck_copy_dates
    CHECK ("Start" < "End");

ALTER TABLE Student MODIFY (Name          NOT NULL);
ALTER TABLE Student MODIFY (Faculty       NOT NULL);
ALTER TABLE Student MODIFY (Year_of_study NOT NULL);
ALTER TABLE Student ADD CONSTRAINT ck_student_year
    CHECK (Year_of_study BETWEEN 1 AND 4);

INSERT INTO Student VALUES (1, 'Cristea Alexandru',   4, 'AC', 9.75);
INSERT INTO Student VALUES (2, 'Toma Ionut',          3, 'AC', 8.90);
INSERT INTO Student VALUES (3, 'Pop Patric',          2, 'AC', 9.60);
INSERT INTO Student VALUES (4, 'Boros Fabian',        4, 'AC', 7.60);
INSERT INTO Student VALUES (5, 'Bujanca Cristian',    1, 'AC', 8.90);

INSERT INTO Book_title VALUES (10, 'Introduction to Algorithms', 'T. Cormen, C. Leiserson, R. Rivest, C. Stein', 2009, 'MIT Press',     1312);
INSERT INTO Book_title VALUES (20, 'Database System Concepts',   'A. Silberschatz, H. Korth, S. Sudarshan',      2019, 'McGraw-Hill',    1376);
INSERT INTO Book_title VALUES (30, 'Clean Code',                 'R. Martin',                                    2008, 'Prentice Hall',   464);
INSERT INTO Book_title VALUES (40, 'The C Programming Language', 'B. Kernighan, D. Ritchie',                     1988, 'Prentice Hall',   272);
INSERT INTO Book_title VALUES (50, 'SQL Pocket Guide',           'J. Needham',                                   2020, 'Editura UPT',      80);
INSERT INTO Book_title VALUES (60, 'Oracle Cheat Sheet',         'M. Popa',                                      2022, 'Editura UPT',      60);

INSERT INTO Book_copy VALUES (101, 10, 1,    DATE '2026-09-01', DATE '2026-09-21');
INSERT INTO Book_copy VALUES (102, 10, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (201, 20, 2,    DATE '2026-09-05', DATE '2026-09-25');
INSERT INTO Book_copy VALUES (301, 30, 5,    DATE '2026-09-02', NULL);
INSERT INTO Book_copy VALUES (401, 40, 4,    DATE '2026-09-03', NULL);
INSERT INTO Book_copy VALUES (501, 50, 3,    DATE '2026-09-08', NULL);
INSERT INTO Book_copy VALUES (502, 50, 1,    DATE '2026-09-10', DATE '2026-09-20');
INSERT INTO Book_copy VALUES (601, 60, 2,    DATE '2026-09-12', NULL);
INSERT INTO Book_copy VALUES (602, 60, NULL, NULL,              NULL);


CREATE SEQUENCE borrow_seq START WITH 1 INCREMENT BY 1 NOCACHE;

SELECT borrow_seq.NEXTVAL AS Nr,
       s.Name             AS Student_name,
       bt.Title           AS Book_title
  FROM Book_copy bc
  JOIN Book_title bt ON bt.T_ID = bc.Title_ID
  JOIN Student s     ON s.S_ID  = bc.Student_ID
 WHERE bt.Page_number < 100;
