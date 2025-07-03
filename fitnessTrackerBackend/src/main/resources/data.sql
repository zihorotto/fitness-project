-- Tábla létrehozása, ha még nincs
CREATE TABLE IF NOT EXISTS wods (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  type VARCHAR(50),
  category VARCHAR(50),
  duration_in_minutes INTEGER,
  description TEXT,
  full_description TEXT,
  movements TEXT
);

-- Adatok beszúrása, ha nincs még egyetlen sor sem a táblában
INSERT INTO wods (name, type, category, duration_in_minutes, description, full_description, movements)
SELECT * FROM (
  VALUES
    ('Cindy', 'AMRAP', 'BENCHMARK', 20,
     '5 Pull-ups, 10 Push-ups, 15 Air Squats',
     'Perform as many rounds as possible in 20 minutes., Great bodyweight benchmark WOD., Aim for steady pacing.',
     'Pull-ups, Push-ups, Air Squats'),

    ('Mary', 'AMRAP', 'BENCHMARK', 20,
     '5 Handstand Push-ups, 10 Pistols (each leg), 15 Pull-ups',
     'Perform as many rounds as possible in 20 minutes., A challenging benchmark focusing on gymnastics skills.',
     'Handstand Push-ups, Pistols, Pull-ups'),

    ('Barbara', 'AMRAP', 'BENCHMARK', 20,
     '20 Pull-ups, 30 Push-ups, 40 Sit-ups, 50 Air Squats',
     'Perform as many rounds as possible in 20 minutes., A classic bodyweight burner with high reps.',
     'Pull-ups, Push-ups, Sit-ups, Air Squats'),

    ('Chelsea', 'AMRAP', 'BENCHMARK', 30,
     '5 Pull-ups, 10 Push-ups, 15 Air Squats',
     'Perform as many rounds as possible in 30 minutes., Similar to Cindy, but with a longer duration.',
     'Pull-ups, Push-ups, Air Squats'),

    ('Annie', 'For Time', 'BENCHMARK', NULL,
     '50 Double-unders, 50 Sit-ups, 40 Double-unders, 40 Sit-ups, 30 Double-unders, 30 Sit-ups, 20 Double-unders, 20 Sit-ups, 10 Double-unders, 10 Sit-ups',
     'Perform the following triplet ladder for time: 50-40-30-20-10 reps of Double-unders and Sit-ups.',
     'Double-unders, Sit-ups'),

    ('Fran', 'For Time', 'BENCHMARK', NULL,
     '21-15-9 reps of:, Thrusters (95/65 lb), Pull-ups',
     'Complete all rounds as fast as possible., A short and intense benchmark with barbell and bodyweight movements.',
     'Thrusters, Pull-ups'),

    ('Helen', 'For Time', 'BENCHMARK', NULL,
     '3 rounds for time of:, 400m Run, 21 Kettlebell Swings (53/35 lb), 12 Pull-ups',
     'Complete all three rounds as fast as possible., A benchmark combining running, kettlebell, and pull-ups.',
     'Run, Kettlebell Swings, Pull-ups'),

    ('Grace', 'For Time', 'BENCHMARK', NULL,
     '30 Clean & Jerks (135/95 lb)',
     'Complete all 30 Clean & Jerks as fast as possible., A simple yet brutal barbell benchmark.',
     'Clean & Jerks'),

    ('Diane', 'For Time', 'BENCHMARK', NULL,
     '21-15-9 reps of:, Deadlifts (225/155 lb), Handstand Push-ups',
     'Complete all rounds as fast as possible., A benchmark combining heavy lifting and gymnastics.',
     'Deadlifts, Handstand Push-ups'),

    ('Elizabeth', 'For Time', 'BENCHMARK', NULL,
     '21-15-9 reps of:, Cleans (135/95 lb), Ring Dips',
     'Complete all rounds as fast as possible., A benchmark focusing on Olympic lifting and gymnastics.',
     'Cleans, Ring Dips'),

    ('Angie', 'For Time', 'BENCHMARK', NULL,
     '100 Pull-ups, 100 Push-ups, 100 Sit-ups, 100 Air Squats',
     'Complete all 100 repetitions of each exercise in any order., A long and grueling bodyweight challenge.',
     'Pull-ups, Push-ups, Sit-ups, Air Squats'),

    ('Modified Cindy', 'AMRAP', 'SCALED', 20,
     '5 Ring Rows, 10 Knee Push-ups, 15 Air Squats',
     'Perform as many rounds as possible in 20 minutes., A scaled version of Cindy for beginners.',
     'Ring Rows, Knee Push-ups, Air Squats'),

    ('Bodyweight Blast', 'AMRAP', NULL, 15,
     '8 Burpees, 12 Lunges (each leg), 16 Mountain Climbers (each leg)',
     'Perform as many rounds as possible in 15 minutes., A high-intensity bodyweight workout.',
     'Burpees, Lunges, Mountain Climbers'),

    ('Core Crusher', 'AMRAP', NULL, 18,
     '10 Sit-ups, 10 Russian Twists, 10 Leg Raises',
     'Perform as many rounds as possible in 18 minutes., Focuses on core strength and endurance.',
     'Sit-ups, Russian Twists, Leg Raises'),

    ('Upper Body Burn', 'AMRAP', NULL, 25,
     '6 Pull-ups, 12 Push-ups, 18 Dips',
     'Perform as many rounds as possible in 25 minutes., Targets the upper body muscles.',
     'Pull-ups, Push-ups, Dips'),

    ('Leg Day Ladder', 'AMRAP', NULL, 20,
     '10 Air Squats, 10 Walking Lunges (each leg), 10 Glute Bridges',
     'Perform as many rounds as possible in 20 minutes., Focuses on lower body strength and endurance.',
     'Air Squats, Walking Lunges, Glute Bridges'),

    ('Cardio Circuit', 'AMRAP', NULL, 16,
     '20 Jumping Jacks, 10 Burpees, 15 High Knees (each leg)',
     'Perform as many rounds as possible in 16 minutes., A cardio-focused bodyweight workout.',
     'Jumping Jacks, Burpees, High Knees'),

    ('Full Body Flow', 'AMRAP', NULL, 22,
     '5 Burpees, 10 Air Squats, 15 Push-ups',
     'Perform as many rounds as possible in 22 minutes., A well-rounded bodyweight workout.',
     'Burpees, Air Squats, Push-ups'),

    ('Gymnastics Grind', 'AMRAP', NULL, 17,
     '3 Pull-ups, 6 Push-ups, 9 Air Squats, 3 Handstand Holds (seconds)',
     'Perform as many rounds as possible in 17 minutes., Incorporates basic gymnastics elements.',
     'Pull-ups, Push-ups, Air Squats, Handstand Holds'),

    ('Endurance Challenge', 'AMRAP', NULL, 30,
     '10 Air Squats, 10 Sit-ups, 10 Jumping Jacks',
     'Perform as many rounds as possible in 30 minutes., Tests your bodyweight endurance.',
     'Air Squats, Sit-ups, Jumping Jacks'),

    ('Quick Hit', 'AMRAP', NULL, 12,
     '5 Burpees, 10 Air Squats, 15 Mountain Climbers (each leg)',
     'Perform as many rounds as possible in 12 minutes., A short and effective bodyweight blast.',
     'Burpees, Air Squats, Mountain Climbers')
) AS vals(name, type, category, duration_in_minutes, description, full_description, movements)
WHERE NOT EXISTS (SELECT 1 FROM wods);
