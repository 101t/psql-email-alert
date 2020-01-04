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

CREATE OR REPLACE VIEW v_crm_tracking_alert AS
SELECT   a.id                    lead_id,
         b.name                  lead_stage,
         a.name                  lead_name,
         Substr(
                 (
                 SELECT x.activity
                 FROM   v_crm_activities x
                 WHERE  x.activity_id IN
                        (
                                 SELECT   Max(activity_id) activity_id
                                 FROM     v_crm_activities
                                 WHERE    activity_status = 'Done'
                                 GROUP BY lead_id)
                 AND    x.lead_id = a.id),1,510) last_activity,
         (
                SELECT To_char(x.done_on,'DD-Mon-YY') done_on
                FROM   v_crm_activities x
                WHERE  x.activity_id IN
                       (
                                SELECT   Max(activity_id) activity_id
                                FROM     v_crm_activities
                                WHERE    activity_status = 'Done'
                                GROUP BY lead_id)
                AND    x.lead_id = a.id) last_activity_date,
         (
                SELECT x.assigned_to
                FROM   v_crm_activities x
                WHERE  x.activity_id IN
                       (
                                SELECT   Max(activity_id) activity_id
                                FROM     v_crm_activities
                                WHERE    activity_status = 'Done'
                                GROUP BY lead_id)
                AND    x.lead_id = a.id) last_activity_by,
         Substr(
                 (
                 SELECT x.activity
                 FROM   v_crm_activities x
                 WHERE  x.due_on IN
                        (
                               SELECT Min(z.due_on)
                               FROM   v_crm_activities z
                               WHERE  z.activity_status <> 'Done'
                               AND    z.lead_id = a.id)
                 AND    x.lead_id = a.id),1,510) next_activity,
         (
                SELECT To_char(x.due_on ,'DD-Mon-YY') due_on
                FROM   v_crm_activities x
                WHERE  x.due_on IN
                       (
                              SELECT Min(z.due_on)
                              FROM   v_crm_activities z
                              WHERE  z.activity_status <> 'Done'
                              AND    z.lead_id = a.id)
                AND    x.lead_id = a.id) next_activity_date,
         (
                SELECT x.assigned_to
                FROM   v_crm_activities x
                WHERE  x.due_on IN
                       (
                              SELECT Min(z.due_on)
                              FROM   v_crm_activities z
                              WHERE  z.activity_status <> 'Done'
                              AND    z.lead_id = a.id)
                AND    x.lead_id = a.id) next_activity_by,
         (
                SELECT x.activity_status
                FROM   v_crm_activities x
                WHERE  x.due_on IN
                       (
                              SELECT Min(z.due_on)
                              FROM   v_crm_activities z
                              WHERE  z.activity_status <> 'Done'
                              AND    z.lead_id = a.id)
                AND    x.lead_id = a.id) next_activity_status
FROM     crm_lead a,
         crm_stage b
WHERE    a.stage_id = b.id
ORDER BY b.name = 'New Leads' DESC,
         b.name = 'Proposition' DESC,
         b.name = 'Opportunity' DESC,
         b.name = 'Qualified Opportunity' DESC,
         b.name = 'Negotiation' DESC,
         b.name = 'Won' DESC,
         b.name = 'Lost' DESC;