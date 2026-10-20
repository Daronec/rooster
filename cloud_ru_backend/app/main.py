"""Cloud.ru Serverless Functions для Rooster.

FastAPI приложение с REST API для задач, списков, планов, материалов,
профиля и команд. Интеграция с PostgreSQL и Cloud.ru Object Storage.
"""

from typing import Optional

from fastapi import FastAPI, HTTPException, Depends, status
from pydantic import BaseModel, Field
from sqlalchemy import create_engine, Column, String, Integer, Float, Boolean, Text, JSON, DateTime, ForeignKey
from sqlalchemy.orm import declarative_base, sessionmaker, Session, relationship
from sqlalchemy.sql import func
from datetime import datetime, timezone
import boto3
from botocore.client import Config

# ==================== Configuration ====================

DATABASE_URL = "postgresql://user:pass@host:5432/rooster"
S3_ENDPOINT = "https://storage.cloud.ru"
S3_ACCESS_KEY = ""
S3_SECRET_KEY = ""
S3_BUCKET = "rooster-media"
S3_AVATARS_BUCKET = "rooster-avatars"
SECRET_KEY = "your-secret-key-change-in-production"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

# ==================== Database ====================

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# ==================== Pydantic Models ====================

class TaskCreate(BaseModel):
    id: str
    list_id: str
    title: str
    description: Optional[str] = ""
    status: str = "pending"
    updated_at_millis: int
    content_revision: int = 0
    parent_task_id: Optional[str] = None
    owner_user_id: Optional[str] = None
    executor_user_id: Optional[str] = None
    priority: str = "normal"
    due_at: Optional[int] = None

class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    status: Optional[str] = None
    updated_at_millis: Optional[int] = None
    content_revision: Optional[int] = None

class TaskListCreate(BaseModel):
    id: str
    name: str
    color_argb: int
    updated_at_millis: int
    content_revision: int = 0

class PlanCreate(BaseModel):
    id: str
    title: str
    updated_at_millis: int
    content_revision: int = 0
    tasks: Optional[list] = []

class MaterialStockUpdate(BaseModel):
    items: list[dict]
    updated_at_millis: int
    content_revision: int = 0

class ProfileUpdate(BaseModel):
    user_id: str
    first_name: str
    last_name: str
    avatar_id: Optional[str] = None

class TeamCreate(BaseModel):
    team_name: str
    members: list[dict]
    current_user_membership_id: str
    current_user_is_owner: bool = True
    created_at_millis: int

class TeamInvitationCreate(BaseModel):
    team_id: str
    email: str
    invitation_return_url: str

class TeamInvitationAccept(BaseModel):
    invitation_token: str

class TeamMemberRoleUpdate(BaseModel):
    member_user_id: str
    roles: list[str]

class PresignedUrlRequest(BaseModel):
    bucket: str
    object_key: str
    content_type: str

# ==================== SQLAlchemy Models ====================

class Task(Base):
    __tablename__ = "tasks"

    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, index=True, nullable=False)
    list_id = Column(String, index=True, nullable=False)
    title = Column(String, nullable=False)
    description = Column(Text, default="")
    status = Column(String, default="pending")
    updated_at_millis = Column(Integer, nullable=False)
    content_revision = Column(Integer, default=0)
    parent_task_id = Column(String, nullable=True)
    owner_user_id = Column(String, nullable=True)
    executor_user_id = Column(String, nullable=True)
    priority = Column(String, default="normal")
    due_at = Column(Integer, nullable=True)
    data = Column(JSON, default={})

    user = relationship("User", back_populates="tasks")

class TaskList(Base):
    __tablename__ = "task_lists"

    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, index=True, nullable=False)
    name = Column(String, nullable=False)
    color_argb = Column(Integer, nullable=False)
    updated_at_millis = Column(Integer, nullable=False)
    content_revision = Column(Integer, default=0)

    user = relationship("User", back_populates="lists")

class Plan(Base):
    __tablename__ = "plans"

    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, index=True, nullable=False)
    title = Column(String, nullable=False)
    updated_at_millis = Column(Integer, nullable=False)
    content_revision = Column(Integer, default=0)
    data = Column(JSON, default={})

    user = relationship("User", back_populates="plans")

class MaterialStock(Base):
    __tablename__ = "material_stock"

    id = Column(String, primary_key=True, default="singleton")
    user_id = Column(String, index=True, nullable=False, unique=True)
    data = Column(JSON, nullable=False)
    updated_at_millis = Column(Integer, nullable=False)
    content_revision = Column(Integer, default=0)

class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, index=True)
    first_name = Column(String, default="")
    last_name = Column(String, default="")
    avatar_id = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    tasks = relationship("Task", back_populates="user")
    lists = relationship("TaskList", back_populates="user")
    plans = relationship("Plan", back_populates="user")

class Team(Base):
    __tablename__ = "teams"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    owner_user_id = Column(String, nullable=False)
    created_at_millis = Column(Integer, nullable=False)
    data = Column(JSON, default={})

    members = relationship("TeamMember", back_populates="team")
    invitations = relationship("TeamInvitation", back_populates="team")

class TeamMember(Base):
    __tablename__ = "team_members"

    id = Column(String, primary_key=True, index=True)
    team_id = Column(String, ForeignKey("teams.id"), nullable=False)
    user_id = Column(String, nullable=False)
    roles = Column(JSON, default=[])
    joined_at_millis = Column(Integer, nullable=False)
    is_owner = Column(Boolean, default=False)

    team = relationship("Team", back_populates="members")

class TeamInvitation(Base):
    __tablename__ = "team_invitations"

    id = Column(String, primary_key=True, index=True)
    team_id = Column(String, ForeignKey("teams.id"), nullable=False)
    email = Column(String, nullable=False)
    token = Column(String, unique=True, nullable=False)
    status = Column(String, default="pending")  # pending, accepted, revoked, rejected
    created_at_millis = Column(Integer, nullable=False)
    expires_at_millis = Column(Integer, nullable=False)

    team = relationship("Team", back_populates="invitations")

# ==================== S3 Client ====================

s3_client = boto3.client(
    "s3",
    endpoint_url=S3_ENDPOINT,
    aws_access_key_id=S3_ACCESS_KEY,
    aws_secret_access_key=S3_SECRET_KEY,
    config=Config(signature_version="s3v4"),
)

# ==================== App ====================

app = FastAPI(title="Rooster Cloud.ru API", version="1.0.0")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ==================== Helpers ====================

def get_or_create_user(db: Session, user_id: str) -> User:
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        user = User(id=user_id)
        db.add(user)
        db.flush()
    return user

# ==================== Tasks API ====================

@app.get("/tasks")
def list_tasks(db: Session = Depends(get_db), user_id: str = None):
    """Получить все задачи пользователя."""
    query = db.query(Task)
    if user_id:
        query = query.filter(Task.user_id == user_id)
    tasks = query.order_by(Task.updated_at_millis.desc()).all()
    return [t.__dict__ for t in tasks]

@app.get("/tasks/{task_id}")
def get_task(task_id: str, db: Session = Depends(get_db)):
    """Получить задачу по ID."""
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task.__dict__

@app.post("/tasks")
def create_task(task: TaskCreate, db: Session = Depends(get_db)):
    """Создать задачу."""
    existing = db.query(Task).filter(Task.id == task.id).first()
    if existing:
        raise HTTPException(status_code=409, detail="Task already exists")

    user = get_or_create_user(db, task.id.split("-")[0] if "-" in task.id else "unknown")
    db_task = Task(
        id=task.id,
        user_id=user.id,
        list_id=task.list_id,
        title=task.title,
        description=task.description or "",
        status=task.status,
        updated_at_millis=task.updated_at_millis,
        content_revision=task.content_revision,
        parent_task_id=task.parent_task_id,
        owner_user_id=task.owner_user_id,
        executor_user_id=task.executor_user_id,
        priority=task.priority,
        due_at=task.due_at,
    )
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    return db_task.__dict__

@app.put("/tasks/{task_id}")
def update_task(task_id: str, task: TaskUpdate, db: Session = Depends(get_db)):
    """Обновить задачу."""
    db_task = db.query(Task).filter(Task.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")

    update_data = task.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_task, key, value)

    db.commit()
    db.refresh(db_task)
    return db_task.__dict__

@app.delete("/tasks/{task_id}")
def delete_task(task_id: str, db: Session = Depends(get_db)):
    """Удалить задачу."""
    db_task = db.query(Task).filter(Task.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")

    db.delete(db_task)
    db.commit()
    return {"status": "deleted"}

@app.post("/tasks/sync")
def sync_tasks(tasks: list[TaskCreate], db: Session = Depends(get_db)):
    """Batch upsert задач."""
    results = []
    for task_data in tasks:
        existing = db.query(Task).filter(Task.id == task_data.id).first()
        if existing:
            for key, value in task_data.model_dump().items():
                setattr(existing, key, value)
            results.append(existing.__dict__)
        else:
            user = get_or_create_user(db, task_data.id.split("-")[0] if "-" in task_data.id else "unknown")
            db_task = Task(
                id=task_data.id,
                user_id=user.id,
                list_id=task_data.list_id,
                title=task_data.title,
                description=task_data.description or "",
                status=task_data.status,
                updated_at_millis=task_data.updated_at_millis,
                content_revision=task_data.content_revision,
                parent_task_id=task_data.parent_task_id,
                owner_user_id=task_data.owner_user_id,
                executor_user_id=task_data.executor_user_id,
                priority=task_data.priority,
                due_at=task_data.due_at,
            )
            db.add(db_task)
            results.append(db_task.__dict__)

    db.commit()
    return {"status": "ok", "count": len(results)}

# ==================== Task Lists API ====================

@app.get("/task-lists")
def list_task_lists(db: Session = Depends(get_db), user_id: str = None):
    """Получить все списки задач."""
    query = db.query(TaskList)
    if user_id:
        query = query.filter(TaskList.user_id == user_id)
    return [t.__dict__ for t in query.all()]

@app.post("/task-lists")
def create_task_list(task_list: TaskListCreate, db: Session = Depends(get_db)):
    """Создать список задач."""
    existing = db.query(TaskList).filter(TaskList.id == task_list.id).first()
    if existing:
        raise HTTPException(status_code=409, detail="List already exists")

    user = get_or_create_user(db, task_list.id.split("-")[0] if "-" in task_list.id else "unknown")
    db_list = TaskList(
        id=task_list.id,
        user_id=user.id,
        name=task_list.name,
        color_argb=task_list.color_argb,
        updated_at_millis=task_list.updated_at_millis,
        content_revision=task_list.content_revision,
    )
    db.add(db_list)
    db.commit()
    db.refresh(db_list)
    return db_list.__dict__

@app.put("/task-lists/{list_id}")
def update_task_list(list_id: str, task_list: TaskListCreate, db: Session = Depends(get_db)):
    """Обновить список задач."""
    db_list = db.query(TaskList).filter(TaskList.id == list_id).first()
    if not db_list:
        raise HTTPException(status_code=404, detail="List not found")

    for key, value in task_list.model_dump().items():
        setattr(db_list, key, value)

    db.commit()
    db.refresh(db_list)
    return db_list.__dict__

@app.delete("/task-lists/{list_id}")
def delete_task_list(list_id: str, db: Session = Depends(get_db)):
    """Удалить список задач."""
    db_list = db.query(TaskList).filter(TaskList.id == list_id).first()
    if not db_list:
        raise HTTPException(status_code=404, detail="List not found")

    db.delete(db_list)
    db.commit()
    return {"status": "deleted"}

@app.post("/task-lists/sync")
def sync_task_lists(lists: list[TaskListCreate], db: Session = Depends(get_db)):
    """Batch upsert списков задач."""
    for list_data in lists:
        existing = db.query(TaskList).filter(TaskList.id == list_data.id).first()
        if existing:
            for key, value in list_data.model_dump().items():
                setattr(existing, key, value)
        else:
            user = get_or_create_user(db, list_data.id.split("-")[0] if "-" in list_data.id else "unknown")
            db_list = TaskList(
                id=list_data.id,
                user_id=user.id,
                name=list_data.name,
                color_argb=list_data.color_argb,
                updated_at_millis=list_data.updated_at_millis,
                content_revision=list_data.content_revision,
            )
            db.add(db_list)

    db.commit()
    return {"status": "ok"}

# ==================== Plans API ====================

@app.get("/plans")
def list_plans(db: Session = Depends(get_db), user_id: str = None):
    """Получить все планы."""
    query = db.query(Plan)
    if user_id:
        query = query.filter(Plan.user_id == user_id)
    return [p.__dict__ for p in query.all()]

@app.post("/plans")
def create_plan(plan: PlanCreate, db: Session = Depends(get_db)):
    """Создать план."""
    existing = db.query(Plan).filter(Plan.id == plan.id).first()
    if existing:
        raise HTTPException(status_code=409, detail="Plan already exists")

    user = get_or_create_user(db, plan.id.split("-")[0] if "-" in plan.id else "unknown")
    db_plan = Plan(
        id=plan.id,
        user_id=user.id,
        title=plan.title,
        updated_at_millis=plan.updated_at_millis,
        content_revision=plan.content_revision,
        data={"tasks": plan.tasks or []},
    )
    db.add(db_plan)
    db.commit()
    db.refresh(db_plan)
    return db_plan.__dict__

@app.put("/plans/{plan_id}")
def update_plan(plan_id: str, plan: PlanCreate, db: Session = Depends(get_db)):
    """Обновить план."""
    db_plan = db.query(Plan).filter(Plan.id == plan_id).first()
    if not db_plan:
        raise HTTPException(status_code=404, detail="Plan not found")

    for key, value in plan.model_dump().items():
        setattr(db_plan, key, value)

    db.commit()
    db.refresh(db_plan)
    return db_plan.__dict__

@app.delete("/plans/{plan_id}")
def delete_plan(plan_id: str, db: Session = Depends(get_db)):
    """Удалить план."""
    db_plan = db.query(Plan).filter(Plan.id == plan_id).first()
    if not db_plan:
        raise HTTPException(status_code=404, detail="Plan not found")

    db.delete(db_plan)
    db.commit()
    return {"status": "deleted"}

@app.post("/plans/sync")
def sync_plans(plans: list[PlanCreate], db: Session = Depends(get_db)):
    """Batch upsert планов."""
    for plan_data in plans:
        existing = db.query(Plan).filter(Plan.id == plan_data.id).first()
        if existing:
            for key, value in plan_data.model_dump().items():
                setattr(existing, key, value)
        else:
            user = get_or_create_user(db, plan_data.id.split("-")[0] if "-" in plan_data.id else "unknown")
            db_plan = Plan(
                id=plan_data.id,
                user_id=user.id,
                title=plan_data.title,
                updated_at_millis=plan_data.updated_at_millis,
                content_revision=plan_data.content_revision,
                data={"tasks": plan_data.tasks or []},
            )
            db.add(db_plan)

    db.commit()
    return {"status": "ok"}

# ==================== Material Stock API ====================

@app.get("/material-stock")
def get_material_stock(user_id: str = None, db: Session = Depends(get_db)):
    """Получить склад материалов."""
    stock = db.query(MaterialStock).filter(MaterialStock.user_id == user_id).first()
    if not stock:
        raise HTTPException(status_code=404, detail="Stock not found")
    return stock.__dict__

@app.put("/material-stock")
def update_material_stock(stock: MaterialStockUpdate, db: Session = Depends(get_db), user_id: str = None):
    """Обновить склад материалов."""
    existing = db.query(MaterialStock).filter(MaterialStock.user_id == user_id).first()
    if existing:
        existing.data = {"items": stock.items}
        existing.updated_at_millis = stock.updated_at_millis
        existing.content_revision = stock.content_revision
    else:
        db_stock = MaterialStock(
            user_id=user_id,
            data={"items": stock.items},
            updated_at_millis=stock.updated_at_millis,
            content_revision=stock.content_revision,
        )
        db.add(db_stock)

    db.commit()
    return {"status": "ok"}

# ==================== Profile API ====================

@app.get("/profile")
def get_profile(user_id: str = None, db: Session = Depends(get_db)):
    """Получить профиль пользователя."""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Profile not found")
    return {
        "userId": user.id,
        "firstName": user.first_name,
        "lastName": user.last_name,
        "avatarId": user.avatar_id,
    }

@app.put("/profile")
def update_profile(profile: ProfileUpdate, db: Session = Depends(get_db)):
    """Обновить профиль пользователя."""
    user = db.query(User).filter(User.id == profile.user_id).first()
    if not user:
        user = User(id=profile.user_id)
        db.add(user)
        db.flush()

    user.first_name = profile.first_name
    user.last_name = profile.last_name
    user.avatar_id = profile.avatar_id

    db.commit()
    db.refresh(user)
    return {"status": "ok"}

# ==================== Teams API ====================

@app.get("/teams")
def list_teams(user_id: str = None, db: Session = Depends(get_db)):
    """Получить команды пользователя."""
    teams = db.query(Team).join(TeamMember).filter(TeamMember.user_id == user_id).all()
    return [t.__dict__ for t in teams]

@app.post("/teams")
def create_team(team: TeamCreate, db: Session = Depends(get_db)):
    """Создать команду."""
    db_team = Team(
        id=f"team_{team.team_name.lower().replace(' ', '_')}_{datetime.now().timestamp()}",
        name=team.team_name,
        owner_user_id=team.members[0]["userId"] if team.members else "unknown",
        created_at_millis=team.created_at_millis,
        data={"members": team.members},
    )
    db.add(db_team)
    db.commit()
    db.refresh(db_team)
    return db_team.__dict__

@app.put("/teams/{team_id}")
def update_team(team_id: str, team: TeamCreate, db: Session = Depends(get_db)):
    """Обновить команду."""
    db_team = db.query(Team).filter(Team.id == team_id).first()
    if not db_team:
        raise HTTPException(status_code=404, detail="Team not found")

    db_team.name = team.team_name
    db_team.data = {"members": team.members}

    db.commit()
    db.refresh(db_team)
    return db_team.__dict__

@app.delete("/teams/{team_id}")
def delete_team(team_id: str, db: Session = Depends(get_db)):
    """Удалить команду."""
    db_team = db.query(Team).filter(Team.id == team_id).first()
    if not db_team:
        raise HTTPException(status_code=404, detail="Team not found")

    db.delete(db_team)
    db.commit()
    return {"status": "deleted"}

@app.post("/teams/invite")
def invite_to_team(invitation: TeamInvitationCreate, db: Session = Depends(get_db)):
    """Пригласить участника в команду."""
    import uuid
    token = str(uuid.uuid4())

    db_invitation = TeamInvitation(
        team_id=invitation.team_id,
        email=invitation.email,
        token=token,
        status="pending",
        created_at_millis=int(datetime.now().timestamp()),
        expires_at_millis=int(datetime.now().timestamp()) + 86400 * 7,  # 7 days
    )
    db.add(db_invitation)
    db.commit()
    return {"status": "ok", "token": token}

@app.post("/teams/accept-invitation")
def accept_invitation(request: TeamInvitationAccept, db: Session = Depends(get_db)):
    """Принять приглашение в команду."""
    invitation = db.query(TeamInvitation).filter(
        TeamInvitation.token == request.invitation_token,
        TeamInvitation.status == "pending",
    ).first()

    if not invitation:
        raise HTTPException(status_code=404, detail="Invitation not found or expired")

    invitation.status = "accepted"
    db.commit()
    return {"status": "ok"}

@app.post("/teams/reject-invitation")
def reject_invitation(request: TeamInvitationAccept, db: Session = Depends(get_db)):
    """Отклонить приглашение."""
    invitation = db.query(TeamInvitation).filter(
        TeamInvitation.token == request.invitation_token,
        TeamInvitation.status == "pending",
    ).first()

    if not invitation:
        raise HTTPException(status_code=404, detail="Invitation not found or expired")

    invitation.status = "rejected"
    db.commit()
    return {"status": "ok"}

@app.delete("/teams/invitations")
def revoke_invitation(team_id: str, invitation_id: str, db: Session = Depends(get_db)):
    """Отозвать приглашение."""
    invitation = db.query(TeamInvitation).filter(
        TeamInvitation.id == invitation_id,
        TeamInvitation.team_id == team_id,
        TeamInvitation.status == "pending",
    ).first()

    if not invitation:
        raise HTTPException(status_code=404, detail="Invitation not found")

    invitation.status = "revoked"
    db.commit()
    return {"status": "ok"}

@app.get("/teams/{team_id}/invitations")
def list_team_invitations(team_id: str, db: Session = Depends(get_db)):
    """Получить список активных приглашений команды."""
    invitations = db.query(TeamInvitation).filter(
        TeamInvitation.team_id == team_id,
        TeamInvitation.status == "pending",
    ).all()
    return [i.__dict__ for i in invitations]

@app.put("/teams/members/{member_user_id}/role")
def update_member_role(team_id: str, member_user_id: str, request: TeamMemberRoleUpdate, db: Session = Depends(get_db)):
    """Обновить роль участника."""
    member = db.query(TeamMember).filter(
        TeamMember.team_id == team_id,
        TeamMember.user_id == member_user_id,
    ).first()

    if not member:
        raise HTTPException(status_code=404, detail="Member not found")

    member.roles = request.roles
    db.commit()
    db.refresh(member)
    return member.__dict__

@app.delete("/teams/members")
def remove_member(team_id: str, member_user_id: str, db: Session = Depends(get_db)):
    """Удалить участника из команды."""
    member = db.query(TeamMember).filter(
        TeamMember.team_id == team_id,
        TeamMember.user_id == member_user_id,
    ).first()

    if not member:
        raise HTTPException(status_code=404, detail="Member not found")

    db.delete(member)
    db.commit()
    return {"status": "ok"}

@app.delete("/teams/leave")
def leave_team(team_id: str, membership_id: str, db: Session = Depends(get_db)):
    """Покинуть команду."""
    member = db.query(TeamMember).filter(
        TeamMember.team_id == team_id,
        TeamMember.id == membership_id,
    ).first()

    if not member:
        raise HTTPException(status_code=404, detail="Membership not found")

    db.delete(member)
    db.commit()
    return {"status": "ok"}

# ==================== Storage API ====================

@app.post("/storage/presigned-upload")
def generate_presigned_upload_url(request: PresignedUrlRequest, db: Session = Depends(get_db)):
    """Сгенерировать presigned URL для загрузки файла."""
    try:
        url = s3_client.generate_presigned_url(
            "put_object",
            Params={
                "Bucket": request.bucket,
                "Key": request.object_key,
                "ContentType": request.content_type,
            },
            ExpiresIn=3600,  # 1 hour
        )
        return {"url": url}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/storage/presigned-download")
def generate_presigned_download_url(request: PresignedUrlRequest, db: Session = Depends(get_db)):
    """Сгенерировать presigned URL для скачивания файла."""
    try:
        url = s3_client.generate_presigned_url(
            "get_object",
            Params={
                "Bucket": request.bucket,
                "Key": request.object_key,
            },
            ExpiresIn=3600,  # 1 hour
        )
        return {"url": url}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ==================== Init ====================

Base.metadata.create_all(bind=engine)
