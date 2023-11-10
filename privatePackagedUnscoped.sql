WITH
    PrivatePackages AS (
        SELECT DISTINCT
        Requirement.Name
    FROM
        sos-scratch.test_dataset.Requirements
    WHERE 
        System="NPM"
    AND
        Requirement.Name NOT LIKE '@%'
    AND
        Requirement.Name 
        NOT IN (
            SELECT DISTINCT
                Name
            FROM
                `bigquery-public-data.deps_dev_v1.PackageVersionsLatest`
            WHERE
                System="NPM"
        )
    )
SELECT * from PrivatePackages LIMIT 100;

-- 23507
