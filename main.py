from fastapi import FastAPI, Request, Form
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from starlette import status
from starlette.middleware.sessions import SessionMiddleware
from dotenv import load_dotenv
import os




load_dotenv()

app = FastAPI()

app.add_middleware(SessionMiddleware, secret_key=os.getenv("SECRET_KEY"))

app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")

chamados = []

ADMIN_USER = os.getenv("ADMIN_USER")
ADMIN_PASS = os.getenv("ADMIN_PASS")



@app.get("/", response_class=HTMLResponse)
async def home(request: Request):
    return templates.TemplateResponse("home.html", {"request": request})



@app.get("/cadastro", response_class=HTMLResponse)
async def pagina_cadastro(request: Request):
    return templates.TemplateResponse("cadastro.html", {"request": request})



@app.post("/enviar-chamado")
async def criar_chamado(
    nome: str = Form(...),
    email: str = Form(...),
    telefone: str = Form(...),
    descricao: str = Form(...)
):
    novo_chamado = {
        "id": len(chamados) + 1,
        "nome": nome,
        "email": email,
        "telefone": telefone,
        "descricao": descricao
    }
    chamados.append(novo_chamado)
    return RedirectResponse(url="/", status_code=status.HTTP_303_SEE_OTHER)



@app.get("/login", response_class=HTMLResponse)
async def login_page(request: Request):
    return templates.TemplateResponse("login.html", {"request": request})



@app.get("/dashboard", response_class=HTMLResponse)
async def dashboard_page(request: Request):
    if not request.session.get("logado"):
        return RedirectResponse(url="/login", status_code=status.HTTP_302_FOUND)
    
    return templates.TemplateResponse("dashboard.html", {"request": request, "todos_os_chamados": chamados})



@app.post("/login", response_class=HTMLResponse)
async def login_post(
    request: Request,
    usuario: str = Form(...),
    senha: str = Form(...)
):
    if usuario.strip() == ADMIN_USER and senha.strip() == ADMIN_PASS:
        request.session["logado"] = True
        return RedirectResponse(url="/dashboard", status_code=status.HTTP_302_FOUND)
 
    return templates.TemplateResponse(
        "login.html",
        {"request": request, "erro": "Usuário ou senha incorretos."},
        status_code=401
    )



@app.get("/logout")
async def logout(request: Request):
    request.session.clear()
    return RedirectResponse(url="/login", status_code=status.HTTP_302_FOUND)



if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)