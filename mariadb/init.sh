#!/bin/bash
# mariadb 이미지가 첫 기동 때 source 한다. docker_process_sql 은 MARIADB_DATABASE(sm_db)로 접속한다.
# code.sql 은 schema.sql 의 FK 대상(t_code)이라 뒤에 넣는다. 없으면 건너뛴다.
for f in schema.sql code.sql; do
  if [ -f "/sm_db/$f" ]; then
    echo "sm_db: $f"
    docker_process_sql < "/sm_db/$f"
  fi
done
