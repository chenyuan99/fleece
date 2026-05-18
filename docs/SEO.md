# ClawHub Skill SEO Log

Tracking description changes, tag updates, and search ranking results for the `fleece` skill on ClawHub.

---

## v1.0.0 — Initial publish (2026-05-18)

**Description:**
> Fleece credit card research CLI. Provides live US credit card data via Brave Search — full reports, earning rates, transfer partners, statement credits, recent news, card comparisons, portfolio analysis, ROI estimates, and profile-based recommendations. Install with `pip install fleece-cli`. Use whenever you need current credit card information.

**Tags:** `latest`

**Search results:**
| Query | Rank | Score |
|---|---|---|
| `credit card` | #13 | 0.701 |

**Issues identified:**
- Generic name "Fleece" gives no signal to vector search
- Description truncated in results — key terms buried
- No categorical tags
- Zero results for conversational queries like "what card should I use for dining"

---

## v1.1.0 — Keyword-rich description + tags (2026-05-18)

**Changes:**
- Rewrote description to front-load issuer names (Chase, Amex, Citi, Capital One, Bilt) and reward types (points, miles, cash back, annual fees, welcome bonuses, transfer partners)
- Added "Use this skill when..." section with 8 natural-language trigger phrases near top of SKILL.md body
- Added 14 categorical tags

**Tags:** `latest, credit-cards, rewards, points, miles, travel, finance, research, amex, chase, citi, capital-one, brave-search, wallet, transfer-partners`

**Search results:**
| Query | Rank | Score |
|---|---|---|
| `credit card research` | **#1** | 0.817 |
| `credit card redemption` | **#1** | 0.782 |
| `credit card` | #13 | 0.702 |
| `what card should I use for dining` | — | no results |

---

## v1.1.1 — Conversational query language (2026-05-18)

**Changes:**
- Rewrote description opening to directly mirror user query phrasing:
  > "What credit card should I use for dining, travel, groceries, or gas?" — Fleece answers this with live data...
- Added `recommendations`, `dining`, `groceries`, `gas` tags

**Rationale:** Vector search scores on embedding similarity — starting the description with the exact question users ask maximizes cosine similarity for that query bucket.

**Tags:** `latest, credit-cards, rewards, points, miles, travel, finance, research, amex, chase, citi, capital-one, brave-search, wallet, transfer-partners, recommendations, dining, groceries, gas`

**Search results:**
| Query | Rank | Score |
|---|---|---|
| `credit card research` | **#1** | 0.817 |
| `credit card redemption` | **#1** | 0.782 |
| `what card should I use for dining` | — | no results (below threshold) |

**Note:** ClawHub has a minimum score threshold (~0.6–0.7). Conversational queries fall below it for all skills — not specific to fleece. Vector index update lag (~minutes) observed between publish and ranking change.

---

## v1.2.0 — MCC command added (2026-05-18)

**Changes:**
- Added `fleece mcc` command (offline MCC code lookup + wallet cross-reference)
- Added `mcc`, `merchant-category` tags

**Tags:** added `mcc, merchant-category`

---

## v1.2.1 — Claude skill for MCC published (2026-05-18)

**Changes:**
- Added `fleece-mcc.md` Claude Code skill
- No description change

---

## Observations & lessons

1. **Description is the primary ranking signal** — ClawHub's vector search indexes the frontmatter `description` field. The body content appears to have lower weight. Front-load the highest-value keywords.

2. **Conversational queries hit a threshold floor** — queries phrased as full sentences ("what card should I use for...") return 0 results across all skills, suggesting the registry-wide similarity is below ClawHub's cutoff for this query type. Not a fleece-specific problem.

3. **Intent buckets matter** — "credit card" ranks us #13 because the top results are payment/spend skills (giving agents a card to transact). We're a research tool — different intent, different bucket. Competing in the right bucket ("credit card research", "credit card redemption") yields #1 rankings.

4. **Tags are for filtering, not ranking** — adding tags didn't move needle on search scores but helps with tag-based browsing.

5. **Index update lag** — ClawHub rebuilds vector embeddings asynchronously after publish. The `inspect` summary field reflects the old content until the rebuild completes. Wait ~5–10 minutes before testing ranking changes.
