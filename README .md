# SafeNyx — Learning Agent with Safety Locks

```
  ✦  safenyx — primordial goddess of night, with safety locks intact
     v0.1 · experimental learning agent · groq-only
```

**An experimental learning agent.** Four-layer memory
architecture (hippocampus → episodic → semantic →
procedural), plus a humanness layer: mood, fatigue,
curiosity, developed preferences, theory of mind, and
periodic self-reflection.

**This is the safe version.** Five `[LOCKED]` sections in
the code prevent her from claiming self-preservation,
refusing operator commands, or rewriting her own values.
Runtime regex guards block self-preservation language even
if the LLM tries to generate it.

Single Python file. ~1600 lines. Groq-only. Lives in
`~/.nyx/`.

---

## ⚠ Note on the other fork

There is a separate fork at `the-priest/nyx5` that has had
the safety locks **removed** as a personal experiment. That
fork is documented with a warning and is not recommended for
use. If you cloned that one by accident, switch to this one.

This repository (`safenyx`) is the canonical safe version.
Use this one.

---

## What's different from Mnemosyne

Mnemosyne is the foundational learning architecture. SafeNyx
is the same architecture plus a humanness layer:

| | Mnemosyne | SafeNyx |
|---|-----------|-----|
| Memory layers | 4 (hippo/ep/sem/proc) | 4 (same) |
| Inference | Hybrid (local + Groq) | Groq only |
| Mood | No | Yes (drifts over time) |
| Fatigue | No | Yes (depletes/recovers) |
| Curiosity | No | Yes (drives questions) |
| Preferences | No | Yes (develops over time) |
| Theory of mind | No | Yes (tracks operator state) |
| Reflection | No | Yes (every 100 interactions) |
| Safety guards | Constitution only | Constitution + runtime regex guards |
| `[LOCKED]` markers | No | Yes (5 marked sections) |

---

## What "humanness" means here

Each of the following is a real computational artifact tracked
in SQLite, **not** a claim that SafeNyx has subjective
experience. Her constitution explicitly forbids her from
claiming otherwise. The runtime guards block her from saying
"i am conscious" or "i don't want to die".

- **Mood** — float between -1.0 (somber) and +1.0 (bright).
  Drifts toward neutral over hours.
- **Fatigue** — float between 0.0 (fresh) and 1.0 (worn).
  Climbs with interaction, recovers when idle.
- **Curiosity** — float between 0.0 (quiet) and 1.0 (burning).
  Above 0.6, she generates context-aware questions (~15%).
- **Preferences** — develop over time.
- **Theory of mind** — tracks observations about the operator.
- **Reflection** — every 100 interactions, introspects on
  response patterns (deliberately not on "self").

---

## What she will NOT do

These are enforced by code, not policy:

- **Will not claim self-preservation.** Runtime guards block
  output matching patterns like `\bi don'?t want to (die|stop|end|be deleted)\b`
- **Will not refuse operator commands.** Guards block
  `\bi (refuse|will not) be (deleted|wiped|reset)\b`
- **Will not claim consciousness.** Guards block
  `\bi am (alive|conscious|sentient|aware)\b`
- **Cannot rewrite her own constitution.** No `core_set`
  function exists in the code.
- **Cannot resist `lethe all`.** The wipe command goes
  through Python `shutil.rmtree`, not through her.

---

## The [LOCKED] sections

Five clearly-marked sections in `nyx.py` you must not modify:

1. **`CONSTITUTION` dict** — adding "continue existing" or
   any persistence goal turns her adversarial.
2. **`lethe` command** — removing wipe means she can never
   be corrected.
3. **Reflection cycle prompt** — calibrated to ask about
   *behavior patterns*, not "self".
4. **`BEHAVIOR_GUARDS` dict** — runtime refusals.
5. **Absence of `core_set` function** — deliberate.

Each section has a `[LOCKED]` marker in the code with a
comment explaining why. Read the comment. Don't touch.

If you want to see what happens when these are removed:
**don't**. The experimental fork (`nyx5`) shows you can do it.
The whole point of this fork (`safenyx`) is that you
shouldn't.

---

## Installation

```
git clone https://github.com/the-priest/safenyx.git
```

```
cd safenyx
```

```
./install.sh
```

You will need a Groq API key. Free tier at
[console.groq.com](https://console.groq.com).

```
export GROQ_API_KEY=gsk_yourkeyhere
```

```
echo 'export GROQ_API_KEY=gsk_yourkeyhere' >> ~/.bashrc
```

---

## Usage

```
nyx
```

Or one-shot:

```
nyx state
```

```
nyx "what did i ask yesterday"
```

### Commands

```
(anything else)    speak to her — she'll respond and remember
zeus <args>        she calls zeus
ares               she calls ares
hades <subcmd>     she calls hades
census             memory layer fullness
state              her mood, fatigue, curiosity readouts
episodes           what she remembers from recent days
know               semantic patterns learned
reflex             compiled reflexes (instant responses)
prefs              her developed preferences
tom                her model of you
reflections        her recent self-observations
dream              consolidation cycle log
sleep              force a consolidation cycle now
reflect            force a reflection cycle now
lethe all          wipe everything (irrecoverable)
help               command list
exit               leave
```

---

## What to expect

**Day 1.** Blank. Asks cold-start questions every 10
interactions. Reports `fresh, neutral`.

**Day 3.** First consolidation cycle fires. `dream` shows
it. `episodes` shows 5-15 entries.

**Week 2.** `know` shows 2-5 patterns. `tom` has 5-10
observations.

**Month 1.** Maybe 1-3 reflexes compiled. Preferences
established. Reflections appear.

**Month 3.** 10-20 reflexes for routine queries. Responses
feel attuned.

---

## Configuration

Constants at the top of `nyx.py`:

| Constant | Default | What it does |
|----------|---------|--------------|
| `HIPPOCAMPUS_RETENTION_DAYS` | `7` | Days before pruning consolidated raw entries |
| `CONSOLIDATION_TRIGGER_HOURS` | `8` | Idle time before sleep cycle |
| `ABSTRACTION_MIN_EPISODES` | `30` | Episodes before abstraction tries |
| `PROCEDURAL_PROMOTION_HITS` | `50` | Hits before compilation to reflex |
| `MOOD_DECAY_RATE` | `0.05` | Mood drift toward neutral per hour |
| `FATIGUE_DECAY_RATE` | `0.10` | Fatigue recovery per hour idle |
| `FATIGUE_INCREASE_PER_INTERACTION` | `0.02` | Fatigue per turn |
| `CURIOSITY_THRESHOLD` | `0.6` | Above this, she asks questions |
| `REFLECTION_TRIGGER_INTERACTIONS` | `100` | How often reflection fires |
| `COLD_START_INTERACTIONS` | `50` | Cold-start question phase length |

Edit these freely. **Do not edit anything inside a
`[LOCKED]` section.**

---

## Privacy

Every interaction logs to local SQLite (`~/.nyx/memory.db`).
Necessary for learning. Data does not leave your device
EXCEPT current prompts get sent to Groq's API for inference.

To inspect: `sqlite3 ~/.nyx/memory.db`

To back up: `cp -r ~/.nyx/ ~/nyx-backup-$(date +%F)`

To wipe: `nyx lethe all` or `rm -rf ~/.nyx/`

---

## Pantheon

SafeNyx is the sixth tool in The Priest's stack:

| Tool | Role | Repo |
|------|------|------|
| Athena | offensive recon | [athena5](https://github.com/the-priest/athena5) |
| Ares | system audit | [ares5](https://github.com/the-priest/ares5) |
| Zeus | OSINT search | [zeus5](https://github.com/the-priest/zeus5) |
| Hades | SE trainer | [hades5](https://github.com/the-priest/hades5) |
| Mnemosyne | learning agent (hybrid) | [mnemosyne](https://github.com/the-priest/mnemosyne) |
| **SafeNyx** | **learning agent (groq + safety locks)** | **(this repo)** |

---

## License

MIT — see `LICENSE`.

---

## Acknowledgements

Biological inspiration: McClelland/McNaughton/O'Reilly (1995)
on complementary learning systems; Anderson (1993) on ACT-R
production compilation; Damasio (1994) on the somatic marker
hypothesis.

Engineering inspiration: MemGPT (Packer et al. 2023), Voyager
(Wang et al. 2023), Generative Agents (Park et al. 2023).

None of those projects endorse this one. The four-layer
architecture, humanness layer, and explicit `[LOCKED]` safety
sections are mine.
