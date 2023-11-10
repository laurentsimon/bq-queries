SELECT COUNT(*) FROM (
    SELECT DISTINCT
        Name
    FROM
        `deps-dev-insights.internal_v1.PackageVersionsLatest`
    WHERE
        Deprecated IS NOT NULL
    AND
        System="NPM"
)


-- 2488502
-- SELECT
--     Requirement.Name
-- FROM
--     sos-scratch.test_dataset.Requirements
-- WHERE 
--     System="NPM"
-- AND
--     Requirement.Name 
--     NOT IN (
--         SELECT DISTINCT
--             Dependent.Name
--         FROM
--             `bigquery-public-data.deps_dev_v1.DependentsLatest`
--         WHERE
--             System="NPM"
--     )
-- LIMIT 10
-- WITH
--     KnownDeps AS (
--         SELECT DISTINCT
--             Dependent.Name as Name
--         FROM
--             `bigquery-public-data.deps_dev_v1.DependentsLatest`
--         WHERE
--             System="NPM"
--         GROUP BY
--             Dependent.Name
--         ORDER BY
--             Count DESC
--     ),
--     PrivateNames AS (
--         SELECT DISTINCT
--             Requirement.Name
--         FROM
--             sos-scratch.test_dataset.Requirements
--         WHERE 
--             System="NPM"
--         AND
--             Requirement.Name
--             NOT IN (
--                 SELECT
--                     nd.Name
--                 FROM
--                     KnownDeps as nd
--             )
--     )
-- SELECT * FROM PrivateNames ORDER BY Name DESC LIMIT 10
-- SELECT
--     nd.Name, nd.Count
-- FROM
--     KnownDeps AS nd
-- INNER JOIN
--     PrivateNames AS pn
-- ON 
--     pn.Name = nd.Name
-- ORDER BY
--     nd.Count DESC
-- LIMIT 10;

-- TODO: not in the dependency table
-- WITH
--     OrderedDeps AS (
--         SELECT
--             Name, COUNT(Name) as Count
--         FROM
--             `bigquery-public-data.deps_dev_v1.DependentsLatest`
--         WHERE
--             System="NPM"
--         GROUP BY
--             Name
--         ORDER BY
--             Count DESC
--     ),
--     Updated AS (
--         SELECT 
--             DISTINCT(Name)
--         FROM
--             `deps-dev-insights.internal_v1.PackageVersionsLatest`
--         WHERE
--             System="PYPI"
--         AND
--             UpstreamPublishedAt > '2015-01-30 00:00:00'
--     ),
--     NotUpdated AS (
--         SELECT
--             od.Name, od.Count
--         FROM
--             OrderedDeps as od
--         WHERE 
--             od.Name
--         NOT IN (
--             SELECT
--                 u.Name
--             FROM
--                 Updated as u
--             )
--     )
-- SELECT
--     *
-- FROM
--     NotUpdated
-- ORDER BY
--     2 DESC
-- LIMIT 1000
