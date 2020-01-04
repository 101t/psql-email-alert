CREATE OR REPLACE VIEW v_crm_activities AS
SELECT a.id                  activity_id,
       CASE
              WHEN CURRENT_DATE = a.date_deadline::date THEN 'Planned Today'
              WHEN CURRENT_DATE > a.date_deadline::date THEN 'Delayed'
              WHEN CURRENT_DATE < a.date_deadline::date THEN 'Planned'
       END                                                                            activity_status,
       b.name                                                                         activity_type,
       c.id                                                                           lead_id,
       c.name                                                                         lead_name,
       a.summary                                                                      activity,
       REGEXP_REPLACE(REGEXP_REPLACE(a.note, e'<.*?>', '', 'g' ), e'&nbsp;', '', 'g') activity_note,
       d.partner_name                                                                 assigned_to,
       a.create_date::date                                                            assigned_on,
       a.date_deadline                                                                due_on,
       NULL                                                                           done_on
FROM   mail_activity a,
       mail_activity_type b,
       crm_lead c,
       v_users d
WHERE  a.activity_type_id = b.id
AND    a.res_id = c.id
AND    a.user_id = d.user_id
AND    a.res_model = 'crm.lead'
UNION ALL
SELECT a.id                                                                                                                        activity_id,
       'Done'                                                                                                                      activity_status,
       c.name                                                                                                                      activity_type,
       b.id                                                                                                                        lead_id,
       b.name                                                                                                                      lead_name,
       REPLACE(REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(a.body, e'<.*?>', '', 'g' ), e'&nbsp;', '', 'g'),' ',''),'             ','') activity,
       ''::text                                                                                                                    activity_note,
       d.partner_name                                                                                                              done_by,
       NULL                                                                                                                        assigned_on,
       NULL                                                                                                                        due_on,
       a.date::date                                                                                                                done_on
FROM   mail_message a,
       crm_lead b,
       mail_activity_type c,
       v_users d
WHERE  a.res_id = b.id
AND    a.author_id = d.partner_id
AND    a.mail_activity_type_id = c.id;
       --and a.record_name = 'ENGIE | Italy ERP'