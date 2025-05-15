
CREATE TABLE season (
    season_id VARCHAR(20) PRIMARY KEY,
    year SMALLINT NOT NULL CHECK (year BETWEEN 1900 AND 2025),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL
);

CREATE TABLE team (
    team_id VARCHAR(20) PRIMARY KEY,
    team_name VARCHAR(255) NOT NULL UNIQUE,
    coach_name VARCHAR(255) NOT NULL,
    region VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE player (
    player_id VARCHAR(20) PRIMARY KEY,
    player_name VARCHAR(255) NOT NULL,
    dob DATE NOT NULL CHECK (dob < '2016-01-01'),
    batting_hand VARCHAR(20) NOT NULL CHECK (batting_hand IN ('left', 'right')),
    bowling_skill VARCHAR(20) CHECK (bowling_skill IN ('fast', 'medium', 'legspin', 'offspin')),
    country_name VARCHAR(20) NOT NULL
);

CREATE TABLE player_team (
    player_id VARCHAR(20) NOT NULL,
    team_id VARCHAR(20) NOT NULL,
    season_id VARCHAR(20) NOT NULL,
    PRIMARY KEY (player_id, team_id, season_id),
    FOREIGN KEY (player_id) REFERENCES player(player_id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES team(team_id) ON DELETE CASCADE,
    FOREIGN KEY (season_id) REFERENCES season(season_id) ON DELETE CASCADE
);

CREATE TABLE match (
    match_id VARCHAR(30) PRIMARY KEY,
    match_type VARCHAR(20) NOT NULL CHECK (match_type IN ('league', 'playoff', 'knockout')),
    venue VARCHAR(20) NOT NULL,
    team_1_id VARCHAR(20) NOT NULL,
    team_2_id VARCHAR(20) NOT NULL,
    match_date DATE NOT NULL,
    season_id VARCHAR(20) NOT NULL,
    win_run_margin SMALLINT,
    win_by_wickets SMALLINT,
    win_type VARCHAR(20) CHECK (win_type IN ('runs', 'wickets', 'draw')),
    toss_winner SMALLINT CHECK (toss_winner IN (1, 2)),
    toss_decide VARCHAR(20) CHECK (toss_decide IN ('bowl', 'bat')),
    winner_team_id VARCHAR(20),
    FOREIGN KEY (team_1_id) REFERENCES team(team_id) ON DELETE CASCADE,
    FOREIGN KEY (team_2_id) REFERENCES team(team_id) ON DELETE CASCADE,
    FOREIGN KEY (season_id) REFERENCES season(season_id) ON DELETE CASCADE,
    FOREIGN KEY (winner_team_id) REFERENCES team(team_id)
);

CREATE TABLE player_match (
    player_id VARCHAR(20) NOT NULL,
    match_id VARCHAR(20) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('batter', 'bowler', 'allrounder', 'wicketkeeper')),
    team_id VARCHAR(20) NOT NULL,
    is_extra BOOLEAN NOT NULL,
    PRIMARY KEY (player_id, match_id),
    FOREIGN KEY (player_id) REFERENCES player(player_id) ON DELETE CASCADE,
    FOREIGN KEY (match_id) REFERENCES match(match_id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES team(team_id) ON DELETE CASCADE
);

ALTER TABLE match 
ADD CONSTRAINT chk_draw_result CHECK (
    (win_type = 'draw' AND win_run_margin IS NULL AND win_by_wickets IS NULL) OR
    (win_type <> 'draw' AND (
        (win_type = 'runs' AND win_by_wickets IS NULL AND win_run_margin IS NOT NULL) OR
        (win_type = 'wickets' AND win_run_margin IS NULL AND win_by_wickets IS NOT NULL)
    ))
);

CREATE TABLE auction (
    auction_id VARCHAR(20) PRIMARY KEY,
    season_id VARCHAR(20) NOT NULL,
    player_id VARCHAR(20) NOT NULL,
    base_price BIGINT NOT NULL CHECK (base_price >= 1000000),
    sold_price BIGINT CHECK (sold_price IS NULL OR sold_price >= base_price),
    is_sold BOOLEAN NOT NULL,
    team_id VARCHAR(20),
    FOREIGN KEY (season_id) REFERENCES season(season_id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES player(player_id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES team(team_id),
    UNIQUE (player_id, team_id, season_id),
    CONSTRAINT sold_check CHECK (
        (is_sold = TRUE AND sold_price IS NOT NULL AND team_id IS NOT NULL AND sold_price >= base_price) OR 
        (is_sold = FALSE AND sold_price IS NULL AND team_id IS NULL)
    )
);

ALTER TABLE auction
ADD CONSTRAINT chk_sold_price CHECK (
    (is_sold = TRUE AND sold_price IS NOT NULL AND team_id IS NOT NULL AND sold_price >= base_price) OR
    (is_sold = FALSE)
);
ALTER TABLE player_team
ADD CONSTRAINT fk_player_auction
FOREIGN KEY (player_id, team_id, season_id)
REFERENCES auction(player_id, team_id, season_id)
ON DELETE CASCADE;


CREATE TABLE awards (
    match_id VARCHAR(20),
    award_type VARCHAR(20) NOT NULL CHECK (award_type IN ('orange_cap', 'purple_cap')),
    player_id VARCHAR(20) NOT NULL,
    PRIMARY KEY (match_id, award_type),
    FOREIGN KEY (match_id) REFERENCES match(match_id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES player(player_id) ON DELETE CASCADE                                                                     
);


CREATE TABLE balls (
    match_id VARCHAR(20) NOT NULL,
    innings_num SMALLINT NOT NULL,
    over_num SMALLINT NOT NULL,
    ball_num SMALLINT NOT NULL,
    striker_id VARCHAR(20) NOT NULL,
    non_striker_id VARCHAR(20) NOT NULL,
    bowler_id VARCHAR(20) NOT NULL,
    PRIMARY KEY (match_id, innings_num, over_num, ball_num),
    FOREIGN KEY (match_id) REFERENCES match(match_id) ON DELETE CASCADE,
    FOREIGN KEY (striker_id) REFERENCES player(player_id) ON DELETE CASCADE,
    FOREIGN KEY (non_striker_id) REFERENCES player(player_id) ON DELETE CASCADE,
    FOREIGN KEY (bowler_id) REFERENCES player(player_id) ON DELETE CASCADE
);

CREATE TABLE batter_score (
    match_id VARCHAR(20) NOT NULL,
    over_num SMALLINT NOT NULL,
    innings_num SMALLINT NOT NULL,
    ball_num SMALLINT NOT NULL,
    run_scored SMALLINT NOT NULL CHECK(run_scored>=0),
    type_run VARCHAR(20) CHECK (type_run IN ('running', 'boundary')),
    PRIMARY KEY (match_id, innings_num, over_num, ball_num),
    FOREIGN KEY (match_id, innings_num, over_num, ball_num) REFERENCES balls(match_id, innings_num, over_num, ball_num) ON DELETE CASCADE
);

CREATE TABLE wickets (
    match_id VARCHAR(20) NOT NULL,
    innings_num SMALLINT NOT NULL,
    over_num SMALLINT NOT NULL,
    ball_num SMALLINT NOT NULL,
    player_out_id VARCHAR(20) NOT NULL,
    kind_out VARCHAR(20) NOT NULL CHECK(kind_out IN ('bowled', 'caught', 'lbw', 'runout', 'stumped', 'hitwicket')),
    fielder_id VARCHAR(20),
    PRIMARY KEY (match_id, innings_num, over_num, ball_num),
    FOREIGN KEY (match_id, innings_num, over_num, ball_num) REFERENCES balls(match_id, innings_num, over_num, ball_num) ON DELETE CASCADE,
    FOREIGN KEY (player_out_id) REFERENCES player(player_id) ON DELETE CASCADE,
    FOREIGN KEY (fielder_id) REFERENCES player(player_id) ON DELETE CASCADE
);

ALTER TABLE wickets
ADD CONSTRAINT chk_fielder_not_null CHECK (
    (kind_out IN ('caught', 'runout', 'stumped') AND fielder_id IS NOT NULL) OR
    (kind_out NOT IN ('caught', 'runout', 'stumped'))
);

CREATE OR REPLACE FUNCTION check_stumped_wicketkeeper()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.kind_out = 'stumped' THEN
        IF NOT EXISTS (
            SELECT 1 FROM player_match
            WHERE player_id = NEW.fielder_id 
              AND match_id = NEW.match_id
              AND role = 'wicketkeeper'
        ) THEN
            RAISE EXCEPTION 'for stumped dismissal, fielder must be a wicketkeeper';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_stumped_wicketkeeper
BEFORE INSERT OR UPDATE ON wickets
FOR EACH ROW EXECUTE FUNCTION check_stumped_wicketkeeper();



CREATE TABLE extras (
    match_id VARCHAR(20),
    innings_num SMALLINT NOT NULL,
    over_num SMALLINT NOT NULL,
    ball_num SMALLINT NOT NULL,
    extra_runs SMALLINT NOT NULL CHECK(extra_runs >=0),
    extra_type VARCHAR(20) NOT NULL CHECK(extra_type IN ('no_ball', 'wide, byes', 'legbyes')),
    PRIMARY KEY (match_id, innings_num, over_num, ball_num),
    FOREIGN KEY (match_id, innings_num, over_num, ball_num) REFERENCES balls(match_id, innings_num, over_num, ball_num) ON DELETE CASCADE
);


-- 
CREATE OR REPLACE FUNCTION insert_player_team()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_sold = TRUE THEN
        INSERT INTO player_team (player_id, team_id, season_id)
        VALUES (NEW.player_id, NEW.team_id, NEW.season_id);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_auction_insert
AFTER INSERT ON auction
FOR EACH ROW
EXECUTE FUNCTION insert_player_team();


CREATE OR REPLACE FUNCTION generate_season_id()
RETURNS TRIGGER AS $$
BEGIN
    NEW.season_id := 'IPL' || NEW.year;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER season_id_trigger
BEFORE INSERT ON season
FOR EACH ROW
EXECUTE FUNCTION generate_season_id();


CREATE OR REPLACE FUNCTION validate_match_id()
RETURNS TRIGGER AS $$
DECLARE
    expected_match_id VARCHAR(30);
    match_count INT;
BEGIN

    SELECT COUNT(*) + 1 INTO match_count FROM match WHERE season_id = NEW.season_id;

    expected_match_id := NEW.season_id || LPAD(match_count::TEXT, 3, '0');

    IF NEW.match_id <> expected_match_id THEN
        RAISE EXCEPTION 'Invalid match_id format. Expected: %', expected_match_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_match_id
BEFORE INSERT ON match
FOR EACH ROW
EXECUTE FUNCTION validate_match_id();


CREATE OR REPLACE FUNCTION enforce_international_limit()
RETURNS TRIGGER AS $$
DECLARE
    international_count INT;
    player_country TEXT;
BEGIN

    SELECT country_name INTO player_country FROM player WHERE player_id = NEW.player_id;

    IF player_country <> 'India' THEN
        SELECT COUNT(*) INTO international_count
        FROM player_team pt
        JOIN player p ON pt.player_id = p.player_id
        WHERE pt.team_id = NEW.team_id
          AND pt.season_id = NEW.season_id
          AND p.country_name <> 'India';

        IF international_count >= 3 THEN
            RAISE EXCEPTION 'there could be at most 3 international players per team per season';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_international_limit
BEFORE INSERT OR UPDATE ON player_team
FOR EACH ROW
EXECUTE FUNCTION enforce_international_limit();




CREATE OR REPLACE FUNCTION check_home_venue()
RETURNS TRIGGER AS $$
DECLARE
    team1_region VARCHAR(255);
    team2_region VARCHAR(255);
    home_matches_count INT;
BEGIN

    SELECT region INTO team1_region FROM team WHERE team_id = NEW.team_1_id;
    SELECT region INTO team2_region FROM team WHERE team_id = NEW.team_2_id;

    IF NEW.match_type = 'league' AND NEW.venue NOT IN (team1_region, team2_region) THEN
        RAISE EXCEPTION 'league match must be played at home ground of one of the teams';
    END IF;

    IF NEW.match_type = 'league' THEN

        SELECT COUNT(*) INTO home_matches_count 
        FROM match 
        WHERE season_id = NEW.season_id
          AND match_type = 'league'
          AND team_1_id = NEW.team_1_id
          AND venue = team1_region;

        IF home_matches_count >= 1 THEN
            RAISE EXCEPTION 'each team can play only one home match in a league against another team';
        END IF;

        SELECT COUNT(*) INTO home_matches_count 
        FROM match 
        WHERE season_id = NEW.season_id
          AND match_type = 'league'
          AND team_2_id = NEW.team_2_id
          AND venue = team2_region;

        IF home_matches_count >= 1 THEN
            RAISE EXCEPTION 'each team can play only one home match in a league against another team';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_home_match_rules
BEFORE INSERT OR UPDATE ON match
FOR EACH ROW
EXECUTE FUNCTION check_home_venue();


CREATE OR REPLACE FUNCTION update_match_winner_and_awards()
RETURNS TRIGGER AS $$
DECLARE
    orange_cap_player INT;
    purple_cap_player INT;
BEGIN

    IF NEW.win_type IS NULL OR NEW.win_type = 'draw' THEN
        NEW.winner_team_id := NULL;
    ELSIF NEW.win_type = 'runs' THEN
        NEW.winner_team_id := (SELECT batting_team FROM balls
                               WHERE match_id = NEW.match_id
                               GROUP BY batting_team
                               ORDER BY SUM(runs) DESC LIMIT 1);
    ELSIF NEW.win_type = 'wickets' THEN
        NEW.winner_team_id := (SELECT bowling_team FROM balls
                               WHERE match_id = NEW.match_id
                               GROUP BY bowling_team
                               ORDER BY SUM(CASE WHEN kind_out IS NOT NULL THEN 1 ELSE 0 END) DESC
                               LIMIT 1);
    END IF;

    SELECT player_id INTO orange_cap_player
    FROM balls
    WHERE match_id = NEW.match_id
    GROUP BY player_id
    ORDER BY SUM(runs) DESC, player_id ASC
    LIMIT 1;

    SELECT player_id INTO purple_cap_player
    FROM balls
    WHERE match_id = NEW.match_id AND kind_out IS NOT NULL
    GROUP BY player_id
    ORDER BY COUNT(kind_out) DESC, player_id ASC
    LIMIT 1;

    INSERT INTO awards (match_id, player_id, award_type)
    VALUES (NEW.match_id, orange_cap_player, 'orange_cap'),
           (NEW.match_id, purple_cap_player, 'purple_cap');

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_match_winner_and_awards
BEFORE UPDATE ON match
FOR EACH ROW
WHEN (OLD.win_type IS NULL AND NEW.win_type IS NOT NULL)
EXECUTE FUNCTION update_match_winner_and_awards();


CREATE OR REPLACE FUNCTION cascade_delete_on_auction()
RETURNS TRIGGER AS $$
BEGIN

    DELETE FROM player_team
    WHERE player_id = OLD.player_id AND season = OLD.season;

    DELETE FROM awards
    WHERE player_id = OLD.player_id
    AND match_id IN (SELECT match_id FROM match WHERE season = OLD.season);

    DELETE FROM player_match
    WHERE player_id = OLD.player_id
    AND match_id IN (SELECT match_id FROM match WHERE season = OLD.season);

    DELETE FROM balls
    WHERE player_id = OLD.player_id
    AND match_id IN (SELECT match_id FROM match WHERE season = OLD.season);

    DELETE FROM batter_score
    WHERE player_id = OLD.player_id
    AND match_id IN (SELECT match_id FROM match WHERE season = OLD.season);

    DELETE FROM extras
    WHERE player_id = OLD.player_id
    AND match_id IN (SELECT match_id FROM match WHERE season = OLD.season);

    DELETE FROM wickets
    WHERE player_id = OLD.player_id
    AND match_id IN (SELECT match_id FROM match WHERE season = OLD.season);

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_cascade_delete_on_auction
AFTER DELETE ON auction
FOR EACH ROW
WHEN (OLD.is_sold = TRUE)
EXECUTE FUNCTION cascade_delete_on_auction();


CREATE OR REPLACE FUNCTION cascade_delete_on_match()
RETURNS TRIGGER AS $$
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

CREATE TRIGGER trg_cascade_delete_on_match
AFTER DELETE ON match
FOR EACH ROW
EXECUTE FUNCTION cascade_delete_on_match();




CREATE OR REPLACE FUNCTION cascade_delete_on_season()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM auction WHERE season_id = OLD.season_id;
    DELETE FROM awards WHERE season_id = OLD.season_id;
    DELETE FROM match WHERE season_id = OLD.season_id;
    DELETE FROM player_team WHERE season_id = OLD.season_id;
    DELETE FROM player_match WHERE match_id IN (SELECT match_id FROM match WHERE season_id = OLD.season_id);
    DELETE FROM balls WHERE match_id IN (SELECT match_id FROM match WHERE season_id = OLD.season_id);
    DELETE FROM batter_score WHERE match_id IN (SELECT match_id FROM match WHERE season_id = OLD.season_id);
    DELETE FROM extras WHERE match_id IN (SELECT match_id FROM match WHERE season_id = OLD.season_id);
    DELETE FROM wickets WHERE match_id IN (SELECT match_id FROM match WHERE season_id = OLD.season_id);

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trg_cascade_delete_on_season
AFTER DELETE ON season
FOR EACH ROW
EXECUTE FUNCTION cascade_delete_on_season();


CREATE VIEW batter_stats AS
SELECT 
    pm.player_id,
    COUNT(DISTINCT pm.match_id) AS Mat,
    COUNT(DISTINCT bs.innings_num) AS Inns,
    COALESCE(SUM(bs.run_scored), 0) AS R,
    COALESCE(MAX(bs.run_scored), 0) AS HS,
    CASE 
        WHEN COUNT(wk.player_out_id) = 0 THEN NULL
        ELSE ROUND(SUM(bs.run_scored) * 1.0 / COUNT(wk.player_out_id), 2) 
    END AS Avg,
    CASE 
        WHEN COUNT(DISTINCT (bl.match_id, bl.innings_num, bl.over_num, bl.ball_num)) = 0 THEN NULL
        ELSE ROUND(SUM(bs.run_scored) * 100.0 / 
            COUNT(DISTINCT (bl.match_id, bl.innings_num, bl.over_num, bl.ball_num)), 2)
    END AS SR,
    SUM(CASE WHEN bs.run_scored >= 100 THEN 1 ELSE 0 END) AS "100s",
    SUM(CASE WHEN bs.run_scored BETWEEN 50 AND 99 THEN 1 ELSE 0 END) AS "50s",
    SUM(CASE WHEN bs.run_scored = 0 AND wk.player_out_id IS NOT NULL THEN 1 ELSE 0 END) AS Ducks,
    COUNT(DISTINCT (bl.match_id, bl.innings_num, bl.over_num, bl.ball_num)) AS BF,
    SUM(CASE WHEN bs.run_scored IN (4, 6) THEN 1 ELSE 0 END) AS Boundaries,
    COUNT(CASE WHEN wk.player_out_id IS NULL THEN 1 END) AS NO
FROM player_match pm
LEFT JOIN batter_score bs ON pm.match_id = bs.match_id
LEFT JOIN wickets wk ON pm.player_id = wk.player_out_id
LEFT JOIN balls bl ON bs.match_id = bl.match_id 
    AND bs.innings_num = bl.innings_num 
    AND bs.over_num = bl.over_num 
    AND bs.ball_num = bl.ball_num
LEFT JOIN extras e ON bl.match_id = e.match_id 
    AND bl.innings_num = e.innings_num 
    AND bl.over_num = e.over_num 
    AND bl.ball_num = e.ball_num
WHERE e.match_id IS NULL
GROUP BY pm.player_id;


CREATE VIEW bowler_stats AS
SELECT 
    b.bowler_id AS player_id,
    COUNT(*) AS B,
    COALESCE(SUM(CASE WHEN w.kind_out IN ('bowled', 'caught', 'lbw', 'stumped') THEN 1 ELSE 0 END), 0) AS W,
    COALESCE(SUM(r.run_scored) + SUM(e.extra_runs), 0) AS Runs,
    CASE 
        WHEN COALESCE(SUM(CASE WHEN w.kind_out IN ('bowled', 'caught', 'lbw', 'stumped') THEN 1 ELSE 0 END), 0) = 0 
        THEN 0 
        ELSE (COALESCE(SUM(r.run_scored) + SUM(e.extra_runs), 0) * 1.0 / COALESCE(SUM(CASE WHEN w.kind_out IN ('bowled', 'caught', 'lbw', 'stumped') THEN 1 ELSE 0 END), 1)) 
    END AS Avg,
    CASE 
        WHEN COUNT(DISTINCT b.over_num) = 0 
        THEN 0 
        ELSE (COALESCE(SUM(r.run_scored) + SUM(e.extra_runs), 0) * 1.0 / COUNT(DISTINCT b.over_num)) 
    END AS Econ,
    CASE 
        WHEN COALESCE(SUM(CASE WHEN w.kind_out IN ('bowled', 'caught', 'lbw', 'stumped') THEN 1 ELSE 0 END), 0) = 0 
        THEN 0 
        ELSE (COUNT(*) * 1.0 / COALESCE(SUM(CASE WHEN w.kind_out IN ('bowled', 'caught', 'lbw', 'stumped') THEN 1 ELSE 0 END), 1)) 
    END AS SR,
    COALESCE(SUM(e.extra_runs), 0) AS Extras
FROM balls b
LEFT JOIN batter_score r ON 
    b.match_id = r.match_id 
    AND b.innings_num = r.innings_num 
    AND b.over_num = r.over_num 
    AND b.ball_num = r.ball_num
LEFT JOIN extras e ON 
    b.match_id = e.match_id 
    AND b.innings_num = e.innings_num 
    AND b.over_num = e.over_num 
    AND b.ball_num = e.ball_num
LEFT JOIN wickets w ON 
    b.match_id = w.match_id 
    AND b.innings_num = w.innings_num 
    AND b.over_num = w.over_num 
    AND b.ball_num = w.ball_num 
GROUP BY b.bowler_id;


CREATE VIEW fielder_stats AS
SELECT 
    w.fielder_id as player_id,
    COUNT(CASE WHEN w.kind_out = 'caught' THEN 1 END) as C,
    COUNT(CASE WHEN w.kind_out = 'stumped' THEN 1 END) AS St,
    COUNT(CASE WHEN w.kind_out = 'run out' THEN 1 END) AS RO
FROM wickets w
WHERE w.fielder_id IS NOT NULL
GROUP BY w.fielder_id;