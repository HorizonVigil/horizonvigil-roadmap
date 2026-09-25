# HorizonVigil Design System

## Experience principles

- Evidence before decoration
- Clear scope: organization, provider, account and region are always visible
- Truthful capability and freshness states
- Safe actions with impact, approval and rollback context
- Accessible, responsive and consistent workflows

## Tokens

Use semantic tokens instead of hardcoded colors: background, surface, text, muted, border, brand, info, success, warning, danger and focus. Dark and light themes must meet WCAG contrast requirements. Status cannot rely on color alone.

Typography uses a readable sans-serif stack with consistent heading, body, label, code and tabular-number styles. Spacing follows a 4px base scale. Components use documented radius, elevation, motion and density tokens.

## Required components

- Application shell, breadcrumbs and scope selector
- Buttons, links, menus, dialogs and forms
- Table, filter, pagination, bulk selection and saved view
- Status badge, capability card and freshness indicator
- Evidence viewer and source citation
- Resource graph and timeline
- Recommendation, approval and decision panels
- Loading skeleton, empty state, partial-data notice and recoverable error
- Toast, notification inbox and asynchronous job progress

## Accessibility and responsive behavior

- WCAG 2.2 AA target
- Full keyboard operation and visible focus
- Semantic landmarks, labels and live regions
- Reduced-motion support
- Mobile below 640px, tablet 640–1023px, desktop 1024px and above
- Dense cloud tables transform into usable cards or horizontal regions on small screens

No component may imply success, compliance or complete coverage when evidence is missing.

