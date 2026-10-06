use HMS;

--Basic analysis--
--7 tables--

select * from Doctor; -- 3 doctors 

select * from Patient; --10 patients

select * from PatientFillHistory; -- each patient has each history id - 10 records

select * from MedicalHistory; --Each history id has one medical history details - 10 records

select * from Medication_Cost; -- 5 records + one blank row

--deleting the blank row
delete from MedicationCost
where Medication ='' and Cost_in$ ='';

select * from Appointment; --10 records

select * from PatientAttendAppointment; --13 records 

-- assuming appoitment id will be unique for patient +doctor+ time slot combo, 
-- there is data inconsistency in PateintAttendAppoitment table. 
-- option 1 - to ignore PateintAttendAppoitment table or
-- option 2 - considering Appointment table as scheduled and PatientAttendAppointment as actually attended ones.


-- shows the discrepencies
select A.AppointmentID as "Scheduled appointment ID", A.patientID as "Scheduled pateint ",
PA.PatientID as "Actual Patient " from PatientAttendAppointment PA
join Appointment A
on PA.AppointmentID= A.AppointmentID
and PA.PatientID <> A.PatientID;