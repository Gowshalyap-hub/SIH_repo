from fastapi.testclient import TestClient
from app.main import app
from app.api.dependencies import get_current_user
from app.models.user import User

client = TestClient(app)

def override_get_current_user():
    return User(id=1, email="test@test.com", role="FARMER", farm_id=1)

app.dependency_overrides[get_current_user] = override_get_current_user

def test_read_main():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "SIH Mastitis Backend API is running"}

def test_get_farms():
    response = client.get("/api/v1/farms")
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_get_cows():
    response = client.get("/api/v1/farms/1/cows")
    assert response.status_code == 200
    assert isinstance(response.json(), list)
