#!/usr/bin/env python3
"""milvus/*.json 정의로 DB 와 컬렉션을 만든다. 이미 있으면 건너뛴다.

    pip install -r requirements.txt
    python3 milvus/create.py                     # http://localhost:19530
    MILVUS_URL=http://host:19530 MILVUS_TOKEN=root:Milvus python3 milvus/create.py

REST API(v2) 대신 pymilvus 를 쓰는 이유: REST 는 필드 description 을 버린다 (2.6.18 확인).
"""
import json
import os
import sys
from pathlib import Path

from pymilvus import DataType, MilvusClient

TYPES = {
    "Int16": DataType.INT16,
    "Int64": DataType.INT64,
    "Float": DataType.FLOAT,
    "VarChar": DataType.VARCHAR,
    "FloatVector": DataType.FLOAT_VECTOR,
}


def create(client: MilvusClient, spec: dict) -> None:
    db, name = spec["database"], spec["collectionName"]
    if db not in client.list_databases():
        client.create_database(db)
        print(f"database {db}: created")
    client.use_database(db)
    if client.has_collection(name):
        print(f"{db}.{name}: exists, skip")
        return

    schema = client.create_schema(
        auto_id=any(f.get("autoId") for f in spec["fields"]),
        enable_dynamic_field=spec.get("enableDynamicField", False),
        description=spec.get("description", ""),
    )
    for f in spec["fields"]:
        params = {k: f[k] for k in ("max_length", "dim") if k in f}
        schema.add_field(
            f["name"], TYPES[f["type"]],
            is_primary=f.get("primaryKey", False),
            nullable=f.get("nullable", False),
            description=f.get("description", ""),
            **params,
        )

    index_params = client.prepare_index_params()
    for i in spec["indexes"]:
        index_params.add_index(i["fieldName"], index_name=i["indexName"],
                               index_type=i["indexType"], metric_type=i["metricType"])

    client.create_collection(
        name, schema=schema, index_params=index_params,
        consistency_level=spec.get("consistencyLevel", "Bounded"),
        num_shards=spec.get("shardsNum", 1),
    )
    print(f"{db}.{name}: created")


if __name__ == "__main__":
    specs = sorted(Path(__file__).parent.glob("*.json"))
    if not specs:
        sys.exit("milvus/*.json 이 없다")
    client = MilvusClient(os.environ.get("MILVUS_URL", "http://localhost:19530"),
                          token=os.environ.get("MILVUS_TOKEN", ""))
    for p in specs:
        create(client, json.loads(p.read_text(encoding="utf-8")))
