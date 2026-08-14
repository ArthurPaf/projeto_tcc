from fastapi import FastAPI


# A instancia da aplicacao. O titulo aparece na pagina /docs.

app = FastAPI(title="API do Meu Projeto", version="0.1.0")



# O decorador diz: "esta funcao atende GET na raiz".

@app.get("/Eventos")

def listar_eventos():

    return [

        {"id": 1, "nome": "Festa1", "barraca": "espetinho", "status": "em andamento"},

        {"id": 2, "nome": "Festa2", "barraca": "bebidas", "status": "concluido"},

    ]