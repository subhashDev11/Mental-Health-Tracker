import httpx
from datetime import date
from fastapi import APIRouter

from app.core.response_model import APIResponse

dailyQuoteRouter = APIRouter()

cached_quote = {}

@dailyQuoteRouter.get("/daily-quote")
async def daily_quote():
    today = date.today().isoformat()
    if cached_quote.get("date") != today:
        async with httpx.AsyncClient() as client:
            response = await client.get("https://zenquotes.io/api/today")
            data = response.json()
            cached_quote["date"] = today
            cached_quote["content"] = data[0]["q"]
            cached_quote["author"] = data[0]["a"]

    return APIResponse.success_response(
        data = cached_quote,
    )