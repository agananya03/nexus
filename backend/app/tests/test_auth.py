from app.tests.conftest import get_auth_headers

def test_register_success(client):
    response = client.post(
        "/auth/register",
        json={"name": "Alice", "email": "alice@test.com", "password": "pass"}
    )
    assert response.status_code == 200
    assert "access_token" in response.json()

def test_register_duplicate_email(client):
    client.post(
        "/auth/register",
        json={"name": "Bob", "email": "bob@test.com", "password": "pass"}
    )
    response = client.post(
        "/auth/register",
        json={"name": "Bob Duplicate", "email": "bob@test.com", "password": "pass"}
    )
    assert response.status_code == 400

def test_login_success(client):
    client.post(
        "/auth/register",
        json={"name": "Charlie", "email": "charlie@test.com", "password": "pass"}
    )
    response = client.post(
        "/auth/login",
        json={"email": "charlie@test.com", "password": "pass"}
    )
    assert response.status_code == 200
    assert "access_token" in response.json()

def test_login_wrong_password(client):
    client.post(
        "/auth/register",
        json={"name": "Dave", "email": "dave@test.com", "password": "pass"}
    )
    response = client.post(
        "/auth/login",
        json={"email": "dave@test.com", "password": "wrong"}
    )
    assert response.status_code == 401

def test_get_me_authenticated(client):
    headers = get_auth_headers(client, "eve@test.com", "pass")
    response = client.get("/auth/me", headers=headers)
    assert response.status_code == 200
    assert response.json()["email"] == "eve@test.com"

def test_get_me_unauthenticated(client):
    response = client.get("/auth/me")
    assert response.status_code == 401
