from fastapi import FastAPI, Request, Form
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from starlette import status
from starlette.middleware.sessions import SessionMiddleware
from dotenv import load_dotenv
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.orm import declarative_base, sessionmaker, Session
from fastapi import Depends
import os


load_dotenv()


engine = create_engine(
    "sqlite:///chamados.db",
    connect_args={"check_same_thread": False}
)

Base = declarative_base()

Session_Local = sessionmaker(bind=engine)

class chamado(Base):
    __tablename__ = "Chamados"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    nome = Column(String, nullable=False)
    email = Column(String, nullable=False)
    telefone = Column(String, nullable=False)
    descricao = Column(String, nullable=False)

Base.metadata.create_all(bind=engine)

def get_db():
    db = Session_Local()
    try:
        yield db
    finally:
        db.close()


app = FastAPI()

app.add_middleware(SessionMiddleware, secret_key=os.getenv("SECRET_KEY"))

app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")

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
    descricao: str = Form(...),
    db: Session = Depends(get_db)
):

    novo_chamado = chamado(nome=nome, email=email, telefone=telefone, descricao=descricao)
    db.add(novo_chamado)
    db.commit()
    
    return RedirectResponse(url="/", status_code=status.HTTP_303_SEE_OTHER)



@app.get("/login", response_class=HTMLResponse)
async def login_page(request: Request):
    return templates.TemplateResponse("login.html", {"request": request})



@app.get("/dashboard", response_class=HTMLResponse)
async def dashboard_page(request: Request, db: Session = Depends(get_db)):
    if not request.session.get("logado"):
        return RedirectResponse(url="/login", status_code=status.HTTP_302_FOUND)
 
    todos_os_chamados = db.query(chamado).all()
    return templates.TemplateResponse(
        "dashboard.html",
        {"request": request, "todos_os_chamados": todos_os_chamados}
    )



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