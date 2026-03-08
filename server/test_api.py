from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health() -> None:
    response = client.get('/health')
    assert response.status_code == 200
    assert response.json() == {'status': 'ok'}


def test_create_job_and_fetch() -> None:
    payload = {
        'mode': 'remote',
        'images': ['a.jpg', 'b.jpg', 'c.jpg'],
        'pipeline': '3dgs',
        'options': {
            'use_colmap': True,
            'iterations': 12000,
            'export_formats': ['splat', 'ply'],
        },
    }

    create_response = client.post('/api/reconstruction/jobs', json=payload)
    assert create_response.status_code == 200
    job = create_response.json()
    assert job['status'] == 'queued'
    assert job['progress'] == 5

    fetch_response = client.get(f"/api/reconstruction/jobs/{job['job_id']}")
    assert fetch_response.status_code == 200
    assert fetch_response.json()['job_id'] == job['job_id']


def test_missing_job_returns_404() -> None:
    response = client.get('/api/reconstruction/jobs/missing-job')
    assert response.status_code == 404
    assert response.json()['detail'] == 'Job not found'
