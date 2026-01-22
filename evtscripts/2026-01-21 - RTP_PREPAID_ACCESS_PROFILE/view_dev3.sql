SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_DETAIL LIMIT 1000;
SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_USE_SUMM LIMIT 1000;
-- access_date
-- access_locn_code
-- media_access_code
-- access_prod_type_code
-- access_code


SELECT 
    us.access_code AS access_code_use_summ
    ,us.access_date AS access_date_use_summ
    -- ,us.hash_match AS hash_match_use_summ

    ,ad.access_code AS access_code_detail
    ,ad.access_date AS access_date_detail
    -- ,ad.hash_match AS hash_match_detail
FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_USE_SUMM AS us
INNER JOIN EDW_TRB_PRD.CURATED.RTP_ACCESS_DETAIL as ad ON 
    ad.access_code = us.access_code
    AND ad.access_date = us.access_date
    AND ad.media_access_code = us.media_access_code
    AND ad.access_location_code = us.access_locn_code

    ;

WITH record_union AS (
    SELECT
        au.access_date AS access_datetime
        ,au.access_code
        ,EDW_TRB_PRD.SEMANTIC.udf_Access_Code_to_Rule(au.access_code) AS access_rule
        ,au.access_locn_code
        ,au.access_prod_type_code
        ,pap.ip_code
    FROM
        (
            SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_USE_SUMM

            UNION ALL

            SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_USE_SUMM_ARCH
            WHERE access_date < TIMESTAMP '2010-05-29 13:13:25.080'
        ) AS au
    INNER JOIN 
        EDW_TRB_PRD.CURATED.RTP_PREPAID_ACCESS_PROFILE AS pap ON pap.access_code = au.access_code
    INNER JOIN 
        EDW_TRB_PRD.CURATED.RTP_ACCESS_RULE AS ar ON ar.access_rule = pap.access_rule
    INNER JOIN 
        EDW_TRB_PRD.CURATED.RTP_ACCESS_RULE_CTGY AS arc ON arc.access_rule_ctgy_code = ar.access_rule_ctgy_code
    INNER JOIN 
        EDW_TRB_PRD.CURATED.RTP_LOCN AS l ON l.locn_code = au.access_locn_code
    INNER JOIN 
        EDW_TRB_PRD.CURATED.RTP_ACCESS_PROD_TYPE AS apt ON apt.access_prod_type_code = au.access_prod_type_code
    WHERE 
        pap.prepaid_access_status_code IN (1, 3)
        AND l.locn_ref = 'Access Location'
        AND au.return_code IN (0, 14, 27)
)

SELECT * FROM record_union;