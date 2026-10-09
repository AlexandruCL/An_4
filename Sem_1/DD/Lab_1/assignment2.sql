DELETE FROM Student s
    WHERE NOT EXISTS(
        SELECT 1
            FROM Book_copy bc 
            WHERE bc.Student_ID = s.S_ID
    );

INSERT INTO Book_title VALUES (60, 'Computer Networks',          'A. Tanenbaum',                 2010, 'McGraw-Hill',  960);
INSERT INTO Book_title VALUES (70, 'Compilers: Principles',      'A. Aho, M. Lam, R. Sethi, J. Ullman', 2006, 'McGraw-Hill', 1040);

INSERT INTO Book_title VALUES (80, 'Baze de Date',               'I. Jurca',                     2015, 'Editura UPT',  320);
INSERT INTO Book_title VALUES (90, 'Programare in C',            'V. Cretu',                     2017, 'Editura UPT',  410);
INSERT INTO Book_title VALUES (100,'Sisteme de Operare',         'M. Popa',                      2019, 'Editura UPT',  380);

INSERT INTO Book_copy VALUES (601, 60, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (602, 60, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (603, 60, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (604, 60, NULL, NULL,              NULL);

INSERT INTO Book_copy VALUES (701, 70, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (702, 70, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (703, 70, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (704, 70, NULL, NULL,              NULL);

INSERT INTO Book_copy VALUES (801, 80, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (802, 80, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (803, 80, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (804, 80, NULL, NULL,              NULL);

INSERT INTO Book_copy VALUES (901, 90, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (902, 90, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (903, 90, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (904, 90, NULL, NULL,              NULL);

INSERT INTO Book_copy VALUES (1001, 100, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (1002, 100, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (1003, 100, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (1004, 100, NULL, NULL,              NULL);
INSERT INTO Book_copy VALUES (1005, 100, NULL, NULL,              NULL);

SELECT '[' ||
       SUBSTR(a1, 1, 1) || SUBSTR(a1, INSTR(a1, '. ') + 2, 1) ||
       SUBSTR(a2, 1, 1) || SUBSTR(a2, INSTR(a2, '. ') + 2, 1) ||
       SUBSTR(a3, 1, 1) || SUBSTR(a3, INSTR(a3, '. ') + 2, 1) ||
       SUBSTR(a4, 1, 1) || SUBSTR(a4, INSTR(a4, '. ') + 2, 1) ||
       SUBSTR(TO_CHAR(Year), 3, 2) ||
       '] ' ||
       Authors || ', "' ||
       Title || '", ' ||
       Publisher || ', ' ||
       TO_CHAR(Year) || ', ' ||
       TO_CHAR(Page_number) || ' pgs.'  AS Reference
  FROM (
        SELECT T_ID, Authors, Title, Publisher, Year, Page_number,
               TRIM(SUBSTR(list, 1, INSTR(list, ', ', 1, 1) - 1)) AS a1,
               TRIM(SUBSTR(list, INSTR(list, ', ', 1, 1) + 2,
                                 INSTR(list, ', ', 1, 2) - INSTR(list, ', ', 1, 1) - 2)) AS a2,
               TRIM(SUBSTR(list, INSTR(list, ', ', 1, 2) + 2,
                                 INSTR(list, ', ', 1, 3) - INSTR(list, ', ', 1, 2) - 2)) AS a3,
               TRIM(SUBSTR(list, INSTR(list, ', ', 1, 3) + 2,
                                 INSTR(list, ', ', 1, 4) - INSTR(list, ', ', 1, 3) - 2)) AS a4
          FROM (
                SELECT bt.*, bt.Authors || ', ' AS list
                  FROM Book_title bt
               )
       )
 ORDER BY T_ID;

--  SELECT '[' ||
--        REGEXP_REPLACE(Authors, '[^A-Z]','')||
--        SUBSTR(TO_CHAR(Year), 3, 2) ||
--        '] ' ||
--        Authors || ', "' ||
--        Title || '", ' ||
--        Publisher || ', ' ||
--        TO_CHAR(Year) || ', ' ||
--        TO_CHAR(Page_number) || ' pgs.'  AS Reference
--   FROM Book_title
--  ORDER BY T_ID;

SELECT bt.T_ID,
       bt.Title,
       bt.Publisher,
       DECODE(bt.Publisher, 'Editura UPT', 'local', 'abroad') AS Origin,
       COUNT(bc.B_ID) AS Available_copies
  FROM Book_title bt
  JOIN Book_copy bc ON bc.Title_ID = bt.T_ID
 WHERE bc.Student_ID IS NULL          
 GROUP BY bt.T_ID, bt.Title, bt.Publisher
HAVING COUNT(bc.B_ID) > 3
 ORDER BY bt.T_ID;
