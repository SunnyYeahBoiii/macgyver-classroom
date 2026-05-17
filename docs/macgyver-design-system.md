# MacGyver Classroom — Design System Spec

> **Mục đích file này:** spec đầy đủ về color + visual style cho project MacGyver Classroom (AI nhận diện vật liệu cũ → gợi ý thí nghiệm STEM cho giáo viên). Paste toàn bộ file này vào AI assistant (Claude / ChatGPT / Cursor / v0 / Bolt) khi cần generate UI/component/illustration để đảm bảo nhất quán.
>
> **Mục lục:**
> - Mục 1-2: Brand context + design principles
> - Mục 3-5: Color tokens, typography, spacing
> - Mục 6-9: Component recipes, Tailwind config, CSS variables, JSON tokens
> - Mục 10-11: Do/Don't checklist + prompt template
> - **Mục 12: Visual style language** — block + grain + circuit (rút từ logo)
> - Mục 13: Changelog

---

## 1. Brand context

- **Product:** AI vision app cho giáo viên STEM cấp 2-3, chụp ảnh tủ đồ cũ → gợi ý thí nghiệm + giáo án.
- **Vibe:** maker spirit, recycled, học mà chơi, ấm áp nhưng vẫn pro.
- **Logo:** monogram "LH" bằng block nâu (cardboard texture) + đường mạch điện xanh dương trên nền vàng honey.
- **Color scheme đã chốt:** **Scheme B — Logo as Accent.** Nền trung tính, dùng màu logo làm điểm nhấn. Lựa chọn này ưu tiên eye-comfort khi giáo viên dùng app 30-45 phút/lần.

---

## 2. Design principles

Khi generate UI theo palette này, tuân thủ 5 nguyên tắc:

1. **Quy tắc 60-30-10.** Surface neutral 60%, card trắng 30%, brand color (xanh + vàng) chỉ ~10%. Đừng full background vàng/xanh.
2. **Vàng KHÔNG phải CTA chính.** CTA primary luôn là xanh dương `#1A24A8`. Vàng chỉ dùng cho badge accent, tier yellow, highlight nhỏ.
3. **Không dùng đen tuyệt đối.** Text chính là `#2C2C2A` (gần đen, ấm), không phải `#000`.
4. **Border 0.5px hoặc 1px.** Không bao giờ dày hơn. Border màu `#E5E2D7`.
5. **Không gradient, không shadow lớn, không glow.** Flat design. Focus ring nhẹ cho input là được.

---

## 3. Color tokens

### 3.1 Surfaces (nền)

| Token | Hex | Dùng cho |
|---|---|---|
| `bg-page` | `#FAFAF7` | Background trang toàn cục (off-white ấm) |
| `bg-card` | `#FFFFFF` | Card, modal, dropdown |
| `bg-subtle` | `#F5F2EA` | Hover state, section divider, code block |

### 3.2 Brand

| Token | Hex | Dùng cho |
|---|---|---|
| `brand-primary` | `#1A24A8` | CTA chính, link active, focus ring, logo |
| `brand-primary-hover` | `#141C8A` | Hover của brand-primary |
| `brand-primary-soft` | `#E8EAF8` | Badge info background, selected state |
| `brand-accent` | `#F5B945` | Highlight nhỏ, accent icon, illustration |
| `brand-accent-soft` | `#FDF1D9` | Badge accent background |
| `brand-earth` | `#7A5B14` | Text trên nền vàng nhạt, accent secondary |

### 3.3 Ink (text)

| Token | Hex | Dùng cho |
|---|---|---|
| `ink-primary` | `#2C2C2A` | Text chính, heading |
| `ink-muted` | `#5F5E5A` | Text phụ, metadata, label |
| `ink-subtle` | `#9A9994` | Placeholder, disabled, hint |

### 3.4 Border

| Token | Hex | Dùng cho |
|---|---|---|
| `border` | `#E5E2D7` | Border mặc định (card, input, divider) |
| `border-strong` | `#C8C5B6` | Hover border, emphasized divider |

### 3.5 Semantic tiers (safety system)

Mỗi tier có cặp soft (background) + dark (text/border).

| Tier | Soft (bg) | Dark (text/border) | Ý nghĩa |
|---|---|---|---|
| Green | `#EAF3DE` | `#3B6D11` | An toàn — học sinh tự làm. Cũng dùng cho ESG impact, success state. |
| Yellow | `#FDF1D9` | `#B47514` | Cần giám sát — giáo viên hỗ trợ. Cũng dùng cho warning. |
| Red | `#FCEBEB` | `#A32D2D` | Chỉ giáo viên thao tác. Cũng dùng cho error/danger. |

---

## 4. Typography

| Role | Font | Weight | Khi dùng |
|---|---|---|---|
| Display / heading | `'Plus Jakarta Sans', Inter, sans-serif` | 500-600 | h1, h2, h3, hero title |
| Body | `'Inter', system-ui, sans-serif` | 400-500 | Mọi text khác |
| Mono | `'JetBrains Mono', ui-monospace, monospace` | 400-500 | Hex code, file path, mã số |

**Font sizes (rem assume 16px base):**

- h1: 28-32px (1.75-2rem), weight 600
- h2: 22-24px (1.375-1.5rem), weight 600
- h3: 18px (1.125rem), weight 500
- Body: 14-15px (0.875-0.9375rem)
- Small/meta: 12-13px
- Tiny/label: 11px uppercase, letter-spacing 0.08em

**Không dùng:**
- Font weight > 700 (quá nặng so với palette warm-neutral)
- Font size < 11px
- Title Case hoặc ALL CAPS trừ label kỹ thuật

---

## 5. Spacing & radius

**Border radius:**
- `4px` — badge, tag
- `6px` — button, input
- `8px` — card nhỏ, dropdown
- `12px` — card lớn, section
- `16px` — modal, hero card

**Spacing scale (multiples of 4):**
- Tight: 4, 6, 8px
- Comfortable: 12, 16, 20px
- Section: 24, 32, 48px

---

## 6. Component recipes

### 6.1 Button

```css
/* Primary CTA */
.btn-primary {
  background: #1A24A8;
  color: white;
  padding: 8px 16px;
  border-radius: 6px;
  border: none;
  font-weight: 500;
  font-size: 14px;
}
.btn-primary:hover { background: #141C8A; }

/* Secondary */
.btn-secondary {
  background: white;
  color: #2C2C2A;
  padding: 8px 16px;
  border-radius: 6px;
  border: 0.5px solid #C8C5B6;
  font-weight: 500;
  font-size: 14px;
}
.btn-secondary:hover { border-color: #1A24A8; }

/* Tertiary (text only) */
.btn-tertiary {
  background: transparent;
  color: #1A24A8;
  padding: 8px 12px;
  border: none;
  font-weight: 500;
}
```

### 6.2 Card

```css
.card {
  background: #FFFFFF;
  border: 0.5px solid #E5E2D7;
  border-radius: 8px;
  padding: 16px 20px;
}
.card:hover { border-color: #C8C5B6; }
```

### 6.3 Badge

```css
.badge {
  display: inline-flex;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}
.badge-info  { background: #E8EAF8; color: #1A24A8; }  /* ngành học, info chung */
.badge-tier-green  { background: #EAF3DE; color: #3B6D11; }  /* tier xanh, ESG */
.badge-tier-yellow { background: #FDF1D9; color: #B47514; }  /* tier vàng, warn */
.badge-tier-red    { background: #FCEBEB; color: #A32D2D; }  /* tier đỏ, danger */
```

### 6.4 Input

```css
.input {
  background: white;
  border: 0.5px solid #E5E2D7;
  border-radius: 6px;
  padding: 8px 12px;
  font-size: 14px;
  color: #2C2C2A;
}
.input:focus {
  outline: none;
  border-color: #1A24A8;
  box-shadow: 0 0 0 3px #E8EAF8;
}
.input::placeholder { color: #9A9994; }
```

---

## 7. Tailwind config (paste vào `tailwind.config.js`)

```js
export default {
  theme: {
    extend: {
      colors: {
        bg: {
          page: '#FAFAF7',
          card: '#FFFFFF',
          subtle: '#F5F2EA',
        },
        brand: {
          primary: '#1A24A8',
          'primary-hover': '#141C8A',
          'primary-soft': '#E8EAF8',
          accent: '#F5B945',
          'accent-soft': '#FDF1D9',
          earth: '#7A5B14',
        },
        ink: {
          primary: '#2C2C2A',
          muted: '#5F5E5A',
          subtle: '#9A9994',
        },
        border: {
          DEFAULT: '#E5E2D7',
          strong: '#C8C5B6',
        },
        tier: {
          green: '#3B6D11',
          'green-soft': '#EAF3DE',
          yellow: '#B47514',
          'yellow-soft': '#FDF1D9',
          red: '#A32D2D',
          'red-soft': '#FCEBEB',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        display: ['"Plus Jakarta Sans"', 'Inter', 'sans-serif'],
        mono: ['"JetBrains Mono"', 'ui-monospace', 'monospace'],
      },
      borderRadius: {
        DEFAULT: '6px',
        md: '8px',
        lg: '12px',
        xl: '16px',
      },
    },
  },
};
```

---

## 8. CSS variables (paste vào file global CSS)

```css
:root {
  /* Surfaces */
  --bg-page: #FAFAF7;
  --bg-card: #FFFFFF;
  --bg-subtle: #F5F2EA;

  /* Brand */
  --brand-primary: #1A24A8;
  --brand-primary-hover: #141C8A;
  --brand-primary-soft: #E8EAF8;
  --brand-accent: #F5B945;
  --brand-accent-soft: #FDF1D9;
  --brand-earth: #7A5B14;

  /* Ink */
  --ink-primary: #2C2C2A;
  --ink-muted: #5F5E5A;
  --ink-subtle: #9A9994;

  /* Border */
  --border: #E5E2D7;
  --border-strong: #C8C5B6;

  /* Semantic tiers */
  --tier-green: #3B6D11;
  --tier-green-soft: #EAF3DE;
  --tier-yellow: #B47514;
  --tier-yellow-soft: #FDF1D9;
  --tier-red: #A32D2D;
  --tier-red-soft: #FCEBEB;

  /* Radius */
  --radius-sm: 4px;
  --radius: 6px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-xl: 16px;
}
```

---

## 9. Design tokens (JSON, Figma-compatible)

```json
{
  "color": {
    "bg": {
      "page":   { "value": "#FAFAF7" },
      "card":   { "value": "#FFFFFF" },
      "subtle": { "value": "#F5F2EA" }
    },
    "brand": {
      "primary":       { "value": "#1A24A8" },
      "primary-hover": { "value": "#141C8A" },
      "primary-soft":  { "value": "#E8EAF8" },
      "accent":        { "value": "#F5B945" },
      "accent-soft":   { "value": "#FDF1D9" },
      "earth":         { "value": "#7A5B14" }
    },
    "ink": {
      "primary": { "value": "#2C2C2A" },
      "muted":   { "value": "#5F5E5A" },
      "subtle":  { "value": "#9A9994" }
    },
    "border": {
      "default": { "value": "#E5E2D7" },
      "strong":  { "value": "#C8C5B6" }
    },
    "tier": {
      "green":       { "value": "#3B6D11" },
      "green-soft":  { "value": "#EAF3DE" },
      "yellow":      { "value": "#B47514" },
      "yellow-soft": { "value": "#FDF1D9" },
      "red":         { "value": "#A32D2D" },
      "red-soft":    { "value": "#FCEBEB" }
    }
  }
}
```

---

## 10. Do / Don't checklist cho AI

Khi AI generate UI theo file này, kiểm tra:

### ✓ Do
- [ ] Background trang dùng `bg-page` (#FAFAF7), không phải #FFF thuần
- [ ] CTA chính luôn là `brand-primary` (xanh)
- [ ] Vàng `brand-accent` chỉ dùng cho badge/highlight, ≤10% diện tích
- [ ] Text dùng `ink-primary` (#2C2C2A), không dùng #000
- [ ] Border 0.5px hoặc 1px, không dày hơn
- [ ] Border-radius dùng giá trị từ scale (4/6/8/12/16)
- [ ] Heading dùng Plus Jakarta Sans, body dùng Inter
- [ ] Tier badge dùng đúng cặp soft + dark từ semantic tiers

### ✗ Don't
- [ ] Đừng dùng vàng/xanh làm full background
- [ ] Đừng dùng 2 màu brand cùng làm CTA (chọn 1)
- [ ] Đừng thêm màu mới ngoài palette
- [ ] Đừng dùng gradient, shadow lớn, glow, neon
- [ ] Đừng dùng emoji thay icon (dùng lucide-react hoặc tabler icons)
- [ ] Đừng Title Case hoặc ALL CAPS trừ label kỹ thuật nhỏ
- [ ] Đừng font weight 700+ (quá nặng)
- [ ] Đừng border-radius asymmetric (vd chỉ rounded một góc)

---

## 11. Prompt mẫu khi dùng file này với AI

> Tôi đã paste color system spec ở trên. Áp dụng đúng palette và nguyên tắc trong đó để generate [TÊN COMPONENT/PAGE]. Yêu cầu cụ thể: [MÔ TẢ].
>
> Constraint:
> - Stack: React + TypeScript + Tailwind (config đã có ở mục 7)
> - Icon: lucide-react
> - Không thêm màu ngoài palette
> - Tuân thủ checklist Do/Don't ở mục 10

**Ví dụ:**

> [Paste file spec]
>
> Tôi đã paste color system spec ở trên. Áp dụng đúng palette để generate component `ExperimentCard` hiển thị 1 thí nghiệm STEM. Yêu cầu:
> - Title thí nghiệm + tier badge (green/yellow/red) cùng hàng
> - Description ngắn 2 dòng
> - Meta: môn học, thời gian, ESG impact (số chai diverted)
> - Nút "Xem giáo án" ở cuối
> - Hover state có border đậm hơn
>
> Constraint: React + Tailwind, lucide-react, không thêm màu ngoài palette.

---

## 12. Visual style — Logo-derived illustration language

Phần này mô tả style ngôn ngữ rút ra từ logo, để AI có thể generate hero illustration, empty state, decorative canvas, background pattern đúng vibe maker.

### 12.1 Five style primitives (rút từ logo)

| Primitive | Mô tả | Khi dùng |
|---|---|---|
| **Block shapes** | Rectangle xếp lệch chồng nhau, có offset 8-20px, không thẳng hàng cứng. Tỷ lệ thẳng đứng (portrait), aspect ratio ~1:2 đến 1:3. | Hero illustration, empty state, section divider |
| **Grain texture** | Stipple/noise texture chất liệu cardboard/wood. Không dùng solid flat fill cho block lớn. | Block shapes, large filled area |
| **Circuit lines** | Đường stroke thẳng, chỉ bẻ góc 90°, kèm node tròn (•) tại điểm uốn. Stroke width 2-4px. Màu `brand-primary`. | Connecting elements, "tech" accent, decorative overlay |
| **Wonky rotation** | Xoay nhẹ 1-4° lệch khỏi trục thẳng. Tránh hoàn hảo. | Block, badge, illustration container |
| **Strict 3-color** | Background warm + block earth + circuit blue. Không thêm màu nào khác trong illustration. | Mọi decorative element |

### 12.2 Block shapes — recipe chi tiết

```css
/* Container cho block illustration */
.block-stack {
  position: relative;
  background: #F5B945;  /* honey background của logo */
  padding: 32px;
  border-radius: 12px;
}

/* Block đơn vị */
.block {
  background-color: #7A5B14;
  /* Texture overlay — xem mục 12.3 */
  background-image: var(--grain-texture);
  background-blend-mode: multiply;
  border-radius: 2px;  /* corner gần như vuông */
}

/* Sizes phổ biến */
.block-tall { width: 60px; height: 160px; }
.block-mid  { width: 60px; height: 120px; }
.block-wide { width: 80px; height: 100px; }

/* Offset positioning */
.block-stack .block:nth-child(1) { transform: translate(0, 0) rotate(-1deg); }
.block-stack .block:nth-child(2) { transform: translate(40px, 20px) rotate(2deg); }
.block-stack .block:nth-child(3) { transform: translate(80px, -10px) rotate(-2deg); }
```

**Nguyên tắc layout block:**
- Tối thiểu 2 block, tối đa 4-5 block trong 1 composition
- Block kế nhau LUÔN khác chiều cao (không bao giờ cùng size)
- Offset cả X và Y, không chỉ 1 chiều
- Rotation -3° đến +3°, không nhiều hơn

### 12.3 Grain texture — implementation

Có 3 cách tạo texture grain, từ đơn giản đến chuyên nghiệp:

**Cách 1 — SVG filter (recommended, không cần asset):**

```html
<svg width="0" height="0" style="position:absolute">
  <defs>
    <filter id="grain">
      <feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="3" seed="5"/>
      <feColorMatrix values="0 0 0 0 0
                             0 0 0 0 0
                             0 0 0 0 0
                             0 0 0 0.4 0"/>
      <feComposite operator="in" in2="SourceGraphic"/>
    </filter>
  </defs>
</svg>

<!-- Apply -->
<div class="block" style="filter: url(#grain) brightness(1)"></div>
```

**Cách 2 — CSS radial-gradient noise (fallback):**

```css
.block {
  background:
    radial-gradient(circle at 20% 30%, rgba(0,0,0,0.15) 0.5px, transparent 1px),
    radial-gradient(circle at 70% 60%, rgba(0,0,0,0.1) 0.5px, transparent 1px),
    radial-gradient(circle at 40% 80%, rgba(0,0,0,0.12) 0.5px, transparent 1px),
    #7A5B14;
  background-size: 8px 8px, 12px 12px, 10px 10px, 100% 100%;
}
```

**Cách 3 — PNG texture asset (production):** dùng file PNG noise/grain riêng, blend `multiply`.

### 12.4 Circuit lines — recipe

```html
<svg viewBox="0 0 400 200" stroke="#1A24A8" stroke-width="3" fill="none">
  <!-- Đường circuit: chỉ góc 90° -->
  <path d="M 20 100 L 100 100 L 100 40 L 200 40 L 200 100 L 380 100"/>

  <!-- Node tại điểm uốn -->
  <circle cx="100" cy="100" r="5" fill="#1A24A8"/>
  <circle cx="100" cy="40"  r="5" fill="#1A24A8"/>
  <circle cx="200" cy="40"  r="5" fill="#1A24A8"/>
  <circle cx="200" cy="100" r="5" fill="#1A24A8"/>

  <!-- Endpoint nodes (lớn hơn chút) -->
  <circle cx="20"  cy="100" r="6" fill="#1A24A8"/>
  <circle cx="380" cy="100" r="6" fill="#1A24A8"/>
</svg>
```

**Nguyên tắc circuit:**
- Chỉ dùng góc 90° — không có đường chéo, không curve
- Node tròn (•) tại MỌI điểm bẻ góc — đây là signature của logo
- Stroke width 2-4px, không nhỏ hơn
- Endpoint có thể là node lớn hơn 1-2px
- Đường circuit có thể "chạy qua" block (overlay phía trên hoặc phía sau)

### 12.5 Composition patterns

3 layout chuẩn cho hero/illustration:

**Pattern A — Logo-like (block + circuit overlay):**
```
┌──────────────────────────┐
│  ╔═══╗ ╔════╗   •─────•  │  ← Circuit chạy qua/quanh block
│  ║   ║ ║    ║   │        │
│  ║▓▓▓║ ║▓▓▓▓║───•   ╔═╗  │  ← Block có grain texture
│  ║   ║ ║    ║       ║▓║  │
│  ╚═══╝ ╚════╝       ╚═╝  │
└──────────────────────────┘
   honey background (#F5B945)
```

**Pattern B — Block-only (cho card lớn, hero phụ):**
```
┌──────────────────────────┐
│  ╔═══╗   ╔═══╗           │
│  ║▓▓▓║   ║▓▓▓║   ╔═══╗   │
│  ║▓▓▓║   ║▓▓▓║   ║▓▓▓║   │
│  ╚═══╝   ╚═══╝   ╚═══╝   │
└──────────────────────────┘
   nền honey hoặc subtle
```

**Pattern C — Circuit-only (decorative line accent):**
```
┌──────────────────────────┐
│                          │
│  •───┐                   │  ← Circuit nhẹ làm divider/accent
│      │       ┌───•       │
│      └───────┘           │
│                          │
└──────────────────────────┘
   nền page hoặc card
```

### 12.6 Use cases cụ thể

| Use case | Pattern | Note |
|---|---|---|
| Hero illustration trang chủ | A | Full composition, dimension 600×400 |
| Empty state ("chưa có thí nghiệm nào") | B | 2-3 block + microcopy phía dưới |
| Loading skeleton | B với animation pulse | Block shapes có opacity 0.5 + pulse |
| Section divider | C | Circuit line ngang, padding 32px trên/dưới |
| Badge/sticker decorative | A mini | Scale xuống còn 60×60px |
| Background pattern (subtle) | C lặp lại | Opacity 0.05-0.1, làm watermark |
| 404 page | A + dimension xoay lệch | Block bị "rơi" |
| Onboarding illustration | A + 1 character icon | Block làm scenery, icon ở giữa |

### 12.7 Do / Don't cho illustration

#### ✓ Do
- [ ] Block LUÔN có grain texture, không bao giờ flat solid
- [ ] Circuit lines LUÔN có node tròn tại điểm bẻ góc
- [ ] Block kế nhau khác chiều cao (variety)
- [ ] Composition có rotation lệch nhẹ -3° đến +3°
- [ ] Strict 3 màu: honey bg + earth block + blue circuit
- [ ] Border-radius nhỏ (1-3px), gần như góc vuông

#### ✗ Don't
- [ ] Đừng dùng curve/arc cho circuit (chỉ góc 90°)
- [ ] Đừng dùng đường chéo (diagonal) cho circuit
- [ ] Đừng border-radius lớn cho block (mất chất cardboard)
- [ ] Đừng thêm gradient cho block (texture, không gradient)
- [ ] Đừng drop shadow lớn (flat, không 3D)
- [ ] Đừng dùng nhiều hơn 5 block trong 1 composition
- [ ] Đừng outline block (chỉ fill + texture, không stroke)
- [ ] Đừng dùng màu khác ngoài 3 màu logo (kể cả tier colors — tier chỉ cho UI badge, không cho illustration)

### 12.8 Code template — hero illustration sẵn dùng

```html
<svg viewBox="0 0 600 400" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <filter id="grain">
      <feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="3" seed="3"/>
      <feColorMatrix values="0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 0.35 0"/>
      <feComposite operator="in" in2="SourceGraphic"/>
    </filter>
  </defs>

  <!-- Honey background -->
  <rect width="600" height="400" fill="#F5B945" rx="12"/>

  <!-- Blocks với grain -->
  <g filter="url(#grain)">
    <rect x="120" y="80"  width="80" height="240" fill="#7A5B14" rx="2" transform="rotate(-1 160 200)"/>
    <rect x="240" y="140" width="80" height="180" fill="#7A5B14" rx="2" transform="rotate(2 280 230)"/>
    <rect x="360" y="100" width="80" height="220" fill="#7A5B14" rx="2" transform="rotate(-2 400 210)"/>
  </g>

  <!-- Circuit overlay -->
  <g stroke="#1A24A8" stroke-width="3" fill="#1A24A8">
    <path d="M 80 200 L 200 200 L 200 60 L 400 60 L 400 200 L 520 200" fill="none"/>
    <circle cx="200" cy="200" r="5"/>
    <circle cx="200" cy="60"  r="5"/>
    <circle cx="400" cy="60"  r="5"/>
    <circle cx="400" cy="200" r="5"/>
    <circle cx="80"  cy="200" r="6"/>
    <circle cx="520" cy="200" r="6"/>
  </g>
</svg>
```

### 12.9 Prompt mẫu cho AI generate illustration

> Tôi cần generate hero illustration cho [USE CASE]. Áp dụng visual style ở mục 12 của spec:
> - 3-4 block earth tone (#7A5B14) có grain texture, xếp lệch
> - Circuit line màu xanh (#1A24A8) bẻ góc 90° kèm node tròn
> - Background honey (#F5B945)
> - Rotation nhẹ -3° đến +3° cho từng block
> - Strict 3 màu, không thêm
>
> Dimension: [VD: 600×400]. Output dạng [SVG inline / React component / standalone SVG file].

---

## 13. Changelog

- **v1.1** (2026-05-16) — Thêm mục 12: Visual style language (block + grain + circuit) rút từ logo.
- **v1.0** (2026-05-16) — Initial Scheme B (Logo as Accent), chốt cho hackathon.

---

*File này là single source of truth cho color system + visual style của project. Khi có thay đổi, cập nhật version + changelog trước khi share lại.*
