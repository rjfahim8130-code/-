from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from dotenv import load_dotenv
import os

load_dotenv()

app = FastAPI(title="Stories API", version="1.0.0")

# CORS — Flutter অ্যাপ থেকে কল করার জন্য
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# MongoDB Connection
MONGODB_URI = os.getenv("MONGODB_URI")
client = AsyncIOMotorClient(MONGODB_URI)
db = client["stories_db"]
stories_collection = db["stories"]


# ---------- Models ----------
class Story(BaseModel):
    id: Optional[str] = Field(None, alias="_id")
    title: str
    description: str = ""
    content: str = ""
    imageUrl: str = ""
    author: str = "Unknown"
    category: str = "গল্প"
    createdAt: Optional[datetime] = None

    class Config:
        populate_by_name = True
        json_encoders = {datetime: lambda v: v.isoformat()}


# ---------- Routes ----------
@app.get("/")
async def root():
    return {"message": "Stories API is running", "status": "ok"}


@app.get("/stories", response_model=List[dict])
async def get_stories():
    """সব গল্প/উপন্যাস ফেরত দেয়"""
    cursor = stories_collection.find({})
    stories = []
    async for doc in cursor:
        doc["_id"] = str(doc["_id"])
        stories.append(doc)
    return stories


@app.get("/stories/{story_id}")
async def get_story(story_id: str):
    """একটা নির্দিষ্ট গল্প"""
    from bson import ObjectId
    try:
        doc = await stories_collection.find_one({"_id": ObjectId(story_id)})
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid story ID")
    
    if not doc:
        raise HTTPException(status_code=404, detail="Story not found")
    
    doc["_id"] = str(doc["_id"])
    return doc


@app.post("/stories")
async def create_story(story: Story):
    """নতুন গল্প যোগ করা (ঐচ্ছিক)"""
    data = story.model_dump(by_alias=True, exclude={"id"})
    data["createdAt"] = datetime.utcnow()
    result = await stories_collection.insert_one(data)
    return {"id": str(result.inserted_id), "message": "Story created"}


@app.get("/health")
async def health():
    try:
        await client.admin.command("ping")
        return {"status": "healthy", "database": "connected"}
    except Exception as e:
        return {"status": "unhealthy", "error": str(e)}
  
