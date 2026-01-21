WITH record_union AS (
    SELECT
        au.access_date AS access_datetime
        ,au.access_code
        ,EDW_TRB_PRD.SEMANTIC.udf_Access_Code_to_Rule(au.access_code) AS access_rule
        ,au.access_locn_code
        ,au.access_prod_type_code
        -- ,ad.ip_code
    FROM
        (
            SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_USE_SUMM

            UNION ALL

            SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_USE_SUMM_ARCH
            WHERE access_date < TIMESTAMP '2010-05-29 13:13:25.080'
        ) AS au
    -- INNER JOIN EDW_TRB_PRD.SEMANTIC.VW_ACCESS_DETAIL_PROFILE as ad ON 
    --     ad.access_code = au.access_code
    --     AND ad.access_date = au.access_date
    --     AND ad.media_access_code = au.media_access_code
    --     AND ad.access_location_code = au.access_locn_code
)

SELECT * FROM record_union;

-- with join
-- 52,844,015 rows
-- without
-- 55,727,974 rows
-- Need more conditions?