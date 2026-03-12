from fastapi import FastAPI, Request, Form, Depends, HTTPException
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from starlette import status

app = FastAPI()

app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")

chamados = []

ADMIN_USER = "adminAPS"
ADMIN_PASS = "Superac123"

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

@app.route("/dashboard", methods=["GET", "POST"])
async def dashboard(
    request: Request,
    usuario: str = Form(None),
    senha: str = Form(None)
):
    
    u_limpo = str(usuario).strip()
    p_limpo = str(senha).strip()


    if u_limpo == ADMIN_USER and p_limpo == ADMIN_PASS:
        return templates.TemplateResponse("dashboard.html", {"request": request, "chamados": chamados})
    else:
        print(f"ERRO DE LOGIN - Recebido: '{usuario}' / Esperado: '{ADMIN_USER}'")
        return HTMLResponse(content="<h1>Acesso Negado</h1><p>Usuário ou senha incorretos.</p><a href='/login'>Tentar novamente</a>", status_code=401)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)