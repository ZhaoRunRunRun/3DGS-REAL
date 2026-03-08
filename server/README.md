# 3DGS REAL Server

FastAPI 后端骨架，提供远端 3DGS 任务创建与状态查询接口。

## 启动

```bash
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8080
```

## 当前接口

- `GET /health`
- `POST /api/reconstruction/jobs`
- `GET /api/reconstruction/jobs/{job_id}`
