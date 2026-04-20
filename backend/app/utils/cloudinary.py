import os
import cloudinary
import cloudinary.uploader

def configure_cloudinary():
    cloudinary.config(secure=True)

def upload_file(file_bytes: bytes, filename: str, folder: str) -> str:
    response = cloudinary.uploader.upload(
        file_bytes,
        resource_type="auto",
        public_id=filename,
        folder=folder
    )
    return response.get("secure_url")
