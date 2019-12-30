CREATE OR REPLACE VIEW v_tasks_tracking AS 

SELECT b.id project_id,
   c.name project_name,
   a.id task_id,
   a.name task_name,
   --a.create_date,
   TO_CHAR(a.date_assign,'DD-Mon') assigned_on,
   g.partner_name assigned_by,
   f.partner_name assigned_to,
   TO_CHAR(a.date_deadline,'DD-Mon') deadline_on,
   a.priority,
   e.name status
FROM project_task a,
	project_project b,
	account_analytic_account c,
	project_task_type e,
	v_users f,
	v_users g
WHERE a.project_id = b.id
	AND b.analytic_account_id = c.id
	AND e.id = a.stage_id
	AND a.user_id = f.user_id
	AND a.create_uid = g.user_id
	AND e.name NOT IN ('Archived','Completed','Done','Solved')
	AND b.id <> 1