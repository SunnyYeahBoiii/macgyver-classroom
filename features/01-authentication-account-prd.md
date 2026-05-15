# PRD - FRS-01 Authentication & Account

## Status

Draft for MVP planning.

## Source Docs

- `docs/macgyver-classroom-frs.md` - FRS-01
- `docs/macgyver-classroom-srs.md` - Auth endpoints, security, JWT pattern
- `docs/macgyver-classroom-system-design.md` - API auth pattern and mobile security

## Problem

MacGyver Classroom needs authenticated teacher, school admin, and content admin access before it can safely store classroom photos, saved lesson plans, school context, exports, feedback, and admin moderation changes.

## Goals

- Let teachers register, sign in, refresh sessions, and sign out.
- Support role-gated access for Teacher, School Admin, and Content Admin.
- Provide mobile bearer-token auth and web/admin cookie-compatible patterns where needed.
- Protect private classroom data, uploaded images, saved lessons, lead administration, and content moderation actions.

## Non-Goals

- Full SSO with school identity providers in MVP.
- Parent or student accounts.
- Public social login beyond Google OAuth if it is explicitly enabled.
- Billing, plan management, or seat provisioning.

## Primary Users

- Teacher: creates inventory scans, lesson plans, exports, and feedback.
- School Admin: views school-level usage and can manage school context where allowed.
- Content Admin: manages curated experiments, mappings, safety rules, leads, and reports.

## User Stories

- As a teacher, I can register with email/password so I can save my scans and lesson plans.
- As a teacher, I can sign in again on the same or another device without losing my library.
- As a user, I can sign out from the current device if I use a shared phone or computer.
- As a content admin, I can access admin-only routes without exposing those tools to teachers.
- As the system, I can reject expired, malformed, or wrong-role requests consistently.

## MVP Scope

- Email/password registration.
- Email/password login.
- Optional Google OAuth login when configured.
- JWT access token and refresh token issuance.
- Refresh-token rotation or invalidation strategy.
- Current-device logout.
- Role model: `Teacher`, `SchoolAdmin`, `ContentAdmin`.
- API guards for authenticated routes and role-restricted routes.
- Basic account profile payload for mobile and admin clients.

## Functional Requirements

| ID      | Requirement                                                                                                          |
| ------- | -------------------------------------------------------------------------------------------------------------------- |
| AUTH-01 | User can register using email and password.                                                                          |
| AUTH-02 | User can sign in using email and password.                                                                           |
| AUTH-03 | User can sign in with Google OAuth only when OAuth config is enabled.                                                |
| AUTH-04 | API returns access token and refresh token using the JWT pattern.                                                    |
| AUTH-05 | User can refresh an access token without re-entering credentials.                                                    |
| AUTH-06 | User can sign out from the current device/session.                                                                   |
| AUTH-07 | API protects private routes with an auth guard.                                                                      |
| AUTH-08 | API protects admin and school routes with role guards.                                                               |
| AUTH-09 | API returns stable, non-leaky auth errors for invalid credentials, expired token, and insufficient role.             |
| AUTH-10 | Mobile app stores refresh token in Keychain/Keystore/Secure Storage and keeps access token in memory where possible. |

## Core Flow

1. User opens the app or admin portal.
2. Client checks for an active session.
3. If no valid session exists, user signs in or registers.
4. API validates credentials and returns user identity, roles, access token, and refresh token.
5. Client calls protected APIs using access token.
6. Client refreshes access token when needed.
7. User signs out and current refresh session is invalidated.

## Data Model

Primary entities:

- `User`: account identity, email, auth provider metadata, status.
- `Session`: refresh-token/session state, device metadata, expiry, revocation state.
- `TeacherProfile`: profile linked after onboarding.
- `OrganizationMember`: organization membership and role.

Key fields:

- `User.email`
- `User.passwordHash`
- `User.status`
- `Session.userId`
- `Session.refreshTokenHash`
- `Session.expiresAt`
- `Session.revokedAt`
- `OrganizationMember.role`

## API Contract

Candidate endpoints from SRS:

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`
- `GET /auth/me`
- `GET /auth/google`
- `GET /auth/google/callback`

Response requirements:

- Never return password hash or raw provider profile.
- Include user ID, email, roles, organization memberships, and onboarding status.
- Use structured error codes for `INVALID_CREDENTIALS`, `TOKEN_EXPIRED`, `TOKEN_REVOKED`, and `FORBIDDEN_ROLE`.

## Security And Privacy

- Use HTTPS-only cookies where web/admin cookie auth is used.
- Do not log passwords, tokens, OAuth codes, or refresh-token hashes.
- Rate limit login, register, refresh, and OAuth callback endpoints.
- Keep production CORS fail-closed using configured origins.
- Use request IDs and global exception filters to avoid leaking raw provider errors.

## Analytics

Track:

- `auth_registered`
- `auth_login_succeeded`
- `auth_login_failed`
- `auth_refreshed`
- `auth_logout`

Do not track raw email, password, OAuth token, or refresh token.

## Acceptance Criteria

- A teacher can register, log in, refresh, call a protected route, and log out.
- Expired or revoked refresh tokens cannot mint new access tokens.
- Teacher role cannot call Content Admin endpoints.
- Content Admin role can call content-admin endpoints.
- Mobile token storage follows secure-storage requirement.
- Auth errors are deterministic and do not expose provider stack traces.

## Open Questions

- Should MVP require email verification before lesson export or sharing?
- Should Google OAuth be enabled at launch or kept behind environment configuration?
- Should School Admin roles be assigned manually by Content Admin during pilot?
