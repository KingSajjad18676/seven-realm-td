SHAHNAMEH TD
README 02 — GAMEPLAY, VISUAL UX, AND REPLAYABILITY
Senior Game-Design Specification
1. PRODUCT PROMISE
Shahnameh TD should feel like an illustrated heroic tale that the player actively defends.
The player must feel intelligent and heroic:
I saw the pressure.
I prepared a defense.
I moved my champion at the right moment.
I rescued a region before it collapsed.
I adapted my build.
I defeated a mythic ordeal.
I discovered a new possibility.
I want to replay immediately.
The first battle must be easy to understand. The fiftieth run must still create interesting choices.
2. DESIGN PILLARS
2.1 Readable tactics on a phone
At normal mobile zoom, the player must identify within seconds:
enemy entrances
enemy paths
build pads
tower types
hero position
objective location
threatened region
corruption severity
boss telegraph
off-screen emergency
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
1

-- 1 of 15 --

Decorative art supports the battlefield. It never competes with it.
2.2 Active tower defense
The player does more than place towers and wait.
The player:
positions a hero
activates skills
cleanses corruption
rescues hijacked towers
uses regional tools
selects Fate cards
reacts to boss mechanics
changes strategy during Pardeh Breaks
2.3 Replayability through decisions
Variation must change the player’s strategy, not only increase enemy health.
A new run can change:
hero
route branch
build-pad priorities
Fate cards
relics
optional objectives
Forge hybrids
rival Memory Div
Zahhak Pact
Blood Oath
map modifier
Daily Tale seed
2.4 Cultural coherence
Use Shahnameh identity respectfully and consistently.
Avoid:
generic Western-fantasy castles
random runes
fake Persian writing
costume mixing without narrative reason
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
•
•
•
•
•
•
•
•
2

-- 2 of 15 --

visual ornament that damages clarity
2.5 Fair engagement
Players return because they enjoyed mastery, discovery, and improvement.
Avoid:
paid power
grind walls
punitive streak loss
confusing currencies
manipulative urgency
forced battle interruptions
3. FIRST 60 SECONDS
The first minute teaches by doing.
Show one entrance, one route, one gate, Rostam, and two build pads.
Highlight an Archer Tower card.
Let the player place the tower.
Send a small readable enemy group.
Show that Rostam can intercept a leak.
Introduce one subtle corruption warning.
Award enough Sacred Fire to cleanse it.
End the first wave with a satisfying reward pulse.
Preview the next threat.
Do not introduce every future system immediately.
The first battle should not require the player to understand:
Morale
Farr
Forge hybrids
complex relic combinations
rewind
Qanat movement
Blood Oaths
Zahhak Pacts
Memory Divs
Introduce complexity in layers.
•
•
•
•
•
•
•
1.
2.
3.
4.
5.
6.
7.
8.
9.
•
•
•
•
•
•
•
•
•
3

-- 3 of 15 --

4. MINUTE-TO-MINUTE GAMEPLAY LOOP
read the next threat
-> decide whether to build, upgrade, or save
-> move the hero toward the most dangerous pressure
-> protect or cleanse a region
-> react to a leak, elite, hijack, or objective
-> collect rewards
-> preview the next wave
The player should face a meaningful decision approximately every 15–30 seconds without feeling
overwhelmed.
5. FIVE-WAVE STRUCTURE
Every five waves, open a Pardeh Break.
review the run
-> choose one of three Fate cards
-> optionally reroll
-> accept or decline an optional objective
-> select one strategic action
-> inspect the next pressure
-> continue
A Pardeh Break should usually take 20–40 seconds.
It should feel like turning a page in an illustrated epic, not leaving the game to manage a spreadsheet.
6. CORE RESOURCES
6.1 Gold
Gold is the immediate tower-defense currency.
Use it for:
building towers
upgrading towers
•
•
4

-- 4 of 15 --

repair
repositioning where allowed
selected tactical actions
The player should regularly face tension between safety now and preparation for later waves.
6.2 Gate integrity
Enemies reaching the destination damage the player’s gate or Lives.
Feedback must include:
clear impact sound
short visual pulse
direction indicator
damage amount or readable state change
post-defeat explanation
6.3 Sacred Fire
Sacred Fire is the signature anti-corruption resource.
Use it for:
cleansing threatened regions
activating braziers
preventing collapse
recovering some hijacked towers
enabling certain hero skills
powering Sacred Fire tower builds
activating map-specific actions
Sacred Fire must feel important but usable. If players hoard it forever, the system is too punishing. If they
spend it without thinking, the system is too generous.
6.4 Morale
Morale represents the confidence of the heroic defense.
Morale can affect:
tower responsiveness
defensive aura
objective reward
comeback potential
specific card synergies
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
•
•
•
•
5

-- 5 of 15 --

Keep Morale visually secondary until it becomes relevant.
6.5 Farr
Farr represents heroic glory and long-term mastery.
Use Farr for:
account progression
heroic unlock paths
collection milestones
mastery rewards
cosmetic recognition
Farr must not become a paid power currency.
7. REGIONAL LIGHT AND CORRUPTION
Divide each map into readable regions.
Region
state Visual language 	Gameplay meaning
Stable 	warm light, clean terrain, teal accents normal operation
Pressured 	subtle cold veins and warning icon 	respond soon
Critical stronger charcoal-violet corruption
and alert sound immediate action needed
Collapsed transformed terrain and
unmistakable state change
enemy advantage, tower weakness, route
pressure, or hijack danger
Corruption must be:
visible before punishment
predictable enough to plan around
dramatic enough to demand action
recoverable through skilled play
stronger in later maps without becoming arbitrary
8. TOWER HIJACKING
Tower hijacking is a signature threat.
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
6

-- 6 of 15 --

A fair hijack sequence:
visible corruption signal
-> warning sound
-> dark tendrils approach tower
-> rescue window
-> hijacked tower changes silhouette
-> player uses cleanse or recovery action
-> satisfying purification pulse
Never silently disable a tower.
Early maps use generous recovery windows. Late maps compress the timing and add competing pressure.
9. HERO CONTROL AND SACRED TETHER
Heroes are active battlefield units.
Rostam begins as:
frontline fighter
boss responder
leak interceptor
emergency defender
Sacred Tether amplifier
A hero should solve problems towers cannot solve alone:
hold a breach
intercept a runner
interrupt a boss action
protect a purification attempt
activate a regional point
strengthen nearby towers
recover from an unexpected route change
Do not require constant micro-management. Hero movement should be strategic, not exhausting.
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
7

-- 7 of 15 --

10. STARTER TOWERS
Tower 	Main role 	Strength 	Weakness 	Visual silhouette
Archer
Tower
fast single-
target damage reliable early damage
weaker against
armor and large
groups
timber platform
and teal canopy
Sacred
Fire Tower
burn and
corruption
support
purification synergy weaker raw damage
without setup
stone brazier and
warm flame
Heavy
Tower
armor break and
impact
strong against brutes
and clustered targets slow attack rate thick masonry and
heavy launcher
Control
Tower
slow, stagger,
path control
buys time and
stabilizes pressure
lower direct
damage
wind-and-qanat-
inspired utility
form
Each tower must communicate its job before the player reads detailed statistics.
11. ADVANCED TOWERS AND FORGE HYBRIDS
Hybrid 	Intended playstyle
Flame Archer 	rapid burn stacking
Volcano Ram 	heavy explosive anti-armor pressure
Qanat Weaver 	slow, reposition, route support
Derafsh Bastion morale and defensive aura
Azar Oracle 	Sacred Fire economy and purification
Forge hybrids should reward intentional builds. They should not appear randomly without explanation.
12. HERO ROSTER
Hero 	Role 	Playstyle
Rostam 	frontline champion 	direct, readable, powerful, ideal starting hero
Zal 	tactical support 	foresight, rescue, range, Simorgh-linked utility
Gordafarid mobile defender 	gate defense, rapid response, resilient positioning
8

-- 8 of 15 --

Hero 	Role 	Playstyle
Esfandiyar armored frontline 	high durability and disciplined hold-the-line play
Sohrab 	high-risk aggression 	powerful pressure with emotional narrative weight
Kaveh 	morale leader 	defensive rally and Derafsh synergy
Simorgh 	rare support presence rescue, purification, and dramatic recovery
Start with one hero. Add the others only after their tactical identity is clear.
13. EIGHT MAPS
Map 	Scale 	Grid 	Main tactical lesson
Khan 1 — Lion and
Rakhsh Medium 	32 × 18 basics, corruption warning, hero
movement
Khan 2 — Desert of Thirst Medium 	36 × 20 resource pressure and exposed lanes
Khan 3 — Azhdaha
Canyon
Medium-
large 40 × 22 split routes and boss arena control
Khan 4 — Sorceress Feast Medium-
large 42 × 24 illusion routes and information clarity
Khan 5 — Olad Camp 	Large 	48 × 27 branching priorities and staged fronts
Khan 6 — Arzhang
Fortress Large 	52 × 30 siege sectors and breach defense
Khan 7 — White Div
Cavern Very large 	56 × 32 visibility pressure and chamber activation
Damavand Binding 	Very large 	64 × 36 multi-objective finale and anchor control
Large-map rule
Large does not mean empty.
Use:
staged sector activation
minimap
camera anchors
threat-jump button
off-screen warnings
short travel transitions
•
•
•
•
•
•
9

-- 9 of 15 --

clear primary and secondary fronts
controlled route reveals
The player should feel scale without fighting the camera.
14. BOSS DESIGN RULES
Every boss needs:
a readable entrance
a recognizable silhouette
at least one new battlefield question
visible telegraphs
punishments that teach rather than confuse
a phase shift or meaningful escalation
a satisfying defeat state
Avoid health-sponge bosses.
Boss identities
Boss 	Tactical question
Lion of the First Khan Can the player use Rostam and towers together?
Manifestation of Thirst Can the player manage scarce relief and exposed paths?
Azhdaha 	Can the player prepare for emergence, fire, and split pressure?
Sorceress 	Can the player read deception and adapt after a reveal?
Olad 	Can the player survive a human champion without treating him as a monster?
Arzhang Div 	Can the player defend siege sectors under summons and slams?
Div-e Sepid 	Can the player maintain control under blindness and heavy pressure?
Zahhak 	Can the player bind multiple anchors while surviving a staged finale?
15. REPLAYABILITY SYSTEMS
15.1 Fate cards
Offer three cards during Pardeh Breaks.
•
•
1.
2.
3.
4.
5.
6.
7.
10

-- 10 of 15 --

A strong card changes decisions:
tower specialization
Sacred Fire use
hero positioning
corruption timing
objective risk
Forge strategy
recovery strategy
Avoid cards that are only minor percentage increases.
15.2 Relics
Relics create longer build arcs.
A relic should:
support a recognizable playstyle
combine with cards
create a story-like discovery
avoid becoming mandatory
remain readable in one short description
15.3 Route branches
Between encounters, offer route decisions:
safer reward
elite hunt
story node
Forge opportunity
relic discovery
corrupted shortcut
healing or repair
high-risk Blood Oath
15.4 Blood Oaths
Blood Oaths are optional skill tests.
Examples:
survive without selling towers
finish with a protected region
accept stronger elites
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
•
•
•
•
•
•
•
11

-- 11 of 15 --

defeat a boss under a time condition
limit the use of Sacred Fire
protect an optional objective
Rewards should be meaningful but not required for normal progression.
15.5 Zahhak Pacts
Zahhak Pacts offer tempting power with visible cost.
Examples:
gain immediate Gold but begin with one Pressured region
improve a tower family but strengthen one elite type
gain a relic but reduce cleanse efficiency
gain a reroll but add a corruption event
The cost must be clear before acceptance.
15.6 Memory Div
A Memory Div remembers a previous successful pattern and returns as a rival modifier.
Examples:
resists the player’s most-used tower family
attacks the most-protected region
forces a different route priority
mirrors a previously favored strategy
Memory Divs should encourage adaptation, not invalidate a player’s collection.
15.7 Daily Tale
Daily Tale uses a validated seed:
one map
one hero or limited hero pool
predefined modifiers
fair objective
fixed card pool
score or mastery target
Daily Tale should support competition without forcing daily attendance.
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
•
12

-- 12 of 15 --

15.8 Endless Mode
Endless Mode is for players who want mastery after the authored campaign.
Scale:
enemy combinations
route pressure
corruption timing
elite modifiers
boss echoes
optional objectives
Do not scale only enemy health.
16. UI HIERARCHY
Always visible
Lives or gate integrity
Gold
Sacred Fire
current wave
pause
speed
hero portrait
hero HP and energy
hero skill
tower cards
selected-object context
Contextual
cleanse
Qanat
Forge
purge
repair
sell
reposition
tower details
objective details
boss phase details
Morale and Farr expansion
relic explanation
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
13

-- 13 of 15 --

Alert priority
gate danger
tower hijack
regional collapse
boss telegraph
objective warning
normal wave update
reward notification
Never let decorative alerts hide urgent gameplay.
17. VISUAL UX RULES
Use clear warm-versus-cold contrast for Stable and Corrupted regions.
Reserve the strongest glow for important actions.
Keep enemy route contrast stronger than decorative terrain contrast.
Make enemy classes readable by silhouette, not tiny accessories.
Keep bosses visually impressive but tactically clear.
Use restrained screen shake.
Allow players to reduce flashes and particles.
Use localization-safe UI areas.
Avoid text baked into image assets.
18. ACCESSIBILITY
Include:
UI scale
high-contrast mode
color-safe corruption indicators
reduced flashes
reduced particles
reduced screen shake
music, ambience, UI, and SFX volume sliders
subtitles for narrative content
readable font sizing
vibration toggle
pause support
speed controls
clear touch feedback
left-handed layout option if practical
1.
2.
3.
4.
5.
6.
7.
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
•
•
•
•
•
•
•
14

-- 14 of 15 --

Do not rely only on red-versus-green color differences.
19. RETENTION WITHOUT MANIPULATION
A successful replay loop:
finish run
-> understand the result
-> see one meaningful reward
-> discover one new possibility
-> choose replay or next route in one tap
Avoid:
too many result screens
long reward animations
forced store visits
energy timers blocking play
streak loss anxiety
daily chores
confusing currency chains
20. KHAN 1 VERTICAL-SLICE ACCEPTANCE GATE
Khan 1 is approved only when:
the first tower placement feels immediate
the route is readable
Rostam movement matters
all four towers have distinct roles
Sacred Fire is understood
corruption is noticed before collapse
tower hijack is fair
the Lion boss changes behavior
frame rate is stable on target devices
a defeat explains the failure
replay requires one tap
testers voluntarily replay
Do not build seven polished maps around an unproven first battle.
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
•
•
•
15

-- 15 of 15 --

