# 🧪 Laboratorio de Automatización: 
### Jugando con las funcionalidades de GitHub Codespaces

Este repositorio es mi entorno experimental en la nube para dominar la infraestructura **Full Stack**. 
El objetivo principal es levantar un ecosistema automatizado de generación de video con inteligencia artificial utilizando **n8n**, un motor de **Text-to-Speech (TTS)** y un backend personalizado (**NCA-Toolkit**) corriendo sobre Docker integrado en la arquitectura nativa de GitHub Codespaces.

---

## 🛠️ Los Componentes del Laboratorio

Tengo el entorno estructurado en tres scripts bash (`.sh`) automatizados que resuelven problemas reales de compatibilidad, manejo de memoria y sockets en entornos Cloud:

### 1. `n8n_instala.sh` (El Motor de Flujos)
*   **Qué hace:** Repara dependencias del contenedor de Codespaces (como repositorios rotos de Yarn), instala Node.js v20 y configura de manera global y limpia **PNPM** para inyectar y arrancar **n8n** sin colisiones de rutas.
*   **Optimización Full Stack:** Modifica las variables de entorno de Node (`--max-old-space-size=4096`) para asegurar que n8n corra con un límite de memoria controlado, evita la acumulación de archivos basura en ejecuciones con error y expone automáticamente el puerto `5678` de manera pública en Codespaces usando el CLI de GitHub (`gh codespace`).

### 2. `n8n_AIVideos01.sh` (El Reparador de Infraestructura para Nube)
*   **Qué hace:** Diseñado específicamente para entornos DevContainers/Codespaces donde no existe `systemd`. Bypassesa el inicio tradicional de servicios de Linux y levanta el demonio de Docker en segundo plano (`dockerd`) forzando los permisos de comunicación sobre el socket `/var/run/docker.sock`.
*   **Resultado:** Levanta una red interna segura en Docker (`video_automation_net`), descarga el contenedor del servidor de voz `Coqui TTS` en el puerto `5002` y compila en caliente el backend de video.

### 3. `n8n_AIVideos02.sh` (La Factoría de APIs de Video)
*   **Qué hace:** Genera en tiempo de ejecución un entorno de desarrollo local con un `Dockerfile` optimizado y un microservidor escrito en **Python + FastAPI**.
*   **Simulación Real:** Compila la imagen local `local/nca-toolkit:latest` metiéndole **FFmpeg nativo**, exponiendo los endpoints críticos en el puerto `9090` que n8n va a consumir:
    *   `POST /v1/image/transform/video` (Efectos de animación de imágenes).
    *   `POST /v1/video/concatenate` (Unión de clips dinámicos).
    *   `POST /v1/ffmpeg/compose` (Mezcla final de video, audio de voz y subtítulos).

---

## 🚦 Estado Actual del Entorno

```bash
@manfredialdo ➜ /workspaces/EntornoWordpress (main) $ ls
n8n_AIVideos01.sh  n8n_AIVideos02.sh  n8n_instala.sh  README.md