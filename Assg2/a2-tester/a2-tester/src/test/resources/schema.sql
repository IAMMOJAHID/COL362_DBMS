CREATE TABLE player (
    player_id VARCHAR(20) PRIMARY KEY,
    player_name VARCHAR(255),
    dob DATE,
    batting_hand VARCHAR(20),
    bowling_skill VARCHAR(20),
    country_name VARCHAR(100)
);

CREATE TABLE season (
    season_id VARCHAR(20) PRIMARY KEY,
    year SMALLINT,
    start_date DATE,
    end_date DATE
);

CREATE TABLE team (
    team_id VARCHAR(20) PRIMARY KEY,
    team_name VARCHAR(255),
    coach_name VARCHAR(255),
    region VARCHAR(100)
);

CREATE TABLE player_team (
    player_id VARCHAR(20),
    team_id VARCHAR(20),
    season_id VARCHAR(20),
    PRIMARY KEY (player_id, team_id, season_id),
    FOREIGN KEY (player_id) REFERENCES player(player_id),
    FOREIGN KEY (team_id) REFERENCES team(team_id),
    FOREIGN KEY (season_id) REFERENCES season(season_id)
);

CREATE TABLE auction (
    auction_id VARCHAR(20) PRIMARY KEY,
    season_id VARCHAR(20),
    player_id VARCHAR(20),
    base_price BIGINT,
    sold_price BIGINT,
    is_sold BOOLEAN,
    team_id VARCHAR(20),
    FOREIGN KEY (season_id) REFERENCES season(season_id),
    FOREIGN KEY (player_id) REFERENCES player(player_id),
    FOREIGN KEY (team_id) REFERENCES team(team_id)
);

CREATE TABLE match (
    match_id VARCHAR(20) PRIMARY KEY,
    match_type VARCHAR(20),
    venue VARCHAR(20),
    team_1_id VARCHAR(20),
    team_2_id VARCHAR(20),
    match_date DATE,
    season_id VARCHAR(20),
    win_run_margin SMALLINT,
    win_by_wickets SMALLINT,
    win_type VARCHAR(20),
    toss_winner SMALLINT,
    toss_decide VARCHAR(20),
    winner_team_id VARCHAR(20),
    FOREIGN KEY (team_1_id) REFERENCES team(team_id),
    FOREIGN KEY (team_2_id) REFERENCES team(team_id),
    FOREIGN KEY (season_id) REFERENCES season(season_id),
    FOREIGN KEY (winner_team_id) REFERENCES team(team_id)
);

CREATE TABLE player_match (
    player_id VARCHAR(20),
    match_id VARCHAR(20),
    role VARCHAR(20),
    team_id VARCHAR(20),
    is_extra BOOLEAN,
    PRIMARY KEY (player_id, match_id),
    FOREIGN KEY (player_id) REFERENCES player(player_id),
    FOREIGN KEY (match_id) REFERENCES match(match_id),
    FOREIGN KEY (team_id) REFERENCES team(team_id)
);

CREATE TABLE balls (
    match_id VARCHAR(20),
    innings_num SMALLINT,
    over_num SMALLINT,
    ball_num SMALLINT,
    striker_id VARCHAR(20),
    non_striker_id VARCHAR(20),
    bowler_id VARCHAR(20),
    PRIMARY KEY (match_id, innings_num, over_num, ball_num),
    FOREIGN KEY (match_id) REFERENCES match(match_id),
    FOREIGN KEY (striker_id) REFERENCES player(player_id),
    FOREIGN KEY (non_striker_id) REFERENCES player(player_id),
    FOREIGN KEY (bowler_id) REFERENCES player(player_id)
);

CREATE TABLE batter_score (
    match_id VARCHAR(20),
    innings_num SMALLINT,
    over_num SMALLINT,
    ball_num SMALLINT,
    run_scored SMALLINT,
    type_run VARCHAR(20),
    PRIMARY KEY (match_id, innings_num, over_num, ball_num),
    FOREIGN KEY (match_id, innings_num, over_num, ball_num) REFERENCES balls(match_id, innings_num, over_num, ball_num)
);

CREATE TABLE extras (
    match_id VARCHAR(20),
    innings_num SMALLINT,
    over_num SMALLINT,
    ball_num SMALLINT,
    extra_runs SMALLINT,
    extra_type VARCHAR(20),
    PRIMARY KEY (match_id, innings_num, over_num, ball_num),
    FOREIGN KEY (match_id, innings_num, over_num, ball_num) REFERENCES balls(match_id, innings_num, over_num, ball_num)
);

CREATE TABLE wickets (
    match_id VARCHAR(20),
    innings_num SMALLINT,
    over_num SMALLINT,
    ball_num SMALLINT,
    player_out_id VARCHAR(20),
    kind_out VARCHAR(20),
    fielder_id VARCHAR(20),
    PRIMARY KEY (match_id, innings_num, over_num, ball_num),
    FOREIGN KEY (match_id, innings_num, over_num, ball_num) REFERENCES balls(match_id, innings_num, over_num, ball_num),
    FOREIGN KEY (player_out_id) REFERENCES player(player_id),
    FOREIGN KEY (fielder_id) REFERENCES player(player_id)
);

CREATE TABLE awards (
    match_id VARCHAR(20),
    award_type VARCHAR(20),
    player_id VARCHAR(20),
    PRIMARY KEY (match_id, award_type),
    FOREIGN KEY (match_id) REFERENCES match(match_id),
    FOREIGN KEY (player_id) REFERENCES player(player_id)
);

ALTER TABLE team 
ADD CONSTRAINT unique_team_name UNIQUE (team_name);
ALTER TABLE team 
ADD CONSTRAINT unique_team_region UNIQUE (region);
ALTER TABLE auction 
ADD CONSTRAINT unique_auction_entry UNIQUE (player_id, team_id, season_id);

ALTER TABLE extras 
ADD CONSTRAINT fk_balls_extras
FOREIGN KEY (match_id, innings_num, over_num, ball_num) 
REFERENCES balls(match_id, innings_num, over_num, ball_num);

ALTER TABLE wickets 
ADD CONSTRAINT fk_balls_wickets 
FOREIGN KEY (match_id, innings_num, over_num, ball_num) 
REFERENCES balls(match_id, innings_num, over_num, ball_num);

ALTER TABLE batter_score 
ADD CONSTRAINT fk_balls_batter_score
FOREIGN KEY (match_id, innings_num, over_num, ball_num) 
REFERENCES balls(match_id, innings_num, over_num, ball_num);

ALTER TABLE player_team 
ADD CONSTRAINT fk_auction_player_team 
FOREIGN KEY (player_id, team_id, season_id) 
REFERENCES auction(player_id, team_id, season_id);

ALTER TABLE extras 
ADD CONSTRAINT chk_extra_type 
CHECK (extra_type IN ('no_ball', 'wide', 'byes', 'legbyes'));

ALTER TABLE awards 
ADD CONSTRAINT chk_award_type 
CHECK (award_type IN ('orange_cap', 'purple_cap'));

ALTER TABLE batter_score 
ADD CONSTRAINT chk_type_run 
CHECK (type_run IN ('running', 'boundary'));

ALTER TABLE match 
ADD CONSTRAINT chk_match_type 
CHECK (match_type IN ('league', 'playoff', 'knockout'));

ALTER TABLE match 
ADD CONSTRAINT chk_win_type 
CHECK (win_type IN ('runs', 'wickets', 'draw'));

ALTER TABLE match 
ADD CONSTRAINT chk_toss_winner 
CHECK (toss_winner IN (1, 2));

ALTER TABLE match 
ADD CONSTRAINT chk_toss_decide 
CHECK (toss_decide IN ('bowl', 'bat'));

ALTER TABLE player 
ADD CONSTRAINT chk_batting_hand 
CHECK (batting_hand IN ('left', 'right'));

ALTER TABLE player 
ADD CONSTRAINT chk_bowling_skill 
CHECK (bowling_skill IN ('fast', 'medium', 'legspin', 'offspin'));

ALTER TABLE player_match 
ADD CONSTRAINT chk_role 
CHECK (role IN ('batter', 'bowler', 'allrounder', 'wicketkeeper'));

ALTER TABLE wickets 
ADD CONSTRAINT chk_kind_out 
CHECK (kind_out IN ('bowled', 'caught', 'lbw', 'runout', 'stumped', 'hitwicket'));

ALTER TABLE batter_score 
ADD CONSTRAINT chk_run_scored 
CHECK (run_scored >= 0);

ALTER TABLE extras 
ADD CONSTRAINT chk_extra_runs 
CHECK (extra_runs >= 0);

ALTER TABLE player 
ADD CONSTRAINT chk_dob 
CHECK (dob < '2016-01-01');

ALTER TABLE season 
ADD CONSTRAINT chk_year 
CHECK (year BETWEEN 1900 AND 2025);

ALTER TABLE auction 
ALTER COLUMN auction_id SET NOT NULL,
ALTER COLUMN season_id SET NOT NULL,
ALTER COLUMN player_id SET NOT NULL,
ALTER COLUMN base_price SET NOT NULL,
ALTER COLUMN is_sold SET NOT NULL;

ALTER TABLE awards 
ALTER COLUMN match_id SET NOT NULL,
ALTER COLUMN award_type SET NOT NULL,
ALTER COLUMN player_id SET NOT NULL;

ALTER TABLE balls 
ALTER COLUMN match_id SET NOT NULL,
ALTER COLUMN innings_num SET NOT NULL,
ALTER COLUMN over_num SET NOT NULL,
ALTER COLUMN ball_num SET NOT NULL,
ALTER COLUMN striker_id SET NOT NULL,
ALTER COLUMN non_striker_id SET NOT NULL,
ALTER COLUMN bowler_id SET NOT NULL;

ALTER TABLE batter_score 
ALTER COLUMN match_id SET NOT NULL,
ALTER COLUMN over_num SET NOT NULL,
ALTER COLUMN innings_num SET NOT NULL,
ALTER COLUMN ball_num SET NOT NULL,
ALTER COLUMN run_scored SET NOT NULL;

ALTER TABLE extras 
ALTER COLUMN match_id SET NOT NULL,
ALTER COLUMN innings_num SET NOT NULL,
ALTER COLUMN over_num SET NOT NULL,
ALTER COLUMN ball_num SET NOT NULL,
ALTER COLUMN extra_runs SET NOT NULL,
ALTER COLUMN extra_type SET NOT NULL;

ALTER TABLE match 
ALTER COLUMN match_id SET NOT NULL,
ALTER COLUMN match_type SET NOT NULL,
ALTER COLUMN venue SET NOT NULL,
ALTER COLUMN team_1_id SET NOT NULL,
ALTER COLUMN team_2_id SET NOT NULL,
ALTER COLUMN match_date SET NOT NULL,
ALTER COLUMN season_id SET NOT NULL;

ALTER TABLE player 
ALTER COLUMN player_id SET NOT NULL,
ALTER COLUMN player_name SET NOT NULL,
ALTER COLUMN dob SET NOT NULL,
ALTER COLUMN batting_hand SET NOT NULL,
ALTER COLUMN country_name SET NOT NULL;

ALTER TABLE player_match 
ALTER COLUMN player_id SET NOT NULL,
ALTER COLUMN match_id SET NOT NULL,
ALTER COLUMN team_id SET NOT NULL,
ALTER COLUMN role SET NOT NULL,
ALTER COLUMN is_extra SET NOT NULL;

ALTER TABLE player_team 
ALTER COLUMN player_id SET NOT NULL,
ALTER COLUMN team_id SET NOT NULL,
ALTER COLUMN season_id SET NOT NULL;

ALTER TABLE season 
ALTER COLUMN season_id SET NOT NULL,
ALTER COLUMN year SET NOT NULL,
ALTER COLUMN start_date SET NOT NULL,
ALTER COLUMN end_date SET NOT NULL;

ALTER TABLE team 
ALTER COLUMN team_id SET NOT NULL,
ALTER COLUMN team_name SET NOT NULL,
ALTER COLUMN coach_name SET NOT NULL,
ALTER COLUMN region SET NOT NULL;

ALTER TABLE wickets 
ALTER COLUMN match_id SET NOT NULL,
ALTER COLUMN innings_num SET NOT NULL,
ALTER COLUMN over_num SET NOT NULL,
ALTER COLUMN ball_num SET NOT NULL,
ALTER COLUMN player_out_id SET NOT NULL,
ALTER COLUMN kind_out SET NOT NULL;

ALTER TABLE match 
ADD CONSTRAINT check_win_type_validity CHECK (
    (win_type = 'draw' AND win_run_margin IS NULL AND win_by_wickets IS NULL) OR
    (win_type = 'runs' AND win_by_wickets IS NULL AND win_run_margin IS NOT NULL) OR
    (win_type = 'wickets' AND win_run_margin IS NULL AND win_by_wickets IS NOT NULL)
);
ALTER TABLE auction 
ADD CONSTRAINT check_sold_price CHECK (
    is_sold = FALSE OR (sold_price IS NOT NULL AND team_id IS NOT NULL AND sold_price >= base_price)
);
ALTER TABLE wickets 
ADD CONSTRAINT check_fielder_for_caught_runout_stumped CHECK (
    (kind_out IN ('caught', 'runout', 'stumped') AND fielder_id IS NOT NULL) OR
    (kind_out NOT IN ('caught', 'runout', 'stumped') AND fielder_id IS NULL)
);

CREATE OR REPLACE FUNCTION check_stumping_wicketkeeper()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.kind_out = 'stumped' THEN
        IF NOT EXISTS (
            SELECT 1 FROM player_match
            WHERE player_id = NEW.fielder_id AND role = 'wicketkeeper' AND match_id = NEW.match_id
        ) THEN
            RAISE EXCEPTION 'for stumped dismissal, fielder must be a wicketkeeper';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_stumping_wicketkeeper
BEFORE INSERT OR UPDATE ON wickets
FOR EACH ROW EXECUTE FUNCTION check_stumping_wicketkeeper();

CREATE OR REPLACE FUNCTION player_team_insert()
RETURNS TRIGGER AS $$
BEGIN
    
    IF NEW.is_sold = TRUE THEN
        INSERT INTO player_team (player_id, team_id, season_id)
        VALUES (NEW.player_id, NEW.team_id, NEW.season_id);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_player_team_insert
AFTER INSERT ON auction
FOR EACH ROW
EXECUTE FUNCTION player_team_insert();

CREATE OR REPLACE FUNCTION season_id_generator()
RETURNS TRIGGER AS $$
BEGIN
    NEW.season_id := 'IPL' || NEW.year;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_season_id_generator
BEFORE INSERT ON season
FOR EACH ROW
EXECUTE FUNCTION season_id_generator();

CREATE OR REPLACE FUNCTION match_id_validator()
RETURNS TRIGGER AS $$
DECLARE
    expected_match_id TEXT;
    last_serial INTEGER;
BEGIN
    SELECT COALESCE(MAX(CAST(SUBSTRING(match_id FROM 8) AS INTEGER)), 0)
    INTO last_serial
    FROM match
    WHERE season_id = NEW.season_id;

    expected_match_id := NEW.season_id || LPAD((last_serial + 1)::TEXT, 3, '0');

    IF NEW.match_id <> expected_match_id THEN
        RAISE EXCEPTION  'sequence of match id violated';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_match_id_validator
BEFORE INSERT OR UPDATE ON match
FOR EACH ROW
EXECUTE FUNCTION match_id_validator();

CREATE OR REPLACE FUNCTION check_international_players()
RETURNS TRIGGER AS $$
DECLARE
    intl_player_count INTEGER;
BEGIN
   
    SELECT COUNT(*) INTO intl_player_count
    FROM player_team pt
    JOIN player p ON pt.player_id = p.player_id
    WHERE pt.team_id = NEW.team_id
      AND pt.season_id = NEW.season_id
      AND p.country_name <> 'India';  

   
    IF (SELECT country_name FROM player WHERE player_id = NEW.player_id) <> 'India' THEN
        IF intl_player_count >= 3 THEN
            RAISE EXCEPTION 'there could be atmost 3 international players per team per season';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_limit_international_players
BEFORE INSERT OR UPDATE ON player_team
FOR EACH ROW
EXECUTE FUNCTION check_international_players();


CREATE OR REPLACE FUNCTION home_match_constraints()
RETURNS TRIGGER AS $$
DECLARE
    home_team_region TEXT;
    away_team_region TEXT;
    home_matches_count INT;
    away_matches_count INT;
BEGIN

    SELECT region INTO home_team_region FROM team WHERE team_id = NEW.team_1_id;
    SELECT region INTO away_team_region FROM team WHERE team_id = NEW.team_2_id;

    IF NEW.match_type = 'League' THEN
        
        IF NEW.venue <> home_team_region AND NEW.venue <> away_team_region THEN
            RAISE EXCEPTION 'league match must be played at home ground of one of the teams';
        END IF;

        SELECT COUNT(*) INTO home_matches_count 
        FROM match 
        WHERE season_id = NEW.season_id 
          AND match_type = 'League'
          AND team_1_id = NEW.team_1_id 
          AND team_2_id = NEW.team_2_id 
          AND venue = home_team_region;

        SELECT COUNT(*) INTO away_matches_count 
        FROM match 
        WHERE season_id = NEW.season_id 
          AND match_type = 'League'
          AND team_1_id = NEW.team_2_id 
          AND team_2_id = NEW.team_1_id 
          AND venue = away_team_region;

        IF home_matches_count >= 1 AND NEW.venue = home_team_region THEN
            RAISE EXCEPTION 'each team can play only one home match in a league against another team';
        END IF;
        
        IF away_matches_count >= 1 AND NEW.venue = away_team_region THEN
            RAISE EXCEPTION 'each team can play only one away match in a league against another team';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_home_match_constraints
BEFORE INSERT OR UPDATE ON match
FOR EACH ROW
EXECUTE FUNCTION home_match_constraints();

CREATE OR REPLACE FUNCTION update_match_winner_and_awards()
RETURNS TRIGGER AS $$
DECLARE
    orange_cap_player INT;
    purple_cap_player INT;
    max_runs INT;
    max_wickets INT;
BEGIN

    IF NEW.win_type = 'Draw' THEN
        NEW.winner_team_id = NULL;
    ELSE
        NEW.winner_team_id = NEW.team_1_id; 
        IF NEW.win_run_margin IS NOT NULL OR NEW.win_by_wickets IS NOT NULL THEN
            NEW.winner_team_id = CASE 
                WHEN NEW.win_type = 'Runs' THEN NEW.team_1_id
                WHEN NEW.win_type = 'Wickets' THEN NEW.team_2_id
                ELSE NULL 
            END;
        END IF;
    END IF;

    SELECT player_id, SUM(runs_scored) AS total_runs
    INTO orange_cap_player, max_runs
    FROM balls
    WHERE season_id = NEW.season_id
    GROUP BY player_id
    ORDER BY total_runs DESC, player_id ASC
    LIMIT 1;


    SELECT player_id, COUNT(*) AS total_wickets
    INTO purple_cap_player, max_wickets
    FROM balls
    WHERE season_id = NEW.season_id AND dismissal_type IS NOT NULL
    GROUP BY player_id
    ORDER BY total_wickets DESC, player_id ASC
    LIMIT 1;

    INSERT INTO awards (season_id, player_id, award_type, award_value)
    VALUES (NEW.season_id, orange_cap_player, 'Orange Cap', max_runs);

    INSERT INTO awards (season_id, player_id, award_type, award_value)
    VALUES (NEW.season_id, purple_cap_player, 'Purple Cap', max_wickets);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_match_winner_and_awards
AFTER UPDATE OF win_run_margin, win_by_wickets, win_type ON match
FOR EACH ROW
WHEN (NEW.win_run_margin IS NOT NULL OR NEW.win_by_wickets IS NOT NULL OR NEW.win_type IS NOT NULL)
EXECUTE FUNCTION update_match_winner_and_awards();

CREATE OR REPLACE FUNCTION delete_auction() RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM player_team WHERE player_id = OLD.player_id AND season_id = OLD.season_id;
    DELETE FROM awards WHERE player_id = OLD.player_id;
    DELETE FROM player_match WHERE player_id = OLD.player_id;
    DELETE FROM balls WHERE striker_id = OLD.player_id OR bowler_id = OLD.player_id;
    DELETE FROM batter_score WHERE match_id IN (SELECT match_id FROM balls WHERE striker_id = OLD.player_id);
    DELETE FROM extras WHERE match_id IN (SELECT match_id FROM balls WHERE striker_id = OLD.player_id);
    DELETE FROM wickets WHERE bowler_id = OLD.player_id;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trgr_delete_auction
AFTER DELETE ON auction
FOR EACH ROW EXECUTE FUNCTION delete_auction();

CREATE OR REPLACE FUNCTION delete_match() RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM awards WHERE match_id = OLD.match_id;
    DELETE FROM balls WHERE match_id = OLD.match_id;
    DELETE FROM batter_score WHERE match_id = OLD.match_id;
    DELETE FROM extras WHERE match_id = OLD.match_id;
    DELETE FROM wickets WHERE match_id = OLD.match_id;
    DELETE FROM player_match WHERE match_id = OLD.match_id;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trgr_delete_match
AFTER DELETE ON match
FOR EACH ROW EXECUTE FUNCTION delete_match();


CREATE OR REPLACE FUNCTION delete_season() RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM auction WHERE season_id = OLD.season_id;
    DELETE FROM awards WHERE match_id IN (SELECT match_id FROM match WHERE season_id = OLD.season_id);
    DELETE FROM balls WHERE match_id IN (SELECT match_id FROM match WHERE season_id = OLD.season_id);
    DELETE FROM batter_score WHERE match_id IN (SELECT match_id FROM match WHERE season_id = OLD.season_id);
    DELETE FROM extras WHERE match_id IN (SELECT match_id FROM match WHERE season_id = OLD.season_id);
    DELETE FROM wickets WHERE match_id IN (SELECT match_id FROM match WHERE season_id = OLD.season_id);
    DELETE FROM player_match WHERE match_id IN (SELECT match_id FROM match WHERE season_id = OLD.season_id);
    DELETE FROM player_team WHERE season_id = OLD.season_id;
    DELETE FROM match WHERE season_id = OLD.season_id;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trgr_delete_season
AFTER DELETE ON season
FOR EACH ROW EXECUTE FUNCTION delete_season();

CREATE OR REPLACE VIEW batter_stats AS
WITH batting AS (
    SELECT 
        b.player_id,
        COUNT(DISTINCT b.match_id) AS Mat,               
        COUNT(b.match_id) AS Inns,                       
        SUM(b.runs) AS R,                                
        MAX(b.runs) AS HS,                               
        COUNT(*) FILTER (WHERE b.runs = 0) AS Ducks,    
        SUM(b.balls_faced) AS BF,                        
        COUNT(*) FILTER (WHERE b.runs >= 100) AS "100s", 
        COUNT(*) FILTER (WHERE b.runs BETWEEN 50 AND 99) AS "50s", 
        SUM(b.boundaries) AS Boundaries,                 
        COUNT(*) FILTER (WHERE b.out_flag = FALSE) AS NO  
    FROM (
        SELECT 
            bl.striker_id AS player_id,  
            bl.match_id,
            COALESCE(SUM(bs.run_scored), 0) AS runs,  
            COUNT(*) FILTER (WHERE e.match_id IS NULL) AS balls_faced, 
            COUNT(*) FILTER (WHERE bs.run_scored IN (4,6)) AS boundaries,
            BOOL_OR(wk.player_out_id IS NOT NULL) AS out_flag  
        FROM balls bl
        LEFT JOIN batter_score bs 
            ON bl.match_id = bs.match_id 
            AND bl.ball_num = bs.ball_num 
            AND bl.innings_num = bs.innings_num
        LEFT JOIN extras e 
            ON bl.match_id = e.match_id 
            AND bl.ball_num = e.ball_num 
            AND bl.innings_num = e.innings_num
        LEFT JOIN wickets wk 
            ON bl.match_id = wk.match_id 
            AND bl.striker_id = wk.player_out_id
        GROUP BY bl.striker_id, bl.match_id
    ) b
    GROUP BY b.player_id
)
SELECT 
    player_id,
    Mat,
    Inns,
    R,
    HS,
    ROUND(CASE WHEN (Inns - NO) > 0 THEN R::numeric / NULLIF((Inns - NO), 0) ELSE 0 END, 2) AS Avg,
    
    ROUND(CASE WHEN BF > 0 THEN ((R::numeric / NULLIF(BF, 0)) * 100) ELSE 0 END, 2) AS SR, 
    "100s",
    "50s",
    Ducks,
    BF,
    Boundaries,
    NO
FROM batting;

CREATE OR REPLACE VIEW bowler_stats AS
WITH bowling AS (
    SELECT 
        b.player_id,
        COUNT(*) AS B,  
        COUNT(*) FILTER (WHERE w.kind_out IN ('bowled', 'caught', 'lbw', 'stumped')) AS W, 
        SUM(b.runs_given) AS Runs,  
        SUM(b.extras_given) AS Extras,
        COUNT(DISTINCT (b.match_id, b.innings_num, b.over_num)) AS Overs 
    FROM (
        SELECT 
            bl.bowler_id AS player_id,
            bl.match_id,
            bl.innings_num,
            bl.over_num,
            bl.ball_num,
            COALESCE(bs.run_scored, 0) + COALESCE(e.extra_runs, 0) AS runs_given, 
            COALESCE(e.extra_runs, 0) AS extras_given
        FROM balls bl
        LEFT JOIN batter_score bs
            ON bl.match_id = bs.match_id
            AND bl.innings_num = bs.innings_num
            AND bl.over_num = bs.over_num
            AND bl.ball_num = bs.ball_num
        LEFT JOIN extras e 
            ON bl.match_id = e.match_id 
            AND bl.innings_num = e.innings_num
            AND bl.over_num = e.over_num
            AND bl.ball_num = e.ball_num
    ) b
    LEFT JOIN wickets w 
        ON b.match_id = w.match_id 
        AND b.innings_num = w.innings_num
        AND b.over_num = w.over_num
        AND b.ball_num = w.ball_num
    GROUP BY b.player_id
)
SELECT 
    player_id,
    B, 
    W, 
    Runs, 
    ROUND(CASE WHEN W > 0 THEN Runs::numeric / W ELSE 0 END, 2) AS Avg, 
    ROUND(CASE WHEN Overs > 0 THEN Runs::numeric / Overs ELSE 0 END, 2) AS Econ, 
    ROUND(CASE WHEN W > 0 THEN B::numeric / W ELSE 0 END, 2) AS SR, 
    Extras
FROM bowling;

CREATE OR REPLACE VIEW fielder_stats AS
SELECT 
    fielder_id AS player_id,
    COUNT(*) FILTER (WHERE kind_out = 'caught') AS C, 
    COUNT(*) FILTER (WHERE kind_out = 'stumped') AS St,
    COUNT(*) FILTER (WHERE kind_out = 'run out') AS RO 
FROM wickets
WHERE kind_out IN ('caught', 'stumped', 'run out')
GROUP BY fielder_id;