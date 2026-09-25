# Catálogo de Modelos de IA — Deep Blue

**v1.1 · Coletado em 11/08/2026 · Preços em USD (exceto indicado) · Fontes oficiais de cada fornecedor**

> **Uso:** referência para escolher o modelo certo por tarefa nas nossas aplicações (Blue, Fórmula, etc.) e insumo para o futuro serviço LLM da Deep Blue.
> **Estratégia:** modelo pequeno para operações simples (custo baixo, alta vazão); modelo grande só quando a tarefa exige.

## Unidades padronizadas (v1.1)

Para comparar direto, **todas as linhas foram convertidas para uma única unidade por categoria**:

| Categoria | Unidade padrão | Exceção/nota |
|---|---|---|
| LLM | $ por 1M tokens (input/output) | nativa de todos os fornecedores |
| Transcrição (STT) | **$ por 1 hora de áudio** | convertido de min/seg |
| Voz (TTS) | **$ por 1M caracteres** | conversão token→char usa 1 token ≈ 4 caracteres [derivado] |
| Agentes de voz | $ por minuto | nativa |
| Imagem | $ por imagem | gpt-image é por 1M tokens (sinalizado) |
| Vídeo | $ por segundo gerado | planos em $/mês |
| Embeddings | $ por 1M tokens | nativa |
| Planos | **$ por mês** | anual mostrado como desconto quando publicado |

- Valores sem marcação = nativos da fonte. Valores com **(≈)** ou **(derivado)** = conversão com premissa explícita.
- Câmbio usado: ¥1 ≈ US$0,14. [derivado]
- STT: 1 hora = 60 min = 3.600 s.

---

## 1. LLMs — $ por 1M tokens (input / output)

### 1.1 Grandes / topo de linha (raciocínio complexo, agentes, código)

| Modelo | Fornecedor | Input | Output | Contexto | Nota |
|---|---|---|---|---|---|
| GPT-5.6 Sol | OpenAI | $5,00 | $30,00 | 1,05M | flagship atual [1] |
| GPT-5.5 / 5.5 Pro | OpenAI | $5 / $30 | $30 / $180 | 272K | [1] |
| Claude Fable 5 | Anthropic | $10 | $50 | — | topo Anthropic [2] |
| Claude Mythos 5 | Anthropic | $10 | $50 | — | disponibilidade limitada [2] |
| Claude Opus 5 | Anthropic | $5 | $25 | — | [2] |
| Gemini 3.1 Pro (preview) | Google | $2,00 | $12,00 | 1M | [3][7] |
| Gemini 3.6 Flash | Google | $1,50 | $7,50 | 1M | [7] |
| Grok 4.5 | xAI | $2,00 | $6,00 | 500K | acima de 200K prompt: $4/$12 [20] |
| Kimi K3 | Moonshot (CN) | $3,00 | $15,00 | 1M | [7] |
| GLM-5.2 | Z.AI (CN) | $1,40 | $4,40 | — | [8] |
| DeepSeek V4 Pro | DeepSeek | $0,435 | $0,87 | 1M | ⚠️ aumento de preço anunciado [5] |
| MiniMax M3 | MiniMax (CN) | $0,30 | $1,20 | 1M | batch $0,15/$0,60 [7] |

### 1.2 Médios (custo x qualidade — agentes, tool calls, rotinas)

| Modelo | Fornecedor | Input | Output | Nota |
|---|---|---|---|---|
| GPT-5.2 | OpenAI | $1,75 | $14,00 | [1] |
| Claude Sonnet 5 | Anthropic | $2,00 | $10,00 | preço introdutório virou padrão [2] |
| Gemini 3.5 Flash | Google | $1,50 | $9,00 | 1M ctx [7] |
| Grok 4.3 | xAI | $1,25 | $2,50 | 1M ctx; >200K prompt: $2,50/$5 [20] |
| DeepSeek V4 Flash | DeepSeek | $0,14 | $0,28 | ⚠️ aumento anunciado; 1M ctx [5] |
| Kimi K2.7 Code | Moonshot (CN) | $0,70 | $3,50 | [7] |
| GLM-4.7 | Z.AI (CN) | $0,60 | $2,20 | cache $0,11 [8] |
| Llama 3.3 70B | Meta (via Groq) | $0,59 | $0,79 | 280 t/s [6] |
| GPT-OSS 120B | OpenAI (open) | $0,15 | $0,60 | via Groq, 500 t/s [6] |
| MiniMax M2.5 | MiniMax (CN) | $0,22 | $0,90 | [7] |
| ERNIE 4.5 VL 424B | Baidu (CN) | $0,42 | $1,25 | multimodal [7] |
| Hunyuan A13B | Tencent (CN) | $0,14 | $0,57 | [7] |

### 1.3 Pequenos / custo-otimizado (operações simples, extração, classificação, alto volume)

| Modelo | Fornecedor | Input | Output | Nota |
|---|---|---|---|---|
| GPT-5 Nano | OpenAI | $0,05 | $0,40 | batch $0,025/$0,20; 400K ctx [1][7] |
| GPT-5.6 Luna | OpenAI | $0,20 | $1,20 | [1] |
| Gemini 2.5 Flash-Lite | Google | $0,10 | $0,40 | 1M ctx; batch $0,05/$0,20 [3][7] |
| Gemini 3.1 Flash-Lite | Google | $0,25 | $1,50 | 1M ctx [7] |
| Qwen 3.7 Flash | Alibaba (CN) | $0,03 | $0,13 | via OpenRouter; 1M ctx [7] |
| GLM-4.7 Flash / FlashX | Z.AI (CN) | $0,06–0,07 | $0,40 | [7][8] |
| Llama 3.1 8B | Meta (via Groq) | $0,05 | $0,08 | 560 t/s [6] |
| GPT-OSS 20B | OpenAI (open) | $0,075 | $0,30 | 1.000 t/s via Groq [6]; `:free` no OpenRouter [7] |
| Ministral 3B / 8B | Mistral | $0,10 | $0,10–0,15 | [7] |
| Grok 4.20 reasoning | xAI | $1,25 | $2,50 | 1M ctx [20] |
| Nemotron 3.5 Lightning | NVIDIA | $0,10 | $0,25 | `:free` disponível [7] |
| Gemma 4 26B/31B | Google (open) | grátis (self-host) | — | `:free` no OpenRouter [7] |

**Grátis no OpenRouter** (uso dev/teste): `openrouter/free`, `openai/gpt-oss-20b:free`, `google/gemma-4-26b-a4b-it:free`, `nvidia/nemotron-3.5-lightning:free`, etc. [7]

---

## 2. Transcrição de áudio (STT) — $ por 1 HORA de áudio

| Serviço | Modelo | $/hora | $/min nativo | Nota |
|---|---|---|---|---|
| Groq | Whisper large-v3-turbo | **$0,04** | — | o mais barato da categoria — ideal p/ volume (ex.: Fórmula) [6] |
| xAI | Grok Speech-to-Text | **$0,10** | — | REST; streaming $0,20/h [20] |
| Cartesia | Ink-Whisper | ≈$0,14–0,18 (derivado) | 1 crédito/s | base Pro 100k créditos/$5 [14] |
| OpenAI | gpt-4o-mini-transcribe | $0,18 | $0,003/min | + diarização $1,25/$5,00 [1] |
| OpenAI | gpt-transcribe | $0,27 | $0,0045/min | [1] |
| OpenAI | Whisper (legado) | $0,36 | $0,006/min | [1] |
| Deepgram | Nova-3 | $0,39 | $0,0065/min | 45+ idiomas, diarização, Whisper Cloud [12] |
| OpenAI | Live transcription | $1,02 | $0,017/min | tempo real [1] |
| Groq | Whisper large-v3 | $0,111 | — | [6] |
| AssemblyAI | Universal-3.5 | **$4,50** | $0,075/min | diarização +$0,02/h; realtime $0,12/h [11] |
| ElevenLabs | Speech-to-Text | ≈$11 (derivado) | 330 créditos/min | plano Pro: 600k créditos/$99 [13] |
| Gemini API | áudio nativo | n/a (token) | — | entrada de áudio paga como token [3] |

**Ranking de custo/hora:** Groq $0,04 < Grok $0,10 < Cartesia ≈$0,15 < OpenAI mini $0,18 < Deepgram $0,39 < AssemblyAI $4,50.

---

## 3. Voz / TTS — $ por 1 MILHÃO de caracteres

| Serviço | Modelo | $/1M chars | Preço nativo | Nota |
|---|---|---|---|---|
| OpenAI | tts-1 | $15 | $15/1M chars | [1] |
| xAI | Grok Text-to-Speech | $15 | $15/1M chars | [20] |
| OpenAI | gpt-4o-mini-tts | ≈$3 (derivado) | $12/1M tokens áudio | 1 token ≈ 4 chars [1] |
| Google | Gemini TTS (Speech) | ≈$5 (derivado) | $20/1M tokens áudio | texto in $1/1M [3] |
| OpenAI | gpt-audio-mini | ≈$5 (derivado) | $10 in/$20 out (áudio) | texto $0,60 [1] |
| Groq | Orpheus V1 English | $22 | $22/1M chars | [6] |
| OpenAI | tts-1-hd | $30 | $30/1M chars | [1] |
| MiniMax | T2A v2 Turbo (CN) | ≈$25 (derivado) | ¥360/2M chars | ¥1≈$0,14 [10] |
| Cartesia | Sonic TTS | ≈$39–50 (derivado) | ~1 crédito/caractere | clone Pro 1,5 crédito/char [14] |
| ElevenLabs | V2 Multilingual e afins | ≈$165–200 (derivado) | 1 crédito/caractere | premium; Pro: 600k créditos/$99 [13] |

**Agentes de voz (por minuto):**
- xAI Grok speech-to-speech: $0,05/min ($3/h) — voz 1.0; $0,08/min ($4,80/h) — voz 2.0; texto $0,004 [20]
- Cartesia: agente $0,06/min + telefonia $0,014/min [14]
- Google speech-to-speech: $3,50/1M tokens ou $0,0053/min [3]

---

## 4. Imagem — $ por imagem

| Modelo | Fornecedor | $/imagem | Nota |
|---|---|---|---|
| Grok Imagine | xAI | **$0,02** (standard) / $0,05 (quality) | o mais barato da categoria [20] |
| Imagen 4 Ultra | Google | $0,06 | [4] |
| Imagen 4 | Google | $0,039 (1K) / $0,067 (1K–2K) / $0,12 (4K) | [3][4] |
| Gemini 3.1 Flash Image | Google | ≈$0,0336 / 1K imagens | $30/1M tokens-img [3] |
| gpt-image-2 | OpenAI | n/a (por 1M tokens) | $8 in / $30 out por 1M tokens-img [1] |
| gpt-image-1.5 | OpenAI | n/a (por 1M tokens) | $8 / $32 [1] |
| gpt-image-1-mini | OpenAI | n/a (por 1M tokens) | $2,50 / $8 — opção barata p/ app [1] |
| Stable Diffusion / Flux | Stability / open | self-host grátis | planos créditos: $19/mês (2k), $50/mês (5k) [16] |
| Flux e modelos abertos | Replicate | billing por hardware (segundos de GPU) | [15] |

---

## 5. Vídeo — $ por SEGUNDO gerado

| Modelo | Fornecedor | $/segundo | Nota |
|---|---|---|---|
| Grok Imagine Video | xAI | **$0,05** | v1.5: $0,08/s [20] |
| Veo 3.1 Lite | Google | $0,08–0,10 (4K $0,25) | [4] |
| Sora-2 | OpenAI | $0,10 (720p) | batch $0,05 [1] |
| Veo 3.1 Fast | Google | $0,20 (4K $0,40; +áudio até $0,60) | [4] |
| Sora-2 Pro | OpenAI | $0,30 (720p) / $0,50 (1024p) / $0,70 (1080p) | batch $0,15/0,25/0,35 [1] |
| Runway (Gen-4.5, Kling 3.0, Seedance, Nano Banana) | Runway | planos, ver §8 | [17] |
| MiniMax H3 | MiniMax (CN) | API (novo modelo de vídeo) | [10] |

---

## 6. Embeddings — $ por 1M tokens

| Modelo | Fornecedor | $/1M | Nota |
|---|---|---|---|
| text-embedding-3-small | OpenAI | $0,02 | o mais barato [1] |
| text-embedding-3-large | OpenAI | $0,13 | [1] |
| Gemini text embedding | Google | $0,15 (batch $0,075) | [3] |
| Gemini multimodal | Google | $0,20 texto / $0,45 imagem / $6,50 vídeo | [3] |

---

## 7. Agregadores e modelos abertos

- **OpenRouter** — 405 modelos, uma API só; inclui `:free`, batch e fallback entre provedores. Melhor porta de entrada para testar vários fornecedores sem contrato. [7]
- **Hugging Face Inference Providers** — créditos grátis $0,10/mês (PRO $2/mês), pay-as-you-go **sem markup** (repasse direto do fornecedor). [18]
- **Self-host (Ollama / vLLM)** — Llama, Qwen, Phi, Gemma, Mistral: custo marginal ~0 além da GPU. Melhor custo em escala.
- **Alibaba Cloud Model Studio (Qwen)** — API direta via console oficial (página de preços JS; valores Qwen confirmados via OpenRouter). [19]

---

## 8. Planos (mensais vs anuais) — $ por MÊS

| Serviço | Plano | $/mês | Créditos | Nota |
|---|---|---|---|---|
| Runway | Standard | $12 | 7.500 créditos/ano | anual economiza $36/ano (≈$9/mês) [17] |
| Runway | Pro | $28 | 27.000 créditos/ano | anual economiza $84/ano (≈$21/mês) [17] |
| Runway | Max | $76 | 114.000 créditos/ano | anual economiza $228/ano (≈$57/mês) [17] |
| Stability | Creator | $19 | 2.000 créditos/mês | créditos não acumulam [16] |
| Stability | Core | $50 | 5.000 créditos/mês | [16] |
| Cartesia | Free / Pro / Startup / Scale | $0 / $5 / $49 / $299 | 20K / 100K / 1,25M / 8M créditos/mês | agentes pagos à parte [14] |
| ElevenLabs | Free / Starter / Creator / Pro / Scale / Business | $0 / $6 / $22 / $99 / $299 / $990 | 10K / 30K / 121K / 600K / 1,8M / 6M créditos/mês | faturamento mensal ou anual [13] |
| Hugging Face | Free / PRO | $0 / $2 | $0,10 / $2,00 créditos/mês | sem markup [18] |

---

## 9. Chineses — resumo (baixo custo, sem restrição de fornecedor)

| Família | Fornecedor | Modelo barato | Modelo forte |
|---|---|---|---|
| DeepSeek | DeepSeek | V4 Flash $0,14/$0,28 | V4 Pro $0,435/$0,87 [5] |
| Qwen | Alibaba | 3.7 Flash $0,03/$0,13 | 3.5 235B $0,09/$0,55 [7] |
| GLM | Z.AI | 4.7 FlashX $0,07/$0,40 | 5.2 $1,40/$4,40 [8] |
| Kimi | Moonshot | K2 $0,57/$2,30 | K3 $3/$15 [7] |
| MiniMax | MiniMax | M2.5 $0,22/$0,90 | M3 $0,30/$1,20 [7] |
| ERNIE | Baidu | 4.5 VL $0,42/$1,25 | — [7] |
| Hunyuan | Tencent | A13B $0,14/$0,57 | — [7] |
| StepFun | StepFun | 3.5 Flash $0,10/$0,30 | 3.7 Flash $0,20/$1,15 [7] |

---

## 10. Recomendações Deep Blue

- **Fórmula:** transcrição → **Groq Whisper turbo ($0,04/h)** ou **Grok STT ($0,10/h)**; rotinas simples → **GPT-5 Nano / Qwen 3.7 Flash / GLM-4.7 Flash**; agentes → **GPT-5.2 / Sonnet 5 / DeepSeek V4 Flash**.
- **Blue:** agentes de sala → LLM médio (Gemini 3.5 Flash ou DeepSeek V4 Flash); voz → Cartesia/ElevenLabs; imagem → **Grok Imagine $0,02/img** ou Imagen/gpt-image-1-mini; vídeo → **Grok Imagine Video $0,05/s** ou Veo Lite/Sora-2 sob demanda.
- **Regra de custo:** comece pelo modelo pequeno; suba de tamanho apenas se a qualidade não atender. Use **batch API (−50%)** quando a latência não importa.
- Este catálogo é o insumo do futuro **LLM service**: roteamento por tarefa → modelo certo → custo mínimo, centralizado em um gateway.

---

## 11. Riscos e alertas

- ⚠️ **DeepSeek anunciou oficialmente aumento significativo de preço em breve** — planejar contingência (Qwen/GLM/Groq como alternativas baratas). [5]
- Preços mudam rápido: validade ~1–2 meses; revisar trimestralmente.
- OpenAI: endpoints com data residency cobram +10% (modelos novos). [1]
- Preços do OpenRouter podem diferir do fornecedor oficial (descontos/margens de rota).

---

## Pendências para v2

- **Luma** (Dream Machine API — doc sem preço público; créditos via plataforma).
- **Kling direto** (página JS) — disponível via Runway e Replicate.
- **Alibaba** oficial (página JS) — valores Qwen confirmados via OpenRouter.
- **Stability API** por imagem (página JS) — planos confirmados.
- **MiniMax H3** precificação oficial (API).
- **Whisper self-host** (custo GPU por hora).

---

## Fontes

1. OpenAI Pricing — https://developers.openai.com/api/docs/pricing
2. Anthropic Pricing — https://platform.claude.com/docs/en/about-claude/pricing
3. Google Gemini API Pricing — https://ai.google.dev/gemini-api/docs/pricing
4. Google Cloud (Vertex) Pricing — https://cloud.google.com/gemini-enterprise-agent-platform/generative-ai/pricing
5. DeepSeek Models & Pricing — https://api-docs.deepseek.com/quick_start/pricing
6. GroqCloud Supported Models — https://console.groq.com/docs/models
7. OpenRouter Models API — https://openrouter.ai/api/v1/models
8. Z.AI Pricing — https://docs.z.ai/guides/overview/pricing
9. Moonshot/Kimi Pricing — https://platform.kimi.ai/docs/pricing
10. MiniMax Pricing — https://platform.minimaxi.com/document/pricing
11. AssemblyAI Pricing — https://www.assemblyai.com/pricing
12. Deepgram Pricing — https://deepgram.com/pricing
13. ElevenLabs Pricing — https://elevenlabs.io/pricing
14. Cartesia Pricing — https://docs.cartesia.ai/pricing · https://www.cartesia.ai/pricing
15. Replicate Pricing — https://replicate.com/pricing
16. Stability AI Plans — https://stability.ai/brand-studio-plans
17. Runway Pricing — https://runway.com/pricing
18. Hugging Face Pricing — https://huggingface.co/pricing
19. Alibaba Cloud Model Studio — https://www.alibabacloud.com/help/en/model-studio/models
20. xAI Grok Pricing — https://docs.x.ai/docs/models
