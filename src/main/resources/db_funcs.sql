---
---
CREATE OR REPLACE FUNCTION random_timestamptz(
    min_date TIMESTAMP WITH TIME ZONE DEFAULT '2000-01-01 00:00:00+00',
    max_date TIMESTAMP WITH TIME ZONE DEFAULT now()
)
    RETURNS TIMESTAMP WITH TIME ZONE AS
$$
DECLARE
    random_interval INTERVAL := (max_date - min_date);
    random_seconds  FLOAT    := random() * EXTRACT(EPOCH FROM random_interval);
BEGIN
    RETURN min_date + random_seconds * INTERVAL '1 second';
END;
$$ LANGUAGE plpgsql;

--
-- EXAMPLE
-- SELECT random_boolean(0.7); -- Returns true with 70% probability
----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION random_boolean(weight_true FLOAT DEFAULT 0.5)
    RETURNS BOOLEAN AS
$$
BEGIN
    RETURN random() < weight_true;
END;
$$ LANGUAGE plpgsql;



---
CREATE OR REPLACE FUNCTION random_string(
    max_length INT DEFAULT 20,
    min_length INT DEFAULT 10,
    language_code TEXT DEFAULT 'en'
)
    RETURNS TEXT AS
$$
DECLARE
    random_length    INT;
    random_string    TEXT;
    random_codepoint INT;
BEGIN
    random_string := '';
    random_length := min_length + floor(random() * (max_length - min_length + 1));

    FOR i IN 1..random_length
        LOOP
            -- Generate a random codepoint within the range of the specified language
            random_codepoint := (SELECT floor(random() * (max - min + 1)) + min
                                 FROM (VALUES ('en', 32,
                                               126), -- English: ASCII printable characters range from 32 to 126
                                              ('es', 161,
                                               255), -- Spanish: Latin-1 Supplement characters range from 161 to 255
                                              ('fr', 192,
                                               255), -- French: Latin-1 Supplement characters range from 192 to 255
                                              ('de', 196,
                                               252), -- German: Latin-1 Supplement characters range from 196 to 252
                                              ('ko', 44032, 55203) -- Korean: Hangul Syllables range from 44032 to 55203
                                          -- TODO: add more
                                      ) AS range_table(language, min, max)
                                 WHERE range_table.language = language_code);

            -- Append the character corresponding to the random codepoint
            random_string := random_string || CHR(random_codepoint);
        END LOOP;

    RETURN random_string;
END;
$$ LANGUAGE plpgsql;
---

---
-- EXAMPLES
--
-- select * from random_string(40);
-- select * from random_string(language_code => 'fr');
---
CREATE OR REPLACE FUNCTION random_string(max_length INT DEFAULT 20, min_length INT DEFAULT 10,
                                         locale_code TEXT DEFAULT 'en')
    RETURNS TEXT AS
$$
DECLARE
    random_length    INT;
    random_string    TEXT;
    codepoint_range  INT[];
    random_codepoint INT;
BEGIN
    -- Lookup the language-specific codepoint range (see https://www.unicode.org/charts/index.html)
    -- ranges for many languages are not simple, this is a just intended to get close...
    -- https://character-table.netlify.app/
    SELECT CASE locale_code
               WHEN 'ar' THEN ARRAY [x'0600'::INT, x'06FF'::INT] -- Arabic: Arabic script characters
               WHEN 'bn' THEN ARRAY [x'0980'::INT, x'09FF'::INT] -- Bengali: Bengali script characters
               WHEN 'en' THEN ARRAY [x'0020'::INT, x'007E'::INT] -- English: ASCII printable characters
               WHEN 'hi' THEN ARRAY [x'0900'::INT, x'097F'::INT] -- Hindi: Devanagari characters
               WHEN 'ja' THEN ARRAY [x'3041'::INT, x'3096'::INT] -- Japanese: Hiragana characters
               WHEN 'jv' THEN ARRAY [x'A980'::INT, x'A9DF'::INT] -- Javanese: Javanese script characters
               WHEN 'ko' THEN ARRAY [x'AC00'::INT, x'D7A3'::INT] -- Korean: Hangul Syllables
               WHEN 'ru' THEN ARRAY [x'0410'::INT, x'04FF'::INT] -- Russian: Cyrillic characters
               WHEN 'zh' THEN ARRAY [x'4E00'::INT, x'9FFF'::INT] -- Chinese: CJK Unified Ideographs
               ELSE ARRAY [x'2700'::INT, x'27BF'::INT] -- Dingbats
               END
    INTO codepoint_range;

    random_string := '';
    random_length := min_length + floor(random() * (max_length - min_length + 1));

    FOR i IN 1..random_length
        LOOP
            -- Generate a random codepoint within the range of the specified language and append it
            random_codepoint := codepoint_range[1] + floor(random() * (codepoint_range[2] - codepoint_range[1] + 1));
            random_string := random_string || CHR(random_codepoint);
        END LOOP;

    RETURN random_string;
END;
$$ LANGUAGE plpgsql;


DO
$$
    DECLARE
        chunk_size INT := 250;
        total_rows INT := 1000000;
        i          INT := 1;
    BEGIN
        WHILE i <= total_rows
            LOOP
                INSERT INTO yb_user(email, display_name, region, password_hash, avatar_url, full_name)
                SELECT 'foo' || seq || '@bar.com', 'Foo ' || seq, 'USA', '***', '', ''
                from generate_series(i, i + chunk_size - 1) as seq;
                i := i + chunk_size;
                RAISE NOTICE 'Inserted % out of % rows', i, total_rows;
                COMMIT;
            END LOOP;
    END
$$;