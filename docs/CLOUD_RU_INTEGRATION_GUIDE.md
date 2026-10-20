# Cloud.ru Object Storage Integration Guide

Comprehensive guide for integrating Cloud.ru S3-compatible object storage in the `velosimulator` project.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Architecture](#2-architecture)
3. [Backend (Python/FastAPI)](#3-backend-pythonfastapi)
   - [Configuration](#31-configuration)
   - [Domain Models](#32-domain-models)
   - [Repository Layer](#33-repository-layer)
   - [Service Layer](#33-service-layer)
   - [API Endpoints](#35-api-endpoints)
   - [Background Workers](#36-background-workers)
4. [Frontend (Flutter)](#4-frontend-flutter)
   - [Structure](#41-structure)
   - [S3 Service](#42-s3-service)
   - [Repository](#43-repository)
   - [Presentation Layer](#44-presentation-layer)
5. [Presigned URLs Workflow](#5-presigned-urls-workflow)
6. [Environment Setup](#6-environment-setup)
7. [Testing](#7-testing)
8. [Security Best Practices](#8-security-best-practices)
9. [Troubleshooting](#9-troubleshooting)

---

## 1. Overview

Cloud.ru provides an S3-compatible object storage service. This integration enables:

- **Video storage** — Store and manage video files from ride telemetry
- **File uploads/downloads** — Presigned URLs for secure client-side transfers
- **Metadata management** — Database-backed tracking of stored files
- **Background processing** — Celery workers for thumbnails, validation, GPX exports

### Key Components

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Backend | Python + FastAPI + boto3 | API for presigned URLs, metadata management |
| Database | PostgreSQL | Store video metadata (`cloud_video_items` table) |
| Cache/Broker | Redis | Celery broker + result backend |
| Worker | Celery | Async video processing, thumbnail generation |
| Frontend | Flutter | S3 client via presigned URLs, download manager |

---

## 2. Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Flutter Client                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │  S3 Service   │  │  Repository  │  │  Presentation     │  │
│  │  (presigned)  │  │              │  │  (CloudStorage    │  │
│  └──────────────┘  └──────────────┘  │   Flow)           │  │
│                                     └──────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │ HTTPS (presigned URL)
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   Cloud.ru Object Storage                    │
│                   (S3-compatible bucket)                      │
│  ────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    Backend API (FastAPI)                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │  /api/v1/     │  │  Cloud       │  │  CloudStorage    │  │
│  │  storage/     │──│  Storage     │──│  Repository      │  │
│  │              │  │  Service     │  │  (SQLAlchemy)    │  │
│  └──────────────┘  └──────┬───────┘  └──────────────────┘  │
│                          │                                   │
│  ┌───────────────────────┴───────┐                           │
│  │    Celery Worker              │                           │
│  │       │                           │
│  │           │                           │
│  │                 │                           │
│  └───────────────────────────────┘                           │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
                    PostgreSQL
              (cloud_video_items)
```

---

## 3. Backend (Python/FastAPI)

### 3.1 Configuration

**File:** `backend/app/config.py`

```python
class Settings(BaseSettings):
    # ... other settings ...

    # Cloud.ru S3 Object Storage
    S3_ENDPOINT: str           # e.g., https://storage.cloud.ru
    S3_ACCESS_KEY: str         # IAM access key
    S3_SECRET_KEY: str         # IAM secret key
    S3_BUCKET: str             # Bucket name (e.g., velosimulator-media)
    S3_REGION: str = "ru-1"    # Cloud.ru region
```

**Environment variables (`.env`):**

```env
S3_ENDPOINT=https://storage.cloud.ru
S3_ACCESS_KEY=YOUR_CLOUD_RU_ACCESS_KEY
S3_SECRET_KEY=YOUR_CLOUD_RU_SECRET_KEY
S3_BUCKET=velosimulator-media
S3_REGION=ru-1
```

### 3.2 Domain Models

**File:** `backend/app/domain/cloud_storage.py`

```python
class CloudVideoItem(Base, UUIDPrimaryKeyMixin, TimestampMixin):
    """Video file stored in cloud storage."""
    __tablename__ = "cloud_video_items"

    user_id: Mapped[UUID]          # Owner of the video
    s3_key: Mapped[str]            # Path in bucket (e.g., {user_id}/{uuid}.mp4)
    display_name: Mapped[str | None]   # Human-readable name
    file_size_bytes: Mapped[int | None]
    mime_type: Mapped[str | None]      # e.g., "video/mp4"
    thumbnail_url: Mapped[str | None]  # URL to generated thumbnail

class DownloadTask(Base, UUIDPrimaryKeyMixin, TimestampMixin):
    """Download task for file operations."""
    __tablename__ = "download_tasks"
    user_id: Mapped[UUID]
    s3_key: Mapped[str]
    status: Mapped[str]            # "pending", "in_progress", "completed", "failed"
```

### 3.3 Repository Layer

**File:** `backend/app/repositories/cloud_storage_repository.py`

```python
class CloudStorageRepository(BaseRepository[CloudVideoItem]):
    async def get_by_user_id(self, session, user_id, skip=0, limit=100):
        """Get all videos for a user."""
        stmt = (
            select(CloudVideoItem)
            .where(CloudVideoItem.user_id == user_id)
            .order_by(CloudVideoItem.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        result = await session.execute(stmt)
        return result.scalars().all()

    async def get_by_key(self, session, user_id, key):
        """Get video by S3 key and user ID."""
        stmt = select(CloudVideoItem).where(
            CloudVideoItem.user_id == user_id,
            CloudVideoItem.s3_key == key,
        )
        result = await session.execute(stmt)
        return result.scalars().first()
```

### 3.4 Service Layer

**File:** `backend/app/services/cloud_storage_service.py`

```python
class CloudStorageService:
    def __init__(self, storage_repo: CloudStorageRepository):
        self.storage_repo = storage_repo

    async def get_upload_url(self, user_id: UUID, request: PresignedUrlRequest) -> PresignedUrlResponse:
        """Generate presigned URL for client-side upload."""
        key = f"{user_id}/{uuid.uuid4()}{os.path.splitext(request.file_name or '')[1]}"
        # TODO: Implement actual boto3 presigned URL generation
        return PresignedUrlResponse(url=f"https://stub-upload-url/{key}", key=key)

    async def register_video(self, session, user_id, s3_key, **kwargs) -> dict:
        """Register video metadata after successful S3 upload."""
        video = await self.storage_repo.create(session, {
            "user_id": user_id, "s3_key": s3_key, **kwargs
        })
        return {"id": str(video.id), "s3_key": video.s3_key, **kwargs}

    async def list_videos(self, session, user_id, page, page_size) -> PaginatedResponse:
        """List user videos with pagination."""
        ...

    async def delete_video(self, session, user_id, video_id) -> None:
        """Delete video from DB (and S3)."""
        video = await self.storage_repo.get_by_id(session, video_id)
        if not video:
            raise ValueError("Video not found")
        await self.storage_repo.delete(session, video)
```

### 3.5 API Endpoints

**File:** `backend/app/api/v1/cloud_storage.py`

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| `POST` | `/api/v1/storage/presigned-url` | Get upload URL | Required |
| `GET` | `/api/v1/storage/presigned-url/{key}` | Get download URL | Required |
| `GET` | `/api/v1/storage/videos` | List user videos (paginated) | Required |
| `DELETE` | `/api/v1/storage/videos/{video_id}` | Delete video | Required |

**Example — Get upload presigned URL:**

```bash
curl -X POST http://localhost:8000/api/v1/storage/presigned-url \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"content_type": "video/mp4", "file_name": "ride_001.mp4"}'
```

Response:
```json
{
  "url": "https://velosimulator-media.storage.cloud.ru/user_id/uuid.mp4?X-Amz-...",
  "key": "user_id/uuid.mp4"
}
```

**Example — List videos:**

```bash
curl http://localhost:8000/api/v1/storage/videos?page=1&page_size=20 \
  -H "Authorization: Bearer <token>"
```

### 3.6 Background Workers

**File:** `backend/app/workers/storage_worker.py`

```python
@celery_app.task(name="workers.process_video_upload", bind=True, max_retries=3)
async def process_video_upload(self, data: dict) -> dict:
    """
    Process uploaded video:
    - Generate thumbnail
    - Validate file integrity
    - Update database record
    """
    user_id = data.get("user_id")
    s3_key = data.get("s3_key")
    video_id = data.get("video_id")
    ...

@celery_app.task(name="workers.generate_gpx_export", bind=True, max_retries=2)
async def generate_gpx_export(self, data: dict) -> dict:
    """
    Generate GPX export and upload to S3.
    """
    session_id = data.get("session_id")
    user_id = data.get("user_id")
    points = data.get("points", [])
    ...
```

**Triggering workers:**

```python
# After video registration
process_video_upload.delay({
    "user_id": str(user_id),
    "video_id": str(video_id),
    "s3_key": s3_key,
})
```

---

## 4. Frontend (Flutter)

### 4.1 Structure

```
velo_app/lib/features/cloud_storage/
├── di/
│   ├── cloud_storage_scope.dart        # DI registration
│   └── i_cloud_storage_scope.dart      # DI interface
├── domain/
│   ├── entities/
│   │   ├── cloud_video_item.dart       # Video entity
│   │   └── download_task.dart          # Download task
│   ├── repositories/
│   │   └── i_cloud_storage_repository.dart  # Repository interface
│   └── services/
│       └── i_s3_service.dart            # S3 service interface
├── data/
│   ├── repositories/
│   │   └── cloud_storage_repository.dart   # API-based implementation
│   └── services/
│       └── s3_service.dart               # Presigned URL S3 client
└── presentation/
    └── screens/
        └── cloud_storage/
            ├── cloud_storage_model.dart
            ├── cloud_storage_screen.dart
            ├── cloud_storage_wm.dart
            └── widgets/
                ├── cloud_storage_empty_widget.dart
                ├── cloud_storage_error_widget.dart
                ├── cloud_storage_loading_widget.dart
```

### 4.2 S3 Service

**File:** `velo_app/lib/features/cloud_storage/data/services/s3_service.dart`

```dart
abstract class IS3Service {
  Future<String> getUploadUrl({
    required String contentType,
    String? fileName,
  });
  Future<String> getDownloadUrl(String key);
  Future<void> uploadFile(String url, String path);
  Future<void> downloadFile(String url, String destinationPath);
}
```

### 4.3 Repository

**File:** `velo_app/lib/features/cloud_storage/domain/repositories/i_cloud_storage_repository.dart`

```dart
abstract class ICloudStorageRepository {
  Future<List<CloudVideoItem>> listVideos({int page = 1, int pageSize = 20});
  Future<void> deleteVideo(String videoId);
  Future<String> getUploadUrl({
    required String contentType,
    String? fileName,
  });
  Future<String> getDownloadUrl(String key);
}
```

### 4.4 Presentation Layer

**Cloud Storage Flow:**

```dart
// Navigate to cloud storage screen
context.router.push(const CloudStorageRoute());

// Access via HomeScope
final scope = context.read<IHomeScope>();
final cloudStorage = scope.cloudStorageScope;

// List videos
final videos = await cloudStorage.cloudStorageRepository.listVideos();

// Start download
cloudStorage.downloadManager.startDownload(videoId, totalBytes);
```

**Download progress listener:**

```dart
class MyDownloadListener implements IDownloadProgressListener {
  @override
  void onProgressUpdate(String videoId, DownloadProgress progress) {
    print('Progress: ${progress.percent}%');
  }

  @override
  void onDownloadCompleted(String videoId) {
    print('Download completed: $videoId');
  }

  @override
  void onDownloadFailed(String videoId, String error) {
    print('Download failed: $error');
  }
}
```

---

## 5. Presigned URLs Workflow

The recommended pattern for large file transfers (videos):

```
┌──────────┐                          ┌──────────┐                          ┌──────────────┐
│  Flutter  │                          │  Backend  │                          │  Cloud.ru S3  │
└────┬─────┘                          └────┬─────┘                          └──────┬───────┘
     │                                     │                                         │
     │  1. POST /presigned-url             │                                         │
     │     {content_type, file_name}       │                                         │
     │────────────────────────────────────>│                                         │
     │                                     │                                         │
     │                                     │  2. Generate presigned URL (boto3)      │
     │                                     │────────────────────────────────────────>│
     │                                     │                                         │
     │                                     │  3. Presigned URL + key                 │
     │     {url, key}                     │<────────────────────────────────────────│
     │<────────────────────────────────────│                                         │
     │                                     │                                         │
     │  4. PUT (direct to S3)              │                                         │
     │     Body: file bytes                │                                         │
     │──────────────────────────────────────────────────────────────────────────────>│
     │                                     │                                         │
     │  5. POST /videos (register)         │                                         │
     │     {s3_key, ...metadata}           │                                         │
     │────────────────────────────────────>│                                         │
     │                                     │                                         │
     │                                     │  6. Trigger Celery worker               │
     │     {success: true}                │<────────┐                                │
     │<────────────────────────────────────│    ││                                │
     │                                     │    ││  celery_app.send_task           │
     │                                     │    ▼│                                │
     │                                     │  Worker: process_video_upload       │
     │                                     │  - Generate thumbnail               │
     │                                     │  - Validate integrity                 │
     │                                     │  - Update DB                          │
```

**Key benefits:**
- Direct client-to-S3 transfer (no backend bandwidth cost)
- Backend only handles metadata and orchestration
- Presigned URLs expire automatically (configurable TTL)

---

## 6. Environment Setup

### 6.1 Cloud.ru Setup

1. **Create bucket:**
   - Panel: Cloud.ru → Object Storage → Buckets
   - Name: `velosimulator-media`
   - Region: `ru-1` (Moscow)
   - ACL: Private

2. **Create IAM user:**
   - Panel: Cloud.ru → IAM → Users
   - Create user with programmatic access
   - Policy: Attach `AmazonS3FullAccess` or custom policy for specific bucket

3. **Save credentials:**
   ```
   Access Key: <your-access-key>
   Secret Key: <your-secret-key>
   Endpoint: https://storage.cloud.ru
   ```

### 6.2 Backend `.env`

```env
# Cloud.ru Object Storage
S3_ENDPOINT=https://storage.cloud.ru
S3_ACCESS_KEY=YOUR_ACCESS_KEY
S3_SECRET_KEY=YOUR_SECRET_KEY
S3_BUCKET=velosimulator-media
S3_REGION=ru-1

# Redis (Celery broker)
REDIS_URL=redis://localhost:6379/0
CELERY_BROKER_URL=redis://localhost:6379/1
CELERY_RESULT_BACKEND=redis://localhost:6379/2
```

### 6.3 Install Dependencies

**Backend:**
```bash
cd backend
pip install boto3
# or
pip install -r requirements.txt  # if boto3 is included
```

**Flutter:**
```bash
cd client_velo_app  # or velo_app
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 7. Testing

### 7.1 Backend Unit Tests

**File:** `backend/tests/unit/test_cloud_storage_service.py`

```python
@pytest.mark.asyncio
async def test_get_upload_url():
    mock_repo = AsyncMock(spec=CloudStorageRepository)
    service = CloudStorageService(storage_repo=mock_repo)
    
    request = PresignedUrlRequest(
        content_type="video/mp4",
        file_name="test.mp4"
    )
    
    response = await service.get_upload_url(UUID(), request)
    
    assert response.url is not None
    assert response.key is not None
```

### 7.2 Integration Tests

**File:** `backend/tests/integration/test_cloud_storage_api.py`

```python
@pytest.mark.asyncio
async def test_list_videos(authenticated_client, video_item_factory):
    # Create test video
    video = await video_item_factory()
    
    response = await authenticated_client.get("/api/v1/storage/videos")
    
    assert response.status_code == 200
    data = response.json()
    assert "videos" in data or "items" in data
```

### 7.3 Flutter Tests

**File:** `velo_app/test/features/cloud_storage/...`

```dart
// Mock S3 service
class MockS3Service extends Mock implements IS3Service {}

// Test
final mockS3 = MockS3Service();
when(() => mockS3.getUploadUrl(contentType: any(named: 'contentType')))
    .thenAnswer((_) async => 'https://presigned-url');
```

---

## 8. Security Best Practices

### 8.1 Credential Management

| Practice | Description |
|----------|-------------|
| **Never commit secrets** | `.env` files are in `.gitignore` |
| **Use IAM roles** | Prefer EC2/ECS instance profiles over access keys |
| **Rotate keys regularly** | Every 90 days minimum |
| **Least privilege** | Grant only required S3 permissions |

### 8.2 Bucket Security

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSpecificBucket",
      "Effect": "Allow",
      "Principal": {"AWS": "arn:aws:iam::..."},
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "arn:aws:s3:::velosimulator-media/*"
    }
  ]
}
```

### 8.3 Presigned URL Security

- Set short expiration (5-15 minutes)
- Include content-type constraints in generation
- Validate user ownership before generating URLs
- Log all presigned URL generation for audit

---

## 9. Troubleshooting

### Common Issues

| Problem | Solution |
|---------|----------|
| `NoSuchBucket` | Verify bucket name and region in config |
| `AccessDenied` | Check IAM user permissions and policy |
| `InvalidAccessKeyId` | Verify access/secret keys in `.env` |
| Presigned URL expired | Regenerate URL before upload |
| Worker not processing | Check Redis connectivity and Celery status |
| `ConnectionRefused` on Redis | Ensure Redis is running: `redis-cli ping` |

### Debug Commands

```bash
# Check Celery workers
celery -A app.workers.celery_app worker --loglevel=info

# Check Redis connectivity
redis-cli ping

# Test S3 connectivity (Python)
python -c "
import boto3
s3 = boto3.client('s3',
    endpoint_url='https://storage.cloud.ru',
    aws_access_key_id='KEY',
    aws_secret_access_key='SECRET'
)
print(s3.list_buckets())
"

# Flutter: Check S3 service logs
# Logs are written when kDebugMode is true in S3Service
```

---

## Appendix A: File Locations

| Component | Path |
|-----------|------|
| Domain Models | `backend/app/domain/cloud_storage.py` |
| DTOs | `backend/app/dtos/cloud_storage.py` |
| Repository | `backend/app/repositories/cloud_storage_repository.py` |
| Service | `backend/app/services/cloud_storage_service.py` |
| API Router | `backend/app/api/v1/cloud_storage.py` |
| Workers | `backend/app/workers/storage_worker.py` |
| Config | `backend/app/config.py` |
| Dependencies | `backend/app/dependencies.py` |
| Unit Tests | `backend/tests/unit/test_cloud_storage_service.py` |
| Integration Tests | `backend/tests/integration/test_cloud_storage_api.py` |
| Architecture Doc | `docs/architecture/cloud_storage_architecture.md` |
| Flutter S3 Service | `velo_app/lib/features/cloud_storage/data/services/s3_service.dart` |
| Flutter Repository | `velo_app/lib/features/cloud_storage/data/repositories/cloud_storage_repository.dart` |
| Flutter Presentation | `velo_app/lib/features/cloud_storage/presentation/screens/cloud_storage/` |

---

## Appendix B: TODO Items (Current Implementation)

The following items are marked as TODO in the current codebase:

- [ ] **Implement actual boto3 presigned URL generation** in `CloudStorageService.get_upload_url()` and `get_download_url()`
- [ ] **Implement video processing logic** in `process_video_upload` Celery task (thumbnail generation, integrity validation)
- [ ] **Implement GPX generation** in `generate_gpx_export` Celery task
- [ ] **Add S3 client initialization** — Create a dedicated S3 client module with boto3 configuration
- [ ] **Add migration** for `download_tasks` table if not already present
- [ ] **Flutter download manager** — Complete implementation in `velo_app`

---

*Generated: 2026-10-20*  
*Project: velosimulator*  
*Storage Provider: Cloud.ru Object Storage (S3-compatible)*
