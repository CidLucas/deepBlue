# Matriz de Modelos — Deep Blue (Seleção Final)

**v2.0 · 12/08/2026 · Preços USD · Fontes oficiais + benchmarks coletados em 11–12/08/2026**

> **Objetivo:** definir, por tipo de modelo, o escolhido (main) + 1–2 fallbacks, pesando **custo × qualidade** (benchmarks).
> **Escopo:** LLM grande, LLM médio, STT, embeddings, imagem (geração), visão.
> **Fora de escopo (decisão 12/08):** TTS e geração de vídeo — não vamos ter agora.
> **Unidades:** LLM/visão/embeddings = $/1M tokens · STT = $/hora de áudio · imagem = $/imagem. Conversões marcadas como (derivado).

---

## 1. Resumo da seleção

| Tipo | Main | Fallback 1 | Fallback 2 | Custo referência |
|---|---|---|---|---|
| LLM Grande | **DeepSeek V4 Pro** | **MiniMax M3** | GLM-5.2 (qualidade/código) | $0,44/$0,87 por 1M |
| LLM Médio | **DeepSeek V4 Flash** | **GLM-4.7-Flash** | Qwen 3.7 Flash (custo) | $0,14/$0,28 por 1M |
| STT (transcrição) | **Whisper large-v3-turbo (Groq)** | **Grok STT (xAI)** | GLM-ASR-2512 (Z.AI) | $0,04/hora |
| Embeddings | **Cohere Embed 4 (multimodal)** | **BGE-M3 (HF, self-host)** | OpenAI text-embedding-3-small | $0–0,02 por 1M |
| Imagem (geração) | **GLM-Image (Z.AI)** | **Grok Imagine (xAI)** | Imagen 4 Ultra (Google) | $0,015–0,06/img |
| Visão (compreensão) | **GLM-5V-Turbo (Z.AI)** | **Qwen3-VL 32B** | Gemini 3.5 Flash (nativo) | $0,10–1,20 por 1M |

---

## 2. LLM Grande — main: DeepSeek V4 Pro · fallback: MiniMax M3

| Modelo | Input | Output | Evidência | Veredito |
|---|---|---|---|---|
| **DeepSeek V4 Pro** (main) | $0,435 | $0,87 | 1M ctx; o mais barato entre os top de linha; ⚠️ aumento de preço anunciado oficialmente [5] | escolha de custo; validar benchmark próprio antes de depender |
| **MiniMax M3** (fallback 1) | $0,30 | $1,20 | 1M ctx; mais barato ainda que DeepSeek hoje [7] | fallback natural de custo |
| GLM-5.2 (fallback 2) | $1,40 | $4,40 | Terminal-Bench 2.1: **81,0** (Opus 4.8: 85,0); SWE-bench Pro 62,1; **melhor open-source** em código long-horizon; 1M ctx [8][21] | fallback de **qualidade** p/ tarefas de código/agentes |

**Por quê:** DeepSeek V4 Pro entrega nível frontier pelo menor preço do segmento (verificado na fonte oficial). MiniMax M3 cobre o risco do aumento anunciado da DeepSeek com custo ainda menor. GLM-5.2 entra como terceira opção quando a tarefa exige o melhor código possível (benchmarks verificados vs Opus 4.8/GPT-5.5).

**Custo exemplo (derivado):** 5M input + 1M output/mês → V4 Pro $3,05 · M3 $2,70 · GLM-5.2 $11,40.

---

## 3. LLM Médio — main: DeepSeek V4 Flash · fallback: GLM-4.7-Flash

| Modelo | Input | Output | Evidência | Veredito |
|---|---|---|---|---|
| **DeepSeek V4 Flash** (main) | $0,14 | $0,28 | 1M ctx, 384K max output [5] | escolhido pelo fundador; excelente custo/qualidade |
| **GLM-4.7-Flash** (fallback 1) | $0,06–0,07 | $0,40 | **SOTA open-source entre modelos de porte comparável**; GLM-4.7 base: HLE 42,8% (> GPT-5.1), SWE-bench Verified 73,8%, LiveCodeBench V6 84,9 (open SOTA), τ²-Bench 84,7 (> Sonnet 4.5) [8][21] | fallback com benchmarks mais fortes do segmento |
| Qwen 3.7 Flash (fallback 2) | $0,03 | $0,13 | 1M ctx [7] | fallback de **custo mínimo** p/ rotinas simples |

**Por quê:** DeepSeek Flash mantém consistência de stack com o V4 Pro (mesmo provedor, mesma API). GLM-4.7-Flash é o backup com melhor evidência de qualidade em tamanho comparável. Qwen 3.7 Flash fica como opção ultra-barata para operações triviais.

**Custo exemplo (derivado):** 10M input + 2M output/mês → Flash $1,96 · GLM-Flash $1,50 · Qwen $0,56.

---

## 4. STT — main: Whisper large-v3-turbo (Groq) · fallback: Grok STT

| Serviço | $/hora | Evidência | Veredito |
|---|---|---|---|
| **Groq Whisper large-v3-turbo** (main) | **$0,04** | 216x speed factor, acurácia alta, otimizado p/ volume [6][22] | o mais barato e rápido da categoria |
| **Grok STT (xAI)** (fallback 1) | $0,10 | REST; streaming $0,20/h [20] | fallback de confiança |
| GLM-ASR-2512 (fallback 2) | ≈$0,144 | $0,0024/min [8] | fallback adicional (Z.AI) |
| OpenAI gpt-4o-mini-transcribe | $0,18 | — [1] | 4,5x o custo do main |

**Custo exemplo (derivado):** 100h de áudio/mês → Groq **$4** · Grok $10 · GLM-ASR $14,40 · AssemblyAI (não escolhido) $450.

---

## 5. Embeddings — main: Cohere Embed 4 · fallback: BGE-M3 (HF) · verificação pedida

| Opção | Custo | Evidência | Nota |
|---|---|---|---|
| **Cohere Embed 4 (v4.0)** | instância dedicada: Embed 4 Small $4/h ($2.500/mês), Medium $5/h ($3.250/mês); pay-as-you-go por token a confirmar no console [23][24] | multimodal **texto + imagem**, classificação e busca cross-modal; família embed-v3 multilingual [23] | main se o uso for multimodal; para só texto, avaliar custo por token antes |
| **BGE-M3 (Hugging Face / open)** | self-host ≈ $0 marginal (GPU) | MTEB v2.10.12 (resultados por tarefa na model card); 100+ idiomas, contexto 8.192 [25] | fallback **custo zero**; forte em PT-BR por ser multilíngue |
| OpenAI text-embedding-3-small | $0,02/1M | — [1] | fallback de API mais barato verificado |
| Gemini text embedding | $0,15/1M (batch $0,075) | — [3] | alternativa |

**Recomendação:** se a Deep Blue vai indexar **texto + imagem** (provável no Blue/Fórmula), Cohere Embed 4 é o main. Se for texto puro e prioridade for custo, **BGE-M3 self-host** vence (MTEB sólido, multilíngue, $0 marginal). Verificação pendente: preço por token do Cohere no console (página JS).

---

## 6. Imagem (geração) — main: GLM-Image · fallback: Grok Imagine

| Modelo | $/imagem | Evidência | Veredito |
|---|---|---|---|
| **GLM-Image (Z.AI)** (main) | **$0,015** | arquitetura autoregressive+diffusion, foco em **texto correto na imagem** (posters, PPT, infográficos) [8] | mais barato verificado + forte em conteúdo textual (caso de uso comercial) |
| **Grok Imagine (xAI)** (fallback 1) | $0,02 (quality $0,05) | — [20] | 2ª opção barata |
| Imagen 4 Ultra (fallback 2) | $0,06 | — [4] | qualidade premium Google |
| gpt-image-1-mini | por 1M tokens ($2,50/$8) | — [1] | opção se já estivermos na stack OpenAI |

**Custo exemplo (derivado):** 1.000 imagens/mês → GLM-Image **$15** · Grok $20 · Imagen $60.

---

## 7. Visão (compreensão de imagem) — main: GLM-5V-Turbo · fallback: Qwen3-VL

| Modelo | Input/Output | Evidência | Veredito |
|---|---|---|---|
| **GLM-5V-Turbo (Z.AI)** (main) | $1,20/$4,00 [7] | primeiro modelo open de **coding multimodal**; visão + código + agentes GUI (AndroidWorld, WebVoyager); processa imagem, vídeo, arquivos [21] | main de **qualidade** — benchmarks verificados |
| **Qwen3-VL 32B** (fallback 1) | $0,104/$0,416 [7] | multimodal via OpenRouter; 10x mais barato | fallback de **custo** (validar benchmarks em produção) |
| Gemini 3.5 Flash | $1,50/$9,00 [7] | multimodal nativo Google | fallback 2 (stack Google) |

**Custo exemplo (derivado):** 2M input + 0,5M output/mês → GLM-5V $4,40 · Qwen3-VL $0,42.

---

## 8. Fora de escopo (decisão do fundador — 12/08)

- **TTS (voz sintetizada):** não vamos ter agora. (Referência futura: Grok/OpenAI $15/1M chars, Gemini ≈$5, ElevenLabs premium.)
- **Geração de vídeo:** não vamos ter agora. (Referência futura: Grok Imagine Video $0,05/s, Veo Lite $0,08/s, Sora-2 $0,10/s.)

---

## 9. Riscos e alertas

- ⚠️ **DeepSeek anunciou aumento significativo de preço em breve** [5] — por isso MiniMax M3 e GLM estão como fallbacks prontos.
- **GLM-5.2/4.7 benchmarks** vêm do próprio Z.AI (fonte do fornecedor) — bons como referência, mas validar em produção com casos reais.
- **Cohere per-token** e **Qwen3-VL benchmarks**: pendências de validação (páginas JS).
- Preços válidos para 11–12/08/2026; revisar trimestralmente.

---

## 10. Pendências de validação

- [ ] Cohere Embed 4: preço por token (console)
- [ ] Qwen3-VL 32B: benchmark real (MMMU) em produção
- [ ] DeepSeek V4 Pro: teste de qualidade próprio (raciocínio/agentes) antes de travar como main
- [ ] Benchmark de visão atualizado (MMMU-Pro / MMMU 2026) — leaderboard oficial é JS

---

## Fontes

1. OpenAI Pricing — https://developers.openai.com/api/docs/pricing
2. Anthropic Pricing — https://platform.claude.com/docs/en/about-claude/pricing
3. Google Gemini API Pricing — https://ai.google.dev/gemini-api/docs/pricing
4. Google Cloud (Vertex) Pricing — https://cloud.google.com/gemini-enterprise-agent-platform/generative-ai/pricing
5. DeepSeek Models & Pricing — https://api-docs.deepseek.com/quick_start/pricing
6. GroqCloud Supported Models — https://console.groq.com/docs/models
7. OpenRouter Models API — https://openrouter.ai/api/v1/models
8. Z.AI Pricing / Models — https://docs.z.ai/guides/overview/pricing · https://docs.z.ai/guides/llm/glm-5.2.md · https://docs.z.ai/guides/llm/glm-4.7.md · https://docs.z.ai/guides/image/glm-image.md
9. Moonshot/Kimi Pricing — https://platform.kimi.ai/docs/pricing
10. MiniMax Pricing — https://platform.minimaxi.com/document/pricing
11. AssemblyAI Pricing — https://www.assemblyai.com/pricing
12. Deepgram Pricing — https://deepgram.com/pricing
13. ElevenLabs Pricing — https://elevenlabs.io/pricing
14. Cartesia Pricing — https://docs.cartesia.ai/pricing
15. Replicate Pricing — https://replicate.com/pricing
16. Stability AI Plans — https://stability.ai/brand-studio-plans
17. Runway Pricing — https://runway.com/pricing
18. Hugging Face Pricing — https://huggingface.co/pricing
19. Alibaba Cloud Model Studio — https://www.alibabacloud.com/help/en/model-studio/models
20. xAI Grok Pricing — https://docs.x.ai/docs/models
21. Z.AI GLM-5V-Turbo — https://docs.z.ai/guides/vlm/glm-5v-turbo.md
22. Groq Whisper Large V3 Turbo — https://console.groq.com/docs/model/whisper-large-v3-turbo
23. Cohere Models — https://docs.cohere.com/docs/models
24. Cohere Pricing — https://cohere.com/pricing
25. BGE-M3 (Hugging Face) — https://huggingface.co/BAAI/bge-m3
