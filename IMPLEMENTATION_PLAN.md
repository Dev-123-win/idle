# Offline-First Architecture Plan

## Overview
This plan transitions the app from a **Server-Authoritative** model (where every action validates with the server) to an **Local-First (Client-Authoritative)** model with periodic synchronization. This ensures the app is fully functional offline while maintaining security for critical actions like Withdrawals.

## Core Rules
1.  **Local Storage (Primary)**: Gameplay data (Coins, Taps, Upgrades, Energy) is stored locally on the device.
2.  **Online-Only (Exceptions)**:
    *   **Auth**: Login/Registration still hits Firebase Auth/Firestore immediately.
    *   **Referrals**: Checking referral codes hits the server to verify validity.
    *   **Withdrawals**: Must be online to prevent double-spending.
    *   **In-App Purchases (Real Money)**: Must be processed and verified online immediately. No offline queuing for real money transactions.
    *   **Leaderboards**: Global data requires server connection.
3.  **Periodic Sync**:
    *   Data is synced to Cloudflare Worker **5 times daily** (approx. every 4.8 hours).
    *   Sync payload includes total accumulated taps and any upgrades purchased offline.

---

## Technical Implementation Steps

### Phase 1: Local Storage Layer (Client-Side)
We need a robust way to store structured data locally. `shared_preferences` is used for simple flags, but for upgrades and balances, we should use a stronger structure or just rigorous JSON management.

**Action Items:**
1.  Add `hive` (authentication-free NoSQL) or specialized `LocalRepository` using `shared_preferences`.
    *   *Recommendation*: Keep it simple with `shared_preferences` storing a JSON blob for `UserData` if data is small, or `hive` if complex.
2.  **Create `LocalGameRepository`**:
    *   `saveUser(UserModel user)`
    *   `getUser()`
    *   `savePendingSync(SyncData data)`
3.  **Update `GameProvider/GameService`**:
    *   **Initialization**: logic changes to `loadFromLocal()`. If null, `fetchFromRemote()`.
    *   **Tapping**: `_localBalance += tapValue`. Save to Local Storage immediately or debounced (every 1-5s).
    *   **Upgrades**:
        *   Remove HTTP call to `/api/purchase-upgrade`.
        *   Implement logic: `if (localBalance >= cost) { localBalance -= cost; addUpgrade(id); save(); }`
        *   Add the purchased upgrade ID to a `pending_upgrades_sync` list.

### Phase 2: Sync System (Periodic)
We need a background timer that runs while the app is alive. (Android/iOS background tasks are complex in Flutter without plugins like `workmanager`, but for a mining app, syncing while *open* is usually sufficient. If "background" sync is strictly required, `workmanager` is needed. We will assume "Periodic while using or upon open" first).

**Strategy:**
*   **Timer**: Runs every X minutes check.
*   **Logic**:
    *   If `lastSyncTime` was > 4.8 hours ago (or user manually triggers):
    *   **Payload**:
        ```json
        {
          "uid": "...",
          "totalTapsSinceLastSync": 50000,
          "purchasedUpgrades": ["hammer_2", "drill_1"],
          "currentBalance": 150200, // Trusted client balance
          "timestamp": 123456789
        }
        ```
    *   **Worker Response**: Updates Firestore with these values.

### Phase 3: Cloudflare Worker Updates
The Worker currently rejects large batches (`MAX_TAPS_PER_SYNC`). We must relax this or change the logic to accept "Blind Updates" from trusted clients, or implement a "Simulation" check.

**Changes to `cloudflare-worker/index.ts`:**
1.  **Modify `handleSyncState`**:
    *   Accept `purchasedUpgrades` array.
    *   Validate that `tapsDelta` is *physically possible* in the time window (e.g., if last sync was 5 hours ago, max taps = 5 hours * max_cps).
    *   Update Firestore `ownedUpgrades` with the new list.
    *   Update `coinBalance` to match Client (or `serverBalance + earnings - upgradeCosts`). *Client Authoritative* means we mostly trust the timestamped final balance or the precise deltas.
    *   **Recommendation**: Send Deltas (`+Earned`, `-Spent`). Client calculates: `ServerBalance + DeltaEarned - DeltaSpent`. This prevents overwriting server-side bonuses (like Referral bonuses) that the client might not know about yet.

### Phase 4: Critical Security (Withdrawals)
Withdrawal logic remains strictly online.
1.  **Pre-Withdrawal Sync**:
    *   When user clicks "Withdraw", **FORCE A SYNC** first.
    *   Ensure server acknowledges the latest balance.
    *   Then, verify server balance >= withdrawal amount.
    *   Process withdrawal on server.

---

## Detailed Task List

### 1. `lib/core/services/game_service.dart`
*   [ ] Remove `_flushSync` (15s timer).
*   [ ] Implement `LocalStorageService` integration.
*   [ ] Change `purchaseUpgrade` to be synchronous/local.
*   [ ] Create `syncData()` method that sends:
    *   `accumulatedTaps`
    *   `offlineUpgrades`
*   [ ] Set detailed Timer: `Timer.periodic(Duration(hours: 4), ...)`

### 2. `cloudflare-worker/index.ts`
*   [ ] Update `/api/sync-state` to handle `purchasedUpgrades`.
*   [ ] Increase strict limits (or adjust for longer durations). `MAX_TAPS_PER_SYNC` must scale with time difference.

### 3. `lib/main.dart`
*   [ ] Initialize Local Storage before running app.

---

## Proposed Data Flow

1.  **User Opens App**:
    *   Load `coinBalance` from Device Storage.
    *   User Taps -> `+1` Coin (Device Storage).
    *   User Buys Upgrade -> `-500` Coins (Device Storage).
2.  **4 Hours Later (or on App Resume/Close)**:
    *   App sends: "I earned 10,000 coins and bought 'Miner Lvl 2'".
    *   Cloudflare: "Ok, verified. Updated Firestore."
3.  **User Withdraws**:
    *   App: "Syncing first..." -> Success.
    *   App: "Request Withdraw 5000".
    *   Cloudflare: "Server Balance is 5000. Approved."

