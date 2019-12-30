CREATE OR REPLACE VIEW v_timesheets_alert AS

SELECT a.ts_date as_of_date,
	a.employee,
	TO_CHAR(a.ts_date,'DD-Mon') ts_day,
	substr(a.ts_desc,1,510) ts_desc,
	a.task_name,
	a.project_name,
	a.amount,
	a.unit_amount
FROM v_timesheets a
WHERE TO_CHAR(a.ts_date,'iw') = TO_CHAR(current_date-1,'iw')