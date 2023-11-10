
WITH
    OrderedDeps AS (
        SELECT
            Name, COUNT(Name) as Count
        FROM
            `bigquery-public-data.deps_dev_v1.DependentsLatest`
        WHERE
            System="NPM"
        GROUP BY
            Name
        ORDER BY
            Count DESC
    ),
    Updated AS (
        SELECT 
            DISTINCT(Name)
        FROM
            `deps-dev-insights.internal_v1.PackageVersionsLatest`
        WHERE
            System="NPM"
        AND
            UpstreamPublishedAt > '2015-01-30 00:00:00'
    ),
    NotUpdated AS (
        SELECT
            od.Name, od.Count
        FROM
            OrderedDeps as od
        WHERE 
            od.Name
        NOT IN (
            SELECT
                u.Name
            FROM
                Updated as u
            )
    )
SELECT
    *
FROM
    NotUpdated
ORDER BY
    2 DESC
LIMIT 1000

# debug: npm>6.14.18>is-callable is present even though it has new packages