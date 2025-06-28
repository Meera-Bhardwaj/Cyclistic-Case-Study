- ###############################################################
-- # Project: Cyclistic Bike-Share: Casual to Member Conversion Strategy
-- # Author: Meera Bhardwaj
-- # Date: June 27, 2025
-- # Tool: Google BigQuery SQL
-- # Dataset: `cyclist_data`
-- # Description: This script performs comprehensive data preprocessing (cleaning, feature engineering),
-- #              merging of monthly trip data, and aggregation for analysis. The goal is to identify
-- #              rider behavior patterns to inform strategies for converting casual riders into annual members.

  -- ###############################################################
  
-- sql/01_data_ingestion_and_merge.sql

-- Purpose: This script merges individual monthly Divvy trip data files into a single, comprehensive table.
-- The data is sourced from `clear-variety-463509-j4.cyclist_data` and includes ride information from January to June 2024.
-- A new table, `all_rides_merged`, is created in the same dataset.

CREATE TABLE `clear-variety-463509-j4.cyclist_data.all_rides_merged` AS
SELECT * FROM `clear-variety-463509-j4.cyclist_data.202401-divvy-tripdata-v2`
UNION ALL
SELECT * FROM `clear-variety-463509-j4.cyclist_data.202402-divvy-tripdata-v2`
UNION ALL
SELECT * FROM `clear-variety-463509-j4.cyclist_data.202403-divvy-tripdata-v2`
UNION ALL
SELECT * FROM `clear-variety-463509-j4.cyclist_data.202404-divvy-tripdata-v2`
UNION ALL
SELECT * FROM `clear-variety-463509-j4.cyclist_data.202405-divvy-tripdata-v2`
UNION ALL
SELECT * FROM `clear-variety-463509-j4.cyclist_data.202406-divvy-tripdata-v2`;

-- Note: Ensure that all source tables have the same schema for UNION ALL to work correctly.
-- If schemas differ, you might need to explicitly select columns and cast data types.

-- ###############################################################

-- sql/02_feature_engineering.sql

-- Purpose: This script calculates various time-based features and filters out invalid ride data
-- from the `all_rides_merged` table.
-- It creates a new table `all_rides_engineered` with additional columns for analysis.

CREATE TABLE `clear-variety-463509-j4.cyclist_data.all_rides_engineered` AS
SELECT
    -- Original columns
    *,
    -- Calculate ride duration in different units
    TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS ride_length_minutes,
    TIMESTAMP_DIFF(ended_at, started_at, SECOND) AS ride_length_seconds,
    TIMESTAMP_DIFF(ended_at, started_at, HOUR) AS ride_length_hours,
    -- Extract date components for analysis
    FORMAT_DATE('%A', DATE(started_at)) AS ride_day_of_week, -- Full day name (e.g., 'Monday')
    EXTRACT(DAYOFWEEK FROM started_at) AS ride_day_of_week_num, -- Day of week number (1=Sunday, 7=Saturday)
    EXTRACT(DAY FROM started_at) AS ride_day_of_month,
    EXTRACT(HOUR FROM started_at) AS ride_start_hour
FROM
    `clear-variety-463509-j4.cyclist_data.all_rides_merged`
WHERE
    -- Filter out incomplete or invalid ride data
    started_at IS NOT NULL
    AND ended_at IS NOT NULL
    AND TIMESTAMP_DIFF(ended_at, started_at, SECOND) > 0 -- Ensure ride duration is positive
    AND TIMESTAMP_DIFF(ended_at, started_at, HOUR) <= 24; -- Filter out extremely long rides (e.g., > 24 hours)

-- Note on BigQuery Time functions:
-- It's best practice to use `TIMESTAMP_DIFF` for TIMESTAMP columns and `TIME_DIFF` for TIME columns.
-- Assuming `started_at` and `ended_at` are TIMESTAMP columns from your merged data, `TIMESTAMP_DIFF` is more appropriate.
-- If `started_at_date` and `started_at_time` are separate columns, you might need to combine them into a TIMESTAMP first
-- using `TIMESTAMP(started_at_date, started_at_time)` before calculating differences.
-- For `FORMAT_DATE` and `EXTRACT`, ensure you're passing a DATE or TIMESTAMP part.
-- I've used `DATE(started_at)` assuming `started_at` is a TIMESTAMP for `FORMAT_DATE`.

-- ###############################################################

-- sql/03_analysis_queries.sql

-- Purpose: This script contains various analytical queries to derive insights from the
-- `all_rides_engineered` table, focusing on ride patterns by member type, time, and station.

-- Define the source table as a CTE for reusability within this script
-- (or directly use `all_rides_engineered` if it's already a persistent table)
WITH `cyclist_data` AS (
    SELECT *
    FROM `clear-variety-463509-j4.cyclist_data.all_rides_engineered`
)

-- 1. Total Rides by Member Type
-- Objective: Understand the distribution of rides between casual riders and annual members.
SELECT
    member_casual,
    COUNT(*) AS total_rides
FROM
    `cyclist_data`
GROUP BY
    member_casual
ORDER BY
    total_rides DESC;

-- 2. Rides by Day of the Week and Member Type (with Average Ride Length)
-- Objective: Analyze ride volume and average duration across different days of the week for
-- both casual and member riders to identify weekly patterns.
SELECT
    member_casual,
    ride_day_of_week,
    COUNT(*) AS total_rides,
    AVG(ride_length_minutes) AS average_ride_length_minutes
FROM
    `cyclist_data`
GROUP BY
    member_casual,
    ride_day_of_week
ORDER BY
    member_casual,
    -- Custom order for days of the week to ensure chronological presentation (Sunday-Saturday or Monday-Sunday)
    CASE
        WHEN ride_day_of_week = 'Sunday' THEN 1
        WHEN ride_day_of_week = 'Monday' THEN 2
        WHEN ride_day_of_week = 'Tuesday' THEN 3
        WHEN ride_day_of_week = 'Wednesday' THEN 4
        WHEN ride_day_of_week = 'Thursday' THEN 5
        WHEN ride_day_of_week = 'Friday' THEN 6
        WHEN ride_day_of_week = 'Saturday' THEN 7
    END;

-- 3. Rides by Start Hour and Member Type
-- Objective: Identify peak riding hours for casual vs. member riders.
SELECT
    member_casual,
    ride_start_hour,
    COUNT(*) AS total_rides
FROM
    `cyclist_data`
GROUP BY
    member_casual,
    ride_start_hour
ORDER BY
    member_casual,
    ride_start_hour;

-- 4. Top 10 End Stations for Casual Riders
-- Objective: Pinpoint the most popular destination stations for casual users.
SELECT
    end_station_name,
    COUNT(*) AS total_ends
FROM
    `cyclist_data`
WHERE
    member_casual = 'casual'
    AND end_station_name IS NOT NULL -- Exclude rides without an recorded end station
GROUP BY
    end_station_name
ORDER BY
    total_ends DESC
LIMIT 10;

-- 5. Top 10 End Stations for Member Riders
-- Objective: Pinpoint the most popular destination stations for annual members.
SELECT
    end_station_name,
    COUNT(*) AS total_ends
FROM
    `cyclist_data`
WHERE
    member_casual = 'member'
    AND end_station_name IS NOT NULL
GROUP BY
    end_station_name
ORDER BY
    total_ends DESC
LIMIT 10;

-- 6. Top 10 Start Stations for Casual Riders
-- Objective: Identify the most popular origin stations for casual users.
SELECT
    start_station_name,
    COUNT(*) AS total_starts
FROM
    `cyclist_data`
WHERE
    member_casual = 'casual'
    AND start_station_name IS NOT NULL -- Exclude rides without an recorded start station
GROUP BY
    start_station_name
ORDER BY
    total_starts DESC
LIMIT 10;

-- 7. Top 10 Start Stations for Member Riders
-- Objective: Identify the most popular origin stations for annual members.
SELECT
    start_station_name,
    COUNT(*) AS total_starts
FROM
    `cyclist_data`
WHERE
    member_casual = 'member'
    AND start_station_name IS NOT NULL
GROUP BY
    start_station_name
ORDER BY
    total_starts DESC
LIMIT 10;


-- ###############################################################
-- # END OF SQL QUERIES
-- ###############################################################
