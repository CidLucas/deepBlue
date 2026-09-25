# Capability: Memória e dados — textos

**Kit técnico:** `memory_api` · `blu_rag_factory` · `blu_data_connectors` · `blu_db_connector` · `blu_supabase_client` · `memory_contract`
**Alinhamento:** mindmap §4 (orquestração com contexto) · §3 (dados em tempo real)
**Dores que ataca:** D2 · D4

## O que é (ferramenta técnica)

A infraestrutura que dá contexto a tudo: memória corporativa de longo prazo,
busca semântica (RAG) sobre os documentos da empresa e conectores de dados
(SQL, Supabase, planilhas, CRMs). Qualquer agente ou assistente que a gente
cria consulta essa camada antes de responder.

## One-liner

Memória e dados: o contexto da empresa, disponível para qualquer agente.

## Parágrafo curto

Memória corporativa de longo prazo, busca semântica nos documentos e conectores
de dados — a camada que dá contexto a agentes e assistentes.

## Parágrafo completo

Toda solução que entregamos usa uma camada de memória e dados: os documentos e
processos da empresa ficam mapeados e buscáveis (busca semântica, RAG), a
memória de longo prazo acumula decisões e contexto, e os conectores puxam dados
das fontes existentes (banco, planilha, CRM). Resultado: o agente responde com
o que a casa sabe, não com texto genérico. Conhecimento isolado deixa de
existir — o que a unidade A aprendeu chega à unidade B.

## O que entrega (bullets)

- Memória corporativa de longo prazo (decisões, contexto, histórico)
- Busca semântica sobre documentos (RAG)
- Conectores de dados: SQL, Supabase, planilhas, CRMs
- Agentes respondem com contexto da casa
- Base para o produto Brain MCP

## Exemplos

- Pergunta "qual a política de reembolso?" → resposta com o doc da política
- "Como a gente fez a proposta da Rastro?" → contexto da memória do projeto
- Conector do banco do cliente → números reais na resposta
