# MacGyver Classroom - Design System

Phiên bản: 0.1
Ngày: 2026-05-15
Trạng thái: Draft mới cho dự án MacGyver Classroom

## 1. Mục tiêu

Design system này là bản mới cho MacGyver Classroom, không copy palette xanh lá/đất của Cityfarm2.0. Hệ thống dùng light theme trắng - xanh biển làm mặc định và sinh dark theme từ cùng semantic tokens.

Định hướng sản phẩm:

- Công cụ làm việc cho giáo viên, không phải landing page trang trí.
- Sáng, sạch, dễ đọc trong môi trường lớp học.
- Ưu tiên scan nhanh, xác nhận inventory, đọc giáo án, xuất tài liệu.
- UI tin cậy, có cảm giác khoa học/giáo dục, không quá game hóa.

## 2. Principles

### 2.1. Teacher-First Utility

Màn hình app phải giúp giáo viên làm nhanh:

- Chụp ảnh.
- Xác nhận vật phẩm.
- Chọn thí nghiệm.
- Đọc/chỉnh giáo án.
- Xuất/chia sẻ tài liệu.

Không dùng text giải thích UI dài dòng trong app. Hướng dẫn ngắn, đúng lúc, gần hành động.

### 2.2. Evidence Over Magic

AI output phải có dấu vết:

- Vật phẩm nào được nhận diện từ ảnh.
- Vật phẩm nào dùng cho thí nghiệm.
- Vì sao thí nghiệm được đề xuất.
- Safety note nào cần kiểm tra.

### 2.3. Calm Classroom Surface

Tránh:

- Gradient/orb/bokeh trang trí.
- Card lồng card.
- Hero marketing trong app.
- Motion dài, custom cursor, hiệu ứng gây phân tâm.

Cho phép:

- Trạng thái rõ.
- Badge nhỏ.
- Divider tinh tế.
- Icon chức năng.
- Animation ngắn cho loading/scan.

### 2.4. Token-First

Không hard-code màu trong component. Dùng semantic tokens:

- `color.background`
- `color.surface`
- `color.primary`
- `color.text`
- `color.border`
- `color.status.warning`

Dark theme được sinh bằng mapping token, không viết lại layout.

## 3. Brand Direction

Tên sản phẩm: MacGyver Classroom
Tinh thần: thực dụng, sáng tạo, an toàn, STEM, giáo viên làm chủ AI.
Visual metaphor: giấy trắng, ánh sáng phòng học, nước/xanh biển, blueprint nhẹ, vật dụng đời thường.

Không dùng:

- Palette xanh lá nông nghiệp của Cityfarm.
- Brown/orange/soil làm màu chính.
- Purple gradient AI cliché.
- Beige/cream vintage.

## 4. Color System

### 4.1. Light Theme - White + Ocean Blue

Light theme là source of truth.

| Token       | Hex       | Usage                     |
| ----------- | --------- | ------------------------- |
| `white`     | `#FFFFFF` | Card, sheet, input        |
| `ocean-25`  | `#F7FCFF` | App background            |
| `ocean-50`  | `#EFF9FF` | Subtle panels             |
| `ocean-100` | `#DFF3FF` | Selected row, info bg     |
| `ocean-200` | `#B9E8FF` | Border active/subtle fill |
| `ocean-300` | `#7DD4F8` | Focus ring, charts        |
| `ocean-400` | `#38BDF8` | Accent                    |
| `ocean-500` | `#0EA5E9` | Primary                   |
| `ocean-600` | `#0284C7` | Primary hover/pressed     |
| `ocean-700` | `#0369A1` | Strong primary text       |
| `navy-900`  | `#082F49` | Main text                 |
| `slate-700` | `#334155` | Secondary text            |
| `slate-500` | `#64748B` | Muted text                |
| `slate-200` | `#E2E8F0` | Border                    |
| `slate-100` | `#F1F5F9` | Disabled bg               |

Semantic light tokens:

| Semantic Token         | Value                      |
| ---------------------- | -------------------------- |
| `color.background`     | `ocean-25`                 |
| `color.surface`        | `white`                    |
| `color.surface-subtle` | `ocean-50`                 |
| `color.surface-raised` | `white`                    |
| `color.text`           | `navy-900`                 |
| `color.text-secondary` | `slate-700`                |
| `color.text-muted`     | `slate-500`                |
| `color.primary`        | `ocean-500`                |
| `color.primary-hover`  | `ocean-600`                |
| `color.primary-text`   | `white`                    |
| `color.accent`         | `#14B8A6`                  |
| `color.border`         | `slate-200`                |
| `color.border-strong`  | `ocean-200`                |
| `color.focus`          | `rgba(14, 165, 233, 0.32)` |

### 4.2. Dark Theme - Generated From Light

Dark theme không đảo màu tự động theo RGB. Nó được sinh theo rule semantic:

| Light Semantic              | Dark Semantic               |
| --------------------------- | --------------------------- |
| `background: ocean-25`      | `#061826`                   |
| `surface: white`            | `#0B2235`                   |
| `surface-subtle: ocean-50`  | `#0F2D44`                   |
| `surface-raised: white`     | `#12334D`                   |
| `text: navy-900`            | `#E6F6FF`                   |
| `text-secondary: slate-700` | `#B7D4E8`                   |
| `text-muted: slate-500`     | `#7FA6BE`                   |
| `primary: ocean-500`        | `#38BDF8`                   |
| `primary-hover: ocean-600`  | `#7DD4F8`                   |
| `primary-text: white`       | `#052033`                   |
| `border: slate-200`         | `rgba(125, 212, 248, 0.18)` |
| `focus`                     | `rgba(56, 189, 248, 0.38)`  |

Dark semantic tokens:

| Semantic Token         | Value                       |
| ---------------------- | --------------------------- |
| `color.background`     | `#061826`                   |
| `color.surface`        | `#0B2235`                   |
| `color.surface-subtle` | `#0F2D44`                   |
| `color.surface-raised` | `#12334D`                   |
| `color.text`           | `#E6F6FF`                   |
| `color.text-secondary` | `#B7D4E8`                   |
| `color.text-muted`     | `#7FA6BE`                   |
| `color.primary`        | `#38BDF8`                   |
| `color.primary-hover`  | `#7DD4F8`                   |
| `color.primary-text`   | `#052033`                   |
| `color.accent`         | `#2DD4BF`                   |
| `color.border`         | `rgba(125, 212, 248, 0.18)` |
| `color.border-strong`  | `rgba(125, 212, 248, 0.36)` |
| `color.focus`          | `rgba(56, 189, 248, 0.38)`  |

### 4.3. Status Colors

| Status  | Light BG  | Light Text | Dark BG                | Dark Text |
| ------- | --------- | ---------- | ---------------------- | --------- |
| Success | `#ECFDF5` | `#047857`  | `rgba(16,185,129,.14)` | `#6EE7B7` |
| Warning | `#FFFBEB` | `#B45309`  | `rgba(245,158,11,.16)` | `#FCD34D` |
| Danger  | `#FEF2F2` | `#B91C1C`  | `rgba(239,68,68,.16)`  | `#FCA5A5` |
| Info    | `#EFF9FF` | `#0369A1`  | `rgba(56,189,248,.14)` | `#7DD4F8` |
| AI      | `#F0FDFA` | `#0F766E`  | `rgba(45,212,191,.14)` | `#5EEAD4` |

Safety-critical UI uses warning/danger, not primary blue.

## 5. Token Files

Canonical token source:

```text
packages/design-tokens/
├── tokens.json
├── tokens.light.json
├── tokens.dark.json
├── build.ts
└── generated/
    ├── tokens.css
    ├── tokens.tailwind.json
    └── tokens.dart
```

Rules:

- Light tokens are authored manually.
- Dark tokens are generated from semantic mapping and manually reviewed.
- Flutter, Next.js landing/admin and docs must consume generated outputs.
- Component files must not define product colors directly.

## 6. CSS Variable Output

```css
:root {
  color-scheme: light;
  --mc-bg: #f7fcff;
  --mc-surface: #ffffff;
  --mc-surface-subtle: #eff9ff;
  --mc-surface-raised: #ffffff;
  --mc-text: #082f49;
  --mc-text-secondary: #334155;
  --mc-text-muted: #64748b;
  --mc-primary: #0ea5e9;
  --mc-primary-hover: #0284c7;
  --mc-primary-text: #ffffff;
  --mc-accent: #14b8a6;
  --mc-border: #e2e8f0;
  --mc-border-strong: #b9e8ff;
  --mc-focus: rgba(14, 165, 233, 0.32);
  --mc-radius-sm: 6px;
  --mc-radius-md: 8px;
  --mc-radius-lg: 12px;
  --mc-radius-pill: 999px;
}

[data-theme="dark"] {
  color-scheme: dark;
  --mc-bg: #061826;
  --mc-surface: #0b2235;
  --mc-surface-subtle: #0f2d44;
  --mc-surface-raised: #12334d;
  --mc-text: #e6f6ff;
  --mc-text-secondary: #b7d4e8;
  --mc-text-muted: #7fa6be;
  --mc-primary: #38bdf8;
  --mc-primary-hover: #7dd4f8;
  --mc-primary-text: #052033;
  --mc-accent: #2dd4bf;
  --mc-border: rgba(125, 212, 248, 0.18);
  --mc-border-strong: rgba(125, 212, 248, 0.36);
  --mc-focus: rgba(56, 189, 248, 0.38);
}
```

## 7. Flutter Theme Mapping

```dart
ThemeData macgyverLightTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF0EA5E9),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF14B8A6),
    onSecondary: Color(0xFFFFFFFF),
    error: Color(0xFFB91C1C),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF082F49),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Color(0xFFF7FCFF),
    fontFamily: 'Inter',
  );
}

ThemeData macgyverDarkTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF38BDF8),
    onPrimary: Color(0xFF052033),
    secondary: Color(0xFF2DD4BF),
    onSecondary: Color(0xFF052033),
    error: Color(0xFFFCA5A5),
    onError: Color(0xFF2A0909),
    surface: Color(0xFF0B2235),
    onSurface: Color(0xFFE6F6FF),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Color(0xFF061826),
    fontFamily: 'Inter',
  );
}
```

## 8. Typography

Primary font:

- Mobile: system font or Inter if bundled.
- Web: Inter or system sans.
- Vietnamese fallback: `Arial`, `Roboto`, `system-ui`, `sans-serif`.

Scale:

| Role       | Mobile | Web/Admin | Weight |
| ---------- | ------ | --------- | ------ |
| Display    | 32/40  | 48/56     | 700    |
| H1         | 28/36  | 36/44     | 700    |
| H2         | 22/30  | 28/36     | 700    |
| H3         | 18/26  | 22/30     | 650    |
| Body       | 16/24  | 16/24     | 400    |
| Body Small | 14/20  | 14/20     | 400    |
| Caption    | 12/16  | 12/16     | 500    |
| Data Label | 11/14  | 12/16     | 600    |

Rules:

- Không scale font theo viewport width.
- Letter spacing mặc định `0`.
- Dùng mono font chỉ cho IDs, JSON, API snippets, model output debug.

## 9. Spacing And Layout

Base spacing unit: 4px.

| Token     | Value | Use                  |
| --------- | ----- | -------------------- |
| `space-1` | 4     | tight icon gap       |
| `space-2` | 8     | compact controls     |
| `space-3` | 12    | field gaps           |
| `space-4` | 16    | default card padding |
| `space-5` | 20    | section internal     |
| `space-6` | 24    | major section        |
| `space-8` | 32    | page blocks          |

Mobile:

- Page horizontal padding: 16px.
- Dense screens: 12px okay inside list rows.
- Bottom safe area always respected.
- Primary bottom action fixed only when it does not hide content.

Landing:

- Max content width: 1120px.
- Hero must show first signal of next section above fold.
- No card-in-card section composition.

Admin:

- Content width fluid.
- Tables/list-detail layouts.
- Dense but not cramped.

## 10. Radius, Border, Shadow

Cards should be 8px radius by default.

| Token         | Value | Use                        |
| ------------- | ----- | -------------------------- |
| `radius-sm`   | 6px   | inputs, chips              |
| `radius-md`   | 8px   | cards, panels              |
| `radius-lg`   | 12px  | sheets, dialogs            |
| `radius-pill` | 999px | badges, segmented controls |

Shadows:

| Token          | Value                             | Use          |
| -------------- | --------------------------------- | ------------ |
| `shadow-sm`    | `0 1px 2px rgba(8, 47, 73, .06)`  | small raised |
| `shadow-md`    | `0 8px 24px rgba(8, 47, 73, .08)` | modal/sheet  |
| `shadow-focus` | `0 0 0 3px var(--mc-focus)`       | focus        |

Avoid heavy drop shadows. Use border first, shadow second.

## 11. Iconography

Use:

- Flutter: Material Symbols or Lucide-equivalent package if adopted.
- Web/admin/landing: Lucide icons.

Icon rules:

- Icon buttons for camera, upload, edit, delete, export, search, filter.
- Tooltips for admin icon-only controls.
- Do not use text inside rounded rectangles when a standard icon is clearer.
- Safety icon always paired with text.

Suggested icons:

| Action     | Icon              |
| ---------- | ----------------- |
| Scan       | Camera            |
| Upload     | Upload            |
| Confirm    | Check             |
| Edit       | Pencil            |
| Export     | Download/FileText |
| Safety     | ShieldAlert       |
| Curriculum | BookOpen          |
| AI         | Sparkles          |
| Inventory  | Boxes             |
| Experiment | FlaskConical      |
| Lesson     | ClipboardList     |

## 12. Core Components

### 12.1. App Shell

Mobile shell:

- Top app bar with title and contextual actions.
- Bottom navigation with 4-5 items.
- Scan action is visually primary.
- Content scrolls behind fixed bottom action only with bottom padding.

Tabs:

- Home
- Scan
- Lessons
- Library
- Account

### 12.2. Buttons

| Variant   | Usage                                           |
| --------- | ----------------------------------------------- |
| Primary   | Main action: Scan, Generate, Save               |
| Secondary | Non-destructive action: Edit inventory, Preview |
| Ghost     | Low-emphasis toolbar actions                    |
| Danger    | Delete/archive                                  |
| Safety    | Acknowledge safety checklist                    |

Button height:

- Mobile normal: 44px.
- Mobile primary bottom: 48px.
- Admin dense: 36px.

### 12.3. Cards

Use cards for repeated items:

- Experiment suggestion.
- Lesson plan item.
- Inventory item group.
- Lead row detail summary.

Do not use cards as page section wrappers on landing.

Card anatomy:

- Title row.
- Metadata row.
- Status badges.
- Primary action.
- Optional evidence/reason area.

### 12.4. Inventory Item Row

Required fields:

- Item name.
- Quantity.
- Confidence.
- Editable canonical name.
- Safety flag if any.

States:

- Detected
- Edited
- Confirmed
- Low confidence
- Unsafe/needs review

### 12.5. Experiment Suggestion Card

Required fields:

- Experiment title.
- Match score.
- Materials available/missing.
- Grade/subject/topic.
- Duration.
- Safety level.
- Reason why matched.

Primary action:

- Generate lesson plan.

### 12.6. Lesson Plan Editor

Layout:

- Section navigation.
- Editable blocks.
- Safety checklist pinned near export.
- Export button.

Sections:

- Objectives.
- Materials.
- Setup.
- Lesson flow.
- Guiding questions.
- Assessment.
- Safety notes.

### 12.7. Safety Checklist

Safety checklist must be visually distinct from ordinary info cards.

Required states:

- Not reviewed.
- Teacher acknowledged.
- Blocked by system.

Blocked state uses danger color and disables export.

### 12.8. Admin Curation Queue

Pattern:

- Filter bar.
- List/table.
- Detail drawer.
- Status badges.
- Review notes.
- Audit history.
- Publish/archive controls.

Must support:

- Real pagination.
- Persisted notes.
- Optimistic UI rollback.

## 13. Landing Page Design

Landing page should be product-proof first, not abstract AI branding.

First viewport:

- H1: `MacGyver Classroom`.
- Supporting copy: teacher-focused one-liner.
- Real product mock: photo -> detected materials -> experiment suggestions -> lesson plan preview.
- CTA: `Đăng ký pilot`.

Sections:

1. Hero with product proof.
2. Pipeline 4 bước.
3. Safety and curriculum trust.
4. Use cases by role.
5. Pilot form.
6. FAQ.

Visual rules:

- White/ocean blue palette.
- Realistic classroom/object imagery preferred.
- No purple AI gradient.
- No decorative orbs.
- No custom cursor.
- Motion subtle and reduced-motion safe.

## 14. Dark Theme Generation Rules

Dark theme generation is token-level:

1. Keep semantic intent.
2. Replace backgrounds with near-navy.
3. Raise surfaces by lightness, not by shadows.
4. Increase border opacity slightly.
5. Primary blue becomes brighter.
6. Keep status meaning stable.
7. Validate contrast.

Contrast targets:

- Body text >= 4.5:1.
- Large text >= 3:1.
- Critical buttons >= 4.5:1.
- Focus ring visible on both themes.

## 15. Platform Mapping

| Design Token       | Flutter                    | Web/Admin                            |
| ------------------ | -------------------------- | ------------------------------------ |
| `color.primary`    | `ColorScheme.primary`      | `--mc-primary`                       |
| `color.background` | `scaffoldBackgroundColor`  | `--mc-bg`                            |
| `color.surface`    | `ColorScheme.surface`      | `--mc-surface`                       |
| `color.text`       | `ColorScheme.onSurface`    | `--mc-text`                          |
| `radius-md`        | `BorderRadius.circular(8)` | `border-radius: var(--mc-radius-md)` |
| `space-4`          | `EdgeInsets.all(16)`       | `padding: 1rem`                      |

## 16. Accessibility

Required:

- Touch target >= 44x44px on mobile.
- Visible focus states on web/admin.
- Labels for icon buttons.
- Text not hidden behind bottom nav.
- Reduced-motion support.
- Error messages close to fields.
- Safety warnings not color-only.

## 17. Content Voice

Voice:

- Clear.
- Practical.
- Teacher-facing.
- Safety-aware.

Use:

- `Tạo giáo án`
- `Xác nhận vật phẩm`
- `Cần kiểm tra an toàn`
- `Phù hợp lớp 8 - Vật lý`
- `Thiếu 1 vật liệu`

Avoid:

- `AI thần kỳ`
- `Tự động 100%`
- `Không cần kiểm tra`
- Marketing claims không đo được.

## 18. Migration From Cityfarm Visuals

Replace:

- Green/soil tokens -> white/ocean tokens.
- Gamified plant cards -> utilitarian classroom cards.
- Marketplace moderation UI -> experiment curation queue.
- Garden scan -> classroom object scan.
- Plant detail -> experiment detail/lesson detail.

Keep:

- Mobile-first shell.
- Sticky headers.
- Bottom primary action.
- Camera/upload modal pattern.
- Status badges.
- List/detail admin workflow.
- Tokenized CSS variable approach.

Do not keep:

- Public image URL assumption.
- Hardcoded hex in component CSS.
- Custom cursor.
- Decorative orbs.
- Card-in-card marketing layout.

## 19. Acceptance Criteria

Design system is acceptable when:

- Light theme is visibly white + ocean blue.
- Dark theme can be generated by token replacement only.
- Flutter and web can consume the same design token source.
- No product component needs hardcoded brand hex.
- Safety states are visually distinct from normal AI/info states.
- Landing page looks like an education product, not generic AI SaaS.
- Mobile screens remain readable in classroom lighting.
