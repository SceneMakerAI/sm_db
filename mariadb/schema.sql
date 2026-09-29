/*M!999999\- enable the sandbox mode */ 

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;
DROP TABLE IF EXISTS `t_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_category` (
  `cate_id` smallint(5) unsigned NOT NULL,
  `cate_name` varchar(45) DEFAULT NULL COMMENT '카테고리이름',
  `p_cate_id` smallint(5) DEFAULT NULL COMMENT '상위카테고리',
  PRIMARY KEY (`cate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_chapter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_chapter` (
  `v_id` mediumint(8) unsigned NOT NULL COMMENT 'FK t_video',
  `chap_id` smallint(5) unsigned NOT NULL COMMENT '영상 내 챕터 일련번호',
  `level` tinyint(4) NOT NULL COMMENT '1=sub(10분/막), 2=scene(씬)',
  `parent_chap_id` smallint(5) unsigned DEFAULT NULL COMMENT 'scene→소속 sub의 chap_id (sub은 NULL)',
  `start_time` time NOT NULL COMMENT '00:00:00',
  `end_time` time NOT NULL COMMENT '00:10:00',
  `start_seg` smallint(5) unsigned DEFAULT NULL COMMENT '구성 세그먼트 시작 seg_id',
  `end_seg` smallint(5) unsigned DEFAULT NULL COMMENT '구성 세그먼트 끝 seg_id',
  `title` varchar(100) DEFAULT NULL COMMENT '짧은 라벨 (예: 수양대군 등장)',
  `summary` text DEFAULT NULL COMMENT '줄거리 본문 (임베딩 대상)',
  `cast` varchar(500) DEFAULT NULL COMMENT '하위 cast 집계 (인물별 검색)-화면에 등장하는 인물',
  `keywords` varchar(500) DEFAULT NULL COMMENT '검색/필터용 키워드',
  `emotion` varchar(50) DEFAULT NULL COMMENT '감성 몽타주/광고 매칭용',
  `meta` longtext DEFAULT NULL COMMENT '확장 여지(JSON)',
  `status_code` smallint(6) NOT NULL DEFAULT 2001 COMMENT '처리 상태',
  `status_reason` varchar(100) NOT NULL DEFAULT 'OK' COMMENT '상태 사유',
  `reg_datetime` datetime NOT NULL DEFAULT current_timestamp() COMMENT '최초 입력시간',
  `upd_datetime` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT '업데이트 시간',
  PRIMARY KEY (`v_id`,`chap_id`) USING BTREE,
  CONSTRAINT `fk_t_chapter_t_video1` FOREIGN KEY (`v_id`) REFERENCES `t_video` (`v_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_code`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_code` (
  `code` smallint(6) NOT NULL,
  `object` varchar(30) NOT NULL DEFAULT 'ALL' COMMENT '사용하는 테이블 (ALL: 전체-2개 이상 테이블일 경우)\n',
  `result` tinyint(1) DEFAULT 0 COMMENT '-1: 에러, 0: 처리 완료, 1:진행 중',
  `name` varchar(100) NOT NULL,
  `description` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`code`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_compose`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_compose` (
  `v_id` mediumint(8) unsigned NOT NULL COMMENT 't_video.v_id',
  `comp_id` smallint(5) unsigned NOT NULL COMMENT '편성 id — v_id 안에서 1부터',
  `search_id` varchar(32) DEFAULT NULL COMMENT '접수 식별자 {요청일}-{v_id}-{comp_id} — 응답으로 돌려준다',
  `stream_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '편성 범위 청크(t_video_file.stream_id) — NULL 이면 영상 전체',
  `query` varchar(200) NOT NULL COMMENT '사용자 질의 원문',
  `budget_sec` smallint(5) unsigned DEFAULT NULL COMMENT '요청 목표 분량(초) — NULL=미지정(절단 없음)',
  `status_code` smallint(6) NOT NULL COMMENT 't_code 4000번대 — 4020~4040 편성 진행 / 4050 렌더 진행 / 4000 완료 / 4001 빈 편성 / 4900 편성 실패 / 4950 렌더 실패',
  `duration_sec` smallint(5) unsigned NOT NULL DEFAULT 0 COMMENT '최종 클립 길이 합(초)',
  `clip_cnt` smallint(5) unsigned NOT NULL DEFAULT 0 COMMENT '최종 클립 수',
  `bumper_yn` char(1) NOT NULL DEFAULT 'Y' COMMENT '렌더 시 이닝 그룹 사이 범퍼 삽입 여부',
  `callback_url` varchar(200) DEFAULT NULL COMMENT '편성 완료를 통보할 URL — 요청이 준 값. 미지정이면 통보하지 않는다',
  `reg_datetime` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`v_id`,`comp_id`),
  KEY `fk_t_compose_t_code` (`status_code`),
  CONSTRAINT `fk_t_compose_t_code` FOREIGN KEY (`status_code`) REFERENCES `t_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='질의 기반 편성 헤더 (agent-compose)';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_compose_clip`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_compose_clip` (
  `v_id` mediumint(8) unsigned NOT NULL COMMENT 't_video.v_id',
  `comp_id` smallint(5) unsigned NOT NULL COMMENT 't_compose.comp_id (v_id 안 시퀀스)',
  `clip_seq` smallint(5) unsigned NOT NULL COMMENT '재생 순서 (시간순, 1부터)',
  `stream_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'VOD' COMMENT '스트림 청크 id — t_video_file.stream_id (VOD 는 ''VOD''). 상류와 콜레이션 일치(utf8mb4_bin)',
  `scene_stream_seq` smallint(5) unsigned NOT NULL COMMENT '구간 번호(청크 안) — (v_id, stream_id, 이 값)이 t_scene_baseball 정본 키',
  `scene_seq` smallint(5) unsigned NOT NULL COMMENT '구간 번호(전체 통산) — 표시·정렬용. 앞 청크 재처리로 낡을 수 있어 매칭에 쓰지 않는다',
  `merge_seqs` varchar(100) DEFAULT NULL COMMENT '병합으로 흡수한 구간 번호 콤마 — scene_stream_seq(청크 안 번호) 축, 시간순. 앞 구간은 scene_stream_seq 가 가리키므로 넣지 않는다. 병합 없으면 NULL',
  `start_stream_sec` int(10) unsigned NOT NULL COMMENT '클립 시작 초 — 청크 파일 기준 (pitch 앵커)',
  `end_stream_sec` int(10) unsigned NOT NULL COMMENT '클립 끝 초 — 청크 파일 기준',
  `start_sec` int(10) unsigned NOT NULL COMMENT '클립 시작 초 — 전체 영상 기준',
  `end_sec` int(10) unsigned NOT NULL COMMENT '클립 끝 초 — 전체 영상 기준',
  `tags` varchar(255) DEFAULT NULL COMMENT '전광판 사건 태그 콤마 (표시용 사본)',
  `labels` varchar(255) DEFAULT NULL COMMENT '구간 판정 라벨 콤마 (표시용 사본)',
  `inning` varchar(10) NOT NULL COMMENT '이닝 (1회초…) — 그룹핑 키',
  PRIMARY KEY (`v_id`,`comp_id`,`clip_seq`) USING BTREE,
  UNIQUE KEY `uk_compose_clip_scene` (`v_id`,`comp_id`,`stream_id`,`scene_stream_seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='편성 클립 (agent-compose) — 좌표 정수 초, 청크/전체 두 축';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_dialogue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_dialogue` (
  `v_id` mediumint(8) unsigned NOT NULL COMMENT 'FK t_video',
  `stream_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '' COMMENT '대화순서',
  `seq` smallint(5) unsigned NOT NULL,
  `start_stream_sec` smallint(5) unsigned NOT NULL,
  `end_stream_sec` smallint(5) unsigned NOT NULL,
  `start_stream_time` time(1) NOT NULL COMMENT '00:00:00.0',
  `end_stream_time` time(1) NOT NULL COMMENT '00:00:10.0',
  `speaker` char(12) NOT NULL COMMENT '발화자 (SPEAKER_0001)',
  `speaker_name` varchar(20) NOT NULL DEFAULT '' COMMENT '발화자 교정 (이름)',
  `lang` char(10) NOT NULL COMMENT '발화언어',
  `dialogue` varchar(1024) NOT NULL COMMENT '대사',
  `reg_datetime` datetime DEFAULT current_timestamp() COMMENT '최초 입력시간',
  PRIMARY KEY (`v_id`,`stream_id`,`seq`) USING BTREE,
  CONSTRAINT `fk_t_obj_t_video1` FOREIGN KEY (`v_id`) REFERENCES `t_video` (`v_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_dialogue_summary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_dialogue_summary` (
  `v_id` mediumint(8) unsigned NOT NULL COMMENT 'FK t_video',
  `stream_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '',
  `seq` smallint(5) unsigned NOT NULL COMMENT '구간 순번 (0부터)',
  `start_stream_sec` smallint(5) unsigned NOT NULL,
  `end_stream_sec` smallint(5) unsigned NOT NULL,
  `start_stream_time` time(1) NOT NULL COMMENT '구간 시작 00:00:00.0',
  `end_stream_time` time(1) NOT NULL COMMENT '구간 종료 (start + window_sec)',
  `window_sec` smallint(5) unsigned NOT NULL DEFAULT 60 COMMENT '구간 길이(초). 60=1분',
  `summary` varchar(1024) NOT NULL DEFAULT '' COMMENT '이 구간 대사 요약',
  `reg_datetime` datetime NOT NULL DEFAULT current_timestamp() COMMENT '최초 입력시간',
  PRIMARY KEY (`v_id`,`stream_id`,`seq`) USING BTREE,
  CONSTRAINT `fk_t_dialogue_summary_t_video` FOREIGN KEY (`v_id`) REFERENCES `t_video` (`v_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='STT 1분 구간 요약 (summary/summarizer 산출물)';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_frame_baseball`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_frame_baseball` (
  `v_id` mediumint(8) unsigned NOT NULL COMMENT 'FK t_video',
  `stream_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'vod',
  `idx_stream_sec` mediumint(8) unsigned NOT NULL COMMENT '청크 영상 내 시각(초)',
  `idx_stream_time` time(1) NOT NULL COMMENT '청크 영상 내 시각 00:00:00.0',
  `idx_sec` mediumint(8) unsigned NOT NULL COMMENT '전체 영상 내 시각(초)',
  `idx_time` time(1) NOT NULL COMMENT '전체 영상 내 시각 00:00:00.0',
  `normal` tinyint(4) NOT NULL COMMENT '0=normal(야구) / 1=adv(광고)',
  `pitch` tinyint(4) NOT NULL COMMENT '0=pitch / 1=none',
  `board_type` tinyint(4) NOT NULL COMMENT '{"NONE":0, "AsianGame_SBS": 1, "KBO_KBSN": 2, "KBO_MBC": 3, "KBO_SBS": 4, "KBO_SPOTV": 5, "AsianGame_SBS_2": 6}',
  `board_type_score` decimal(4,3) NOT NULL DEFAULT 0.000,
  `detect_major_obj` tinyint(4) NOT NULL COMMENT '0=none, 5=5개 detect 됨',
  `reg_datetime` datetime DEFAULT current_timestamp() COMMENT '최초 입력시간',
  PRIMARY KEY (`v_id`,`stream_id`,`idx_stream_sec`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='프레임 단위 광고/정상 분류 결과';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_frame_baseball_board`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_frame_baseball_board` (
  `v_id` mediumint(8) unsigned NOT NULL COMMENT 'FK t_video',
  `stream_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'vod',
  `idx_stream_sec` mediumint(8) unsigned NOT NULL COMMENT '전체 내 시각(초)',
  `idx_stream_time` time(1) NOT NULL COMMENT '청크 영상 내 시각 00:00:00.0',
  `idx_sec` mediumint(8) unsigned NOT NULL COMMENT '전체 내 시각(초)',
  `idx_time` time(1) NOT NULL COMMENT '전체 영상 내 시각 00:00:00.0',
  `board` tinyint(1) NOT NULL COMMENT '0=없음 / 1=스코어보드 있음',
  `score` decimal(4,3) NOT NULL DEFAULT 0.000 COMMENT '검출 확신도 0.000~1.000',
  `x` smallint(5) NOT NULL DEFAULT 0 COMMENT '박스 좌상단 x (원본 픽셀)',
  `y` smallint(5) NOT NULL DEFAULT 0 COMMENT '박스 좌상단 y (원본 픽셀)',
  `w` smallint(5) NOT NULL DEFAULT 0 COMMENT '박스 너비',
  `h` smallint(5) NOT NULL DEFAULT 0 COMMENT '박스 높이',
  `reg_datetime` datetime DEFAULT current_timestamp() COMMENT '최초 입력시간',
  PRIMARY KEY (`v_id`,`stream_id`,`idx_stream_sec`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='프레임 단위 스코어보드 검출 결과';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_frame_baseball_board_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_frame_baseball_board_detail` (
  `v_id` mediumint(8) unsigned NOT NULL COMMENT 'FK t_video',
  `stream_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'vod',
  `idx_stream_sec` mediumint(8) unsigned NOT NULL COMMENT '청크 영상 내 시각(초)',
  `kind` varchar(16) NOT NULL COMMENT '검출 항목 TEAM/INNING/COUNT/OUT/BASE/ETC/TURN',
  `idx_stream_time` time(1) NOT NULL COMMENT '청크 영상 내 시각 00:00:00.0',
  `idx_sec` mediumint(8) unsigned NOT NULL COMMENT '전체  영상 내 시각(초)',
  `idx_time` time(1) NOT NULL COMMENT '전체 영상 내 시각 00:00:00.0',
  `detect` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0=없음 / 1=검출됨',
  `score` decimal(4,3) NOT NULL DEFAULT 0.000 COMMENT '검출 확신도 0.000~1.000',
  `txt` varchar(128) NOT NULL DEFAULT '' COMMENT '읽은 값 — TEAM "기아 3: 삼성 2" / INNING "9회초" / COUNT "2-0" / OUT "1" / BASE "1루, 2루"',
  `x` smallint(5) NOT NULL DEFAULT 0 COMMENT '박스 좌상단 x (보드 crop 기준 픽셀)',
  `y` smallint(5) NOT NULL DEFAULT 0 COMMENT '박스 좌상단 y (보드 crop 기준 픽셀)',
  `w` smallint(5) NOT NULL DEFAULT 0 COMMENT '박스 너비',
  `h` smallint(5) NOT NULL DEFAULT 0 COMMENT '박스 높이',
  `reg_datetime` datetime DEFAULT current_timestamp() COMMENT '최초 입력시간',
  PRIMARY KEY (`v_id`,`stream_id`,`idx_stream_sec`,`kind`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='프레임 단위 스코어보드 세부 항목(팀/이닝/카운트/아웃/베이스) 검출 결과';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_play_baseball`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_play_baseball` (
  `v_id` mediumint(8) unsigned NOT NULL COMMENT '비디오 ID — t_video.v_id',
  `stream_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '스트림 청크 id — t_video_file.stream_id',
  `idx_stream_sec` mediumint(8) unsigned NOT NULL COMMENT '관측 초. 청크 영상 기준(0부터)',
  `idx_stream_time` time(1) NOT NULL COMMENT '청크 영상 내 관측 시각',
  `idx_sec` mediumint(8) unsigned NOT NULL COMMENT '관측 초. 전체 영상 기준',
  `idx_time` time(1) NOT NULL COMMENT '전체 영상 내 관측 시각',
  `change_yn` char(1) NOT NULL COMMENT '전광판 변화 여부 (Y/N) — 관측 있는 행끼리 직전과 상태가 다르면 Y',
  `tags` varchar(200) DEFAULT NULL COMMENT '사건 태그 — t_scoreboard_baseball 복사',
  `scene_type` varchar(50) DEFAULT NULL COMMENT '샷 유형 — t_vision.scene_type 복사 (관측만 있는 행은 NULL)',
  `inning` varchar(10) DEFAULT NULL COMMENT '1회초 · 1회말 (NULL=전광판 관측 없음)',
  `home_team` varchar(50) NOT NULL COMMENT '홈 팀명 — 경기 내 상수',
  `away_team` varchar(50) NOT NULL COMMENT '원정 팀명 — 경기 내 상수',
  `score_away` tinyint(3) unsigned DEFAULT NULL COMMENT '원정 팀 점수 (NULL=미인식·관측 없음)',
  `score_home` tinyint(3) unsigned DEFAULT NULL COMMENT '홈 팀 점수 (NULL=미인식·관측 없음)',
  `ball` tinyint(3) unsigned DEFAULT NULL COMMENT '볼 카운트 0~3 (NULL=미인식·관측 없음)',
  `strike` tinyint(3) unsigned DEFAULT NULL COMMENT '스트라이크 카운트 0~2 (NULL=미인식·관측 없음)',
  `out` tinyint(3) unsigned DEFAULT NULL COMMENT '아웃 카운트 0~3 (3=이닝 종료 보정값, NULL=미인식·관측 없음)',
  `base` char(3) DEFAULT NULL COMMENT '루 점유 1·2·3루 순 (100=1루, 101=1·3루, NULL=관측 없음)',
  `batter_num` tinyint(3) unsigned DEFAULT NULL COMMENT '타순 1~9 (NULL=관측 없음)',
  `scene_summary` varchar(1024) DEFAULT NULL COMMENT '샷 설명 — t_vision.summary 복사',
  `change_diff` varchar(200) DEFAULT NULL COMMENT '변화 항목 나열 ''[이름|이전,이후]'' (예: [볼|0,1]) — 변화 행에만',
  PRIMARY KEY (`v_id`,`stream_id`,`idx_stream_sec`) USING BTREE,
  UNIQUE KEY `uk_v_id_idx_sec` (`v_id`,`idx_sec`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='vision∪scoreboard 합집합 원장 — 초 단위, 단계별로 컬럼을 채운다';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_scene_baseball`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_scene_baseball` (
  `v_id` mediumint(8) unsigned NOT NULL COMMENT '비디오 ID — t_video.v_id',
  `stream_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '스트림 청크 id — t_video_file.stream_id',
  `scene_stream_seq` smallint(5) unsigned NOT NULL COMMENT '구간 번호 — 청크 안 시간순 일련번호 (1부터). PK·적재·색인의 축',
  `scene_seq` smallint(5) unsigned NOT NULL COMMENT '구간 번호 — 전체 영상 통산 시간순 일련번호 (1부터). 앞선 청크의 마지막 번호를 이어받는다 (레거시 보존·디버깅용)',
  `start_scb_stream_sec` mediumint(8) unsigned NOT NULL COMMENT '구간 시작초 (포함). 청크 영상 기준 — 클립 절단 좌표',
  `end_scb_stream_sec` mediumint(8) unsigned NOT NULL COMMENT '구간 끝초 (포함). 청크 영상 기준 — 클립 절단 좌표',
  `pitch_stream_sec` mediumint(8) unsigned DEFAULT NULL COMMENT '투구 시점 초. 청크 영상 기준 (미탐지 NULL)',
  `end_stream_secs` varchar(100) DEFAULT NULL COMMENT '클립 종료 후보 초 콤마 연결. 청크 영상 기준',
  `start_scb_sec` mediumint(8) unsigned NOT NULL COMMENT '구간 시작초 (포함). 전체 영상 기준 — 이전 스코어보드 관측 행',
  `end_scb_sec` mediumint(8) unsigned NOT NULL COMMENT '구간 끝초 (포함). 전체 영상 기준 — 결과 스코어보드 관측 행',
  `pitch_sec` mediumint(8) unsigned DEFAULT NULL COMMENT '투구 시점 초. 전체 영상 기준 (미탐지 NULL)',
  `end_secs` varchar(100) DEFAULT NULL COMMENT '클립 종료 후보 초 콤마 연결. 전체 영상 기준',
  `inning` varchar(10) NOT NULL COMMENT '이닝 (예: 1회초) — 끝점 행 스냅샷',
  `home_team` varchar(50) NOT NULL COMMENT '홈 팀명',
  `away_team` varchar(50) NOT NULL COMMENT '원정 팀명',
  `score_home` tinyint(3) unsigned NOT NULL COMMENT '홈 팀 점수 — 끝점 행 스냅샷',
  `score_away` tinyint(3) unsigned NOT NULL COMMENT '원정 팀 점수 — 끝점 행 스냅샷',
  `tags` varchar(200) DEFAULT NULL COMMENT '사건 태그 — 구간 안 사건 행들의 태그 합침 (중복 제거)',
  `labels` varchar(255) DEFAULT NULL COMMENT 'LLM 판정 결과 — 규정 용어 콤마 연결',
  `diff_score` tinyint(4) NOT NULL COMMENT '구간 시작→끝 점수(합) 변화량 — 미인식 끼면 0',
  `diff_out` tinyint(4) NOT NULL COMMENT '구간 시작→끝 아웃 변화량 — 미인식 끼면 0',
  `diff_base` varchar(10) DEFAULT NULL COMMENT '루 점유 변화 ''100>010'' — 변화 없으면 NULL',
  PRIMARY KEY (`v_id`,`stream_id`,`scene_stream_seq`) USING BTREE,
  UNIQUE KEY `v_id` (`v_id`,`scene_seq`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='플레이 구간 원장 — 사건 단위로 묶은 구간, 클립 생성의 기준';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_scoreboard_baseball`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_scoreboard_baseball` (
  `v_id` mediumint(8) unsigned NOT NULL COMMENT '비디오/경기 ID',
  `stream_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '스트림 청크 id — t_video_file.stream_id',
  `idx_stream_sec` mediumint(8) unsigned NOT NULL COMMENT '관측 초. 청크 영상 기준(0부터)',
  `idx_stream_time` time(1) NOT NULL COMMENT '청크 영상 내 관측 시각',
  `idx_sec` mediumint(8) unsigned NOT NULL COMMENT '관측 초. 전체 영상 기준',
  `idx_time` time(1) NOT NULL COMMENT '전체 영상 내 관측 시각',
  `inning` varchar(10) DEFAULT NULL COMMENT '1회초 · 1회말 (NULL=미인식)',
  `score_home` tinyint(3) unsigned DEFAULT NULL COMMENT '홈 팀 점수 (NULL=미인식)',
  `score_away` tinyint(3) unsigned DEFAULT NULL COMMENT '원정 팀 점수 (NULL=미인식)',
  `ball` tinyint(3) unsigned DEFAULT NULL COMMENT '볼 카운트 0~3 (NULL=미인식)',
  `strike` tinyint(3) unsigned DEFAULT NULL COMMENT '스트라이크 카운트 0~2 (NULL=미인식)',
  `out` tinyint(3) unsigned DEFAULT NULL COMMENT '아웃 카운트 0~3 (3=이닝 종료 보정값, NULL=미인식)',
  `base` char(3) DEFAULT NULL COMMENT '주자 상황 1·2·3루 순 (100=1루, 101=1·3루, NULL=미인식)',
  `etc` varchar(200) DEFAULT NULL COMMENT '기타 비고 정보',
  `check_yn` char(1) NOT NULL COMMENT '확인 필요 (Y/N) — 판정번복 의심 등',
  `jumping_cnt` tinyint(3) unsigned NOT NULL COMMENT '관측 공백 — 직전 행과의 사이에 못 본 투구 수(최소치). 0=끊김 없음',
  `tags` varchar(200) DEFAULT NULL COMMENT '사건 태그 — 아웃·득점·진루 등 (콤마 연결)',
  `pitching_yn` char(1) NOT NULL COMMENT '투구 진행 여부 (Y/N)',
  `batter_num` tinyint(3) unsigned DEFAULT NULL COMMENT '타순 1~9 (NULL=미상)',
  PRIMARY KEY (`v_id`,`stream_id`,`idx_stream_sec`) USING BTREE,
  UNIQUE KEY `uk_v_id_idx_sec` (`v_id`,`idx_sec`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='전광판 상태 원장 — 변화가 트리거된 프레임만, 초 단위';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_team_baseball`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_team_baseball` (
  `team_id` varchar(16) NOT NULL COMMENT 'KBO 전광판 표기 (LG·KIA·SSG…)',
  `alias` varchar(255) NOT NULL COMMENT '별칭 콤마 나열 (엘지,트윈스…)',
  PRIMARY KEY (`team_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='야구 팀명 사전 — 질의의 다양한 팀 표기를 전광판 표기(team_id)로 정규화';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_video`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_video` (
  `v_id` mediumint(8) unsigned NOT NULL,
  `p_v_id` mediumint(8) DEFAULT NULL COMMENT '시리즈 일때 사용 (낭만닥터-2 에서 낭만닥터-1 바라봄)',
  `cate_id` smallint(5) unsigned DEFAULT NULL COMMENT 'FK t_category',
  `name` varchar(45) NOT NULL COMMENT '영상명',
  `play_time` float(5,2) NOT NULL DEFAULT 0.00 COMMENT '영상 재생 시간',
  `play_year` int(4) DEFAULT NULL,
  `is_sbs` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'SBS 공개 뷰어 노출 여부(1=노출)',
  `stream_mode` char(1) DEFAULT 'N' COMMENT 'N : VOD 모드, Y: Stream Mode',
  `summary` text DEFAULT NULL COMMENT '영상 요약 (ai 전처리 후 입력)',
  `summary_stt` text DEFAULT NULL COMMENT 'STT 에서 남긴 영상 요약',
  `search_query` text NOT NULL COMMENT 'STT에서 남긴 등장인물을 찾는 요청값',
  `search_result` text NOT NULL COMMENT 'STT에서 남긴 등장인물 (WEB-SEARCH 결과)',
  `reg_datetime` datetime NOT NULL DEFAULT current_timestamp() COMMENT '최초 입력시간',
  `upd_datetime` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT '변경시간',
  `comment` varchar(200) DEFAULT NULL COMMENT '주석',
  PRIMARY KEY (`v_id`) USING BTREE,
  KEY `fk_t_video_t_category1_idx` (`cate_id`) USING BTREE,
  CONSTRAINT `fk_t_video_t_category` FOREIGN KEY (`cate_id`) REFERENCES `t_category` (`cate_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_video_board_baseball`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_video_board_baseball` (
  `v_id` mediumint(8) unsigned NOT NULL COMMENT 'FK t_video',
  `stream_id` varchar(20) NOT NULL,
  `kind` varchar(16) NOT NULL COMMENT 'BOARD / TEAM / INNING / COUNT / OUT / BASE / ETC',
  `x` smallint(5) NOT NULL DEFAULT -1 COMMENT '박스 좌상단 x (원본 프레임 절대 픽셀). -1=못 구함',
  `y` smallint(5) NOT NULL DEFAULT -1 COMMENT '박스 좌상단 y',
  `w` smallint(5) NOT NULL DEFAULT -1 COMMENT '박스 너비',
  `h` smallint(5) NOT NULL DEFAULT -1 COMMENT '박스 높이',
  `reg_datetime` datetime DEFAULT current_timestamp() COMMENT '최초 입력시간',
  PRIMARY KEY (`v_id`,`stream_id`,`kind`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='영상 단위 고정 박스 — 프레임별 검출 박스의 흔들림을 하나로 굳힌 값';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_video_file`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_video_file` (
  `v_id` mediumint(8) unsigned NOT NULL,
  `stream_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT 'VOD',
  `stream_seq` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `stream_idx_last` smallint(5) unsigned NOT NULL,
  `file_path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `stream_last` varchar(1) NOT NULL DEFAULT 'Y',
  `forced_yn` varchar(1) NOT NULL DEFAULT 'Y',
  `callback_url` varchar(200) DEFAULT NULL,
  `status_code` smallint(6) DEFAULT NULL COMMENT '영상 상태 코드',
  `play_time` float(5,2) NOT NULL DEFAULT 0.00 COMMENT '영상 재생 시간',
  `reg_datetime` datetime NOT NULL DEFAULT current_timestamp() COMMENT '최초 입력시간',
  `upd_datetime` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT '변경시간',
  `comment` varchar(200) DEFAULT NULL COMMENT '주석',
  PRIMARY KEY (`v_id`,`stream_id`) USING BTREE,
  KEY `fk_t_video_t_code` (`status_code`),
  CONSTRAINT `fk_t_video_t_code` FOREIGN KEY (`status_code`) REFERENCES `t_code` (`code`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `t_vision`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `t_vision` (
  `v_id` mediumint(8) unsigned NOT NULL COMMENT 'FK t_video',
  `stream_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '스트림 청크 id — t_video_file.stream_id',
  `idx_stream_sec` mediumint(8) unsigned NOT NULL COMMENT '샷 시작 초. 청크 영상 기준(0부터). 프레임·크롭 파일 번호와 같은 축',
  `idx_sec` mediumint(8) unsigned NOT NULL COMMENT '샷 시작 초. 전체 영상 기준(start_time 올림, 0부터)',
  `start_stream_time` time(1) NOT NULL COMMENT '청크 영상 내 샷 시작 시각',
  `end_stream_time` time(1) NOT NULL COMMENT '청크 영상 내 샷 종료 시각(= 다음 샷 시작)',
  `start_time` time(1) NOT NULL COMMENT '전체 영상내 샷 시작 시각',
  `end_time` time(1) NOT NULL COMMENT '전체 샷 종료 시각(= 다음 샷 시작)',
  `scene_type` varchar(50) DEFAULT NULL COMMENT '투구전, 투구, 타격, 수비, 공, 내야, 외야, 야구장전체, 관중, 덕아웃, 광고, 기타',
  `summary` varchar(1024) DEFAULT NULL COMMENT 'VLM이 생성한 샷 설명',
  PRIMARY KEY (`v_id`,`stream_id`,`idx_stream_sec`) USING BTREE,
  KEY `idx_v_id_scene_type` (`v_id`,`scene_type`) USING BTREE,
  CONSTRAINT `fk_t_vision_t_video` FOREIGN KEY (`v_id`) REFERENCES `t_video` (`v_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='샷(컷) 단위. baseball : PySceneDetect 컷 분할 구간 + VLM 샷 유형/캡션, t_play 구간 보정용';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

