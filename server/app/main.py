from datetime import datetime
from enum import Enum
from uuid import uuid4

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

app = FastAPI(title='3DGS REAL API', version='0.1.0')


class ReconstructionMode(str, Enum):
    local = 'local'
    remote = 'remote'


class JobStatus(str, Enum):
    queued = 'queued'
    running = 'running'
    done = 'done'
    failed = 'failed'


class ReconstructionOptions(BaseModel):
    use_colmap: bool = True
    iterations: int = 30000
    export_formats: list[str] = Field(default_factory=lambda: ['splat', 'ply'])


class CreateJobRequest(BaseModel):
    mode: ReconstructionMode
    images: list[str]
    pipeline: str = '3dgs'
    options: ReconstructionOptions = Field(default_factory=ReconstructionOptions)


class JobResponse(BaseModel):
    job_id: str
    status: JobStatus
    progress: int
    preview_url: str | None = None
    artifacts: list[str] = Field(default_factory=list)
    logs: list[str] = Field(default_factory=list)
    created_at: datetime


JOBS: dict[str, JobResponse] = {}


@app.get('/health')
def health() -> dict[str, str]:
    return {'status': 'ok'}


@app.post('/api/reconstruction/jobs', response_model=JobResponse)
def create_job(payload: CreateJobRequest) -> JobResponse:
    job_id = uuid4().hex[:12]
    job = JobResponse(
        job_id=job_id,
        status=JobStatus.queued,
        progress=5,
        created_at=datetime.utcnow(),
        logs=[
            f'Received {len(payload.images)} images',
            f'Pipeline: {payload.pipeline}',
            f'Mode: {payload.mode.value}',
        ],
    )
    JOBS[job_id] = job
    return job


@app.get('/api/reconstruction/jobs/{job_id}', response_model=JobResponse)
def get_job(job_id: str) -> JobResponse:
    job = JOBS.get(job_id)
    if job is None:
        raise HTTPException(status_code=404, detail='Job not found')
    return job
