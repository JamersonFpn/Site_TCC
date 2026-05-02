from fastapi import FastAPI, Request, Form, Depends
from fastapi.responses import HTMLResponse, RedirectResponse, JSONResponse
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from starlette import status
from starlette.middleware.sessions import SessionMiddleware
from sqlalchemy.orm import Session
from dotenv import load_dotenv
from database import chamado, get_db
from datetime import datetime
from pydantic import BaseModel
import os


load_dotenv()

app = FastAPI()


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.add_middleware(SessionMiddleware, secret_key=os.getenv("SECRET_KEY"))
app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")

ADMIN_USER = os.getenv("ADMIN_USER")
ADMIN_PASS = os.getenv("ADMIN_PASS")



class ChamadoSchema(BaseModel):
    nome: str
    email: str
    telefone: str
    descricao: str

class LoginSchema(BaseModel):
    usuario: str
    senha: str

class StatusSchema(BaseModel):
    status_chamado: str



@app.get("/", response_class=HTMLResponse)
async def home(request: Request):
    sucesso = request.query_params.get("sucesso")
    return templates.TemplateResponse("home.html", {"request": request, "sucesso": sucesso})


@app.get("/cadastro", response_class=HTMLResponse)
async def pagina_cadastro(request: Request):
    return templates.TemplateResponse("cadastro.html", {"request": request})


@app.post("/enviar-chamado")
async def criar_chamado_html(
    nome: str = Form(...),
    email: str = Form(...),
    telefone: str = Form(...),
    descricao: str = Form(...),
    db: Session = Depends(get_db)
):
    novo_chamado = chamado(
        nome=nome, email=email, telefone=telefone,
        descricao=descricao, criado_em=datetime.now(),
        status_chamado="Pendente"
    )
    db.add(novo_chamado)
    db.commit()
    return RedirectResponse(url="/?sucesso=1", status_code=status.HTTP_303_SEE_OTHER)


@app.get("/login", response_class=HTMLResponse)
async def login_page(request: Request):
    return templates.TemplateResponse("login.html", {"request": request})


@app.get("/dashboard", response_class=HTMLResponse)
async def dashboard_page(request: Request, db: Session = Depends(get_db)):
    if not request.session.get("logado"):
        return RedirectResponse(url="/login", status_code=status.HTTP_302_FOUND)
    todos_os_chamados = db.query(chamado).order_by(chamado.criado_em.desc()).all()
    return templates.TemplateResponse(
        "dashboard.html",
        {"request": request, "todos_os_chamados": todos_os_chamados}
    )


@app.post("/login")
async def login_post(request: Request, usuario: str = Form(...), senha: str = Form(...)):
    if usuario.strip() == ADMIN_USER and senha.strip() == ADMIN_PASS:
        request.session["logado"] = True
        return RedirectResponse(url="/dashboard", status_code=status.HTTP_302_FOUND)
    return templates.TemplateResponse(
        "login.html",
        {"request": request, "erro": "Usuário ou senha incorretos."},
        status_code=401
    )


@app.get("/atualizar-status/{chamado_id}")
async def atualizar_status_get(chamado_id: int, request: Request):
    return RedirectResponse(url="/dashboard", status_code=status.HTTP_302_FOUND)


@app.post("/atualizar-status/{chamado_id}")
async def atualizar_status(
    chamado_id: int, request: Request,
    novo_status: str = Form(...), db: Session = Depends(get_db)
):
    if not request.session.get("logado"):
        return RedirectResponse(url="/login", status_code=status.HTTP_302_FOUND)
    status_permitidos = ["Pendente", "Em andamento", "Concluído"]
    if novo_status not in status_permitidos:
        return RedirectResponse(url="/dashboard", status_code=status.HTTP_302_FOUND)
    c = db.query(chamado).filter(chamado.id == chamado_id).first()
    if c:
        c.status_chamado = novo_status
        db.commit()
    return RedirectResponse(url="/dashboard", status_code=status.HTTP_303_SEE_OTHER)


@app.post("/remover-chamado/{chamado_id}")
async def remover_chamado(
    chamado_id: int, request: Request, db: Session = Depends(get_db)
):
    if not request.session.get("logado"):
        return RedirectResponse(url="/login", status_code=status.HTTP_302_FOUND)
    c = db.query(chamado).filter(chamado.id == chamado_id).first()
    if c:
        db.delete(c)
        db.commit()
    return RedirectResponse(url="/dashboard", status_code=status.HTTP_303_SEE_OTHER)


@app.get("/logout")
async def logout(request: Request):
    request.session.clear()
    return RedirectResponse(url="/login", status_code=status.HTTP_302_FOUND)



@app.post("/api/chamados")
async def api_criar_chamado(dados: ChamadoSchema, db: Session = Depends(get_db)):
    novo = chamado(
        nome=dados.nome, email=dados.email,
        telefone=dados.telefone, descricao=dados.descricao,
        criado_em=datetime.now(), status_chamado="Pendente"
    )
    db.add(novo)
    db.commit()
    db.refresh(novo)
    return {"mensagem": "Chamado enviado com sucesso!", "id": novo.id}


@app.post("/api/login")
async def api_login(dados: LoginSchema):
    if dados.usuario.strip() == ADMIN_USER and dados.senha.strip() == ADMIN_PASS:
        return {"autenticado": True}
    return JSONResponse(status_code=401, content={"autenticado": False, "erro": "Credenciais inválidas"})


@app.get("/api/chamados")
async def api_get_chamados(db: Session = Depends(get_db)):
    chamados = db.query(chamado).order_by(chamado.criado_em.desc()).all()
    return [
        {
            "id": c.id,
            "nome": c.nome,
            "email": c.email,
            "telefone": c.telefone,
            "descricao": c.descricao,
            "criado_em": c.criado_em.strftime("%d/%m/%Y %H:%M"),
            "status_chamado": c.status_chamado,
        }
        for c in chamados
    ]


@app.patch("/api/chamados/{chamado_id}")
async def api_atualizar_status(
    chamado_id: int, dados: StatusSchema, db: Session = Depends(get_db)
):
    c = db.query(chamado).filter(chamado.id == chamado_id).first()
    if not c:
        return JSONResponse(status_code=404, content={"erro": "Chamado não encontrado"})
    c.status_chamado = dados.status_chamado
    db.commit()
    return {"mensagem": "Status atualizado com sucesso!"}


@app.delete("/api/chamados/{chamado_id}")
async def api_remover_chamado(chamado_id: int, db: Session = Depends(get_db)):
    c = db.query(chamado).filter(chamado.id == chamado_id).first()
    if not c:
        return JSONResponse(status_code=404, content={"erro": "Chamado não encontrado"})
    db.delete(c)
    db.commit()
    return {"mensagem": "Chamado removido com sucesso!"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)