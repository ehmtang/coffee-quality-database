-- Create new table containing the certification, cupping, green and sample information
CREATE TABLE IF NOT EXISTS `coffee-quality-institute.cqi_coffee_reviews.arabica_coffee_complete_table`
AS
SELECT *
FROM `coffee-quality-institute.cqi_coffee_reviews.arabica_coffee_certification_information` AS cert
INNER JOIN `coffee-quality-institute.cqi_coffee_reviews.arabica_coffee_cupping_scores` AS scores
USING (coffee_id)
INNER JOIN `coffee-quality-institute.cqi_coffee_reviews.arabica_coffee_green_analysis` AS green
USING (coffee_id)
INNER JOIN `coffee-quality-institute.cqi_coffee_reviews.arabica_coffee_sample_infomation` AS sample
USING (coffee_id);

-- Create new columns of expiration and grading date in DATE format
ALTER TABLE `coffee-quality-institute.cqi_coffee_reviews.arabica_coffee_complete_table`
ADD COLUMN IF NOT EXISTS parsed_expiration DATE,
ADD COLUMN IF NOT EXISTS parsed_grading_date DATE;
UPDATE `coffee-quality-institute.cqi_coffee_reviews.arabica_coffee_complete_table`
SET parsed_expiration = PARSE_DATE('%B %e %Y', Expiration),
    parsed_grading_date = PARSE_DATE('%B %e %Y', Grading_Date)
WHERE parsed_expiration IS NULL OR parsed_grading_date IS NULL;


/** 1. Basic statistics:
  What is the average quality score of the coffees?
  What is the highest and lowest quality score in the dataset?
  What is the distribution of quality scores?
**/
-- Descriptive statistics of 'Total_Cup_Points'
CREATE TABLE IF NOT EXISTS `coffee-quality-institute.cqi_coffee_queries.descriptive_statistics_total_cup_scores`
AS
WITH filtered AS (
  SELECT 
    PERCENTILE_CONT(Total_Cup_Points, 0.25) OVER() AS percentile_25_total_cup_points,
    PERCENTILE_CONT(Total_Cup_Points, 0.50) OVER() AS percentile_50_total_cup_points,
    PERCENTILE_CONT(Total_Cup_Points, 0.75) OVER() AS percentile_75_total_cup_points,
    Total_Cup_Points 
  FROM `coffee-quality-institute.cqi_coffee_reviews.arabica_coffee_complete_table`
  )
SELECT 
  COUNT(Total_Cup_Points) AS count_records,
  ROUND(MAX(Total_Cup_Points),3) AS max_total_cup_points,
  ROUND(MIN(Total_Cup_Points),3) AS min_total_cup_points,
  ROUND(AVG(Total_Cup_Points),3) AS avg_total_cup_points,
  ROUND(STDDEV_SAMP(Total_Cup_Points),3) AS stdev_total_cup_points,
  percentile_25_total_cup_points,
  percentile_50_total_cup_points,
  percentile_75_total_cup_points
FROM 
  filtered
GROUP BY 
  percentile_25_total_cup_points,
  percentile_50_total_cup_points,
  percentile_75_total_cup_points;


/** 2. Region-specific analysis:
  What are the top coffee-producing regions based on quality scores?
  How do the quality scores vary across different regions?
  Is there a correlation between the region and other factors such as altitude or processing method?
**/
-- Get top 5 performing coffee by country of origin
CREATE TABLE IF NOT EXISTS `coffee-quality-institute.cqi_coffee_queries.top5_total_cup_scores_by_country_of_origin`
AS
SELECT 
  Country_of_Origin,
  ROUND(MIN(Total_Cup_Points),3) AS min_total_cup_points,
  ROUND(AVG(Total_Cup_Points),3) AS avg_total_cup_points,
  ROUND(MAX(Total_Cup_Points),3) AS max_total_cup_points
FROM `coffee-quality-institute.cqi_coffee_reviews.arabica_coffee_complete_table`
GROUP BY Country_of_Origin
ORDER BY max_total_cup_points DESC
LIMIT 5;

-- Get normal distribution parameters varying by country of origin 
CREATE TABLE IF NOT EXISTS `coffee-quality-institute.cqi_coffee_queries.norm_dist_parameters_total_cup_points_by_country_of_origin`
AS
WITH country_avg AS (
  SELECT 
    Country_of_Origin,
    AVG(Total_Cup_Points) AS avg_total_cup_score
  FROM `coffee-quality-institute.cqi_coffee_reviews.arabica_coffee_complete_table`
  GROUP BY Country_of_Origin
)
SELECT 
    ROUND(AVG(avg_total_cup_score),3) AS country_avg_total_cup_score,
    ROUND(STDDEV_SAMP(avg_total_cup_score),3) AS country_stdev_total_cup_points
FROM country_avg;

-- Get min, avg and max total cup points grouped by altitude
-- reference https://twochimpscoffee.com/blogs/how-does-altitude-affect-coffee-and-its-caffeine-levels/
CREATE TABLE IF NOT EXISTS `coffee-quality-institute.cqi_coffee_queries.total_cup_scores_by_altitude`
AS
SELECT 
  CASE 
    WHEN altitude < 610 THEN 'Very Low'
    WHEN altitude >= 610 AND altitude < 760 THEN 'Low Altitude'
    WHEN altitude >= 760 AND altitude < 1200 THEN 'Medium Altitude'
    WHEN altitude >= 1200 AND altitude < 1525 THEN 'High Altitude'
    WHEN altitude >= 1525 THEN 'Very High Altitude'
    ELSE 'Other'
  END AS bin,
  COUNT(*) AS count,
  ROUND(MIN(Total_Cup_Points),3) AS min_total_cup_score,
  ROUND(AVG(Total_Cup_Points),3) AS avg_total_cup_score,
  ROUND(MAX(Total_Cup_Points),3) AS max_total_cup_score,
FROM `coffee-quality-institute.cqi_coffee_reviews.arabica_coffee_complete_table`
WHERE Altitude IS NOT NULL
GROUP BY bin
HAVING bin <> 'Other';


/** 3. Varietal analysis:
  What are the most common coffee varietals in the dataset?
  How do the quality scores differ between different coffee varietals?
  Are certain varietals associated with specific flavor profiles?
**/
CREATE TABLE IF NOT EXISTS `coffee-quality-institute.cqi_coffee_queries.total_cup_scores_by_variety`
AS
SELECT
  Variety,
  COUNT(*) AS count_record,
  ROUND(AVG(Aroma),3) AS avg_aroma,
  ROUND(AVG(Flavor),3) AS avg_flavor,
  ROUND(AVG(Aftertaste),3) AS avg_aftertaste,
  ROUND(AVG(Acidity),3) AS avg_acidity,
  ROUND(AVG(Body),3) AS avg_body,
  ROUND(AVG(Balance),3) AS avg_balance,
  ROUND(AVG(Total_Cup_Points),3) AS avg_total_cup_points,
  ROUND(STDDEV_SAMP(Total_Cup_Points),3) AS stdev_total_cup_points
FROM `coffee-quality-institute.cqi_coffee_reviews.arabica_coffee_complete_table`
WHERE Variety IS NOT NULL AND Variety <> 'unknown'
GROUP BY
  Variety
ORDER BY
  count_record DESC
LIMIT 10;


/** 4. Processing method analysis:
  What are the different coffee processing methods used in the dataset?
  How does the processing method affect the quality scores?
  Are there any specific processing methods that consistently produce higher quality coffees?
**/
CREATE TABLE IF NOT EXISTS `coffee-quality-institute.cqi_coffee_queries.total_cup_scores_by_processing_method`
AS
SELECT
  Processing_Method,
  COUNT(*) AS count_record,
  ROUND(AVG(Aroma),3) AS avg_aroma,
  ROUND(AVG(Flavor),3) AS avg_flavor,
  ROUND(AVG(Aftertaste),3) AS avg_aftertaste,
  ROUND(AVG(Acidity),3) AS avg_acidity,
  ROUND(AVG(Body),3) AS avg_body,
  ROUND(AVG(Balance),3) AS avg_balance,
  ROUND(AVG(Total_Cup_Points),3) AS avg_total_cup_points,
  ROUND(STDDEV_SAMP(Total_Cup_Points),3) AS stdev_total_cup_points
FROM `coffee-quality-institute.cqi_coffee_reviews.arabica_coffee_complete_table`
WHERE Processing_Method IS NOT NULL AND Processing_Method <> 'unknown'
GROUP BY
  Processing_Method
ORDER BY
  count_record DESC;

/** 5. Relationship between attributes:
  Is there a correlation between altitude and quality scores?
  How does the moisture content, defects, quakers of coffee beans relate to their quality?
**/
-- Correlation between altitude and quality scores by country of origin
CREATE TABLE IF NOT EXISTS `coffee-quality-institute.cqi_coffee_queries.correlation_altitude_total_cup_scores_by_country_of_origin`
AS
SELECT 
  Country_of_Origin,
  COUNT(*) AS count_record,
  ROUND(AVG(Altitude),3) AS avg_altitude,
  ROUND(AVG(Total_Cup_Points),3) AS avg_total_cup_points,
  ROUND(CORR(Altitude, Total_Cup_Points),3) AS corr_altitude_total_cup_points
FROM `coffee-quality-institute.cqi_coffee_reviews.arabica_coffee_complete_table`
GROUP BY Country_of_Origin
HAVING count_record >= 50
ORDER BY count_record DESC;

-- Correlation between altitude and quality scores by variety
CREATE TABLE IF NOT EXISTS `coffee-quality-institute.cqi_coffee_queries.correlation_altitude_total_cup_scores_by_variety`
AS
SELECT 
  Variety,
  COUNT(*) AS count_record,
  ROUND(AVG(Altitude),3) AS avg_altitude,
  ROUND(AVG(Total_Cup_Points),3) AS avg_total_cup_points,
  ROUND(CORR(Altitude, Total_Cup_Points),3) AS corr_altitude_total_cup_points
FROM `coffee-quality-institute.cqi_coffee_reviews.arabica_coffee_complete_table`
WHERE Variety IS NOT NULL AND Variety <> 'unknown'
GROUP BY Variety
HAVING count_record >= 50
ORDER BY count_record DESC;

-- Correlation between moisture and total cup points by processing methods 
CREATE TABLE IF NOT EXISTS `coffee-quality-institute.cqi_coffee_queries.correlation_moisture_total_cup_scores_by_processing_method`
AS
SELECT
  Processing_Method,
  COUNT(*) as count_record,
  ROUND(AVG(Moisture),3) AS avg_moisture,
  ROUND(CORR(Moisture, Total_Cup_Points),3) AS corr_moisture_total_cup_points
FROM `coffee-quality-institute.cqi_coffee_reviews.arabica_coffee_complete_table`
WHERE Processing_Method IS NOT NULL AND Processing_Method <> 'unknown'
GROUP BY
  Processing_Method
ORDER BY
  count_record DESC;

-- Category One defects relationship with total cup points
CREATE TABLE IF NOT EXISTS `coffee-quality-institute.cqi_coffee_queries.defects_total_cup_scores`
AS
SELECT 
  CASE 
    WHEN Category_One_Defects = 0 THEN '0 Category One Defects'
    WHEN Category_One_Defects > 0 AND Category_One_Defects <= 5 THEN '1-5 Category One Defects'
    WHEN Category_One_Defects > 5 AND Category_One_Defects <= 10 THEN '5-10 Category One Defects'
    WHEN Category_One_Defects > 10 THEN '10+ Category One Defects'
  END AS bin,
  COUNT(*) AS count,
  ROUND(MIN(Total_Cup_Points),3) AS min_total_cup_score,
  ROUND(AVG(Total_Cup_Points),3) AS avg_total_cup_score,
  ROUND(MAX(Total_Cup_Points),3) AS max_total_cup_score
FROM `coffee-quality-institute.cqi_coffee_reviews.arabica_coffee_complete_table`
GROUP BY bin;
