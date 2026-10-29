-- Фізична схема реляційної БД ПП IdiomLens
-- СУБД: MySQL 9.7 LTS
-- Отримана з логічної схеми (2.3-LogicalModel/RelLogicalSchema.puml)

CREATE TABLE cards (
    card_id INTEGER NOT NULL AUTO_INCREMENT,
    illustration_path VARCHAR(255) NOT NULL,
    CONSTRAINT cards_pk PRIMARY KEY (card_id)
);

CREATE TABLE idioms (
    idiom_id INTEGER NOT NULL AUTO_INCREMENT,
    idiom_name VARCHAR(100) NOT NULL,
    meaning VARCHAR(500) NOT NULL,
    CONSTRAINT idioms_pk PRIMARY KEY (idiom_id),
    CONSTRAINT idioms_name_uq UNIQUE (idiom_name),
    -- Регулярний вираз 1: назва ідіоми – лише латинські літери, пробіл,
    -- апостроф, дефіс та кома; починається з літери
    CONSTRAINT idioms_name_chk CHECK (
        REGEXP_LIKE(idiom_name, '^[A-Za-z][A-Za-z '',-]*$', 'c')
    )
);

CREATE TABLE markers (
    marker_id INTEGER NOT NULL AUTO_INCREMENT,
    image_path VARCHAR(255) NOT NULL,
    card_id INTEGER,
    idiom_id INTEGER NOT NULL,
    CONSTRAINT markers_pk PRIMARY KEY (marker_id),
    CONSTRAINT markers_image_uq UNIQUE (image_path),
    CONSTRAINT markers_card_uq UNIQUE (card_id),
    CONSTRAINT markers_idiom_uq UNIQUE (idiom_id),
    CONSTRAINT markers_card_fk FOREIGN KEY (card_id)
    REFERENCES cards (card_id) ON DELETE SET NULL,
    CONSTRAINT markers_idiom_fk FOREIGN KEY (idiom_id)
    REFERENCES idioms (idiom_id) ON DELETE CASCADE
);

CREATE TABLE pronunciations (
    pronunciation_id INTEGER NOT NULL AUTO_INCREMENT,
    audio_path VARCHAR(255) NOT NULL,
    speaker_name VARCHAR(100) NOT NULL,
    idiom_id INTEGER NOT NULL,
    CONSTRAINT pronunciations_pk PRIMARY KEY (pronunciation_id),
    CONSTRAINT pronunciations_idiom_uq UNIQUE (idiom_id),
    CONSTRAINT pronunciations_idiom_fk FOREIGN KEY (idiom_id)
    REFERENCES idioms (idiom_id) ON DELETE CASCADE,
    -- Регулярний вираз 2: шлях до аудіозапису – малі латинські літери,
    -- цифри, «_», «-», «/» та розширення «.mp3»
    CONSTRAINT pronunciations_audio_chk CHECK (
        REGEXP_LIKE(audio_path, '^[a-z0-9_/-]+\\.mp3$', 'c')
    )
);

CREATE TABLE media_fragments (
    fragment_id INTEGER NOT NULL AUTO_INCREMENT,
    video_url VARCHAR(500) NOT NULL,
    duration_num SMALLINT NOT NULL,
    quote_text VARCHAR(500) NOT NULL,
    source_name VARCHAR(200) NOT NULL,
    source_type VARCHAR(20) NOT NULL,
    idiom_id INTEGER NOT NULL,
    CONSTRAINT media_fragments_pk PRIMARY KEY (fragment_id),
    CONSTRAINT media_fragments_idiom_fk FOREIGN KEY (idiom_id)
    REFERENCES idioms (idiom_id) ON DELETE CASCADE,
    -- Регулярний вираз 3: URL-посилання на зовнішньому сервісі
    -- медіаконтенту починається з «https://» і не містить пробілів
    CONSTRAINT media_fragments_url_chk CHECK (
        REGEXP_LIKE(video_url, '^https://[^ ]+$', 'c')
    ),
    CONSTRAINT media_fragments_duration_chk CHECK (
        duration_num BETWEEN 1 AND 30
    ),
    CONSTRAINT media_fragments_type_chk CHECK (
        source_type IN ('film', 'series', 'news')
    )
);

CREATE TABLE explanations (
    explanation_id INTEGER NOT NULL AUTO_INCREMENT,
    situation_text VARCHAR(1000) NOT NULL,
    interpretation VARCHAR(500) NOT NULL,
    fragment_id INTEGER NOT NULL,
    CONSTRAINT explanations_pk PRIMARY KEY (explanation_id),
    CONSTRAINT explanations_fragment_uq UNIQUE (fragment_id),
    CONSTRAINT explanations_fragment_fk FOREIGN KEY (fragment_id)
    REFERENCES media_fragments (fragment_id) ON DELETE CASCADE
);
