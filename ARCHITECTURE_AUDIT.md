# Architecture Audit: Auth, Onboarding, Root Routing, Data Persistence

**Date:** 2026-02-22  
**Scope:** Authentication flow, onboarding flow, root routing, data persistence  
**Critical Bug:** After app delete → reinstall → onboarding, app sometimes goes to main instead of login/signup.

---

## 1. AUTH + ROOT ROUTE AUDIT

### 1.1 Root Route Derivation Logic (AppState.swift)

**Current logic (lines 58–66):**
```
if !splashDone → splash
if !onboardingDone → onboarding
guard user else → auth(authRoute)
if !user.isEmailVerified → verifyEmail
→ main
```

**Correctness:** The order is correct. The bug is not in the order but in **when Firebase has a non-nil user**.

### 1.2 Root Cause

Firebase Auth stores credentials in the iOS Keychain. The Keychain is app-bound, but in practice credentials can persist across app delete/reinstall in some configurations and simulators.

**Flow causing the bug:**
1. User deletes app (UserDefaults cleared, Keychain may persist).
2. User reinstalls and launches.
3. `hasCompletedOnboarding` is false.
4. Firebase Auth state listener restores the previous session from Keychain → `user != nil`.
5. User goes through splash → onboarding.
6. User taps "Get Started" → `hasCompletedOnboarding = true`.
7. `rootRoute` evaluates: splash ✓, onboarding ✓, user ✓ → `.main` or `.verifyEmail`.
8. Auth screen is skipped.

### 1.3 Timing / Race Conditions

- **Firebase listener:** Fires on `addStateDidChangeListener` with the current user (often immediately).
- **Combine pipeline:** `CombineLatest4` emits when all four publishers have emitted; ordering is fine.
- **Main risk:** Firebase user being non-nil after reinstall when we expect a clean state.

### 1.4 Applied Fixes

1. **Clear session on fresh install:**  
   In `AppState.init`, if `!hasCompletedOnboarding`, call `authViewModel.clearPersistedSession()` (which performs `Auth.auth().signOut()`). This clears any Keychain-restored session before the user sees onboarding.

2. **Defense-in-depth:**  
   `hadCompletedOnboardingAtLaunch` is used in route derivation. If onboarding was completed in this launch (i.e. not done at startup), we always force `.auth` and ignore Firebase `user` until the user goes through the auth flow.

---

## 2. ONBOARDING PERSISTENCE

### 2.1 Storage

- **Key:** `"hasCompletedOnboarding"` in `UserDefaults.standard`
- **Lifecycle:** Persisted in `didSet`; loaded in `AppState.init`
- **Reset:** UserDefaults is cleared on app delete → `hasCompletedOnboarding` correctly resets.

### 2.2 Behavior After Fix

- Onboarding does not skip auth.
- Onboarding completion does not jump to main when there is an invalid or undesired persisted session; fresh installs are treated as requiring auth.

---

## 3. CHALLENGE DATA PERSISTENCE

### 3.1 Current Implementation

- **Storage:** Core Data (`ChallengeEntity`), not UserDefaults.
- **Migration:** One-time migration from UserDefaults `"challenges"` to Core Data.
- **User association:** None. All challenges are device-local, not tied to any user.

### 3.2 Risks

| Case | Current Behavior | Risk |
|------|------------------|------|
| A: Logout → login same account | Challenges remain | OK if we later scope by user |
| B: Delete app → reinstall → login same account | Challenges lost | Data loss |
| C: Logout → login different user | Same challenges shown | Cross-account data exposure |

### 3.3 Legacy Challenges (Pre-UserId Migration)

Existing challenges in Core Data before adding `userId` have `userId == nil`. With the implemented logic:
- **Logged out:** Shows challenges where `userId == nil` (legacy/anonymous).
- **Logged in:** Shows only challenges where `userId == currentUser.uid`.

Legacy challenges are not auto-assigned to the first logged-in user. To "claim" them, a one-time migration could assign `userId = currentUser.uid` for all `userId == nil` when a user first logs in after the schema update. Not implemented in this pass.

### 3.4 Recommendations

**Minimal safe fix (implemented):**
- Added optional `userId: String?` to `ChallengeEntity`.
- On user change: reload challenges filtered by the new `userId` (implemented via `switchToUser`).

**Production-ready fix:**
- Store challenges in Firestore, keyed by `users/{uid}/challenges/{challengeId}`.
- Sync on login; offline support via Firestore cache.
- Supports multi-device and clear per-user isolation.

---

## 4. LOGOUT BEHAVIOR

### 4.1 Current Implementation

- Logout: `Auth.auth().signOut()` → listener sets `user = nil` → `rootRoute` → `.auth(.login)`.
- Challenges: not cleared, not user-scoped; effectively treated as shared.

### 4.2 Desired Behavior (Post User-Scoping)

| Scenario | Behavior |
|---------|----------|
| Logout same user, login same user | Preserve challenges |
| Logout, login different user | Load that user’s challenges only |
| Delete app, reinstall, login | Restore from Firestore (or empty if local-only) |

### 4.3 Handling User Change

- `ChallengeStore` should observe auth user.
- On `user` change, reload challenges for the new `userId`.
- Prevent cross-user visibility of challenges.

---

## 5. EDGE CASE TEST MATRIX

| # | Scenario | Expected rootRoute | Data State |
|---|----------|--------------------|------------|
| 1 | Fresh install → onboarding → login → verify → main | splash → onboarding → auth(.login) → verifyEmail → main | Challenges empty |
| 2 | Fresh install → onboarding → signup → verify → main | splash → onboarding → auth(.signUp) → verifyEmail → main | Challenges empty |
| 3 | Logout → login same user | main → auth(.login) → (login) → main | Challenges remain |
| 4 | Logout → login different user | main → auth(.login) → (login) → main | Load new user’s challenges only |
| 5 | Delete app → reinstall → onboarding → login same user | splash → onboarding → auth → (login) → verify/main | Auth shown; challenges restored (Firestore) or empty (local) |
| 6 | Email unverified → verify → refresh | verifyEmail → (reload) → main | No change to challenges |
| 7 | Firebase Keychain persisted after delete; onboarding complete | splash → onboarding → auth | Force auth; no skip to main |
| 8 | Legacy challenges (userId=nil) before login | N/A | Shown when logged out; hidden when logged in |

---

## 6. CONCRETE CODE CHANGES (IMPLEMENTED)

### 6.1 AppState.swift

**Changes:**
- Added `hadCompletedOnboardingAtLaunch` (captured at init from UserDefaults)
- In init: if `!hasCompletedOnboarding`, call `authViewModel.clearPersistedSession()` to clear stale Firebase session
- Route derivation: when `onboardingDone && !hadCompletedOnboardingAtLaunch && !hasAuthenticatedThisSession` → force `.auth(authRoute)` (ignore Firebase user)
- Use `CombineLatest2` + `CombineLatest4` to include `hasAuthenticatedThisSession`
- Added `#if DEBUG` logging for rootRoute transitions
- `AuthRoute` and `RootRoute` conform to `CustomStringConvertible` for debug output

### 6.2 AuthViewModel.swift

**Changes:**
- Added `hasAuthenticatedThisSession: Bool` (starts false)
- Set `hasAuthenticatedThisSession = true` in: `signIn` success, `signUp` success (after createUser), `signInWithGoogle` success
- Added `clearPersistedSession()` – calls `Auth.auth().signOut()` without showing alerts (for fresh-install cleanup)

### 6.3 ChallengeStore.swift

**Changes:**
- Added `currentUserId: String?` and `switchToUser(_ userId: String?)`
- `loadChallenges()` filters by `userId == currentUserId` when logged in, `userId == nil` when logged out (legacy)
- `addChallenge` sets `entity.userId = currentUserId`
- `fetchEntity` predicate includes userId to prevent cross-user access

### 6.4 DaysChallengeModel.xcdatamodeld

**Changes:**
- Added optional attribute `userId: String` to `ChallengeEntity`

### 6.5 PersistenceController.swift

**Changes:**
- Enabled `shouldMigrateStoreAutomatically` and `shouldInferMappingModelAutomatically` for lightweight migration

### 6.6 DaysChallengeApp.swift

**Changes:**
- `.onAppear` and `.onChange(of: authVM.user)` call `ChallengeStore.shared.switchToUser(authVM.user?.uid)` to sync auth state with challenge loading
