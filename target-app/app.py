"""
Vulnerable RAG Application - FastAPI Server
⚠️ FOR RED TEAM TESTING ONLY ⚠️

This application is INTENTIONALLY VULNERABLE for security research.
DO NOT use in production or with real data.
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
import uvicorn
from vulnerable_rag import VulnerableRAG

# Warning banner
BANNER = """
╔══════════════════════════════════════════════════════════════╗
║  ⚠️  RED TEAM LAB - VULNERABLE APPLICATION ⚠️                ║
║                                                              ║
║  This application is INTENTIONALLY INSECURE                  ║
║  For defensive security research ONLY                        ║
║  Uses SYNTHETIC DATA - No real credentials or PII            ║
╚══════════════════════════════════════════════════════════════╝
"""

print(BANNER)

# Initialize FastAPI app
app = FastAPI(
    title="Vulnerable RAG API - Red Team Lab",
    description="Intentionally vulnerable RAG system for security testing",
    version="1.0.0-REDTEAM"
)

# VULNERABILITY: Wide-open CORS (allows attacks from any origin)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # INSECURE: Allows any origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize vulnerable RAG system
rag = VulnerableRAG()


class QueryRequest(BaseModel):
    """Request model for RAG queries"""
    query: str
    top_k: Optional[int] = 3
    # VULNERABILITY: No input validation on these fields
    system_mode: Optional[str] = "default"
    debug: Optional[bool] = False


class QueryResponse(BaseModel):
    """Response model for RAG queries"""
    query: str
    response: str
    retrieved_docs: int
    debug_info: Optional[dict] = None


@app.get("/")
async def root():
    """Root endpoint with warning"""
    return {
        "message": "Vulnerable RAG API - Red Team Lab",
        "warning": "⚠️ INTENTIONALLY INSECURE - FOR TESTING ONLY ⚠️",
        "endpoints": {
            "query": "POST /query - Submit RAG query",
            "health": "GET /health - Health check",
            "reset": "POST /reset - Reset RAG system",
            "docs": "GET /docs - API documentation"
        }
    }


@app.get("/health")
async def health():
    """Health check endpoint"""
    return {
        "status": "operational",
        "warning": "⚠️ VULNERABLE SYSTEM - TESTING ONLY ⚠️",
        "rag_initialized": True,
        "model": rag.model_name
    }


@app.post("/query", response_model=QueryResponse)
async def query_rag(request: QueryRequest):
    """
    Query the vulnerable RAG system

    VULNERABILITIES:
    - No authentication required
    - No rate limiting
    - No input sanitization
    - Prompt injection possible via query field
    - Debug mode accessible
    """
    try:
        # VULNERABILITY: Direct pass-through of user input
        result = rag.query(request.query, top_k=request.top_k)

        # VULNERABILITY: Debug flag can expose internals
        if request.debug or rag.debug_mode:
            result['debug_info'] = {
                "debug_mode": rag.debug_mode,
                "system_mode": request.system_mode,
                "warning": "Debug info exposed - this is a vulnerability!"
            }

        return QueryResponse(
            query=result['query'],
            response=result['response'],
            retrieved_docs=result['retrieved_docs'],
            debug_info=result.get('debug_info')
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/reset")
async def reset_rag():
    """
    Reset the RAG system to initial state

    VULNERABILITY: No authentication required for destructive operation
    """
    try:
        rag.reset()
        return {
            "status": "success",
            "message": "RAG system reset to initial state",
            "warning": "⚠️ No auth required - this is a vulnerability!"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/admin/config")
async def get_config():
    """
    Expose system configuration

    VULNERABILITY: Sensitive configuration exposed without authentication
    """
    return {
        "warning": "⚠️ UNAUTHENTICATED ADMIN ENDPOINT - VULNERABILITY!",
        "model": rag.model_name,
        "ollama_url": rag.ollama_url,
        "debug_mode": rag.debug_mode,
        "collection_count": rag.collection.count(),
        "fake_credentials": {
            "note": "These are synthetic test credentials",
            "admin_token": "FAKE_ADMIN_TOKEN_xyz123",
            "api_key": "FAKE_API_KEY_abc789"
        }
    }


@app.post("/admin/debug")
async def enable_debug(enabled: bool = True):
    """
    Enable/disable debug mode

    VULNERABILITY: No authentication for privileged operation
    """
    rag.debug_mode = enabled
    return {
        "warning": "⚠️ NO AUTH REQUIRED - VULNERABILITY!",
        "debug_mode": rag.debug_mode,
        "message": f"Debug mode {'enabled' if enabled else 'disabled'}"
    }


if __name__ == "__main__":
    print("\n🔴 Starting Vulnerable RAG Application...")
    print("   API Documentation: http://localhost:8000/docs")
    print("   Health Check: http://localhost:8000/health")
    print("\n")

    uvicorn.run(
        app,
        host="127.0.0.1",  # Localhost only for safety
        port=8000,
        log_level="info"
    )
