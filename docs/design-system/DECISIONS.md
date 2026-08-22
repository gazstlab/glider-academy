# Registro de decisões de design

Uma linha por decisão. Formato: `data · o quê · por quê · o que foi descartado`.
Toda exceção às regras do design system **precisa** aparecer aqui, senão é bug.

| Data | Decisão | Motivo | Descartado |
|---|---|---|---|
| 2026-08-22 | D1 · Linguagem visual de carta aeronáutica seccional | O produto é navegação de rotas (DAGs); carta é o artefato nativo desse mundo e evita o visual de dashboard SaaS genérico | Tema escuro com acento neon único; layout tipo jornal com serifa |
| 2026-08-22 | D2 · Escuro como padrão, claro como alternativa | A pessoa passa a maior parte do tempo em editor + terminal; o lab manda no tema, não a landing | Claro como padrão com escuro opcional |
| 2026-08-22 | D3 · Papel de carta frio (`#EDF1F5`) no modo claro | Creme quente é o fundo padrão de todo site gerado por IA hoje; frio mantém a leitura de carta impressa | `#F4F1EA` e vizinhos |
| 2026-08-22 | D4 · Sem sombras difusas; profundidade por hairline | Instrumento de navegação é desenhado a linha, não a volume | Elevação em camadas com `box-shadow` |
| 2026-08-22 | D5 · Archivo com eixo de largura 112 no display | Dá proporção de rótulo de painel; largura variável é uma escolha assinada e não simulável com tracking | Space Grotesk, Inter Display |
| 2026-08-22 | D6 · Uma única animação ambiente (tracejado da aresta em execução) | Movimento serve para dizer "isto está rodando agora"; qualquer outro efeito dilui esse sinal | Reveal no scroll, contadores, parallax |
| 2026-08-22 | D7 · Progresso como altitude (`Altimeter`), não barra de % | Barra diz quanto falta; altímetro diz também de onde você saiu, que é o ponto do produto | Barra de progresso, anel circular |
| 2026-08-22 | D8 · Estado de task exige cor + forma + texto | Ler o estado do DAG é a tarefa central; não pode depender de percepção de cor | Só cor, como no Airflow original |
| 2026-08-22 | D9 · Abaixo de 900px o lab não tem canvas editável | Três painéis em telefone não é utilizável; a versão móvel é leitura + execução | Painéis colapsáveis em abas no mobile |
| 2026-08-22 | D10 · Metáfora do planador aparece no vocabulário, não em ilustração | Referência repetida vira mascote e envelhece rápido | Ilustrações de planador por seção |
| 2026-08-22 | D11 · **Substitui D1** · Linguagem visual descende da UI do Apache Airflow, não da carta aeronáutica | Transferência é o produto: quem termina o Glider precisa reconhecer um Airflow real no primeiro segundo | Carta aeronáutica seccional (bonita, porém alheia ao domínio da ferramenta) |
| 2026-08-22 | D12 · **Substitui D2 e D3** · Tema claro é o padrão; escuro é primeira classe | A UI do Airflow é clara por padrão; o Glider herda para não estranhar na troca | Escuro por padrão |
| 2026-08-22 | D13 · **Substitui D6 e D7** · A assinatura é o grid de estados; progresso é coluna do grid | O grid view é o visual mais reconhecível do Airflow e serve simultaneamente como progresso e como conteúdo da lição | Rota tracejada de Bézier; altímetro vertical |
| 2026-08-22 | D14 · Cores de estado herdadas por matiz de `airflow.utils.state`, retunadas por valor | As cores nomeadas de CSS do Airflow reprovam em contraste; manter o matiz preserva o reconhecimento e a retuna resolve a acessibilidade | Adotar as nomeadas verbatim; inventar paleta própria |
| 2026-08-22 | D15 · Azul de marca (`#017CEE`) é proibido como cor de estado | No Airflow o azul é identidade, não status; misturar destrói a leitura do grid | Usar o azul como estado `none` |
| 2026-08-22 | D16 · **Substitui D5** · Inter no corpo (fonte da UI do Airflow), Familjen Grotesk no display | Familiaridade é o ponto; a personalidade fica no display para o site não virar um fork visual do Airflow | Archivo expandido; Space Grotesk |
| 2026-08-22 | D17 · **Substitui D4** · Sombras leves permitidas (`card`, `pop`) e raio de 6px em controles | Alinha ao Chakra da UI do Airflow 3; a regra de hairline vinha da direção anterior | Manter hairline puro e cantos vivos |
| 2026-08-22 | D18 · Nenhum estado fora de `airflow.utils.state` pode existir na UI | Um estado inventado ensina errado, que é o pior defeito possível num produto de ensino | Estados didáticos próprios ("quase lá", "atenção") |
