---
name: csmoove-music-taste
description: Cuy Sheffield's music generation preferences and taste profile. Use when generating music with Suno AI or similar tools to produce tracks Cuy will actually like. Triggers on "generate music", "make a song", "create a track", "music prompt", "suno", "vibe coding playlist", "workout playlist".
metadata: { "openclaw": { "emoji": "🎵", "autoTrigger": true } }
---

# CSmoove Music Taste Profile

## Overview
This skill captures Cuy's music preferences based on feedback from AI-generated music sessions. Use this to improve future music generation quality and craft better prompts.

## Universal Rules (All Genres)

### Instrumentals Win
- Always generate as **instrumental** — AI vocals are not good enough
- If vocals are needed, keep them minimal, abstract, and textural (e.g., breathy chops, not lead vocals)
- Never include lyrics about the specific activity (working out, coding, etc.) — it's always corny

### Prompt Strategy
- Suno has a **500 character limit** in non-custom mode — keep prompts concise
- Use **V4_5 model** for best quality
- Never reference specific artist names — causes generation failures. Use generic style descriptors instead
- Each generation produces 2 variations with wildly different quality — generate multiple batches (3+) to get enough good options
- **Hit rate is ~10%** — expect to curate heavily. Quantity gives better odds.

### Quality Patterns
- Cuy is very sensitive to production *execution*, not just the prompt description
- Two tracks from the same prompt can rate 2/10 and 7/10 — it's about feel, groove, and space
- BPM alone doesn't determine quality — a 90 BPM track can beat a 115 BPM track if the groove is right

---

## Genre Profile: Workout / Lifting Music

### Session: March 8, 2026
- 2 of 21 tracks were good (~9.5% hit rate)
- Best track: **Iron Rep Symphony** (instrumental)

### What Works
- "Hard hitting trap beat"
- "Aggressive workout anthem"
- "Menacing bass", "Dark atmospheric"
- "Cinematic orchestral elements"
- BPM range: **130-150** for heavy lifting
- Heavy 808s and bass

### What Doesn't Work
- Motivational spoken word (corny)
- Explicit workout/gym lyrics
- Overly positive "you can do it" vocal delivery

### Preferred Prompt Style
```
"Dark atmospheric trap instrumental, 138 BPM, cinematic orchestral hits with heavy 808s, aggressive energy"
```

---

## Genre Profile: Jazz-Hop / K-R&B (Vibe Coding)

### Session: March 22, 2026
- 2 of 8 tracks scored 6+ out of 10
- Best track: **서울 새벽 산책 #2** (Seoul Dawn Walk) — 7/10

### What Works
- **Groove over speed** — top track was 90 BPM, not the faster ones
- Head-nodding, groovy feel with space between elements
- Korean R&B / Seoul night aesthetic
- Rhodes electric piano with jazz voicings (7ths, 9ths)
- Lo-fi vinyl crackle, tape saturation
- Breathy Korean vocal chops as reverb texture (not lead)
- Warm analog synth pads
- Intimate saxophone in bridge sections
- Spacious, warm mixing

### What Doesn't Work
- Tracks that feel "sleepy" despite being slow — need rhythmic energy even at low BPM
- The 105-110 BPM range scored worst (2-3/10) — not a sweet spot for this genre
- Too many competing elements without enough space

### Ratings Data
| Track | BPM | Rating |
|-------|-----|--------|
| 서울 새벽 산책 #1 | 90 | 4/10 |
| 서울 새벽 산책 #2 | 90 | **7/10** |
| Gangnam Night Compiler #1 | 110 | 3/10 |
| Gangnam Night Compiler #2 | 110 | 3/10 |
| Seoul Night Debug #1 | 105 | 2/10 |
| Seoul Night Debug #2 | 105 | 3/10 |
| Midnight Stack Trace #1 | 115 | 2/10 |
| Midnight Stack Trace #2 | 115 | **6/10** |

### Preferred Prompt Style
```
"Dreamy instrumental jazz-hop, Korean R&B feel. Rhodes piano with jazz 7th and 9th chords over soft trap drums, muted 808, hi-hat rolls, lo-fi vinyl crackle. Analog synth pads. Nylon guitar phrases. Breathy Korean vocal chops in reverb as texture. Intimate sax solo in bridge. Seoul at 2am vibe. 90 BPM. Spacious warm analog mix, tape saturation. Melancholic but hopeful."
```

---

## Next Session Ideas
- Jazz-hop: Try keeping 90 BPM but with more rhythmic bounce in the drums (boom-bap influence)
- Jazz-hop: Experiment with fewer production elements — top tracks may have had more space
- Jazz-hop: Try Suno custom mode for more structural control
- Workout: Try cinematic/orchestral instrumentals without any trap influence
- Generate in batches of 3+ (6+ variations) to improve odds of getting a hit
