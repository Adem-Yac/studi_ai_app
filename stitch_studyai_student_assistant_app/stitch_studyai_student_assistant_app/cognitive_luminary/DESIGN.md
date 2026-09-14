---
name: Cognitive Luminary
colors:
  surface: '#f9f9ff'
  surface-dim: '#d3daef'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f1f3ff'
  surface-container: '#e9edff'
  surface-container-high: '#e1e8fd'
  surface-container-highest: '#dce2f7'
  on-surface: '#141b2b'
  on-surface-variant: '#464555'
  inverse-surface: '#293040'
  inverse-on-surface: '#edf0ff'
  outline: '#767586'
  outline-variant: '#c6c5d7'
  surface-tint: '#474adb'
  primary: '#4143d5'
  on-primary: '#ffffff'
  primary-container: '#5b5fef'
  on-primary-container: '#f9f6ff'
  inverse-primary: '#c0c1ff'
  secondary: '#6b38d4'
  on-secondary: '#ffffff'
  secondary-container: '#8455ef'
  on-secondary-container: '#fffbff'
  tertiary: '#006645'
  on-tertiary: '#ffffff'
  tertiary-container: '#008259'
  on-tertiary-container: '#e1ffec'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e1e0ff'
  primary-fixed-dim: '#c0c1ff'
  on-primary-fixed: '#05006c'
  on-primary-fixed-variant: '#2c2cc3'
  secondary-fixed: '#e9ddff'
  secondary-fixed-dim: '#d0bcff'
  on-secondary-fixed: '#23005c'
  on-secondary-fixed-variant: '#5516be'
  tertiary-fixed: '#6ffbbe'
  tertiary-fixed-dim: '#4edea3'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005236'
  background: '#f9f9ff'
  on-background: '#141b2b'
  surface-variant: '#dce2f7'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 40px
    fontWeight: '800'
    lineHeight: 48px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '800'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.015em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.005em
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0em
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0.005em
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
    letterSpacing: 0.01em
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.04em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

The visual narrative combines academic precision with radiant, encouraging intelligent assistance. Designed for ambitious students balancing demanding academic workloads, the experience avoids clinical sterile software tropes in favor of an uplifting, luminous atmosphere that feels like an encouraging study partner.

The visual style is **Modern Fluid Tech-Academic**: a blend of Material 3 and iOS fluidity, characterized by expansive soft-tinted canvases, generous squircle radii, featherweight ambient lighting, and vivid electric gradient infusions. Micro-interactions should feel tactile, elastic, and celebratory, reinforcing cognitive focus, retention milestones, and frictionless retrieval.

## Colors

The palette balances authoritative readability with focused dynamic energy:

- **Primary (`#5B5FEF` - Electric Indigo):** Drives primary actions, system status, active selection rings, and key focal anchors.
- **Secondary (`#8B5CF6` - Vibrant Violet):** Used for AI synthesis states, generative insights, streak badges, and progressive gradients alongside the primary hue.
- **Tertiary / Success (`#10B981` - Emerald Green):** Signals mastery, verified answers, positive memory retention, and study streak completions.
- **Warning (`#F59E0B` - Amber):** Highlights pending review cycles, exam countdown warnings, and intermediate confidence scores.
- **Error (`#EF4444` - Rose Red):** Flags incorrect responses, missed intervals, and critical network drops.
- **Canvas Base (`#F7F8FC`):** A soft, pale lavender-gray ground layer that suppresses optical glare during long study sessions while maintaining daylight clarity.
- **Surface Pure (`#FFFFFF`):** High-layer elevation containers, flashcard faceplates, and floating input modules.
- **Text Primary (`#111827`):** High-contrast deep slate for instant comprehension of academic text.
- **Text Secondary (`#6B7280`):** Neutral cool gray for meta-labels, timestamps, question counts, and subtle hints.
- **Structural Border (`#E5E7EB`):** Subtle boundaries separating nested modules without creating harsh gridlines.

## Typography

Plus Jakarta Sans provides geometric balance and warm, open apertures that feel human, approachable, and distinct from sterile standard system sans-serifs.

- **Numerics & Academic Formulae:** Tabular lining figures are enforced across flashcard decks, quiz scorecards, countdown timers, and metrics.
- **Emoji Accents:** System emojis act as contextual category identifiers (e.g., 🧬 Biology, 📐 Calculus, 💡 Flashcard) and must scale at 1.15x relative to their paired text baseline to preserve visual weight against bold headings.
- **Text Rhythm:** Academic body copy retains generous line height (150%) to facilitate scanning and active recall under mental fatigue.

## Layout & Spacing

The layout is built around a mobile-first, single-column viewport that translates cleanly into multi-column split views on larger tablets:

- **Mobile Viewports (<600px):** Single-column flow with a strict `1.25rem` (`20px`) horizontal outer margin, standard safe-area insets, and an 8pt vertical rhythm. Element spacing strictly utilizes the token scale (`space-xs` to `space-xl`).
- **Tablet / Foldable Viewports (600px–1024px):** Dual-pane structure (split-screen flashcards, note-taking panel beside conversation assistant) with `1.5rem` (`24px`) gutters and margins.
- **Bottom Navigation Dock:** Mobile layout anchors all critical trigger points (e.g., Ask AI, Next Card) within the bottom ergonomic thumb zone (bottom 35% of the screen height).

## Elevation & Depth

Depth is established through soft, light-permeable layering rather than heavy drop shadows:

- **Surface Ground (`#F7F8FC`):** The foundational backdrop layer.
- **Surface Elevation 1 (Card Default):** Crisp `#FFFFFF` resting on `#F7F8FC`, framed with a `1px` stroke of `#E5E7EB` and an ambient shadow: `0px 4px 20px -2px rgba(91, 95, 239, 0.04)`.
- **Surface Elevation 2 (Active/Floating Cards & Popovers):** `#FFFFFF` paired with `0px 12px 32px -4px rgba(17, 24, 39, 0.08)` and a faint primary reflection `0px 0px 0px 1px rgba(91, 95, 239, 0.08)`.
- **AI Glowing Elevation (Generative States):** Contextual modules actively streaming responses receive a dynamic dual aura: `0px 0px 24px 0px rgba(139, 92, 246, 0.15)` combined with a subtle interior gradient border.
- **Modal Backdrops:** Frosted backdrop filter (`blur(12px)`) with a tint of `rgba(17, 24, 39, 0.35)`.

## Shapes

The interface embraces organic, comfortable squircles consistent with modern mobile environments:

- **Base Cards & Modules:** Standardized at `16px` (`rounded-lg`) up to `24px` (`rounded-xl`) corner radii, preventing visual harshness.
- **Pill Containers:** Pill shapes (`9999px`) are reserved exclusively for contextual tags, status badges, action chips, and bottom floating interaction prompts.
- **Input Fields:** Form controls utilize `16px` radii, harmonizing with nested surface modules.
- **Flashcard Component:** Master interactive cards adopt `24px` radii with continuous Apple-style squircle curvature.

## Components

### Buttons
- **Primary Action:** Solid Electric Indigo (`#5B5FEF`) or vibrant gradient (`#5B5FEF` to `#8B5CF6`), text pure `#FFFFFF` (`label-lg`), height `52px`, radius `9999px` (pill). Depressed state scales down slightly to `0.98` with enhanced contrast.
- **Secondary Action:** Tinted light indigo fill (`rgba(91, 95, 239, 0.08)`), text `#5B5FEF`, no border, height `52px`, radius `9999px`.
- **Ghost / Tertiary:** No fill, text `#6B7280` hovering to `#111827`, minimal tap target `44px x 44px`.

### Chips & Filter Pills
- **State:** Inactive chips have `#FFFFFF` fill with `1px` border of `#E5E7EB` and `#6B7280` text. Active chips adopt Electric Indigo fill with `#FFFFFF` text.
- **Dimensions:** Height `36px`, horizontal padding `16px`, pill radius (`9999px`), typography `label-md`.

### Cards & Flashcards
- **Flashcard Deck:** Stacked container pattern with a `#FFFFFF` faceplate, `24px` corner radius, `1px` solid `#E5E7EB` edge. Active flipped card reveals deep `#111827` backplate with Electric Indigo highlights.
- **Module Card:** Standard card background `#FFFFFF`, radius `16px`, internal padding `space-md` (`16px`) to `space-lg` (`24px`).

### Text Inputs & AI Prompt Box
- **Search & Text Input:** Height `52px`, background `#FFFFFF`, border `1.5px` solid `#E5E7EB`, radius `16px`, placeholder color `#6B7280`. Focused state shifts border to `#5B5FEF` with an outer halo of `rgba(91, 95, 239, 0.12)`.
- **Floating AI Prompt Bar:** Multi-line pill capsule elevated at Elevation 2, housing input, microphone action, and sending button within an integrated unified bar.

### Selection Controls
- **Checkboxes & Radios:** `22px` diameter, `6px` radius for checkboxes, full circle for radios. Active state filled with `#5B5FEF` with `#FFFFFF` checkmark icon or center dot. Inactive state features `1.5px` outline of `#E5E7EB`.

### Specialized Domain Components
- **Streak & Mastery Tracker:** Compact horizontal pill pillioned with an animated flame emoji (`🔥`), numeric count in `Plus Jakarta Sans ExtraBold`, and an active progress bar accented with Tertiary Emerald (`#10B981`).
- **AI Citation Snippet:** Micro-callout within AI answers showing reference textbook pages with a pale purple tint (`rgba(139, 92, 246, 0.08)`), rounded `8px`, and `body-sm` typography.