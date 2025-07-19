use study_db; # database used

# create table
CREATE TABLE students_performance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    gender VARCHAR(10),
    race_ethnicity VARCHAR(50),
    parental_level_of_education VARCHAR(50),
    lunch VARCHAR(20),
    test_preparation_course VARCHAR(30),
    math_score INT,
    reading_score INT,
    writing_score INT
);

# data load to table
LOAD DATA LOCAL INFILE 'C:/Users/Koteswarao/Downloads/StudentsPerformance.csv'
INTO TABLE students_performance
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(gender, race_ethnicity, parental_level_of_education, lunch, test_preparation_course, math_score, reading_score, writing_score);

# show the structure of a table.
DESCRIBE students_performance;

#Count total rows:
select count(*) from students_performance;

# Show first five  values from table
select *
from students_performance
limit 5;

# detect null values 
select 
concat('sum( ',column_name, ' is null) as ', column_name,'_null') as null_check
from information_schema.columns
where table_name = 'students_performance'
and table_schema = 'study_db';

SELECT 
    SUM(gender IS NULL) AS gender_nulls,
    SUM(race_ethnicity IS NULL) AS race_ethnicity_nulls,
    SUM(parental_level_of_education IS NULL) AS parental_level_of_education_nulls,
    SUM(lunch IS NULL) AS lunch_nulls,
    SUM(test_preparation_course IS NULL) AS test_preparation_course_nulls,
    SUM(math_score IS NULL) AS math_score_nulls,
    SUM(reading_score IS NULL) AS reading_score_nulls,
    SUM(writing_score IS NULL) AS writing_score_nulls
FROM students_performance;

#blank values
select
concat('sum(trim(',column_name, ") =' ') as ",column_name, '_blank') as blank_value
from information_schema.columns
where table_name = 'students_performance'
and table_schema = 'study_db'
and data_type in ('varchar','text','char');

select
sum(trim(gender) =' ') as gender_blank,
sum(trim(race_ethnicity) =' ') as race_ethnicity_blank,
sum(trim(parental_level_of_education) =' ') as parental_level_of_education_blank,
sum(trim(lunch) =' ') as lunch_blank,
sum(trim(test_preparation_course) =' ') as test_preparation_course_blank,
sum(math_score is null or math_score < 0 or math_score > 100 ) as math_score_invalid,
sum(reading_score is null or reading_score < 0 or reading_score > 100) as reading_score_invalid,
sum(writing_score is null or writing_score < 0 or writing_score > 100) as writing_score_invalid
from students_performance;

#find duplicate values
SELECT *
FROM (
  SELECT *, 
         ROW_NUMBER() OVER (
           PARTITION BY gender, race_ethnicity, parental_level_of_education, lunch,
                        test_preparation_course, math_score, reading_score, writing_score
           ORDER BY id
         ) AS rn
  FROM students_performance
) AS ranked
WHERE rn > 1;

#remove deplicate values
DELETE FROM students_performance
WHERE id IN (
  SELECT id FROM (
    SELECT id,
           ROW_NUMBER() OVER (
             PARTITION BY gender, race_ethnicity, parental_level_of_education, lunch,
                          test_preparation_course, math_score, reading_score, writing_score
             ORDER BY id
           ) AS rn
    FROM students_performance
  ) AS ranked
  WHERE rn > 1
);
#Total count for after remove duplicates
select count(*) from students_performance;

# Overall Summary for Scores
SELECT 
  COUNT(*) AS total_rows,
  ROUND(AVG(math_score), 2) AS avg_math,
  ROUND(MIN(math_score), 2) AS min_math,
  ROUND(MAX(math_score), 2) AS max_math,

  ROUND(AVG(reading_score), 2) AS avg_reading,
  ROUND(MIN(reading_score), 2) AS min_reading,
  ROUND(MAX(reading_score), 2) AS max_reading,

  ROUND(AVG(writing_score), 2) AS avg_writing,
  ROUND(MIN(writing_score), 2) AS min_writing,
  ROUND(MAX(writing_score), 2) AS max_writing
FROM students_performance;

# Average Scores Grouped by Gender
SELECT 
  gender,
  ROUND(AVG(math_score), 2) AS avg_math,
  ROUND(AVG(reading_score), 2) AS avg_reading,
  ROUND(AVG(writing_score), 2) AS avg_writing
FROM students_performance
GROUP BY gender;

# Average Scores by Parental Education Level
SELECT 
  parental_level_of_education,
  ROUND(AVG(math_score), 2) AS avg_math,
  ROUND(AVG(reading_score), 2) AS avg_reading,
  ROUND(AVG(writing_score), 2) AS avg_writing
FROM students_performance
GROUP BY parental_level_of_education
ORDER BY avg_math DESC;

# Count of Students per Group 
SELECT 
  gender,
  lunch,
  COUNT(*) AS student_count
FROM students_performance
GROUP BY gender, lunch;

# add avg column
ALTER TABLE students_performance ADD average_score DECIMAL(5,2);

UPDATE students_performance
SET average_score = ROUND((math_score + reading_score + writing_score)/3, 2);

select * from students_performance;


SET SQL_SAFE_UPDATES = 0;

UPDATE students_performance
SET average_score = ROUND((math_score + reading_score + writing_score) / 3, 2)
WHERE math_score IS NOT NULL
  AND reading_score IS NOT NULL
  AND writing_score IS NOT NULL;
  
SET SQL_SAFE_UPDATES = 1;

# add column
ALTER TABLE students_performance
ADD performance_level VARCHAR(20);

# student marks performance
UPDATE students_performance
SET performance_level = CASE
    WHEN average_score >= 90 THEN 'Excellent'
    WHEN average_score >= 75 THEN 'Good'
    WHEN average_score >= 50 THEN 'Average'
    ELSE 'Poor'
END
WHERE average_score IS NOT NULL;


