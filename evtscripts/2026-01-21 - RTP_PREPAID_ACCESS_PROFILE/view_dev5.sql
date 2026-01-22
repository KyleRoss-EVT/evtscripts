WITH record_union AS (
    SELECT
        au.*
        ,ad.ip_code
        -- au.access_date AS access_datetime
        -- ,au.access_code
        -- ,EDW_TRB_PRD.SEMANTIC.udf_Access_Code_to_Rule(au.access_code) AS access_rule
        -- ,au.access_locn_code
        -- ,au.access_prod_type_code
        -- ,ad.ip_code
    FROM
        (
            SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_USE_SUMM

            UNION ALL

            SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_USE_SUMM_ARCH
            WHERE access_date < TIMESTAMP '2010-05-29 13:13:25.080'
        ) AS au
    INNER JOIN EDW_TRB_PRD.SEMANTIC.VW_ACCESS_DETAIL_PROFILE as ad ON 
        ad.access_date = au.access_date
        AND ad.access_code = au.access_code
        AND ad.access_prod_type_code = au.access_prod_type_code
        AND ad.access_location_code = au.access_locn_code
        AND ad.media_access_code = au.media_access_code
    ORDER BY au.row_num
)

-- access_date
-- access_locn_code
-- media_access_code
-- access_prod_type_code
-- access_code

SELECT * FROM record_union
WHERE access_code = 'THRST0338HX88H6FL';

-- with join
-- 52,844,015 rows
-- without
-- 55,727,974 rows
-- Need more conditions?

SELECT * FROM EDW_TRB_PRD.SEMANTIC.VW_ACCESS_DETAIL_PROFILE 
WHERE access_code = 'THRST0338HX88H6FL'
ORDER BY access_date;

SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_DETAIL LIMIT 100;

SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_DETAIL_ARCHIVE
WHERE access_code = 'THRST0338HX88H6FL'
ORDER BY access_date;

SELECT * 
FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_USE_SUMM
WHERE access_code = 'THRST0338HX88H6FL'
ORDER BY access_date;

SELECT * FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_USE_SUMM
WHERE access_src_code = 2
LIMIT 1;

SELECT * 
FROM EDW_TRB_PRD.CURATED.RTP_ACCESS_USE_SUMM
WHERE access_code = 'THRCO29DKHTE8R5NX'
ORDER BY access_date;