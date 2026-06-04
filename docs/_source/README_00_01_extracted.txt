SHAHNAMEH TD
README 00 — MASTER PROJECT INDEX
Senior Game-Design, Art-Production, Development, and Business Plan
Engine: Godot 4.6
Primary platform: landscape mobile
Genre: active 2D tower-defense roguelite
Campaign: Seven Khans plus the Damavand Binding finale
Main battlefields: 8
Core visual identity: hand-painted Shahnameh-inspired Iranian epic art with strong mobile readability
1. PROJECT PROMISE
Shahnameh TD is a heroic illustrated tower-defense roguelite inspired by Ferdowsi’s Shahnameh. The player
builds a defense, moves a legendary champion, protects regions of sacred light, purifies corruption, rescues
hijacked towers, drafts Fate cards, and confronts mythic bosses.
The game must not feel like a generic tower defense with Persian decorations. Its identity must appear in:
the story structure
the characters and mythic ordeals
the shape language of towers
the contrast between Sacred Fire and corruption
the regional map design
the ornamental UI rhythm
the soundtrack and sound effects
the narrator presentation
the replayable roguelite choices
2. CORE PLAYER LOOP
read the battlefield
-> place a tower
-> react to enemy pressure
-> reposition the hero
-> earn and spend Sacred Fire
-> cleanse corruption
-> rescue threatened towers
•
•
•
•
•
•
•
•
•
1

-- 1 of 35 --

-> choose a Fate card
-> defeat a mythic boss
-> unlock a discovery
-> replay with a different build
3. FIRST PRODUCTION TARGET
Build only the Khan 1 vertical slice first:
place Archer Tower
-> defeat readable enemy group
-> move Rostam near a leak
-> notice regional corruption
-> activate Sacred Fire cleanse
-> prevent tower hijack
-> survive five waves
-> choose one Fate card
-> defeat the Lion of the First Khan
-> press replay
Do not mass-produce the full campaign until real testers voluntarily replay Khan 1.
4. PROJECT READMES
README 	Purpose
README_00_MASTER_PROJECT_INDEX.md project identity, reading order, and
locked decisions
README_01_PHASE_BASED_ASSET_GENERATION.md
art direction, complete modular
prompts, phase inventories, and
approval gates
README_02_GAMEPLAY_VISUAL_UX_REPLAYABILITY.md combat, maps, towers, heroes, bosses,
UI, replayability, and balancing
README_03_ETHICAL_MONETIZATION_BUSINESS.md fair revenue strategy, products, ads,
pricing tests, and business roadmap
README_04_DEVELOPMENT_PRODUCTION_ROADMAP.md Godot architecture, milestones, QA,
performance, and release engineering
2

-- 2 of 35 --

README 	Purpose
README_05_LAUNCH_LIVEOPS_COMMUNITY.md soft launch, analytics, community,
sustainable updates, and support
5. LOCKED DESIGN DECISIONS
Area 	Decision
Genre 	active hero-led tower defense with roguelite runs
Platform 	landscape mobile first
Core battle resource 	Gold
Signature resource 	Sacred Fire
Signature threat 	regional corruption and tower hijacking
Main campaign 	Seven Khans plus Damavand Binding
Map count 	8
Map progression 	medium to very large
Large-map solution layered TileMaps, active sectors, camera anchors, minimap, threat-jump
navigation
Starting towers 	Archer, Sacred Fire, Heavy, Control
Starting hero 	Rostam
Replayability cards, relics, routes, Forge hybrids, objectives, heroes, Pacts, Hunt, Endless,
Daily Tale
Monetization 	cosmetics-first, supporter pack, ad removal, limited optional rewarded ads
Forbidden
monetization
paid combat power, paid loot boxes, forced ads during battle, manipulative
defeat-screen offers
Production rule 	prove Khan 1 gameplay before producing the full asset catalog
6. CORRECT WORK ORDER
Lock the visual style with Rostam, one map, one HUD, and several animations.
Build the Khan 1 graybox before creating the full asset library.
Test touch controls and battlefield readability on real phones.
Integrate only Phase 0 and Phase 1 assets.
1.
2.
3.
4.
3

-- 3 of 35 --

Tune the first boss and replay flow.
Prove that players understand corruption and voluntarily replay.
Build the roguelite foundations.
Expand the Seven Khans campaign.
Add meta progression and collections.
Add Hunt, Endless, Daily Tale, cosmetics, and launch content.
Soft-launch with a small audience.
Improve retention and clarity before increasing marketing spend.
7. SUCCESS TEST FOR THE FIRST PLAYABLE BUILD
A tester should be able to answer:
What do the four starter towers do?
Where will enemies travel?
What is Rostam useful for?
What does Sacred Fire do?
What does corruption look like before a collapse?
How do I rescue a hijacked tower?
Why did I win or lose?
What new decision would I try in a replay?
The most important signal is simple:
After finishing or failing Khan 1, does the player press replay without being asked?
8. NON-NEGOTIABLE QUALITY RULES
Never sacrifice readability for decoration.
Never use fake Persian writing.
Never cover critical gameplay with particles.
Never make a boss only a large health bar.
Never create large empty maps merely to claim scale.
Never hide the reason for a defeat.
Never require spending to recover from difficulty.
Never generate hundreds of assets before proving the gameplay loop.
5.
6.
7.
8.
9.
10.
11.
12.
•
•
•
•
•
•
•
•
•
•
•
•
•
•
•
•
4

-- 4 of 35 --

SHAHNAMEH TD
README 01 — PHASE-BASED ASSET GENERATION
Complete Modular Prompt System for Production Art
1. WHY THIS PROMPT SYSTEM IS MODULAR
A professional asset library should not repeatedly paste the same 50-line visual system into every prompt.
Repetition increases inconsistency and makes correction difficult.
For each image-generation request, paste these sections in order:
1. GLOBAL VISUAL BLOCK
2. ONE ASSET-TYPE BLOCK
3. ONE ASSET SPECIFICATION
4. GLOBAL NEGATIVE BLOCK
Generate only one isolated asset, atlas, strip, map package, or UI screen per request.
Approve the base design first. Generate animations only after the base design is locked.
2. GLOBAL VISUAL BLOCK
Create production-ready 2D illustrated game art for SHAHNAMEH TD, a landscape-
mobile tower-defense roguelite inspired by Ferdowsi’s Shahnameh and Persian
miniature painting.
Use the attached approved Rostam reference image as the primary visual-style
anchor.
TRANSFER THE VISUAL SYSTEM, NOT ROSTAM’S EXACT COSTUME.
VISUAL SYSTEM:
- detailed hand-painted 2D game illustration
- strong dark-brown or near-black outer contour lines
- thinner controlled internal linework
- painterly cel-shading with compact shadow shapes and warm highlights
- aged bronze, antique gold, copper, leather, timber, stone, brick, textile, and
parchment materials
5

-- 5 of 35 --

- deep teal, lapis-inspired blue, crimson, rust red, ivory, charcoal, and
controlled warm-orange Sacred Fire accents
- restrained cold-blue and shadow-violet corruption accents
- Iranian epic identity and Persian-miniature-inspired ornamental rhythm
- polished modern mobile-game readability
- elevated three-quarter gameplay perspective unless another camera angle is
explicitly requested
- consistent material language, perspective, lighting, scale, and silhouette
quality
- medium-high detail density without clutter
- culturally coherent heroic and mythic atmosphere
CANONICAL RULE:
When the asset is based on a Shahnameh figure, creature, episode, or location,
preserve the correct narrative role, Iranian epic identity, dignity, and
cultural coherence. Do not redesign it as generic Western fantasy.
GAMEPLAY-ADAPTATION RULE:
When the asset is an invented gameplay enemy, tower, prop, or effect, make it
visually belong inside the same Shahnameh-inspired world without falsely
presenting it as a canonical character.
3. GLOBAL NEGATIVE BLOCK
NEGATIVE PROMPT:
photorealistic, photography, 3D-render appearance, generic Western fantasy,
European medieval plate armor, European castle design, Viking styling, Roman
armor, samurai armor, Chinese imperial armor, science-fiction technology,
cyberpunk, neon holograms, flat vector minimalism, generic cartoon, anime
styling, low-detail mobile icon art, fake Persian writing, random runes,
readable text, logos, signatures, watermarks, excessive spikes, oversized
shoulder armor, excessive glow, excessive smoke, uncontrolled particles, blurry
silhouette, weak contrast, cropped body parts, cropped weapons, cropped wings,
cropped tails, duplicate limbs, broken anatomy, inconsistent scale, inconsistent
perspective, inconsistent lighting, green spill, green outline, green shadow.
6

-- 6 of 35 --

4. OUTPUT CONTROL PROMPTS
4.1 Review-grid version
Generate a Review Grid version of the approved isolated asset.
Requirements:
- use exact uniform chroma-key green background #00FF00
- add thin dark-gray 2-pixel grid lines
- preserve the requested canvas size
- preserve the requested grid structure
- keep every asset fully inside its assigned cell
- preserve consistent scale and camera angle
- do not add labels
- do not add text
- do not add a watermark
4.2 Transparent production version
Generate a Clean Production version of the approved asset.
Requirements:
- preserve the approved design exactly
- preserve the exact canvas size and frame positions
- remove all visible grid lines
- remove labels and text
- use a transparent RGBA background
- preserve clean anti-aliased edges
- do not add scenery
- do not add a watermark
4.3 Correction prompt
Regenerate the asset with these corrections:
- preserve the approved Shahnameh TD visual system
- match the Rostam style anchor more closely
- keep the complete asset inside every grid cell
- do not crop weapons, limbs, tails, wings, mane, or effects
- preserve identical scale across frames
- preserve the requested elevated three-quarter gameplay perspective
- remove duplicate limbs and broken anatomy
- preserve strong contour lines and painterly cel-shading
7

-- 7 of 35 --

- preserve the bronze, teal, crimson, ivory, charcoal, leather, and warm-orange
material system
- reduce clutter
- remove text and watermarks
- preserve the requested grid and canvas dimensions exactly
5. ASSET-TYPE BLOCKS
5.1 Isolated character, creature, hero, enemy, or boss
ASSET TYPE:
Approved isolated base design for later animation production.
TECHNICAL OUTPUT:
- produce one full-body isolated design
- transparent RGBA background
- elevated three-quarter gameplay perspective
- bottom-center pivot
- preserve safe padding around limbs, weapons, mane, tail, wings, and effects
- mobile-readable silhouette
- no scenery
- no text
- no watermark
5.2 Character or creature animation strip
ASSET TYPE:
Production-ready animation strip based on the attached approved isolated base
design.
TECHNICAL OUTPUT:
- generate one animation strip only
- grid: 8 columns × 1 row
- transparent RGBA background
- preserve identical costume, face, anatomy, proportions, scale, perspective,
material rendering, and lighting in every frame
- bottom-center pivot
- full silhouette visible in every frame
- no frame overlap
- no cropped body parts, weapons, tails, wings, mane, or effects
- no scenery
8

-- 8 of 35 --

- no text
- no watermark
Recommended cell sizes:
Asset class 	Cell size
small enemy 	192 × 192
hero or companion 	256 × 256
standard boss 	384 × 384
final boss or very large creature 512 × 512
5.3 Tower base design
ASSET TYPE:
Approved isolated tower-family base design.
TECHNICAL OUTPUT:
- isolated full tower design
- transparent RGBA background
- elevated three-quarter top-down gameplay perspective
- bottom-center pivot
- fit inside a 256 × 256 cell with safe padding
- keep the tower base fixed and readable
- expose a clear projectile or effect origin point
- avoid baked terrain beneath the tower
- no text
- no watermark
5.4 Tower animation strip
ASSET TYPE:
Production-ready tower animation strip based on the attached approved tower
design.
TECHNICAL OUTPUT:
- grid: 8 columns × 1 row
- cell size: 256 × 256 pixels
- transparent RGBA background
- fixed bottom-center pivot
- preserve tower footprint, camera angle, materials, lighting, and scale
- animate only the requested action
9

-- 9 of 35 --

- full tower silhouette visible in each frame
- no baked terrain
- no text
- no watermark
5.5 Battlefield map package
ASSET TYPE:
Layered landscape battlefield map package for a mobile tower-defense scene.
TECHNICAL OUTPUT:
- use the requested logical tile grid
- tile size: 128 × 128 pixels
- landscape 16:9 overview composition
- enemy routes at least two logical tiles wide
- readable build pads
- readable enemy entrances and player gate
- readable regional-light sectors
- terrain fills the canvas
- no characters
- no enemies
- no towers
- no UI
- no readable text
- no labels
- no watermark
DELIVER SEPARATE LAYERS OR REVIEW EXPORTS:
1. clean terrain
2. visible-grid review overlay
3. enemy-path overlay
4. build-pad overlay
5. regional-light overlay
6. corruption-mask overlay
7. collision overlay
8. camera-anchor overlay
9. sector-activation overlay for large maps
5.6 Tileset atlas
ASSET TYPE:
Seamless terrain tileset atlas.
TECHNICAL OUTPUT:
10

-- 10 of 35 --

- atlas grid: 8 columns × 8 rows
- tile size: 128 × 128 pixels
- total atlas: 1024 × 1024 pixels
- every tile fills its complete cell
- seamless edges and coherent transitions
- include base terrain, route surfaces, edge transitions, corners, corruption
transitions, sacred-light transitions, and decorative variants
- no characters
- no enemies
- no towers
- no UI
- no text
- no watermark
- deliver one clean atlas and one visible-grid review atlas
5.7 Props or UI-icon atlas
ASSET TYPE:
Isolated atlas.
TECHNICAL OUTPUT:
- use the requested grid and cell dimensions
- transparent RGBA background
- center each item with safe padding
- preserve consistent scale and elevated gameplay perspective where applicable
- ensure strong mobile-readable silhouettes
- no labels
- no readable text
- no watermark
5.8 VFX strip
ASSET TYPE:
Animated VFX strip.
TECHNICAL OUTPUT:
- grid: 8 columns × 1 row
- cell size: 256 × 256 pixels unless otherwise specified
- transparent RGBA background
- centered effect
- clear start, expansion, peak, and dissolve progression
- mobile-readable shape language
- controlled particle count
- no scenery
11

-- 11 of 35 --

- no text
- no watermark
- avoid sci-fi holograms and random runes
5.9 UI screen
ASSET TYPE:
Polished illustrated mobile UI screen and isolated UI-atlas package.
INTERFACE VISUAL SYSTEM:
- dark-charcoal foundations
- aged-bronze and antique-gold frames
- deep-teal and crimson textile accents
- ivory parchment surfaces
- restrained Persian ornamental geometry
- large mobile touch targets
- clear hierarchy
- localization-safe empty zones
- no baked text, numbers, prices, dates, or fake writing
TECHNICAL OUTPUT:
- canvas: 4096 × 2304 pixels
- landscape 16:9 mobile composition
- no watermark
DELIVER:
1. full-screen mockup
2. isolated frame atlas
3. button atlas
4. meter atlas where needed
5. alert or state atlas where needed
6. high-contrast accessibility variation
6. MAP SCALE PROGRESSION
Do not use the same battlefield size for all eight maps.
Map 	Scale Logical
grid Design intention
Khan 1 — Lion and
Rakhsh Medium 	32 × 18 	readable first battlefield
12

-- 12 of 35 --

Map 	Scale Logical
grid Design intention
Khan 2 — Desert of Thirst Medium 	36 × 20 	exposed routes and scarce relief
Khan 3 — Azhdaha
Canyon
Medium-
large 40 × 22 	split pressure and arena threat
Khan 4 — Sorceress Feast Medium-
large 42 × 24 	illusion routes and reveal mechanics
Khan 5 — Olad Camp 	Large 	48 × 27 	branching choices and moving fronts
Khan 6 — Arzhang
Fortress Large 	52 × 30 	siege layers and fortress sectors
Khan 7 — White Div
Cavern Very large 	56 × 32 underground sectors and visibility
pressure
Damavand Binding 	Very large 	64 × 36 	multi-anchor finale and staged sectors
Large maps must not become giant empty bitmaps. Build them from layered TileMaps and activate sectors
in stages. Use camera anchors, minimap navigation, off-screen alerts, and a button that jumps to the
highest-priority threat.
7. PHASE 0 — VISUAL LOCK AND TECHNICAL PROOF
Generate these assets before mass production.
7.1 Rostam base-design specification
ASSET ID:
hero_rostam
CHARACTER:
Rostam
NARRATIVE IDENTITY:
Legendary champion of Zabulistan, protector of Iran, dragon-slayer, and central
heroic warrior of the Shahnameh.
GAMEPLAY ROLE:
Frontline playable hero, boss fighter, leak interceptor, and Sacred Tether
amplifier.
DESIGN REQUIREMENTS:
13

-- 13 of 35 --

- broad heroic silhouette
- mature commanding face and strong moustache
- practical bronze-and-antique-gold armor
- deep-teal and crimson Iranian textile panels
- leather straps and engraved bronze details
- sword, lasso, and restrained ox-headed mace
- subtle Babr-e Bayan tiger or leopard-pattern reference
- avoid Viking, barbarian, and European-knight styling
CELL TARGET:
256 × 256 pixels for later hero animations
7.2 Rostam animation specifications
hero_rostam_idle:
Eight-frame subtle breathing loop. Preserve a heroic grounded stance. Animate
small chest, cloth, and weapon-settle movements only.
hero_rostam_walk:
Eight-frame forward walking loop facing screen-right. Keep lasso and weapons
controlled and visible.
hero_rostam_basic_attack:
Eight-frame ox-headed-mace or sword attack. Include readable anticipation,
impact, and recovery.
7.3 Prototype Battle HUD specification
UI ID:
ui_battle_hud_prototype
PURPOSE:
Validate hierarchy, mobile touch zones, and consistency with the Rostam visual
anchor.
REQUIRED ZONES:
- top-left: Lives, Gold, Sacred Fire, Wave
- top-right: pause, speed, settings, cleanse
- bottom-left: hero portrait, HP, energy, skill, Tether
- bottom-center: four starter tower cards
- bottom-right: contextual tower action
- center: alert-banner safe area
IMPORTANT:
14

-- 14 of 35 --

Do not show every future system at once. The vertical slice HUD must remain
calm, readable, and touch-friendly.
7.4 Khan 1 map specification
MAP ID:
map_khan_01_lion_rakhsh
TITLE:
Khan 1 — Lion and Rakhsh
CANONICAL STORY ANCHOR:
Rakhsh confronts a lion while Rostam rests.
ENVIRONMENT:
Mythic Iranian woodland meadow with stylized trees, grasses, rocks, reeds,
stream edges, flower patches, hero-rest area, and a central lion arena.
GAMEPLAY LAYOUT:
- enemy entrance at upper-right
- player gate at lower-left
- two-tile-wide winding path
- central 6 × 6 lion arena
- eight readable 2 × 2 build pads
- three regional-light sectors
- one Sacred Fire brazier point
- one hero-rest marker
GRID:
32 columns × 18 rows
Phase 0 approval gate
Do not proceed until:
Rostam reads clearly at normal mobile zoom.
Animations fit their cells without cropping.
The map route is understandable in two seconds.
Build pads are easy to see.
The HUD supports one-thumb and two-thumb play.
The player can identify Sacred Fire without reading a tutorial paragraph.
•
•
•
•
•
•
15

-- 15 of 35 --

8. PHASE 1 — KHAN 1 PLAYABLE VERTICAL SLICE
8.1 Base designs
Asset ID 	Subject 	Gameplay role 	Key design requirements
companion_rakhsh 	Rakhsh
narrative
companion and
warning support
warm reddish coat, darker mane
and tail, heroic stallion anatomy,
restrained saddle, bronze and
teal details
enemy_corrupted_jackal corrupted
jackal fast runner
lean anatomy, dusty-brown fur,
subtle charcoal veins, no
exaggerated mutation
enemy_corrupted_boar corrupted
boar
early armored
enemy
broad low silhouette, dark
bristles, short tusks, restrained
corruption
boss_mythic_lion Lion of the
First Khan Khan 1 boss
believable powerful lion, tawny
fur, darker mane accents, no
armor or demonic mutation
8.2 Starter towers
Asset ID 	Tower 	Gameplay role 	Design requirements
tower_archer Archer
Tower
fast single-target
damage
Iranian-inspired timber watchtower,
carved rails, bow racks, quivers, teal
canopy
tower_sacred_fire Sacred
Fire Tower
burn, cleanse
support, Sacred Fire
generation
stone-and-brick brazier tower,
protected flame bowl, copper
ornament
tower_heavy Heavy
Tower
slow impact and
armor break
thick masonry, bronze reinforcement,
restrained ox-head motif, heavy
launcher
tower_control Control
Tower
slow, stagger, path
control
qanat-and-wind-inspired tower, cloth
streamers, turquoise water channel,
bronze pipe details
8.3 Tower animation states
Generate these for all four starter towers:
16

-- 16 of 35 --

idle
attack
construction
corruption_warning
hijacked
purification
8.4 Character and boss animations
Rakhsh:
idle
run
warning_stomp
Lion of the First Khan:
idle
run
claw_attack
pounce_attack
roar
defeat
Corrupted Jackal:
run
bite_attack
defeat
Corrupted Boar:
walk
charge
defeat
8.5 Khan 1 terrain and props
tileset_woodland:
grass variants, meadow flowers, forest floor, shallow stream, stream edges,
river corners, reeds, dirt path, path turns, stone path, mossy rock ground,
cliff edges, corrupted-ground transitions, Sacred-Light transitions, decorative
variants
props_shared_vertical_slice:
1. Sacred Fire brazier
2. extinguished brazier
3. corrupted brazier
17

-- 17 of 35 --

4. woodland rock
5. reeds
6. woodland shrub
7. small tree
8. dead tree
9. hero-rest carpet
10. broken shield
11. rope coil
12. lasso coil
13. sword in ground
14. fallen banner without text
15. gate repair material
16. Sacred stone marker
8.6 Khan 1 VFX
vfx_arrow_release:
compact bow-release flash with restrained ivory motion line and warm bronze
spark
vfx_arrow_impact:
compact arrow-hit burst with dust, bronze spark, and restrained impact lines
vfx_sacred_fire_cleanse:
radial purification wave that burns away dark tendrils using warm orange, gold,
ivory, and copper
vfx_region_corruption_stage_01:
subtle first-stage ground-shadow veins using charcoal, muted violet, and
restrained cold blue
vfx_tower_hijack_start:
dark ribbons coil upward around an invisible tower footprint using charcoal,
muted violet, and cold blue-gray
8.7 Production Battle HUD specification
UI ID:
ui_battle_hud
REQUIRED ALWAYS-VISIBLE COMPONENTS:
- Lives or gate integrity
- Gold
- Sacred Fire
18

-- 18 of 35 --

- wave progress
- pause
- speed
- hero portrait
- hero HP
- hero energy
- hero skill
- four to six tower cards depending on progression
- selected-tower contextual action
CONTEXTUAL OR EXPANDABLE COMPONENTS:
- Morale
- Farr
- objective tracker
- cleanse
- brazier
- Qanat
- rewind
- Forge
- purge
- repair
- sell
- reposition
- relic details
- tower inspect panel
- boss-specific information
CENTER ALERT TYPES:
wave, objective, hijack, collapse, boss, oath, adaptation, revive, binding
RULE:
Do not show every icon continuously. Use progressive disclosure and contextual
panels.
8.8 Core icon atlas
Gold
Sacred Fire
Lives
Morale
Farr
hero energy
rewind
Forge
pause
resume
19

-- 19 of 35 --

speed
settings
cleanse
brazier
Qanat
Tether
upgrade
sell
repair
reposition
purge
inspect
burn
slow
stun
armor break
corruption warning
hijack
purified
boss
objective active
objective complete
objective failed
Phase 1 approval gate
Do not proceed until:
all four towers have unmistakable roles
corruption is noticed before collapse
a hijack warning is fair
Rostam movement is useful but not exhausting
the Lion boss changes player behavior
the UI remains readable on a mid-range phone
testers replay Khan 1 voluntarily
•
•
•
•
•
•
•
20

-- 20 of 35 --

9. PHASE 2 — SEVEN KHANS CAMPAIGN
PRODUCTION
9.1 Playable and supporting heroes
hero_zal:
wise ranged-support hero with Simorgh-linked visual cues, white hair, dignified
Iranian heroic identity, tactical rescue support
hero_gordafarid:
mobile defensive hero, commanding warrior silhouette, practical Iranian-inspired
armor, strong gate-defense identity
hero_esfandiyar:
armored frontline hero with restrained invulnerability identity, disciplined
silhouette, heroic Iranian plate-and-textile design
9.2 Campaign enemies and bosses
Khan 2:
enemy_mirage_shade
enemy_salt_crust_brute
boss_manifestation_of_thirst
Khan 3:
enemy_canyon_serpent
enemy_scorched_cave_hound
boss_azhdaha
Khan 4:
enemy_illusion_attendant
enemy_feast_shade
boss_sorceress_illusion_form
boss_sorceress_revealed_fiend_form
Khan 5:
enemy_mountain_raider
enemy_mountain_archer
boss_olad_champion_form
companion_olad_guide_form
Khan 6:
enemy_div_infantry
21

-- 21 of 35 --

enemy_div_brute
enemy_div_stone_thrower
enemy_div_standard_bearer
enemy_div_corruptor
enemy_div_sorcerer
boss_arzhang_div
Khan 7:
enemy_white_div_thrall
enemy_cavern_boulder_brute
enemy_cavern_corruptor
boss_div_e_sepid
9.3 Campaign map specifications
map_khan_02_desert_thirst:
36 × 20 logical grid
open mythic Iranian desert, dry channels, shade islands, mirage sectors, thirst-
pressure zones, exposed paths, scarce Sacred relief points
map_khan_03_azhdaha_canyon:
40 × 22 logical grid
rocky canyon, caves, scorch marks, branching serpent routes, central dragon
emergence zone, safe camera anchors, split-pressure sectors
map_khan_04_sorceress_feast:
42 × 24 logical grid
enchanted woodland feast clearing, deceptive beauty, illusion route overlays,
reveal-state transitions, corrupted banquet arena
map_khan_05_olad_camp:
48 × 27 logical grid
mountain camp, branching lanes, tents, barricades, elevated path choices, moving
fronts, staged active sectors
map_khan_06_arzhang_fortress:
52 × 30 logical grid
Div fortress, siege gates, layered courtyards, ramparts, banner zones, breach
sectors, camera anchors, staged progression
map_khan_07_white_div_cavern:
56 × 32 logical grid
vast cavern, underground chambers, mist, boulders, visibility pressure, lantern-
safe sectors, staged active chambers
22

-- 22 of 35 --

9.4 Campaign tilesets
tileset_desert
tileset_dragon_canyon
tileset_enchanted_glade
tileset_mountain_camp
tileset_div_fortress
tileset_white_div_cavern
9.5 Advanced towers and Forge hybrids
Asset ID 	Tower 	Role
tower_support 	Support Tower range, speed, repair, and adjacent-tower utility
tower_mystic 	Mystic Tower 	corruption response and magical utility
tower_flame_archer 	Flame Archer 	fast burn-focused hybrid
tower_volcano_ram 	Volcano Ram 	heavy explosive anti-armor hybrid
tower_qanat_weaver 	Qanat Weaver 	slow, reposition, and route-control hybrid
tower_derafsh_bastion Derafsh Bastion morale and defensive aura hybrid
tower_azar_oracle 	Azar Oracle 	Sacred Fire economy and purification hybrid
9.6 Environmental animation set
env_brazier_flame
env_corrupted_brazier
env_qanat_flow
env_stream_ripple
env_desert_heat_distortion
env_sand_drift
env_dragon_scorch_embers
env_illusion_shimmer
env_fortress_banner_sway
env_cavern_mist
env_falling_cave_dust
9.7 Boss animation sets
Azhdaha:
idle, slither, bite, tail_sweep, flame_breath, rock_emergence, enraged, defeat
23

-- 23 of 35 --

Sorceress illusion form:
idle, illusion_cast, curse_bolt, reveal_transition
Sorceress fiend form:
idle, claw_attack, shadow_wave, defeat
Olad champion form:
idle, walk, sword_combo, command_shout, nonlethal_defeat
Arzhang Div:
idle, walk, mace_attack, ground_slam, summon, rage, defeat
Div-e Sepid:
idle, walk, claw_attack, crushing_grapple, ground_slam, dark_hail,
blindness_wave, summon, enraged, defeat
9.8 Boss VFX
vfx_azhdaha_flame_breath
vfx_azhdaha_tail_sweep
vfx_azhdaha_rock_emergence
vfx_sorceress_illusion_split
vfx_sorceress_curse_bolt
vfx_sorceress_reveal
vfx_arzhang_ground_slam
vfx_arzhang_summon
vfx_white_div_ground_slam
vfx_white_div_blindness_wave
vfx_white_div_dark_hail
10. PHASE 3 — ROGUELITE AND REPLAYABILITY
ASSETS
10.1 UI screens
ui_pardeh_break
ui_scroll_of_fate
ui_roguelite_node_icons
24

-- 24 of 35 --

ui_fate_card_frames
ui_objective_icons
10.2 Fate card art
flame_of_azar
eternal_brazier
purifying_chant
ashes_of_renewal
fire_keeper
rakhsh_fury
wisdom_of_zal
gordafarid_resolve
esfandiyar_armor
sohrab_rage
derafsh_kaviani
song_of_the_narrator
last_stand
arash_precision
stone_of_alborz
wind_of_sistan
forge_memory
zahhak_whisper
ahriman_bargain
serpent_hunger
blackened_crown
cup_of_vision
qanat_reserve
heroic_gate
mountain_patience
feathered_rescue
chain_of_damavand
forged_oath
cleanse_before_dawn
corrupted_bounty
rapid_volley
heavy_judgment
sacred_scout
broken_clock
narrator_mercy
dark_route
sacred_route
elite_hunt
forge_adjacent
morale_surge
25

-- 25 of 35 --

10.3 Strategic-action cards
rekindle_region
repair_tower
reposition_tower
scout_next_wave
consult_narrator
strengthen_gate
feed_forge
purge_shadow
invoke_simorgh
mark_path
exchange_relic
sacred_reserve
10.4 Relic icons
feather_of_simorgh
saddle_of_rakhsh
cup_of_jamshid
derafsh_kaviani
chains_of_damavand
ox_headed_mace
bizhan_dagger
seal_of_rudabeh
armor_of_esfandiyar
zal_white_feather
arash_bowstring
kaveh_apron
fire_of_azar
sorceress_mirror
star_iron_fragment
first_talisman
damavand_anchor_fragment
narrator_scroll
qanat_stone
lion_claw
dragon_scale
sorceress_broken_cup
olad_guide_map
arzhang_banner_fragment
white_div_stone
zahhak_chain_seal
farr_emblem
sacred_brazier_core
26

-- 26 of 35 --

forge_hammer_fragment
hidden_jamshid_shard
sistani_wind_knot
gate_guardian_plate
purified_root
div_blue_eye_stone
ahriman_shadow_coin
broken_zervan_ring
qanat_copper_key
heroic_banner_pin
fire_temple_ash
mountain_echo_stone
10.5 Challenge-system assets
blood_oath_assets:
oath frames, risk icon, reward icon, accepted state, completed state, failed
state
zahhak_pact_assets:
pact frames, corruption-risk icon, sacrifice icon, reward icon, accepted state
memory_div_assets:
rival elite frame, adaptation icon, remembered-build warning, defeat marker
11. PHASE 4 — NARRATIVE, COLLECTIONS, AND
META PROGRESSION
11.1 Positive-character base designs
Sohrab
Giv
Goudarz
Bizhan
Kay Khosrow
Kaveh
Fereydun
Simorgh
27

-- 27 of 35 --

11.2 Narrative portraits
Sam
Zavareh
Faramarz
Siyavash
Manijeh
Farangis
Rudabeh
Tahmineh
Sindokht
Kay Kavus
Kay Qobad
Lohrasp
Pashotan
Zarir
Bastwar
Qaren
Rohham
Gostaham
Bahram
Piran
Homan
Katayun
Homay
Behafarid
Arash
Jamshid
Hushang
Tahmuras
11.3 Collection and meta UI
ui_hero_hall
ui_tower_codex
ui_relic_collection
ui_narrators_book
ui_ancestral_forge
ui_narrative_frames
28

-- 28 of 35 --

12. PHASE 5 — HUNT, ENDLESS, LIVE-OPS, AND
COSMETICS
12.1 Final hunt characters
boss_zahhak:
mythic imprisoned tyrant, restrained serpent-shoulder identity, Damavand-binding
visual language, culturally coherent, not generic demonic fantasy
enemy_zahhak_serpent_guard
enemy_chainbreaker_div
enemy_akvan_div
enemy_afrasiyab
12.2 Damavand Binding map
MAP ID:
map_damavand_binding
GRID:
64 × 36 logical tiles
ENVIRONMENT:
Mythic Mount Damavand finale with snow, volcanic fissures, chained anchors,
layered cliffs, Sacred Fire points, active sectors, multiple camera anchors,
staged reveals, and a final binding arena.
GAMEPLAY:
- multiple chain-anchor objectives
- staged sector activation
- off-screen threat alerts
- minimap
- threat-jump navigation
- final Zahhak binding sequence
12.3 Damavand assets
tileset_damavand
vfx_damavand_anchor_activation
vfx_zahhak_serpent_strike
vfx_zahhak_poison_cone
29

-- 29 of 35 --

vfx_zahhak_binding_resistance
vfx_zahhak_final_chain_seal
env_damavand_snow_drift
env_volcanic_embers
env_chain_vibration
12.4 Mode UI
ui_endless_mode
ui_hunt_for_zahhak
ui_daily_tale
ui_seasonal_event
ui_cosmetic_shop
ui_weekly_challenge
ui_community_event
12.5 Cosmetic preview templates
cosmetic_hero_skin_preview
cosmetic_tower_skin_preview
cosmetic_projectile_effect_preview
cosmetic_sacred_fire_effect_preview
cosmetic_gate_skin_preview
cosmetic_profile_banner_preview
liveops_event_badges
Do not generate a battle-pass UI during the initial launch unless a sustainable update cadence has already
been proven.
13. PHASE 6 — ACCESSIBILITY, BRANDING, RELEASE
ART, AND AUDIO
13.1 Utility UI
ui_settings
ui_accessibility
ui_pause
ui_victory
30

-- 30 of 35 --

ui_defeat
ui_simorgh_revive
13.2 Branding and marketing
branding_app_icon
branding_logo_ornament_frame
marketing_store_feature_graphic
marketing_store_screenshot_frames
marketing_trailer_storyboard
13.3 Loading screens
loading_rakhsh_lion
loading_rostam_desert
loading_rakhsh_warns_azhdaha
loading_sorceress_feast
loading_olad_guides_rostam
loading_arzhang_fortress
loading_div_e_sepid_cavern
loading_zahhak_damavand
loading_simorgh_arrival
loading_kaveh_derafsh
loading_zal_scroll
loading_gordafarid_gate
13.4 Audio briefs
music_main_menu_theme
music_world_map_theme
music_scroll_of_fate_theme
music_pardeh_break_theme
music_khan_01_lion_theme
music_khan_02_desert_thirst_theme
music_khan_03_azhdaha_theme
music_khan_04_sorceress_theme
music_khan_05_olad_theme
music_khan_06_arzhang_div_theme
music_khan_07_div_e_sepid_theme
music_hunt_zahhak_theme
music_damavand_binding_theme
music_victory_theme
music_defeat_theme
31

-- 31 of 35 --

sfx_shared_ui_pack
sfx_signature_system_pack
ambience_map_pack
Audio direction:
Create an original soundtrack brief for SHAHNAMEH TD.
Use an Iranian epic and mythic atmosphere with respectful instrumental
inspiration, strong melodic identity, controlled percussion, mobile-friendly
clarity, and dynamic layers that support gameplay intensity.
Avoid generic Hollywood trailer music, excessive wall-of-sound mixing, modern
EDM drops, and imitation of copyrighted melodies.
Deliver:
- narrative intention
- tempo range
- instrumentation direction
- calm layer
- combat layer
- boss layer where applicable
- seamless loop guidance
- transition stingers
- mobile-mix notes
14. PHASE 7 — GODOT INTEGRATION TASKS
Create implementation tasks for:
system_sprite_import_pipeline
system_sprite_validator
system_tilemap_pipeline
system_battle_hud
system_pardeh_break
system_vfx_pooling
system_audio_manager
system_data_resources
system_save_service
system_liveops_config
system_cosmetic_shop
32

-- 32 of 35 --

system_analytics
system_mobile_performance
Required engineering rule:
Every production asset must be referenced by a stable asset ID.
Never rely on filename guessing inside gameplay code.
Use data-driven resources for heroes, enemies, waves, towers, cards, relics,
maps, objectives, and cosmetics.
15. FULL ASSEMBLED PROMPT EXAMPLE — RAKHSH
Create production-ready 2D illustrated game art for SHAHNAMEH TD, a landscape-
mobile tower-defense roguelite inspired by Ferdowsi’s Shahnameh and Persian
miniature painting.
Use the attached approved Rostam reference image as the primary visual-style
anchor. Transfer the visual system, not Rostam’s exact costume.
VISUAL SYSTEM:
detailed hand-painted 2D game illustration; strong dark-brown or near-black
contour lines; thinner controlled internal linework; painterly cel-shading; aged
bronze, antique gold, copper, leather, timber, stone, textile, and parchment
materials; deep teal, lapis-inspired blue, crimson, rust red, ivory, charcoal,
and controlled warm-orange Sacred Fire accents; restrained cold-blue and shadow-
violet corruption accents; Iranian epic identity; polished mobile-readable
silhouette; elevated three-quarter gameplay perspective.
CANONICAL RULE:
Preserve the correct Shahnameh narrative role, Iranian epic identity, dignity,
and cultural coherence.
ASSET ID:
companion_rakhsh
ASSET TYPE:
Approved isolated base companion design for later animation production.
CHARACTER:
Rakhsh
NARRATIVE IDENTITY:
Rakhsh is Rostam’s loyal, brave, intelligent horse and an important companion in
33

-- 33 of 35 --

the Shahnameh.
GAMEPLAY ROLE:
Companion, mobility support, warning animation, and Khan 1 narrative asset.
DESIGN REQUIREMENTS:
- believable heroic stallion anatomy
- warm reddish coat
- darker mane and tail
- expressive eyes
- powerful legs
- restrained heroic saddle
- bronze details
- deep-teal textile accents
- no monster features
- no excessive armor
TECHNICAL OUTPUT:
- one full-body isolated design
- transparent RGBA background
- elevated three-quarter gameplay perspective
- bottom-center pivot
- safe padding around legs, mane, and tail
- compose for later 256 × 256 animation cells
- no scenery
- no text
- no watermark
NEGATIVE PROMPT:
photorealistic, photography, 3D render, anime, generic cartoon, generic Western
fantasy, European knight styling, Viking styling, fake Persian writing, text,
logos, watermark, excessive armor, cropped body, cropped tail, broken anatomy,
duplicate limbs, blurry silhouette, inconsistent perspective.
16. FINAL ASSET QA CHECKLIST
Style
Does the asset match the Rostam visual anchor?
Are contour lines and cel-shading consistent?
Does it belong in the same illustrated world?
•
•
•
34

-- 34 of 35 --

Cultural coherence
Is the design recognizably Iranian-epic-inspired?
Did the generator accidentally add generic Western fantasy?
Is all fake writing removed?
Gameplay readability
Is the silhouette recognizable at mobile scale?
Are enemies distinguishable by behavior?
Are build pads and routes readable?
Are VFX controlled enough to preserve tactical clarity?
Technical quality
Are transparent edges clean?
Are pivots consistent?
Do animations stay inside cells?
Are map layers separable?
Are UI touch targets large enough?
Are asset IDs stable?
Production discipline
Was the asset approved before animation production?
Is the asset actually needed for the current milestone?
Has it been tested inside the game rather than judged only as an isolated image?
•
•
•
•
•
•
•
•
•
•
•
•
•
•
•
•
35

-- 35 of 35 --

