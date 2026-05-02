from sqlalchemy import create_engine, Column, Integer, String, DateTime
from sqlalchemy.orm import declarative_base, sessionmaker, Session
from datetime import datetime




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
    criado_em = Column(DateTime, default=datetime.now)
    status_chamado = Column(String, default="Pendente")


Base.metadata.create_all(bind=engine)


def get_db():
    db = Session_Local()
    try:
        yield db
    finally:
        db.close()