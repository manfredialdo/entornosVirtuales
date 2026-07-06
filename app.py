from flask import Flask, render_template, request, jsonify
import requests

app = Flask(__name__)

# URL por defecto de la API local de Ollama
OLLAMA_API_URL = "http://localhost:11434/api/generate"
# Nombre del modelo que descargamos en el script anterior
MODEL_NAME = "llama3.2:1b"

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/ask", methods=["POST"])
def ask_ollama():
    # Obtenemos la pregunta del usuario desde el frontend
    user_prompt = request.json.get("prompt", "")
    
    if not user_prompt:
        return jsonify({"error": "El prompt no puede estar vacío"}), 400

    # Cuerpo de la petición para Ollama (desactivamos stream para simplificar)
    payload = {
        "model": MODEL_NAME,
        "prompt": user_prompt,
        "stream": False
    }

    try:
        # Hacemos la consulta a Ollama
        response = requests.post(OLLAMA_API_URL, json=payload, timeout=None)
        response.raise_for_status() # Lanza error si el status no es 200
        
        # Extraemos el texto de la respuesta de Ollama
        ollama_data = response.json()
        ai_response = ollama_data.get("response", "No se recibió respuesta del modelo.")
        
        return jsonify({"response": ai_response})

    except requests.exceptions.RequestException as e:
        return jsonify({"error": f"Error al conectar con Ollama: {str(e)}"}), 500

if __name__ == "__main__":
    # Escuchamos en el puerto 5000, visible en Codespaces
    app.run(host="0.0.0.0", port=5000, debug=True)