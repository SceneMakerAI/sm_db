# sm_db

SceneMaker 의 저장소 스키마. 관계형(MariaDB)은 원본, 벡터(Milvus)는 검색용 파생본이다.
두 정의 모두 운영(2026-09-29)에서 그대로 추출했다.

| 파일 | 내용 |
|---|---|
| `mariadb/schema.sql` | `sm_db` 테이블 18개 DDL (데이터 없음) |
| `mariadb/init.sh` | 컨테이너 첫 기동 때 `schema.sql` → `code.sql`(있으면) 순서로 적재 |
| `milvus/sm_sport_baseball.json` | 컬렉션 정의 — 필드 18개, `vector` 2560차원, AUTOINDEX / COSINE |
| `milvus/create.py` | 위 JSON 으로 DB·컬렉션·인덱스 생성. 있으면 건너뛴다 |
| `docker-compose.yml` | MariaDB 12.3 + Milvus 2.6.18 |

## 빈 환경 만들기

```
cp .env.example .env            # MARIADB_ROOT_PASSWORD 채우기
docker compose up -d --wait     # MariaDB: sm_db 와 빈 테이블 18개가 자동 생성된다
pip install -r requirements.txt
python3 milvus/create.py        # Milvus: DB sm_db 와 빈 컬렉션 생성
```

포트는 `.env` 의 `MARIADB_PORT` · `MILVUS_PORT` 로 바꾼다. 테이블은 볼륨이 빈 첫 기동 때만 만들어지므로, 다시 만들려면 `docker compose down -v`.

## 운영과 다른 점

- Milvus 를 한 컨테이너(내장 etcd + 로컬 저장소)로 띄운다. 운영은 etcd · MinIO 를 따로 둔다. MinIO 공개 이미지를 더 받을 수 없어서다. 스키마에는 영향이 없다.
- `t_code`(상태 코드표)는 데이터가 필요하다. `t_video_file` · `t_compose` 의 `status_code` 가 이 표를 FK 로 참조하므로, 비어 있으면 첫 INSERT 가 실패한다. `mariadb/code.sql` 을 넣으면 `init.sh` 가 함께 적재한다.
