SELECT DISTINCT ad.accessdate,
                ad.accesscode,
                ad.accesslocationcode,
                l.description,
                g.gatename,
                arc.accessrulecategorycode,
                arc.description,
                arg.accessrulegroupcode,
                arg.description,
                apt.accessproducttypecode,
                apt.description,
                ar.accessrule,
                ar.description,
                pap.ipcode,
                ad.mediaaccesscode,
                pap.productheadercode
FROM   dbo.accessdetail ad WITH (nolock)
       JOIN dbo.prepaidaccessprofile pap WITH (nolock)
         ON ad.accesscode = pap.accesscode
            AND pap.prepaidaccessstatuscode IN ( 1, 3 )
       JOIN dbo.accessrule ar WITH (nolock)
         ON ar.accessrule = pap.accessrule
       JOIN dbo.accessrulecategory arc WITH (nolock)
         ON arc.accessrulecategorycode = ar.accessrulecategorycode
       JOIN dbo.accessrulegroup arg WITH (nolock)
         ON arg.accessrulegroupcode = arc.accessrulegroupcode
       JOIN dbo.location l WITH (nolock)
         ON l.locationcode = ad.accesslocationcode
            AND l.locationreference = 'Access Location'
       JOIN dbo.accessproducttype apt WITH (nolock)
         ON apt.accessproducttypecode = ad.accessproducttypecode
       JOIN dbo.gate g WITH (nolock)
         ON g.gatecode = ad.handheldid
WHERE  ad.returncode IN ( 0, 14, 27 )
       AND ad.accessdate > '2025-09-25'
UNION
SELECT DISTINCT ad.accessdate,
                ad.accesscode,
                ad.accesslocationcode,
                l.description,
                g.gatename,
                arc.accessrulecategorycode,
                arc.description,
                arg.accessrulegroupcode,
                arg.description,
                apt.accessproducttypecode,
                apt.description,
                ar.accessrule,
                ar.description,
                pap.ipcode,
                ad.mediaaccesscode,
                pap.productheadercode
FROM   dbo.accessdetailarchive ad WITH (nolock)
       JOIN dbo.prepaidaccessprofile pap WITH (nolock)
         ON ad.accesscode = pap.accesscode
            AND pap.prepaidaccessstatuscode IN ( 1, 3 )
       JOIN dbo.accessrule ar WITH (nolock)
         ON ar.accessrule = pap.accessrule
       JOIN dbo.accessrulecategory arc WITH (nolock)
         ON arc.accessrulecategorycode = ar.accessrulecategorycode
       JOIN dbo.accessrulegroup arg WITH (nolock)
         ON arg.accessrulegroupcode = arc.accessrulegroupcode
       JOIN dbo.location l WITH (nolock)
         ON l.locationcode = ad.accesslocationcode
            AND l.locationreference = 'Access Location'
       JOIN dbo.accessproducttype apt WITH (nolock)
         ON apt.accessproducttypecode = ad.accessproducttypecode
       JOIN dbo.gate g WITH (nolock)
         ON g.gatecode = ad.handheldid
WHERE  ad.returncode IN ( 0, 14, 27 )
       AND ad.accessdate > '2025-09-25'
ORDER  BY ad.accessdate; 