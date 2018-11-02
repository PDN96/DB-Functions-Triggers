-- Problem 1
select A.x AS x, 
       sqrt(A.x) AS square_root_x, 
       power(A.x,2) AS x_squared, 
       power(2,A.x) AS two_to_the_power_x, 
       (A.x)! AS x_factorial, 
       ln(A.x) AS logarithm_x from A A;

/-- Problem 2
select 
    not exists(select * from A except select * from B) as empty_A_minus_B, 
    exists(select * from A except select * from B
           union
           select * from B except select * from A) as not_empty_symmetric_difference,
    not exists(select * from A intersect select * from B) as empty_A_intersection_B;

/* Problem 3
*/

select p1.x as x1, p1.y as y1, p2.x as x2, p2.y as y2
from Pair p1, Pair p2
where p1.x+p1.y = p2.x + p2.y and not(p1.x = p2.x and p2.y = p2.y);

-- Problem 4
select p.value as p, q.value as q, r.value as r, 
       not(not p.value or q.value) or r.value as value 
       from p p, q q, r r;

-- Problem 5.a
select exists((select a.x from A a) INTERSECT (select b.x from B b)) as answer;

select exists(select a.x from A a
              where  a.x in (select b.x from B b)) as answer;

-- Problem 5.b
select not exists((select a.x from A a) EXCEPT (select b.x from B b)) as answer;

select not exists(select a.x from A a 
                  where  a.x not in (select b.x from B b)) as answer;

-- Problem 5.c
select not exists((select b.x from B b) EXCEPT (select a.x from A a)) as answer;

select not exists(select b.x from B b
                  where  b.x not in (select a.x from A a)) as answer;

-- Problem 5.d
select  exists((select a.x from A a EXCEPT select b.x from B b)
               union
               (select b.x from B b EXCEPT select a.x from A a)) as value;

select  exists(select a.x from A a where a.x not in (select b.x from B b)) or
        exists(select b.x from B b where b.x not in (select a.x from A a)) as value;

-- Problem 5.e		
with A_intersection_B as (select * from a intersect select * from b)
select not exists(select 1
                  from   A_intersection_B a1, A_intersection_B a2
                  where  a1.x <> a2.x) as answer;

with A_intersection_B as (select a.x from a where a.x in (select b.x from b))
select not exists(select 1
                  from   A_intersection_B a1, A_intersection_B a2
                  where  a1.x <> a2.x) as answer;

-- Problem 5.f
with A_union_B as (select * from a union select * from b)
select not exists((select e.x from A_union_B e) EXCEPT (select c.x from C c)) as answer;                  
with A_union_B as (select * from a union select * from b)
select not exists(select e.x from A_union_B e where e.x not in (select c.x from C c)) as answer;                  
-- Problem 5.g
with A_minus_B_union_B_minus_C as ((select * from a except select * from B) union
                                          (select * from b except select * from C))
select exists(select 1 from A_minus_B_union_B_minus_C) and
       not exists (select 1 from A_minus_B_union_B_minus_C e1, 
                                 A_minus_B_union_B_minus_C e2
                   where   e1.x <> e2.x) as answer;

with A_minus_B_union_B_minus_C as (select a.x from a where a.x not in (select b.x from b) union
                                          select b.x from b where b.x not in (select c.x from C))
select exists(select 1 from A_minus_B_union_B_minus_C) and
       not exists (select 1 from A_minus_B_union_B_minus_C e1, 
                                 A_minus_B_union_B_minus_C e2
                   where   e1.x <> e2.x) as answer;

-- Problem 6.a
select (select count(1) from
         ((select a.x from A a) INTERSECT (select b.x from B b)) q) >= 1 as answer;

select (select count(1) from
         (select a.x from A a where a.x in (select b.x from B b)) q) >= 1 as answer;
-- Problem 6.b
select (select count(1) from
        ((select a.x from A a) EXCEPT (select b.x from B b)) q) = 0 as answer;

-- Problem 6.c
select (select count(1) from
         ((select b.x from B b) EXCEPT (select a.x from A a)) q) = 0 as answer;

-- Problem 6.d
select (select count(1) from
           ((select a.x from A a EXCEPT select b.x from B b)
             union
            (select b.x from B b EXCEPT select a.x from A a)) q) >= 1 as value;

-- Problem 6.e
with A_intersection_B as (select * from a intersect select * from b)
select (select count(1) from A_intersection_B) < 2 as value;

-- Problem 6.f
with A_union_B as (select * from a union select * from b)
select (select count(1) from
         ((select e.x from A_union_B e) EXCEPT (select c.x from C c)) q) = 0 as answer;                  

-- Problem 6.g
with A_minus_B_union_B_minus_C as ((select * from a except select * from B) union
                                          (select * from b except select * from C))
select (select count(1) from A_minus_B_union_B_minus_C) = 1 as value;

-- Problem 7
/*
 Let $W(A,B)$ be a relation schema.  The domain of $A$ is INTEGER and
  the domain of $B$ is VARCHAR(5).

  Write a SQL query with returns the $A$-values of tuples in $W$ if
  $A$ is a primary key of $W$.  Otherwise, i.e., if $A$ is not a
  primary key, then your query should return the $A$-values of tuples
  in $W$ for which the primary key property is violated.  (In this
  query you should consider creating views for intermediate results.)

 In the following violations are the A values where
the key property does not hold.  Violation can be empty or not.
This is what the union query takes advantages of. */

with violations as 
      (select distinct w.a
       from W w
       where exists(select 1
                    from   W w1
                    where  w.A = w1.A and w.B <> w1.B) )
select * from violations 
union  
select distinct w.a
from   W w
where  not exists (select 1 from violations);


-- Problem 8.a.i
/* 
Write a function {\tt booksBoughtbyStudent(sid int, out bookno int,
out title VARCHAR(30), out price integer)} that takes a student sid as
input and returns the book information of books bought by that
student.
*/

create or replace function booksBoughtbyStudent(student integer) 
     returns table(bookno integer, title varchar(30), price integer) as
$$
select b.bookno, b.title, b.price
from   buys t, book b
where  t.sid = student and t.bookno = b.bookno
order by bookno;
$$ language sql;

-- Problem 8.a.ii

select * from booksBoughtbyStudent(1001);

select * from booksBoughtbyStudent(1015);

-- Problem 8.a.iii.A 
/*
Find the sids and names of students who bought
exactly one book that cost less than \$50.
*/

select s.sid, s.sname
from   student s
where  (select count(1)
        from   (select * from booksBoughtbyStudent(s.sid)
                intersect
                select * from book where price < 50) q) = 1;

/*
 sid  | sname 
------+-------
 1011 | Nick
 1013 | Lisa
 1020 | Greg
 1040 | Pam
(4 rows)
*/

-- Problem 8.a.iii.B

/*
Find the pairs of different student sids (s1,s2) such that student s1
 and student s2 bought the same books.
*/

select s1.sid as s1, s2.sid as s1
from   student s1, student s2
where  (select count(1)
        from   (select * from booksBoughtbyStudent(s1.sid)
                except
                select * from booksBoughtbyStudent(s2.sid)) q) = 0 and
       (select count(1)
        from   (select * from booksBoughtbyStudent(s2.sid)
                except
                select * from booksBoughtbyStudent(s1.sid)) q) = 0 and
        s1.sid <> s2.sid;

/*
  s1  |  s1  
------+------
 1004 | 1006
 1005 | 1008
 1006 | 1004
 1008 | 1005
 1015 | 1016
 1016 | 1015
(6 rows)
*/


-- Problem 8.b.i
create or replace function studentsWhoBoughtBook(book integer) 
     returns table(sid integer, sname varchar(15)) as
$$
select s.sid, s.sname 
from   buys t, student s
where  t.bookno = book and t.sid = s.sid
order by sid;
$$ language sql;

-- Problem 8.b.ii

select * from studentsWhoBoughtBook(2001);

select * from studentsWhoBoughtBook(2010);

-- Problem 8.b.iii
/*
Using this function and the {\tt booksBoughtbyStudent} function from
problem~\ref{booksBought} write the query ``Find the booknos of books
bought by a least two CS students who each bought at least one book
that cost more that \$30."
*/

with CS_studentsWhoBoughtBookAbove30 as
(select s.sid, s.sname
from   student s
where  s.sid in (select m.sid
                 from   major m, buys t, book b
                 where  m.major = 'CS' and
                        m.sid = t.sid and t.bookno = b.bookno and
                        b.price > 30))
select b.bookno
from   book b
where  (select count(1)
        from   (select * from CS_studentsWhoBoughtBookAbove30
                intersect
                select * from studentsWhoBoughtBook(b.bookno)) q) >= 2;

/*
 bookno 
--------
   2001
   2002
   2006
   2007
   2008
   2012
   2013
   2011
(8 rows
*/

--Problem 8.c.i

/* Find the sid and major of each student who
bought at least 4 books that cost more than \$30
*/

create or replace function books_that_cost_more_than(price integer) 
     returns table(bookno integer, title varchar(30), price integer) as
$$
select b.bookno, b.title, b.price
from   book b
where  b.price > books_that_cost_more_than.price
order by bookno;
$$ language sql;

select m.sid, m.major
from   major m
where  (select count(1)
        from   (select * from booksBoughtbyStudent(m.sid)
                intersect 
                select * from books_that_cost_more_than(30)) b) >= 4;

/*
sid  |  major  
------+---------
 1002 | CS
 1002 | Math
 1004 | CS
 1006 | CS
 1007 | CS
 1007 | Physics
 1009 | Biology
 1010 | Biology
(8 rows)
*/


--Problem 8.c.ii
/*  Find the pairs $(s_1,s_2)$ of different students who spent the same
amount of money on the books they bought.
*/

select s1.sid as s1, s2.sid as s2
from   student s1, student s2
where  (select sum(price)
        from   booksBoughtbyStudent(s1.sid)) =
       (select sum(price)
        from   booksBoughtbyStudent(s2.sid)) and
       s1.sid <> s2.sid;

--Problem 8.c.iii
/*
Find the sid and name of each student who spent more money on
the books he or she bought than the average cost that was spent on books by
students who major in `CS'.
*/


create or replace function cost_spent_on_books_by(student integer)
       returns bigint as
$$
select sum(price)
from   booksBoughtbyStudent(student);
$$ language SQL;

select avg(cost_spent_on_books_by(m.sid))
from   major m
where  m.major = 'CS';

select s.sid, s.sname
from   student s
where  cost_spent_on_books_by(s.sid) >
       (select avg(cost_spent_on_books_by(m.sid))
        from   major m
        where  m.major = 'CS');

/*
 sid  |   sname   
------+-----------
 1002 | Maria
 1003 | Anna
 1004 | Chin
 1006 | Ryan
 1007 | Catherine
 1009 | Jan
 1010 | Linda
 1017 | Ellen
(8 rows)
*/


--Problem 8.c.iv       
/*
Find the booknos and titles of the third most expensive books.
*/

select q.bookno, q.title
from   (select b.bookno, b.title, (select count(1)
                                   from   book  b1
                                   where  b1.price > b.price) + 1 as rank
        from   book b) q
where q.rank = 3;

/*
 bookno |    title     
--------+--------------
   2008 | DataScience
   2011 | Anthropology
(2 rows)
*/

--Problem 8.c.v

/* Find the bookno and title of each book that is only bought by students 
who major in `CS'.  (Make sure to use the COUNT aggregate function instead of
the EXISTS predicate.)
*/

/*
select b.bookno, b.title
from   book b
where  not exists (select t.sid
                   from   buys t
                   where  t.bookno = b.bookno
                   except
                   select m.sid
                   from   major m
                   where  m.major = 'CS');
*/


select b.bookno, b.title
from   book b
where  (select count (1)
          from (select sid
                from   studentsWhoBoughtBook(b.bookno)
                except
                select m.sid
                from   major m
                where  m.major = 'CS') q) = 0;

/*
 bookno |        title        
--------+---------------------
   2004 | AI
   2005 | DiscreteMathematics
   2006 | SQL
   2010 | Philosophy
(4 rows)
*/


--Problem 8.c.vi

/* Find the sid and name of each student who not only bought books that
were bought by at least two 'CS' students.
(Make sure to use the COUNT aggregate function instead of
the EXISTS predicate.)
*/

select s.sid, s.sname 
from   student s 
where (select count(1) 
       from (select b.bookno from 
             booksBoughtbyStudent(s.sid) b 
             except 
             select t1.bookno
             from buys t1, buys t2, major m1, major m2
             where m1.sid <> m2.sid and m1.major = 'CS' and m2.major = 'CS' and 
                   t1.sid = m1.sid and t2.sid = m2.sid and t1.bookno = t2.bookno) q) >= 1;

/* ALternatively,
*/

select s.sid, s.sname
from   student s
where  (select count(1)
        from   (select b.bookno
                from   booksBoughtbyStudent(s.sid) b
                except
                select bookno
                from   book b
                where  (select count(1)
                        from   studentsWhoBoughtBook(b.bookno) s, major m
                        where  s.sid = m.sid and m.major = 'CS') >= 2) q) >= 1;

/*
 sid  |   sname   
------+-----------
 1001 | Jean
 1007 | Catherine
 1010 | Linda
 1017 | Ellen
 1022 | Qin
 1023 | Melanie
(6 rows)
*/

--Problem 8.c.vii

/* Find each $(s,b)$ pair where $s$ is the sid of a student and where $b$
is the bookno of a book bought that student whose price is strictly below the average
price of the books bought by that student.
*/

select s.sid, b.bookno
from   student s, lateral booksBoughtbyStudent(s.sid) b
where  b.price < (select avg(price)
                  from   booksBoughtbyStudent(s.sid));

/* The answer has 44 rows */


--Problem 8.c.viii
/* Find each pair $(s_1,s_2)$ where $s_1$ and $s_2$ are the sids of
different students who have a common major and who bought the same
number of books.
*/

select m1.sid as s1, m2.sid as s2
from   major m1, major m2
where  m1.sid <> m2.sid and m1.major = m2.major and
       (select count(1)
        from   booksBoughtbyStudent(m1.sid)) =
       (select count(1)
        from   booksBoughtbyStudent(m2.sid));

/*
  s1  |  s2  
------+------
 1001 | 1003
 1002 | 1006
 1002 | 1004
 1003 | 1001
 1004 | 1006
 1004 | 1002
 1006 | 1004
 1006 | 1002
 1011 | 1013
 1013 | 1011
(10 rows)
*/

--Problem 8.c.ix
/* Find the triples $(s_1,s_2,n)$ where $s_1$ and $s_2$ are the sids of
students who share a major and where $n$ is the number of books that was bought by
student $s_1$ but not by student $s_2$.
*/

select m1.sid as s1, m2.sid as s2, (select count(1)
                                    from   (select b.bookno
                                            from   booksBoughtbyStudent(m1.sid) b
                                            except 
                                            select b.bookno
                                            from   booksBoughtbyStudent(m2.sid) b) q) as n
from   major m1, major m2
where  m1.major = m2.major and
       m1.sid <> m2.sid order by s1, s2, n;

/* number of triples is 76
*/


--Problem 8.c.x
/* Find the bookno of each book that was bought buy all-but-one student who majors in 'CS'.
*/

select b.bookno
from   book b
where  (select count (1)
        from   (select m.sid
                from   major m
                where  m.major = 'CS'
                except
                select s.sid
                from   studentsWhoBoughtBook(b.bookno) s) q) = 1;
/*
 bookno 
--------
   2012
   2011
(2 rows)
*/


/* In this example we have a base table Student and
a view CS_student.   We now show how triggers can be used
to insert and delete tupe in the view CS_student.  The
triggers operate by propragating the insert and deletes
to the base table Student */

-- Problem 9
/*
Develop appropriate triggers to permit (1) inserts and deletes in the
Enroll relation and (2) deletes in the Waitlist governed by the
following constraints:
*/

/*
A student can only enroll in a course if he or she has taken all the prerequisites
for that course.  If the enrollment succeeds, the total enrollment for that course
needs to be incremented by $1$.
*/

/* A student can only enroll in a course if his or her enrollment does
not exceed the maximum enrollment for that course.  However, the
student must then be placed at the next available position on the
waitlist for that course.
*/

/*
A student can drop a course.   When this happens and if there are students on the waitlist
for that course, then the student who is at the first position gets enrolled and removed from the
waitlist.  If there are no students on the waitlist, then the total enrollment for that course needs
to decrease by $1$.
*/

/* A student may remove himself or herself from the waitlist for a
course.  When this happens, the positions of the other students who
are waitlisted for that course need to be adjusted.
*/

CREATE TABLE Student (sid int, sname text);
CREATE TABLE Course(cno int, cname text, total int, max int);
CREATE TABLE Prerequisite(cno int, prereq int);
CREATE TABLE HasTaken(sid int, cno int);

/* The following relation is crucial for the solution*/
CREATE TABLE EnrollWait(sid int, cno int, location int);
/* Location 0 means enrolled;
   Location > 0 is location on the waitlist for a course
   We will maintain the waitlist for a course as a queue
*/

/* We can then define two views over EnrollWait.  The first for the enroll records,
and the second for the waitlist records.   Once this is
done, we can define triggers on these views to insert and
delete enrollment records with the constraints specified in the
problem.   The EnrollWait can be interpreted as combined materialized
views for Enroll and Waitlist */
CREATE VIEW Enroll AS 
      SELECT sid, cno
      FROM   EnrollWait 
      WHERE  location = 0;

CREATE VIEW Waitlist AS
      SELECT sid, cno, location
      FROM   EnrollWait 
      WHERE  location > 0;

INSERT INTO student values(1, 'John'), (2, 'Mary');

INSERT INTO course values(100, 'DiscreteMath', 0, 3), (101, 'PL', 0, 3), (102, 'Calculus', 0, 3);
INSERT INTO course values(201, 'Topology', 0, 3), (202, 'Databases', 0, 3), (300, 'AI', 0, 3);

INSERT INTO prerequisite values (201, 100), (201, 101), 
                                (202, 100), (202, 101), (300, 201), (300, 102);

INSERT INTO hastaken values(1,100), (1,101), (2,100), (2,101),
                           (3,100), (3,101), (4,100), (4,101),
                           (5,100), (5,101);

INSERT INTO enrollwait values (1,201,0), (2,201,0), (3,201,1), (4,201,2);

CREATE OR REPLACE FUNCTION capacityReached(course int) RETURNS BOOLEAN AS
$$
SELECT c.total >= c.max
FROM   Course c
WHERE  c.cno = course;
$$ LANGUAGE SQL;


/* This function can be thought of as looking where the front
of the queue is
*/

CREATE OR REPLACE FUNCTION minLocation(course int) RETURNS int AS
$$
SELECT CASE WHEN EXISTS (SELECT 1
                         FROM   EnrollWait w 
                         WHERE  w.cno = course and w.location > 0) 
            THEN (SELECT MIN(w.location)
                  FROM   EnrollWait w
                  WHERE  w.cno = course and w.location > 0)
            ELSE (SELECT 0)
       END;
$$ LANGUAGE SQL;

/* This function can be thought of as looking where the end
of the queue is
*/
CREATE OR REPLACE FUNCTION maxLocation(course int) RETURNS int AS
$$
SELECT CASE WHEN EXISTS (SELECT 1
                         FROM   EnrollWait w 
                         WHERE  w.cno = course and w.location > 0) 
            THEN (SELECT MAX(w.location)
                  FROM   EnrollWait w
                  WHERE  w.cno = course and w.location > 0)
            ELSE (SELECT 0)
       END;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION HasPrerequisites(student int, course int) 
     RETURNS boolean AS
$$
SELECT NOT EXISTS (SELECT prereq
                   FROM   Prerequisite 
                   WHERE  cno = course AND
                          prereq NOT IN(SELECT cno
                                        FROM   Hastaken
                                        WHERE  sid = student));
$$ LANGUAGE SQL;


/* The following trigger function and trigger accomplish the insertion
in the view Enroll*/


CREATE OR REPLACE FUNCTION insertInEnrollOrWaitlist() RETURNS trigger AS
$$
BEGIN
    IF HasPrerequisites(NEW.sid, NEW.cno)
    THEN 
       IF NOT capacityReached(NEW.cno)
       THEN
          INSERT INTO EnrollWait VALUES (NEW.sid, NEW.cno, 0);
          UPDATE Course SET total = total +1 WHERE cno=NEW.cno;
       ELSE
          INSERT INTO EnrollWait VALUES (NEW.sid, NEW.cno, 
                                  (SELECT maxLocation(NEW.cno)) + 1);
       END IF;
     ELSE RAISE EXCEPTION 'student does not have prerequisite courses';
     END IF;
     RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER add_Enroll_or_Wait
    INSTEAD OF INSERT ON Enroll
    FOR EACH ROW
    EXECUTE PROCEDURE insertInEnrollOrWaitlist();


/* The following trigger function and trigger accomplish the deletion
in the view Enroll*/

CREATE OR REPLACE FUNCTION deleteEnroll() RETURNS trigger AS
$$
BEGIN
  IF NOT capacityReached(OLD.cno)
  THEN 
     DELETE FROM EnrollWait WHERE sid = OLD.sid AND cno = OLD.cno;
     UPDATE Course SET total = total - 1 WHERE cno=OLD.cno;
  ELSE
     IF NOT EXISTS (SELECT 1
                    FROM   EnrollWait
                    WHERE  cno = OLD.cno AND location >= 1)
     THEN 
       DELETE FROM EnrollWait WHERE sid = OLD.sid AND cno = OLD.cno;
       UPDATE Course SET total = total - 1 WHERE cno=OLD.cno;
     ELSE 
       DELETE FROM EnrollWait WHERE sid = OLD.sid AND cno = OLD.cno;
       UPDATE EnrollWait SET location = 0 WHERE location = (SELECT minLocation(OLD.cno)); 
     END IF;
  END IF;
  RETURN OLD;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER delete_Enroll
    INSTEAD OF DELETE ON Enroll
    FOR EACH ROW
    EXECUTE PROCEDURE deleteEnroll();



