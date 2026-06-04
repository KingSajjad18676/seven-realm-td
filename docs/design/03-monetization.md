# Design 03 — Ethical Monetization and Business

**Last updated:** 2026-06-04  
**Design canon** — build revenue by creating trust, not frustration.  
**Related:** [liveops/retention.md](../liveops/retention.md) · [PRD.md](../product/prd.md)  
**Note:** Code may contain IAP/subscription **stubs** for future use; they are **not** launch monetization per this doc.

---

## 1. Business principle

A successful game earns money because players value it. The store must communicate:

- This game respects my time  
- The battle is fair  
- The art is special  
- I understand what I am buying  
- Spending supports the game  
- I do not need to pay to win  

Never create artificial pain merely to sell the cure.

---

## 2. Recommended model

Fair free-to-start:

- Free early game and strong Khan 1 experience  
- Fair campaign progression  
- Optional cosmetics  
- **Founder’s Supporter Pack**  
- Permanent ad-removal purchase  
- Limited optional rewarded ads (only after core loop is fun)  
- Authored expansions after demand is proven  

**Do not launch** with complex battle pass, subscription, or large live-service economy.

---

## 3. What to sell

### 3.1 Founder’s Supporter Pack

May include: permanent ad removal, exclusive profile banner, cosmetic Rostam skin, cosmetic tower-skin set, soundtrack sampler or art gallery (if available), supporter badge — **no combat power**. Test range: **USD 6.99–12.99** (regional pricing).

### 3.2 Permanent ad removal

One-time purchase. Test range: **USD 2.99–5.99**. Removes optional ad prompts without removing earned gameplay rewards.

### 3.3 Cosmetic bundles

Examples: Nowruz Garden towers, Damavand bronze-and-snow set, Rakhsh companion visuals, manuscript HUD theme, Sacred Fire VFX variants, gate skins, portrait frames, profile banners, projectile effects.

| Product | Test range (USD) |
|---------|------------------|
| Small cosmetic item | 0.99–2.99 |
| Focused bundle | 3.99–7.99 |
| Premium themed collection | 7.99–14.99 |

Cosmetics must stay readable in combat.

### 3.4 Authored expansion (post-demand)

New tale, maps, boss sequence, hero, cards/relics, music/loading art. Test range: **USD 4.99–12.99**. Must feel like a real chapter, not cut launch content.

---

## 4. Optional rewarded ads

Must be: optional, clearly described, limited, never automatic in battle, never required to progress, never after emotional defeat pressure, disabled by ad-removal purchase.

| Placement | Reward |
|-----------|--------|
| Post-run optional bonus | Modest non-premium reward |
| Daily Tale preparation | One optional reroll |
| Collection screen | Small cosmetic-preview or lore bonus |
| Pre-run preparation | One limited scout option |

**Avoid:** forced interstitials, in-combat ads, continue spam, unlimited farming, competitive advantage, rewards so large that declining feels punished.

Start **without ads** in internal testing.

---

## 5. What not to sell

Stronger towers, paid overpowered heroes, stat boosts, paid cleanse advantages, boss skips, difficulty removal, loot boxes, randomized paid rewards, confusing multi-currency packs, fear-based limited offers, paid accessibility, power hidden in cosmetics.

---

## 6. Currency design

| Currency | Purpose | Purchasable? |
|----------|---------|--------------|
| Gold | Temporary battle economy | No |
| Sacred Fire | Tactical anti-corruption | No |
| Farr | Long-term mastery and progression | No direct purchase |
| Cosmetics | Store | Optional (direct price preferred) |

Avoid multiple premium currencies unless operationally necessary.

---

## 7. Store presentation

Tabs: Featured, Heroes, Towers, Effects, Profile, Supporter Pack, Restore Purchases.

Rules: show full item, clear price, mark cosmetic-only, in-context preview, no fake discount timers, no misleading rarity, no battle interruption, restore purchases, visible support contact.

---

## 8. Business roadmap stages

| Stage | Revenue | Focus |
|-------|---------|-------|
| 0 Prototype | None | Khan 1, replay, analytics stub, art lock, performance — **no store** |
| 1 Closed alpha | None | Tutorial, corruption, replay, tower readability, boss fairness, stability |
| 2 Closed beta | None | Mock store, cosmetic preview, entitlements, restore flow, privacy inventory, catalog draft |
| 3 Soft launch | Test | Supporter pack, ad removal, few cosmetics, limited rewarded ads if retained, regional pricing, support/refunds |
| 4 Global release | Launch | Small polished catalog, real screenshots, clear value, stable purchase recovery |
| 5 Post-launch | Expand | Curated cosmetics, seasonal themes, authored expansion, community challenges, sustainable events |

---

## 9. Metrics

**Product health:** tutorial completion, first-battle completion, replay after win/defeat, Khan funnel, session length/count, crash-free sessions, support, review sentiment.

**Business health:** store views, conversion, Supporter Pack and ad-removal conversion, cosmetic distribution, rewarded-ad opt-in/completion, refunds, purchase-recovery failures.

**Fairness health:** non-payers progress normally; ads not required; store prompts don’t spike churn; no pay-to-win complaints; cosmetics don’t harm clarity.

---

## 10. Revenue planning

`gross − platform fees − taxes − refunds − marketing − tools − contractors = operating contribution`

Scenarios: Conservative (low conversion), Expected (healthy retention), Upside (strong reviews/replay). Do not staff live-ops for upside-only projections.

---

## 11. Marketing position

Lead with: hand-painted Shahnameh-inspired TD roguelite where legendary heroes defend sacred regions against corruption.

Show real combat: Rostam movement, tower placement, Sacred Fire purification, corruption transformation, Lion/Azhdaha/Sorceress bosses, Damavand finale, manuscript UI.

Avoid footage more impressive than the shipped game.

---

## 12. Business stop rule

Pause monetization complexity when: players don’t replay Khan 1, weak tutorial completion, frequent crashes, negative store-prompt feedback, content behind schedule, or team can’t support existing products.

The strongest revenue strategy is still a game players sincerely recommend.
