--SQL Analysis --
use HMS;
-----------------------------------------------------------------------------------------------------------------------------------
--1.Appointments per doctor with rank (most to least busy)

select * from Appointment;
select * from Doctor;

select D.DoctorID, CONCAT(D.Fname,' ',D.Lname) as DoctorName,
count(A.AppointmentID) as AppointmentCount, DENSE_RANK() over( order by count(A.AppointmentID) desc) as DoctorRank
from Doctor D
left join Appointment A
on D.DoctorID = A.DoctorID
group by D.DoctorID, D.Fname, D.Lname
order by DoctorRank;

--Inference : Dr.John Doe is the busiest doctor, followed by Dr.Jane Smith adn Michael Johnson.

-----------------------------------------------------------------------------------------------------------------------------------

--2.Peak booking hours (by start time hour)  

--select DATEPART(HOUR,"date") as time from Appointment;
--select FORMAT(cast("date" as datetime),'HH:mm') as time from Appointment;

select FORMAT(cast("date" as datetime),'HH:mm') as BookingHour, count(*) as BookingHourCount,
DENSE_RANK() over( order by count(*) desc) as PeakBookingHour
from Appointment
group by FORMAT(cast("date" as datetime),'HH:mm')
order by PeakBookingHour;

--Inference : With the given data every booking time slot has 1 appoitment , so all are ranked as 1 which makes all booking time as peak ones.

-----------------------------------------------------------------------------------------------------------------------------------

--3. Which doctor has the most appointments?

with doctorRank_CTE as
(select D.DoctorID, CONCAT(D.Fname,' ',D.Lname) as DoctorName,
count(A.AppointmentID) as AppointmentCount, DENSE_RANK() over( order by count(A.AppointmentID) desc) as DoctorRank
from Doctor D
left join Appointment A
on D.DoctorID = A.DoctorID
group by D.DoctorID, D.Fname, D.Lname)

select * from doctorRank_CTE
where DoctorRank = 1;

--Inference : Dr.John Doe has most appointments -4 
-----------------------------------------------------------------------------------------------------------------------------------

--4. How many patients does each doctor treat?
--a using Appointment table

select D.DoctorID,concat(D.Fname,' ',D.Lname) as DoctorName , count(PatientID) as PatientCount
from Doctor D
left join Appointment A
on D.DoctorID = A.DoctorID
group by D.DoctorID, D.Fname,D.Lname;

--Inference : As per scheduled appointment ( Appointment table) 
--Dr. John Doe	4
--Dr. Jane Smith	3
--Dr. Michael Johnson	3

--b. patientAttendAppointment table

select D.DoctorID,concat(D.Fname,' ',D.Lname) as DoctorName , count(P.PatientID) as PatientCount
from Doctor D
left join Appointment A
on D.DoctorID = A.DoctorID
join patientAttendAppointment P
on A.AppointmentID = p.AppointmentID
group by D.DoctorID, D.Fname,D.Lname;

--Inference : As per Actual patients consulted ( patientAttendAppointment table) 
--Dr. John Doe	5
--Dr. Jane Smith	4
--Dr. Michael Johnson	4
-----------------------------------------------------------------------------------------------------------------------------------

--5. Doctor–patient pairs with most interactions (top 10)

-- a.using Appoitment table which has scheduled appointments--
with interaction_cte as
(select D.DoctorID, concat(D.Fname, ' ',D.Lname) as DoctorName,P.PatientID,CONCAT(P.Fname,' ',P.Lname) PatientName,
count(*) as Doctor_patient_interaction_count,
DENSE_RANK() over (order by count(*) desc) as InteractionRank
from Appointment A
join Doctor D
on A.DoctorID = D.DoctorID
join patient P
on A.PatientID = P.PatientID 
group by d.DoctorID, D.Fname,D.Lname,P.PatientID,P.Fname,P.Lname)

select * from interaction_cte
where InteractionRank <=10
order by InteractionRank;

--Inference : Each Doctor-patient pair has exactly 1 interaction.

--b. using PatientAttendAppointment table
with actual_interaction_cte as
(select D.DoctorID, concat(D.Fname, ' ',D.Lname) as DoctorName,P.PatientID,CONCAT(P.Fname,' ',P.Lname) PatientName,
count(*) as Doctor_patient_interaction_count,
DENSE_RANK() over (order by count(*) desc) as InteractionRank
from Appointment A
join PatientAttendAppointment PA
on A.AppointmentID = PA.AppointmentID
join Doctor D
on A.DoctorID = D.DoctorID
join patient P
on PA.PatientID = P.PatientID 
group by d.DoctorID, D.Fname,D.Lname,P.PatientID,P.Fname,P.Lname)

select * from actual_interaction_cte
where InteractionRank <=10
order by InteractionRank;

-----------------------------------------------------------------------------------------------------------------------------------
--6. First and most recent visit per patient (with total visits)
--a. Appointment table
with visit_cte as (select PatientID, format(min(convert(date,"date",101)),'MM/dd/yyyy') as First_visit ,
format(max(convert(date,"date",101)),'MM/dd/yyyy') as Recent_visit,  count(*) as Total_visits
from Appointment
group by PatientID)

select CONCAT(P.Fname,' ',P.Lname) as PatientName, v.*
from visit_cte V join Patient P
on v.PatientID = P.PatientID

--b.PatientAttendAppointment tables
select PA.PatientID, concat(P.Fname,' ',P.Lname) as PatientName,format(min(convert(date,"date",101)),'MM/dd/yyyy') as First_visit ,
format(max(convert(date,"date",101)),'MM/dd/yyyy') as Recent_visit,  
count(*) as Total_visits
from Appointment A
join PatientAttendAppointment PA 
on A.AppointmentID = PA.AppointmentID
join Patient P 
on P.PatientID = PA.PatientID
group by PA.PatientID, P.Fname,P.Lname;

-----------------------------------------------------------------------------------------------------------------------------------