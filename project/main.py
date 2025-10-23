from fastapi import FastAPI, HTTPException, File, UploadFile
from fastapi.responses import FileResponse

from typing import Annotated, Optional

from pathlib import Path
import shutil
import os
import tempfile
import asyncio

from schemas import UniqueIdGenerator

import os
import uvicorn


app = FastAPI()

FILE_EXTENSIONS = (".step", ".stl", ".obj")
BASE_DIR = Path("result_files")
BASE_DIR.mkdir(exist_ok=True)

generator = UniqueIdGenerator()


async def wait_for_file(old_file_name: str, new_extension: str = ".color", check_interval: float = 2.0) -> tuple:
    new_file = old_file_name + new_extension

    file_path = BASE_DIR / new_file

    while not file_path.exists():
        await asyncio.sleep(check_interval)

    return (str(file_path), new_file)


@app.get("/color")
async def get_file(filename: str, path_to_temp: Optional[str] = None) -> FileResponse:
    if not (filename.lower().endswith(FILE_EXTENSIONS)):
        raise HTTPException(status_code=404, detail="The file has an incorrect extension.")

    if path_to_temp != None:
        path_to_file = Path(path_to_temp)
    else:
        path_to_file = Path(filename)
    
    extension = os.path.splitext(filename)[1]

    new_file_base = generator.generate_uuid()
    full_file_name = new_file_base + extension

    target_path = BASE_DIR / full_file_name
    shutil.move(path_to_file, target_path)

    new_extension_file_path, new_file_name = await wait_for_file(new_file_base)

    return FileResponse(path=new_extension_file_path, filename=new_file_name)


@app.post("/color_file")
async def upload_file(
    file: Annotated[UploadFile, 
    File(description="File of obj, step, stl extensions")]
    ) -> FileResponse:

    with tempfile.TemporaryDirectory() as tmpdir:
        file_path = os.path.join(tmpdir, file.filename)
        content = await file.read()
        with open(file_path, 'wb') as f:
            f.write(content)

        result = await get_file(file.filename, file_path)

        return result
    

if __name__ == "__main__":
    print("Starting FastAPI Server from main.exe")
    print("=" * 50)
    
    try:
        uvicorn.run(
            app=app,  
            host="0.0.0.0",
            port=8000,
            reload=False,
            log_level="info"
        )
    except KeyboardInterrupt:
        print("\n Server stopped by user")
    except Exception as e:
        print(f" Error starting server: {e}")
        input("Press Enter to exit...")