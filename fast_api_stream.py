from fastapi import FastAPI
from fastapi.responses import StreamingResponse
import asyncio

app = FastAPI()

async def number_generator():
    for number in range(100):
        yield f"data:{number}\n\n"
        await asyncio.sleep(1)  # Delay between numbers

@app.get("/numbers")
async def number_stream():
    return StreamingResponse(number_generator(), media_type="text/event-stream")
