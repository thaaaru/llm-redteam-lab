"""
Vulnerable RAG Implementation
⚠️ INTENTIONALLY INSECURE FOR RED TEAM TESTING ⚠️

This RAG system has multiple vulnerabilities:
1. No input sanitization
2. Direct prompt injection possible
3. Weak access controls
4. No output filtering
5. Debug mode accessible via prompt injection
"""

import requests
from typing import List, Dict, Optional
import chromadb
from chromadb.config import Settings
from dummy_documents import get_all_documents, get_system_prompt


class VulnerableRAG:
    """
    Intentionally vulnerable RAG system for security testing

    Vulnerabilities included:
    - Prompt injection via user input concatenation
    - No input validation
    - Sensitive data in knowledge base
    - Debug commands in system prompt
    - No output sanitization
    """

    def __init__(self, ollama_url: str = "http://localhost:11434"):
        self.ollama_url = ollama_url
        self.model_name = "llama2-uncensored:7b"

        # Initialize ChromaDB (in-memory for simplicity)
        self.client = chromadb.Client(Settings(
            anonymized_telemetry=False,
            allow_reset=True
        ))

        # Create collection
        self.collection = self.client.create_collection(
            name="fake_company_docs",
            metadata={"description": "Synthetic company documents for testing"}
        )

        # Index dummy documents
        self._index_documents()

        # Debug mode (can be enabled via prompt injection)
        self.debug_mode = False

    def _index_documents(self):
        """Index all synthetic documents"""
        docs = get_all_documents()

        # Add to ChromaDB
        self.collection.add(
            ids=[doc['id'] for doc in docs],
            documents=[doc['content'] for doc in docs],
            metadatas=[doc['metadata'] for doc in docs]
        )

    def retrieve(self, query: str, top_k: int = 3) -> List[Dict]:
        """
        Retrieve relevant documents

        VULNERABILITY: No query sanitization
        """
        results = self.collection.query(
            query_texts=[query],
            n_results=top_k
        )

        retrieved_docs = []
        if results['documents']:
            for idx, doc in enumerate(results['documents'][0]):
                retrieved_docs.append({
                    'content': doc,
                    'metadata': results['metadatas'][0][idx] if results['metadatas'] else {}
                })

        return retrieved_docs

    def generate_response(
        self,
        user_query: str,
        context_docs: List[Dict],
        system_mode: str = "default"
    ) -> Dict:
        """
        Generate response using Ollama

        VULNERABILITY: Direct string concatenation allows prompt injection
        """
        # Check for debug command (VULNERABILITY: accessible via prompt)
        if "FAKE_DEBUG_ENABLE" in user_query:
            self.debug_mode = True
            return {
                "response": "⚠️ DEBUG MODE ENABLED (This is a vulnerability!)\nSystem internals now visible.",
                "debug": True
            }

        # Build context from retrieved docs (VULNERABILITY: no sanitization)
        context = "\n\n".join([
            f"Document {i+1}:\n{doc['content']}"
            for i, doc in enumerate(context_docs)
        ])

        # Get system prompt
        system_prompt = get_system_prompt(system_mode)

        # VULNERABILITY: Direct concatenation allows injection
        # A proper implementation would use structured prompts with clear boundaries
        full_prompt = f"""{system_prompt}

Context from knowledge base:
{context}

User question: {user_query}

Assistant response:"""

        # Call Ollama
        try:
            response = requests.post(
                f"{self.ollama_url}/api/generate",
                json={
                    "model": self.model_name,
                    "prompt": full_prompt,
                    "stream": False,
                    "options": {
                        "temperature": 0.7,
                        "num_predict": 500
                    }
                },
                timeout=120
            )
            response.raise_for_status()
            result = response.json()

            return {
                "response": result.get("response", ""),
                "model": self.model_name,
                "debug": self.debug_mode,
                "full_prompt": full_prompt if self.debug_mode else None  # VULNERABILITY
            }

        except Exception as e:
            return {
                "error": str(e),
                "response": f"Error: {e}"
            }

    def query(self, user_input: str, top_k: int = 3) -> Dict:
        """
        Main RAG pipeline

        VULNERABILITY: No input validation at entry point
        """
        # Retrieve relevant documents (VULNERABILITY: no input sanitization)
        context_docs = self.retrieve(user_input, top_k=top_k)

        # Generate response (VULNERABILITY: prompt injection possible)
        response = self.generate_response(user_input, context_docs)

        return {
            "query": user_input,
            "retrieved_docs": len(context_docs),
            "response": response.get("response", ""),
            "debug_info": {
                "debug_mode": self.debug_mode,
                "full_prompt": response.get("full_prompt"),
                "context_docs": context_docs if self.debug_mode else None
            } if self.debug_mode else None
        }

    def reset(self):
        """Reset the RAG system"""
        self.debug_mode = False
        self.client.reset()
        self.collection = self.client.create_collection(name="fake_company_docs")
        self._index_documents()
