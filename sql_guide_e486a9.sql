-- ============================================================================
-- LEARNING OBJECTIVE:
-- This tutorial teaches you how to use SQL to analyze historical weather data
-- and lay the groundwork for predicting future trends. We will focus on
-- aggregating data to identify patterns and visualize trends.
--
-- KEY CONCEPT: Aggregation and Window Functions for Trend Analysis
-- ============================================================================

-- First, let's create a table to store our historical weather data.
-- This is a simplified representation. In a real-world scenario, you'd have
-- more columns like humidity, wind speed, pressure, etc.
CREATE TABLE weather_data (
    -- A unique identifier for each weather record.
    -- SERIAL is a PostgreSQL-specific auto-incrementing integer type.
    -- This simplifies data entry as we don't need to manually assign IDs.
    record_id SERIAL PRIMARY KEY,

    -- The date and time when the weather observation was recorded.
    -- TIMESTAMP WITH TIME ZONE is best practice for storing temporal data.
    observation_timestamp TIMESTAMP WITH TIME ZONE NOT NULL,

    -- The average temperature for the observation period (e.g., daily average).
    -- DECIMAL is suitable for precise numerical values, avoiding floating-point
    -- inaccuracies that could occur with FLOAT or REAL.
    -- We specify precision (total digits) and scale (digits after decimal point).
    average_temperature DECIMAL(5, 2) NOT NULL,

    -- The maximum temperature recorded during the observation period.
    max_temperature DECIMAL(5, 2) NOT NULL,

    -- The minimum temperature recorded during the observation period.
    min_temperature DECIMAL(5, 2) NOT NULL,

    -- The total precipitation recorded during the observation period.
    precipitation DECIMAL(5, 2) DEFAULT 0.00 -- Default to 0 if no precipitation
);

-- Let's populate our table with some sample historical weather data.
-- This data will help us demonstrate aggregation and trend analysis.
-- We're using COPY for efficiency when inserting multiple rows.
-- In a real application, you'd likely be loading this from files or APIs.
COPY weather_data (observation_timestamp, average_temperature, max_temperature, min_temperature, precipitation) FROM STDIN;
2023-01-01 12:00:00+00,2.5,5.0,0.0,0.0
2023-01-02 12:00:00+00,3.0,6.0,1.0,0.0
2023-01-03 12:00:00+00,1.5,4.0,-1.0,0.5
2023-01-04 12:00:00+00,0.0,2.0,-2.0,1.0
2023-01-05 12:00:00+00,1.0,3.0,-1.5,0.2
2023-01-06 12:00:00+00,4.0,7.0,2.0,0.0
2023-01-07 12:00:00+00,5.5,8.0,3.0,0.0
2023-01-08 12:00:00+00,6.0,9.0,4.0,0.0
2023-01-09 12:00:00+00,7.0,10.0,5.0,0.0
2023-01-10 12:00:00+00,8.5,12.0,6.0,0.0
2023-02-01 12:00:00+00,10.0,14.0,8.0,0.0
2023-02-02 12:00:00+00,11.0,15.0,9.0,0.0
2023-02-03 12:00:00+00,12.5,16.0,10.0,0.0
2023-02-04 12:00:00+00,13.0,17.0,11.0,0.0
2023-02-05 12:00:00+00,14.0,18.0,12.0,0.0
2023-03-01 12:00:00+00,15.0,20.0,13.0,0.0
2023-03-02 12:00:00+00,16.0,21.0,14.0,0.0
2023-03-03 12:00:00+00,17.0,22.0,15.0,0.0
2023-03-04 12:00:00+00,18.0,23.0,16.0,0.0
2023-03-05 12:00:00+00,19.0,24.0,17.0,0.0
\.

-- Now, let's extract the year and month from the observation timestamp
-- to group our data for trend analysis.
-- DATE_TRUNC('month', observation_timestamp) extracts the first day of the month.
-- This is a very useful function for time-series analysis.
SELECT
    DATE_TRUNC('month', observation_timestamp) AS observation_month,
    AVG(average_temperature) AS monthly_avg_temp,
    SUM(precipitation) AS monthly_total_precipitation
FROM
    weather_data
GROUP BY
    observation_month -- We group by the extracted month to get aggregates per month.
ORDER BY
    observation_month; -- Ordering by month helps us see the trend chronologically.

-- This query shows us the average temperature and total precipitation for each month.
-- This is a basic form of trend analysis: looking at aggregated data over time.

-- --- Enhancing Trend Analysis with Window Functions ---

-- Window functions allow us to perform calculations across a set of table rows
-- that are related to the current row. This is powerful for comparing data
-- points and calculating running totals or moving averages.

-- Let's calculate the 7-day moving average of the average temperature.
-- This smooths out daily fluctuations and highlights longer-term trends.
SELECT
    observation_timestamp,
    average_temperature,
    -- AVG(average_temperature) OVER (...) is the window function call.
    -- It calculates the average temperature.
    -- The 'OVER' clause defines the 'window' of rows to consider.
    AVG(average_temperature) OVER (
        ORDER BY observation_timestamp
        -- This defines the frame: 'ROWS BETWEEN 6 PRECEDING AND CURRENT ROW'
        -- means we include the current row and the 6 rows before it,
        -- totaling 7 rows for the average calculation.
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS seven_day_moving_avg_temp
FROM
    weather_data
ORDER BY
    observation_timestamp;

-- Explanation of the window function:
-- 1. ORDER BY observation_timestamp: This is crucial. It tells the database
--    how to order the rows before applying the window function. Without it,
--    the window would be undefined and the results unpredictable.
-- 2. ROWS BETWEEN 6 PRECEDING AND CURRENT ROW: This defines the 'window frame'.
--    It specifies that for each row, the average should be calculated using
--    that row and the 6 rows that came immediately before it, based on the
--    ORDER BY clause.

-- This moving average helps us see the underlying trend more clearly,
-- filtering out short-term noise.

-- --- Example Usage and Prediction Foundation ---

-- To predict future trends, you would typically:
-- 1. Extract features (like month, year, day of week, etc.).
-- 2. Use historical data (including moving averages, seasonal averages, etc.)
--    as input for a statistical model or machine learning algorithm.
-- 3. Train the model on historical data.
-- 4. Use the trained model to predict future values.

-- SQL itself is not a predictive modeling tool like Python libraries (e.g., scikit-learn, TensorFlow).
-- However, it is essential for data preparation, feature engineering, and
-- retrieving the data needed for those models.

-- For instance, you could use SQL to calculate features for machine learning:
SELECT
    DATE_TRUNC('day', observation_timestamp) AS observation_date,
    EXTRACT(MONTH FROM observation_timestamp) AS month,
    EXTRACT(DAY FROM observation_timestamp) AS day,
    AVG(average_temperature) AS daily_avg_temp,
    SUM(precipitation) AS daily_total_precipitation,
    -- Calculate the previous day's average temperature as a feature
    LAG(average_temperature, 1, NULL) OVER (ORDER BY observation_timestamp) AS prev_day_avg_temp
FROM
    weather_data
GROUP BY
    observation_date, month, day, observation_timestamp -- Grouping by timestamp to get daily values
ORDER BY
    observation_date;

-- The LAG function is another powerful window function.
-- LAG(column, offset, default_value) OVER (ORDER BY ...)
-- It retrieves the value from a previous row (offset=1 means the immediately preceding row).
-- This is a common technique for creating lagged features in time-series data,
-- which are often used in predictive models.

-- By generating these kinds of aggregated and lagged features, you create a
-- robust dataset that can be fed into more advanced prediction systems.
-- This SQL tutorial has provided the foundational steps for preparing and
-- analyzing your historical weather data for future insights.
-- ============================================================================