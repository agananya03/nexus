from unittest.mock import patch
from app.tests.conftest import get_auth_headers

def test_upload_note_unauthenticated(client):
    response = client.post(
        "/notes/",
        data={"title": "Test", "subject": "Math", "semester": "1"},
        files={"file": ("test.txt", b"dummy content", "text/plain")}
    )
    assert response.status_code == 401

def test_get_notes_empty(client):
    response = client.get("/notes/")
    assert response.status_code == 200
    assert response.json() == []

@patch("app.routers.notes.upload_file", return_value="http://cloudinary.com/fake.png")
def test_delete_other_users_note(mock_upload, client):
    headers_a = get_auth_headers(client, "user_a_note@test.com", "pass")
    upload_res = client.post(
        "/notes/",
        data={"title": "Test Note", "subject": "Math", "semester": "1"},
        files={"file": ("test.png", b"dummy image", "image/png")},
        headers=headers_a
    )
    
    assert upload_res.status_code == 200
    note_id = upload_res.json()["note_id"]
    
    headers_b = get_auth_headers(client, "user_b_note@test.com", "pass")
    delete_res = client.delete(f"/notes/{note_id}", headers=headers_b)
    
    assert delete_res.status_code == 403
