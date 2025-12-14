# APP MASTER PLAN: CryptoMiner (Idle Mining App)

## 1. Overview
**CryptoMiner** is a high-fidelity idle clicker game where users mine virtual coins, purchase upgrades to automate earnings, and eventually withdraw real money (INR).  
**CRITICAL RULE**: The app is **ONLINE-ONLY**. Users cannot play, mine, or access the app without an active internet connection. This is strictly enforced to ensure Ad monetization integrity and Data Safety.

---

---

## 2. Core Gameplay: Mining Efficiency (Thermal Throttling)
*   **Concept**: Unlimited Tapping is allowed, but rewards drop as "System Temp" rises.
*   **Heat Logic**: +1 Heat/Tap. Passive Cooling (-5/sec).
*   **Zones**:
    *   **Optimal (0-100)**: 100% Rewards.
    *   **Throttled (100-200)**: 50% Rewards.
    *   **Overheated (200+)**: **1% Base Reward**.
*   **Upgrades**: Cooling systems extend the Optimal Zone.
*   **Ads**: "Nitrogen Flush" instantly cools system to 0.

## 3. Architecture: Online-Only Hybrid Model

### Connectivity & State Logic
1.  **Strict Online-Only**:
    *   **App Launch**: Checks internet. If offline, blocks access with "No Internet" screen.
    *   **Runtime**: Monitors connection. If dropped, pauses game immediately.
2.  **Data Flow (Free Tier Optimized)**:
    *   **Lazy Sync (Gameplay)**: Taps/Passive earnings sync every **10 minutes**.
    *   **Critical Sync (Immediate)**: Upgrades, Referrals, Withdrawals, IAP, Login, and Logout trigger **immediate** full-state synchronization.
    *   **Reads**: Fetch User Data **only** on startup or after critical server-side updates.

---

## 3. Critical Data & Device Integrity (Strict)

### One Account Per Device (Absolute Rule)
*   **Mechanism**: On first launch, the app generates/fetches a unique `deviceId` (using `device_info_plus` + `flutter_secure_storage`).
*   **Enforcement**: 
    *   Login/Register payload includes `deviceId`.
    *   **Backend (Cloudflare)**: Checks if this `deviceId` is linked to a distinct `uid`.
    *   **Reject**: If device is used by another account, Login fails: "Device bounded to another account."

### Critical Action Policy (Unlimited Writes acceptable)
These actions are vital for economy security and user trust, so we do not rate-limit them excessively:
1.  **Upgrades**: Immediate server call to deduct coins and grant item.
2.  **Withdrawal**: Immediate balance verification and extensive logging.
3.  **Referral**: Immediate validation of code and rewarding.
4.  **Logout**: Triggers `await forceSync()` before clearing local session.

---

## 4. UI/UX: Feedback & Race Condition Prevention

To prevent "Blank States" and navigation issues during async operations:

### 1. The "Glass" Loading Guard
*   **Usage**: Applied during Login, Upgrades, Withdrawals, and IAP.
*   **Behavior**: A semi-transparent black overlay with a Lottie/Spinkit loader covers the **entire screen**.
*   **Purpose**: 
    *   Prevents user from clicking "Buy" twice.
    *   **Prevents Navigation**: User cannot press "Back" or change tabs, eliminating the race condition of "leaving the screen while a transaction is pending."

### 2. Optimistic UI with Rollback
*   For **Taps**: UI updates instantly. If 10-min sync fails, we retry. No rollback (trusted client).
*   For **Upgrades**: 
    *   UI shows "Buying..." (Loading Guard).
    *   Wait for Server Success.
    *   If Success -> Update UI.
    *   If Fail -> Show Error, do not deduct.
    *   *Why?* Upgrades are high-value; we don't want ephemeral "fake" purchases.

### 3. Navigation Safety
*   **Logout**: When clicking Logout, show "Syncing..." dialog. prevent app close until sync confirms or times out (5s).

---

## 5. Backend & Database Structure

### Database: Cloud Firestore
*   `users/{uid}`: Core profile.
*   `withdrawalRequests/{id}`: Secure requests.
*   `deviceFingerprints/{deviceId}`: Map `deviceId` -> `uid` for strict locking.

### Backend Logic: Cloudflare Workers
*   **`POST /api/purchase-upgrade`**: Atomic check-and-update.
*   **`POST /api/link-device`**: Handles the 1-device-1-account logic.

---

## 6. Security & Anti-Cheat
1.  **Network Enforcement**: No offline play.
2.  **Device Lock**: 1 account/device.
3.  **Speed Limits**: Max 15 taps/sec.
4.  **Root Detection**: App refuses to run on rooted devices.

---

## 7. Monetization Strategy
1.  **Banner Ads**: 100% Fill rate expected.
2.  **Interstitial**: shown upon "Level Up" or "Tab Switch".
3.  **Rewarded**: Mandatory for efficient progress.
