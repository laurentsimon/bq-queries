-- packages with more than 4 years gap in updates
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
    GapUpdates AS (
        SELECT 
            Name, Version, UpstreamPublishedAt,
            -- TIMESTAMP_DIFF does not support month
            DATE_DIFF( 
                CAST(
                    LAG(UpstreamPublishedAt) OVER (PARTITION BY Name ORDER BY UpstreamPublishedAt DESC)
                    AS DATE
                    ),
                CAST(UpstreamPublishedAt AS DATE),
                MONTH
            ) AS Diff
        FROM
            `deps-dev-insights.internal_v1.PackageVersionsLatest`
        WHERE
            System="NPM"
        ORDER BY
            Name DESC,
            UpstreamPublishedAt DESC
    )
SELECT
    DISTINCT(Name), Diff
FROM
    GapUpdates
WHERE
    Diff > 48
ORDER BY
    Diff DESC
LIMIT
    100


    