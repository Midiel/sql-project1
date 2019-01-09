/*
 *	Midiel Rodriguez
 *	Panther ID: xxxxxx
 *	Section: COP4710 RVC 1188
 *	Date: 11/02/2018
 *	Project 3
 *
 *	This function randomly assigns grades to each record in the table "simulated_records"
 *	based on the grade probability distribution for each school from the "school_probs" table.
 *	
 *	Database requirements:
 *	- Character/string representing a grade as empty, must be the same character for all records.
 *	- The number of grades distribution probability must match the number of posible grades, and in the same order.
 *	- Only schools present in "school_probs" will have their records updated.
 *	- If total probability percentage (array elements) is over 100%, only the first 100% will be updated.	
 */

CREATE FUNCTION public.assign_grades()
    RETURNS void
    LANGUAGE 'plpgsql'
    
AS $BODY$
DECLARE

-- Varibles
empty_field text;									-- holds the text identifying the empty record
probs_element numeric;								-- to iterate through the probs array
temp_row school_probs%ROWTYPE;						-- to hold a temporary row of school_probs table
num_grades integer := 0;							-- to hold the number of tuples in the grade_values table

BEGIN

-- saves character/text identifying an empty record
SELECT INTO empty_field grade FROM simulated_records ORDER BY RANDOM() LIMIT 1;

-- saves the number of grades/rows in the grade_values table
SELECT INTO num_grades COUNT(id) FROM grade_values;

-- iterates through the school_probs table to assign the grades
FOR temp_row IN SELECT * FROM school_probs 
	LOOP
		
	-- Subblock
	DECLARE
	temp_num_records INTEGER NOT NULL := 0;			-- to hold number of records per school
	counter integer := 0;							-- counter for loops
	total_graded INTEGER := 0;						-- keep track of total graded crecords
	num_students integer := 0;						-- number of students/records to assign a grade value
	
	
	BEGIN
		
	-- Calculates and saves the number of records per school
	SELECT INTO temp_num_records COUNT(record_id) 
		FROM simulated_records
		WHERE simulated_records.school = temp_row.school;
		
		
	-- Iterates through the school_probs array
	FOREACH probs_element IN ARRAY temp_row.probs
		LOOP
		
		counter = counter + 1;													-- increase counter
		num_students = (probs_element * temp_num_records)::int;		-- calculates the probability distribution
	
		-- updates the simulated_records table with grades to random records
		UPDATE simulated_records SET grade = grade_values.grade
			FROM grade_values
			WHERE grade_values.id = counter
			AND record_id IN (SELECT record_id
								FROM simulated_records
								WHERE simulated_records.school = temp_row.school
								AND simulated_records.grade = empty_field
								ORDER BY RANDOM()
								LIMIT num_students);
							
		total_graded = total_graded + num_students;								-- keep track of how many records were updated
		
		END LOOP;
			
	-- to handle records left without a grade
	WHILE total_graded < temp_num_records
		LOOP

		-- assigns random grades to records left without a grade
		UPDATE simulated_records SET grade = grade_values.grade
			FROM grade_values
			WHERE grade_values.id IN (SELECT CEIL(RANDOM() * num_grades )::int) 	-- generates random number between 1 and possible # of grades
			AND record_id IN (SELECT record_id 
								FROM simulated_records
								WHERE grade = empty_field
								AND simulated_records.school = temp_row.school
								LIMIT 1);
				
		total_graded = total_graded + 1;										-- increase total graded count	
		
		END LOOP;
	END;
	END LOOP;
END;
$BODY$;

ALTER FUNCTION public.assign_grades()
    OWNER TO fall18_mrodr1186;	