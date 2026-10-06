--create database college;
use college;

--Basic analysis--

select * from courses; --8 courses
select * from students; --12 Students

EXEC sp_rename 'FACULTY -INSTRUCTORS', 'faculty';
select * from faculty;

alter table faculty
drop column "Column 5";

select * from faculty; -- 4 faculties
select * from Enrollments; -- 30 enrollments
----------------------------------------------------------
--1. Get the average grade for each student (considering A=4, B=3, C=2, D=1, F=0).
with enrollments_with_gradeNumber as (
select enrollmentid, studentid,
case 
	when Grade = 'A' then 4
	when Grade ='B' then 3
	when Grade ='C' then 2
	when Grade ='D' then 1
	when Grade ='F' then 0
end as grade_number
from enrollments)
select s.StudentID,s.Name,cast(avg(cast(e.grade_number as decimal(3,2))) as decimal(3,2)) as AverageGrade, count(*) as CountOfEnrollments
from students s
join enrollments_with_gradeNumber e
on s.studentid = e.studentid
group by s.studentid, s.name
order by AverageGrade desc;


--Inference : Jane Smith holds highest Average Grade of 4 while Benjamin Martinez has lowest average grade of 0.67.
--------------------------------------------------------------------

--2.List all instructors who are teaching a course with fewer than 3 students enrolled.

with student_count_per_course as(
select c.courseid, c.courseName ,c.instructorid, count(studentid) as student_count
from courses c
left join enrollments e
on c.courseid = e.courseid
group by c.courseid, c.courseName, c.instructorid)

select f.faculty_id, concat(f.first_name,' ',f.last_name) as Faculty_name, scc.courseName, scc.student_count
from faculty f
left join student_count_per_course scc
on f.faculty_id = scc.instructorid
where scc.student_count <3

--Inference : Dr.Adams Wilson's Courses has less than 3 students.

---------------------------------------------------------------------
--3. Find the total number of credits each student has earned, grouped by their major.

--select distinct major from students; --Biology,Chemistry,Computer Science,Mathematics,Physics,Psychology

--select distinct department from faculty; --Chemistry,Computer Science,Mathematics,Physics

select s.major, s.studentid, s.name, sum(cast(c.credits as int)) as TotalCredits
from students s
join enrollments e
on s.studentid = e.studentid
join courses c
on c.courseid = e.courseid
group by s.studentid, s.name, s.major
order by s.major;

select s.major, sum(cast(c.credits as int)) as TotalCredits
from students s
join enrollments e
on s.studentid = e.studentid
join courses c
on c.courseid = e.courseid
group by s.major
order by TotalCredits desc;

-- Inference : Computer science major students has earned more credits follwed by biology.
---------------------------------------------------------------------

--4.Find the average salary of instructors in each department.

select * from faculty;

select department, cast(avg(cast(salary as decimal(10,2))) as decimal(10,2))as AverageSalary
from faculty
group by department
order by AverageSalary desc;

--Inference : Avg. salary of Chemistry department is more.
---------------------------------------------------------------------
--5.List all courses that are taught by more than one instructor . 

select * from courses; --each course is taught by one instructor only.

select Coursename , count(*) as course_instructor_count
from courses 
group by coursename;

--Inference : Each Course is taught by only one instructor. No course is handled by more than 1 instructor.

---------------------------------------------------------------------

--6. List the top 3 students with the highest number of credits earned.

--only top 3 records
select top 3 s.studentid, s.name, sum(cast(c.credits as int)) as TotalCredits
from students s
join enrollments e
on s.studentid = e.studentid
join courses c
on c.courseid = e.courseid
group by s.studentid, s.name
order by TotalCredits desc;

select s.studentid, s.name, sum(cast(c.credits as int)) as TotalCredits
from students s
join enrollments e
on s.studentid = e.studentid
join courses c
on c.courseid = e.courseid
group by s.studentid, s.name
order by TotalCredits desc;

-- top 3 ranked students
with student_rank_cte as(
select s.studentid, s.name, sum(cast(c.credits as int)) as TotalCredits,
dense_rank() over(order by sum(cast(c.credits as int)) desc) as student_rank
from students s
join enrollments e
on s.studentid = e.studentid
join courses c
on c.courseid = e.courseid
group by s.studentid, s.name)

select * from student_rank_cte
where student_rank <=3;

--Inference : 4 students have earned 11 credits and are in top 1 position. 
--			2 students have earned 10 credits and are in 2nd position. 
--			6 students have earned 7 credits and are in 3rd position. 





--order table -- product table
--product not having orders

select p.productid, p.productname
from product p
join order a
on p.productid <> a.productid
where a.productid is null;


--sales , product 

--top3 products by total sales for each month

select top 3 p.productid, month(s.order_date), sum(amount) as total_sales
from products p
join sales s
on p.productid =s.productid
group by p.productid, s.order_month
order by total_sales desc;









