
SELECT * FROM EDW_TRB_DEV.CURATED.RTP_ACCESS_PROD_TYPE
WHERE access_prod_type_code IN (1, 12);

SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_DETAIL LIMIT 1000;

SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_USE_SUMM LIMIT 1000;

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

    ;

SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_DETAIL
WHERE access_code = 'THRTH016IE97ANPYI';

SELECT * FROM EDW_TRB_PRD.CURATED.RTP_PREPAID_ACCESS_PROFILE LIMIT 100;

SELECT * FROM EDW_TRB_PRD.CURATED.RTP_PREPAID_ACCESS_PROFILE WHERE access_code = 'THRTH016IE97ANPYI';

SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_USE_SUMM WHERE access_code = 'THRTH016IE97ANPYI';

SELECT * FROM EDW_TRB_PRD.SEMANTIC.VW_ACCESS_ACTIVITY;

SELECT * FROM EDW_TRB_PRD.CURATED.RTP_STAT;

WITH record_union AS (
    SELECT
        au.access_date AS access_datetime
        ,au.access_code
        ,EDW_TRB_PRD.SEMANTIC.udf_Access_Code_to_Rule(au.access_code) AS access_rule
        ,au.access_locn_code
        ,au.access_prod_type_code
        ,ap.ip_code
        ,ap.update_date
        ,ap.prepaid_access_status_code
    FROM
        (
            SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_USE_SUMM

            UNION ALL

            SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_USE_SUMM_ARCH
            WHERE access_date < TIMESTAMP '2010-05-29 13:13:25.080'
        ) AS au
    LEFT JOIN 
        EDW_TRB_PRD.CURATED.RTP_PREPAID_ACCESS_PROFILE AS ap ON ap.access_code = au.access_code
    INNER JOIN EDW_TRB_PRD.LANDING.RTP_ACCESS_DETAIL AS ad ON ad.access_code = au.access_code
    -- WHERE prepaid_access_status_code = 1
)

-- SELECT * 
-- FROM record_union
-- WHERE 
--     access_code IN ('THRTH016IE97ANPYI')
--     AND access_datetime = TIMESTAMP '2019-03-15 11:24:30.167'
-- ORDER BY access_code, ip_code;

-- SELECT * 
-- FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_USE_SUMM
-- WHERE 
--     access_code IN ('THRTH016IE97ANPYI')
--     AND access_date = TIMESTAMP '2019-03-15 11:24:30.167'
-- ORDER BY access_code;

-- -- SELECT DISTINCT access_code, ip_code 
-- SELECT *
-- FROM record_union
-- -- WHERE access_code NOT IN ('THRAC13DKYT91U5L3')
-- -- WHERE access_code IN ('THRTH016IE97ANPYI', 'THRTH014XI37AN69M', 'THRAC13DKYT91U5L3')
-- -- QUALIFY COUNT(DISTINCT access_datetime) OVER (PARTITION BY access_code) = 1
-- -- ORDER BY access_code, access_datetime;
-- QUALIFY ROW_NUMBER() OVER (PARTITION BY access_datetime, access_prod_type_code, access_code ORDER BY update_date DESC) = 1
-- ORDER BY access_code, ip_code

-- SELECT *
-- FROM record_union
-- QUALIFY ROW_NUMBER() OVER (PARTITION BY access_datetime, access_code ORDER BY update_date DESC) = 1
-- ORDER BY access_code, ip_code;

SELECT * FROM record_union;
-- Before ip_code join
-- 55,727,213 rows
-- After
-- 55,727,212 rows (1 dupe removed)

-- With detail inner join
-- 317,183 rows

SELECT * FROM EDW_TRB_PRD.CURATED.RTP_LOCN;