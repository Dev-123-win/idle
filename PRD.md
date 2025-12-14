PRD: Idle Clicker Crypto Mining App
📋 PRODUCT REQUIREMENTS DOCUMENT
Product Overview
A crypto-themed idle clicker mobile game where users tap to mine virtual currency, watch ads to unlock earnings, and cash out real money via manual processing. Monetized through AdMob ads and Razorpay in-app purchases.

🎯 CORE OBJECTIVES
Business Goals:
Generate ₹10-25K/month profit at 1000-2000 DAU
Maintain 92% ad revenue, give 8% to users
Process manual withdrawals initially, automate later
Break-even or slight profit per active user
User Goals:
Earn ₹50-100/month through casual gameplay (3-6 months grind)
Simple, addictive tap mechanics
Clear progression with upgrades
Trustworthy withdrawal process

👥 TARGET AUDIENCE
Primary:
Age: 18-35
Location: India (Tier 2/3 cities)
Demographics: Students, part-time workers, homemakers
Motivation: Side income, passive earnings, mobile gaming
User Personas:
Persona 1: Casual Grinder
15-20 min/day usage
Watches ads for rewards
Patient with slow earnings
Reaches ₹50 in 60-90 days
Persona 2: Active Farmer
45-60 min/day usage
Maximizes all earning methods
Buys 1-2 IAP items
Reaches ₹50 in 20-30 days
Persona 3: Referral Hunter
Shares app aggressively
Earns primarily through referrals
10-20 successful referrals
Withdraws ₹50-100 monthly

💰 MONETIZATION MODEL
Revenue Streams:
1. AdMob Ads (95% of revenue):
Banner ads (always visible)
Interstitial ads (between screens)
Rewarded video ads (unlock earnings)
App Open ads (on launch)
Native ads (in lists)
2. In-App Purchases (5% of revenue):
Remove Ads: ₹299
Premium upgrades: ₹99-499
Boost packs: ₹49-149
VIP subscription: ₹199/month
User Payouts:
Earning Structure:
Users earn "coins" through gameplay
Coins convert to INR at fixed rate
Minimum withdrawal: ₹50
Processing: 3-5 business days (manual)
Processing fee: ₹10 (deducted from user)
Conversion Rate:
10,000 coins = ₹1
Users earn 300-800 coins/day (casual to active)

🎮 CORE FEATURES
F1: Tap Mining (Primary Mechanic)
Description: User taps a large mining button to earn coins. Every 100 taps requires watching a rewarded ad to claim accumulated earnings.
Requirements:
FR1.1: Tapping button increments coin counter locally
FR1.2: Visual feedback on each tap (number flies up, haptic vibration)
FR1.3: Counter shows "X/100 taps to claim"
FR1.4: At 100 taps, show "Watch Ad to Claim X coins" popup
FR1.5: After rewarded ad completion, add coins to wallet balance
FR1.6: If user declines ad, taps remain locked (can't continue tapping)
FR1.7: Daily tap cap: 5,000 taps maximum
FR1.8: Tap rate: 1 coin per tap (base, upgradeable)
FR1.9: Animation shows mining pickaxe hitting ground on tap
Anti-Cheat:
AC1.1: Validate tap count on server every 100 taps
AC1.2: Maximum tap speed: 10 taps/second
AC1.3: Flag users exceeding 15 taps/second
AC1.4: Session-based tracking (tap count resets on app close)
Technical:
Local state management (Riverpod/Bloc)
Server validation via Cloudflare Workers
AdMob Rewarded Ads integration
Hive storage for offline tap buffer

F2: Passive Mining (Retention Mechanic)
Description: Users earn coins per second even when app is closed. Must claim accumulated earnings when returning to app.
Requirements:
FR2.1: Base passive rate: 0.5 coins/second
FR2.2: Offline accumulation cap: 6 hours maximum (21,600 seconds)
FR2.3: Maximum offline earning: 10,800 coins (6 hours × 0.5/sec × 60 × 60)
FR2.4: On app open, show "You earned X coins while away!" modal
FR2.5: User must watch 1 app open ad OR 1 interstitial ad to claim
FR2.6: If user closes app without claiming, coins remain pending
FR2.7: Passive rate is upgradeable via in-game purchases
FR2.8: Daily passive cap: 50,000 coins maximum
Anti-Cheat:
AC2.1: Server stores last claim timestamp
AC2.2: Calculate max possible passive: (currentTime - lastClaim) × passiveRate
AC2.3: Cap at 6 hours even if offline longer
AC2.4: Validate user didn't manipulate device time
AC2.5: Flag users claiming passive more than once per minute
Technical:
Firebase Firestore: store lastClaimTimestamp
Cloudflare Workers: calculate and validate passive earnings
AdMob App Open Ads / Interstitial Ads

F3: Upgrades System
Description: Users spend earned coins to purchase upgrades that increase tap power and passive mining rate.
Requirements:
FR3.1: Tap Power Upgrades (8 tiers)
Tier
Name
Cost (coins)
Effect
1
Basic GPU
5,000
+0.2 coins/tap
2
Dual GPU
25,000
+1 coin/tap
3
GPU Rig
100,000
+5 coins/tap
4
ASIC Miner
500,000
+25 coins/tap
5
Mining Farm
2,000,000
+100 coins/tap
6
Data Center
10,000,000
+500 coins/tap
7
Server Network
50,000,000
+2500 coins/tap
8
Quantum Rig
250,000,000
+10000 coins/tap

FR3.2: Passive Rate Upgrades (8 tiers)
Tier
Name
Cost (coins)
Effect
1
CPU Miner
8,000
+0.1 coins/sec
2
Old GPU
40,000
+0.5 coins/sec
3
Modern GPU
150,000
+2 coins/sec
4
ASIC Passive
750,000
+10 coins/sec
5
Auto Farm
3,000,000
+50 coins/sec
6
Smart Grid
15,000,000
+250 coins/sec
7
AI Optimizer
75,000,000
+1250 coins/sec
8
Neural Net
400,000,000
+6000 coins/sec

FR3.3: Each upgrade can be leveled up 1-50 times
Level cost increases by 15% per level
Effect increases by 10% per level
FR3.4: Upgrade purchase flow:
Tap upgrade card → show detail modal
Display current stats, next level stats, cost
"Purchase" button (disabled if insufficient coins)
On purchase: deduct coins, apply effect, show success animation
Technical:
Firestore: store user's owned upgrades and levels
Real-time calculation of total tap power and passive rate
Optimistic UI updates with server validation

F4: Daily Login Bonus
Description: Users receive coins for logging in daily. Streak resets if they miss a day.
Requirements:
FR4.1: Bonus amounts:
Days 1-6: 500 coins/day
Day 7: 5,000 coins (week completion)
Day 14: 10,000 coins
Day 30: 50,000 coins
Day 60: 100,000 coins
Day 90: 200,000 coins
FR4.2: Show daily bonus popup on app open (if not claimed today)
FR4.3: Calendar view showing streak progress
FR4.4: If user misses a day (24+ hours since last login), reset to Day 1
FR4.5: Bonus auto-claimed on first app open each day
FR4.6: Push notification at 8 PM: "Don't break your streak!"
Technical:
Firestore: lastLoginDate, currentStreak
Server-side validation of streak
FCM for push notifications

F5: Achievements System
Description: One-time rewards for completing specific milestones.
Requirements:
FR5.1: Achievement Categories (20 total achievements, ~80,000 coins total)
Getting Started (5 achievements, 6,000 coins):
First Tap: Tap once → 500 coins
Century: Tap 100 times → 1,000 coins
First Upgrade: Purchase any upgrade → 1,500 coins
First Claim: Claim passive earnings → 1,000 coins
Week Warrior: 7-day login streak → 2,000 coins
Tap Master (5 achievements, 25,000 coins):
1K Taps: 1,000 total taps → 2,000 coins
10K Taps: 10,000 total taps → 5,000 coins
50K Taps: 50,000 total taps → 8,000 coins
Speed Demon: 50 taps in 10 seconds → 3,000 coins
Tap God: 100,000 total taps → 7,000 coins
Passive Income (3 achievements, 15,000 coins):
Passive Starter: Earn 10,000 coins passively → 3,000 coins
Passive Pro: Earn 100,000 coins passively → 7,000 coins
Overnight Earner: Claim 6-hour passive → 5,000 coins
Wealth Builder (4 achievements, 20,000 coins):
100K Club: Earn 100K total coins → 5,000 coins
Millionaire: Earn 1M total coins → 10,000 coins
Big Spender: Spend 50K on upgrades → 3,000 coins
Investor: Own 5 different upgrades → 2,000 coins
Social (3 achievements, 14,000 coins):
Friend Finder: Refer 1 active user → 2,000 coins
Influencer: Refer 5 active users → 5,000 coins
Ambassador: Refer 10 active users → 7,000 coins
FR5.2: Achievement tracking happens automatically in background FR5.3: Show notification banner when achievement unlocked FR5.4: Achievements screen shows: completed, in-progress, locked FR5.5: Progress bars for in-progress achievements FR5.6: "Claim" button for completed but unclaimed achievements
Technical:
Firestore: user achievements array
Background workers track progress
Push notification on unlock

F6: Referral System
Description: Users invite friends and earn coins when referrals become active.
Requirements:
FR6.1: Each user gets unique referral code (e.g., MINE12345)
FR6.2: Referral screen shows:
Your code (large, copyable)
Share buttons (WhatsApp, Telegram, SMS, generic share)
How it works explanation
Your referrals list (name, status, earnings)
FR6.3: Referral rewards:
Referee (new user): 5,000 coins on signup
Referrer: 20,000 coins when referee earns 10,000 coins
Max 10 referrals per user
FR6.4: New user must enter referral code during signup (optional)
FR6.5: Referral status: Pending → Active (when they earn 10K coins)
FR6.6: Referrer gets push notification when referral becomes active
Anti-Cheat:
AC6.1: One referral code per device ID
AC6.2: Can't use own referral code
AC6.3: Flag users with 3+ referrals from same IP
AC6.4: Referral must earn 10K coins within 30 days (or reward expires)
Technical:
Firestore: referralCode, referredBy, referrals[]
Firebase Dynamic Links for shareable links
Server validation of referral eligibility

F7: Wallet & Withdrawals
Description: Users view balance, convert coins to INR, and submit withdrawal requests.
Requirements:
FR7.1: Wallet Screen:
Display:
Coin balance (large)
INR equivalent (10,000 coins = ₹1)
Lifetime earned coins
Total withdrawn INR
Pending withdrawal amount
FR7.2: Withdrawal Requirements:
Minimum: 500,000 coins (₹50)
Processing fee: 100,000 coins (₹10) deducted from user
User receives: ₹40 net after fee
Email must be verified
FR7.3: Withdrawal Flow:
User taps "Withdraw" button
Enter amount (coins, auto-converts to INR)
Choose method: UPI or Bank Account
For UPI: Enter UPI ID (e.g., name@paytm)
For Bank: Enter account number, IFSC, name
Confirm details
Submit request
Status: "Pending Review" (3-5 business days)
FR7.4: Withdrawal Limits:
Minimum: ₹50
Maximum: ₹5,000 per transaction
Maximum 1 withdrawal per week
FR7.5: Withdrawal History:
List of past withdrawals (date, amount, status, method)
Status: Pending → Processing → Completed / Rejected
Show transaction ID when completed
FR7.6: Email Verification:
If email not verified, show "Verify Email to Withdraw" banner
Send verification OTP to email
User enters OTP to verify
Technical:
Firestore: withdrawalRequests collection
Email verification via Firebase Auth
Manual processing: Admin reviews requests, marks completed in dashboard
Push notification when status changes

F8: In-App Purchases (Razorpay)
Description: Users can buy premium items with real money to accelerate progress.
Requirements:
FR8.1: IAP Items:
One-Time Purchases:
Remove Ads Forever: ₹299
2x Boost (7 days): ₹99
5x Boost (7 days): ₹199
Starter Pack: ₹149 (500K coins + Basic upgrades unlocked)
Growth Pack: ₹349 (2M coins + Tier 1-3 upgrades unlocked)
Subscription:
VIP Monthly: ₹199/month
Ad-free
2x passive earnings
Exclusive badge
Priority withdrawal processing (1-2 days)
FR8.2: Purchase Flow:
User taps IAP item
Show details modal (what they get)
"Buy Now" button → Razorpay payment screen
User completes payment
On success: grant item immediately, show success animation
On failure: show error, don't charge
FR8.3: Restore Purchases:
Button in settings to restore previous purchases
Validates with Razorpay/Firestore
Technical:
Razorpay SDK integration
Firestore: purchases[], vipUntil timestamp
Server-side validation of payment
Receipt verification

F9: AdMob Integration
Description: Monetize through multiple ad formats placed strategically.
Requirements:
FR9.1: Banner Ads:
Placement: Fixed bottom of main screen, above navigation bar
Size: 320x50 standard banner
Always visible during gameplay
Refresh: Every 60 seconds
Hidden if user purchased "Remove Ads"
FR9.2: Interstitial Ads:
Placement:
After upgrade purchase
After claiming passive earnings (if passive > 5000 coins)
Between screen transitions
Frequency: Maximum 1 every 3 minutes
Daily cap: 15 interstitials max per user
FR9.3: Rewarded Video Ads:
Placement:
Claim tap earnings (every 100 taps)
Claim passive earnings
Optional 2x boost (watch ad for 2x coins on next claim)
Must watch to completion
No daily cap (encouraged)
FR9.4: App Open Ads:
Show when app opens from background or cold start
Frequency: Once every 4 hours minimum
Skip if user just watched an ad in last 2 minutes
Hidden for VIP users
FR9.5: Native Ads:
Placement:
Upgrade list (every 5th item)
Achievement list (every 7th item)
Clearly marked as "Ad" or "Sponsored"
FR9.6: Ad Loading:
Preload ads on app start (banner, app open, 1 interstitial, 1 rewarded)
Show loading spinner if ad not ready (for rewarded)
Fallback: if ad fails to load, grant reward anyway (user-friendly)
Technical:
Google AdMob SDK
Ad unit IDs for each format (test IDs during development)
Ad event listeners (loaded, failed, clicked, dismissed)
Analytics tracking for ad performance

F10: Anti-Cheat System
Description: Prevent fraud, bots, and exploitation through client + server validation.
Requirements:
FR10.1: Client-Side Protection:
Root/jailbreak detection (warn user, limit earnings)
Debug mode detection (disable earnings in debug builds)
Certificate pinning (prevent MITM attacks)
Code obfuscation (Flutter's --obfuscate flag)
FR10.2: Server-Side Validation (Cloudflare Workers):
Tap Validation:
Client sends: userId, tapCount, sessionId, timestamp
Server checks:
Max tap speed: 10 taps/sec
Session validity (started < 12 hours ago)
Daily cap not exceeded (5000 taps)
Time since last sync > 5 seconds
If valid: update server tap count, return success
If invalid: reject, flag user, return server state
Passive Validation:
Client requests passive claim
Server calculates: (currentTime - lastClaimTime) × passiveRate
Cap at 6 hours (21,600 seconds)
Apply daily passive cap (50,000 coins)
If valid: credit coins, update lastClaimTime
If invalid: reject, flag user
Ad Validation:
AdMob SDK triggers callback with reward token
Client sends: userId, rewardToken, adUnitId, timestamp
Server validates token with AdMob API (SSV - Server-Side Verification)
Check daily ad limit not exceeded
Check token not already claimed
If valid: credit reward
If invalid: reject
FR10.3: Behavioral Analysis:
Track earning velocity (coins/hour)
Flag if: earnings > 3x median user
Track session patterns (time between actions)
Flag if: perfectly consistent timing (bot behavior)
FR10.4: Device Fingerprinting:
Track: device ID, IP address, install ID
Flag if: multiple accounts from same device
Flag if: VPN detected + suspicious activity
FR10.5: Withdrawal Fraud Detection:
Flag if: account < 7 days old
Flag if: earnings too fast for account age
Flag if: first action was withdrawal (didn't play naturally)
Flag if: multiple withdrawal rejections
FR10.6: Ban System:
Soft ban: Disable earnings for 24-48 hours (warning)
Hard ban: Permanent account termination, balance forfeited
Shadow ban: User thinks they're earning but nothing credits (for investigation)
FR10.7: Rate Limiting:
API endpoints:
Tap sync: Max 1 request/5 seconds per user
Passive claim: Max 1 request/minute per user
Withdrawal request: Max 1/day per user
Profile updates: Max 5/hour per user
Technical:
Cloudflare Workers: validation logic
Firestore: suspiciousFlags[], banStatus, banReason
AdMob SSV (Server-Side Verification) for rewarded ads
Device fingerprinting library (flutter_device_info)

🎨 SCREENS & USER FLOWS
Screen List:
S1: Splash Screen (2 seconds)
App logo
Loading animation
Version number
S2: Login/Signup
"Continue with Google" button
"Continue with Phone" button
Terms & Privacy links
S3: Phone Verification (if phone login)
Enter phone number
OTP input (6 digits)
Resend timer
S4: Referral Code Entry (optional, during signup)
"Have a referral code?" input
Skip button
Apply button
S5: Tutorial (first-time users, 5 steps)
Step 1: Tap the button
Step 2: Reach 100 taps
Step 3: Watch ad to claim
Step 4: Buy first upgrade
Step 5: Passive mining explained
Completion bonus: 5000 coins
S6: Main Mining Screen (primary interface)
Header: balance, notifications, settings icons
Stats: tap power, passive rate
Tap progress: X/100 taps, progress bar
Mining button (large, center)
Passive claim banner (if available)
Bottom nav: Mine, Upgrades, Wallet, Profile
Banner ad at bottom
S7: Upgrades Screen
Filter tabs: All, Tap Power, Passive, Premium
Scrollable list of upgrade cards
Each card shows: icon, name, level, effect, cost, buy button
Detail modal on tap (current stats, next level, cost)
S8: Wallet Screen
Balance display (coins + INR equivalent)
Withdraw button (disabled if < 500K coins)
Earnings breakdown (expandable)
Transaction history list
S9: Withdrawal Request Screen
Choose method: UPI / Bank Account
Enter payment details
Confirm summary (amount, fee, net)
Submit button
S10: Withdrawal Status Screen
Request ID
Status (Pending/Processing/Completed)
Timeline
Expected completion date
Support contact
S11: Achievements Screen
Progress overview (X/20 unlocked)
Filter tabs: All, Completed, In Progress
Achievement cards (icon, title, description, reward, progress bar)
Claim button for completed achievements
S12: Referral Screen
Your referral code (large, copyable)
Share buttons (WhatsApp, Telegram, generic)
How it works section
Your referrals list (name, status, earnings)
S13: Profile/Settings Screen
Profile info (avatar, name, email, user ID)
Account: Verify email, change password
App settings: notifications, sound, haptics, theme
Information: FAQ, Terms, Privacy, Support
Logout / Delete account
S14: Daily Bonus Popup (modal)
Calendar showing streak
Today's bonus amount
Claim button
Streak progress
S15: Achievement Unlocked Popup (modal)
Achievement icon + animation
Title and description
Reward amount
Claim button

🏗️ ARCHITECTURE
Tech Stack:
Frontend:
Flutter 3.x (Android-first, SDK 21+)
State Management: Riverpod or Bloc
Local Database: Hive (offline data, tap buffer)
Animations: Lottie or Rive
Device Info: flutter_device_info
Backend:
Firebase Authentication (Google, Phone OTP)
Cloud Firestore (user data, balances, upgrades, transactions)
Firebase Cloud Messaging (push notifications)
Firebase Storage (user avatars if needed)
Cloudflare Workers (serverless API for validation)
Monetization:
Google AdMob (Banner, Interstitial, Rewarded, App Open, Native)
Razorpay SDK (IAP payments)
Analytics:
Firebase Analytics
Crashlytics
Infrastructure:
Firebase Spark Plan (free tier): 50K Firestore reads/day, 20K writes/day
Cloudflare Workers Free Tier: 100K requests/day
Cost: ₹0 until 500-1000 DAU

Data Models (Firestore):
Collection: users
{
  uid: string,
  email: string,
  phoneNumber: string,
  displayName: string,
  photoURL: string,
  createdAt: timestamp,
  referralCode: string (unique),
  referredBy: string (referral code of referrer),
  
  // Balances
  coinBalance: number,
  lifetimeCoinsEarned: number,
  lifetimeCoinsSpent: number,
  
  // Gameplay
  totalTaps: number,
  dailyTaps: number (resets at midnight),
  lastTapSync: timestamp,
  tapPower: number (coins per tap),
  
  passiveRate: number (coins per second),
  lastPassiveClaim: timestamp,
  dailyPassiveEarned: number,
  offlineCapHours: number (default 6),
  
  // Upgrades (array of owned upgrades)
  ownedUpgrades: [
    { upgradeId: string, tier: number, level: number }
  ],
  
  // Achievements
  achievements: [
    { achievementId: string, unlockedAt: timestamp, claimed: boolean }
  ],
  
  // Referrals
  referrals: [
    { uid: string, status: 'pending' | 'active', joinedAt: timestamp }
  ],
  
  // Daily bonus
  loginStreak: number,
  lastLoginDate: string (YYYY-MM-DD),
  
  // Purchases
  purchases: [
    { itemId: string, purchasedAt: timestamp, orderId: string }
  ],
  vipUntil: timestamp (null if not VIP),
  adsRemoved: boolean,
  
  // Flags
  suspiciousFlags: [],
  banStatus: null | 'soft' | 'hard' | 'shadow',
  banReason: string,
  banUntil: timestamp
}
Collection: withdrawalRequests
{
  requestId: string (auto-generated),
  uid: string,
  amount: number (coins),
  amountINR: number,
  processingFee: number,
  netAmount: number,
  
  method: 'upi' | 'bank',
  upiId: string (if UPI),
  accountNumber: string (if bank),
  ifscCode: string (if bank),
  accountName: string (if bank),
  
  status: 'pending' | 'processing' | 'completed' | 'rejected',
  submittedAt: timestamp,
  processedAt: timestamp,
  completedAt: timestamp,
  
  rejectionReason: string,
  transactionId: string (when completed),
  transactionProof: string (image URL)
}
Collection: transactions
{
  transactionId: string,
  uid: string,
  type: 'earn' | 'spend' | 'withdraw',
  amount: number (coins),
  source: string ('tap', 'passive', 'achievement', 'referral', 'purchase', 'upgrade', 'withdrawal'),
  description: string,
  balanceBefore: number,
  balanceAfter: number,
  createdAt: timestamp
}
Collection: globalConfig (single document)
{
  tapRewardRate: number,
  passiveRewardRate: number,
  coinToINRRate: number (10000 coins = 1 INR),
  minWithdrawal: number (500000 coins),
  processingFee: number (100000 coins),
  dailyTapCap: number (5000),
  dailyPassiveCap: number (50000),
  
  maintenanceMode: boolean,
  maintenanceMessage: string
}

Cloudflare Workers API Endpoints:
POST /api/validateTaps
Input: { uid, tapCount, sessionId, timestamp }
Validates tap count against server state
Returns: { valid: boolean, serverTapCount: number, newBalance: number }
POST /api/claimPassive
Input: { uid, timestamp }
Calculates passive earnings since last claim
Returns: { valid: boolean, coinsEarned: number, newBalance: number }
POST /api/validateAdReward
Input: { uid, rewardToken, adUnitId, timestamp }
Validates reward with AdMob SSV
Returns: { valid: boolean, rewardAmount: number, newBalance: number }
POST /api/purchaseUpgrade
Input: { uid, upgradeId, tier, level }
Validates user has enough coins
Deducts cost, applies upgrade
Returns: { valid: boolean, newBalance: number, newStats: {} }
POST /api/submitWithdrawal
Input: { uid, amount, method, paymentDetails: {} }
Validates balance, creates withdrawal request
Returns: { valid: boolean, requestId: string }
GET /api/checkBanStatus
Input: { uid }
Returns: { banned: boolean, banType: string, banReason: string, banUntil: timestamp }

📊 ANALYTICS EVENTS
User Lifecycle:
app_open
sign_up (method: google/phone)
tutorial_complete
first_tap
first_upgrade
first_passive_claim
first_achievement
email_verified
first_withdrawal_request
first_withdrawal_completed
Engagement:
session_start
session_end (duration)
taps_completed (count: 100/1000/5000)
passive_claimed (amount, hours_offline)
upgrade_purchased (upgradeId, tier, level, cost)
achievement_unlocked (achievementId)
referral_applied (code)
referral_completed (referrerId)
Monetization:
ad_impression (type, unit_id)
ad_clicked (type, unit_id)
ad_reward_earned (amount)
iap_initiated (item_id, price)
iap_completed (item_id, price, order_id)
iap_failed (item_id, error)
Withdrawals:
withdrawal_requested (amount, method)
withdrawal_cancelled
withdrawal_completed (amount, days_taken)
withdrawal_rejected (reason)
Errors:
api_error (endpoint, error_code)
ad_load_failed (type, error)
payment_failed (error)

🚨 ANTI-CH
S
Continue
CHEAT RULES
Automatic Flags:
Flag Type 1: Speed Violation
Trigger: Tap speed > 15 taps/second for 5+ seconds
Action: Soft ban 24 hours, reset daily taps to 0
Flag Type 2: Earning Velocity
Trigger: User earns > 200K coins in 24 hours (20x median)
Action: Manual review required, limit withdrawals
Flag Type 3: Time Manipulation
Trigger: Passive claim with suspicious timestamps (future date, too frequent)
Action: Reject claim, flag account
Flag Type 4: Multiple Accounts
Trigger: 3+ accounts from same device ID or IP
Action: Soft ban all accounts, manual review
Flag Type 5: Ad Fraud
Trigger: 50+ rewarded ads in 1 hour
Action: Stop ad rewards, flag account
Flag Type 6: Referral Abuse
Trigger: 5+ referrals from same IP within 24 hours
Action: Invalidate referrals, flag account
Flag Type 7: Withdrawal Pattern
Trigger: New account (<7 days) requesting withdrawal
Action: Extended review (7-10 days), verify gameplay

🎯 SUCCESS METRICS
Phase 1 (Month 1-3):
500-1500 installs
200-500 DAU
15% D1 retention
10% D7 retention
30-100 withdrawals processed
₹5K-15K monthly revenue
4.0+ app rating
Phase 2 (Month 4-6):
3000-5000 installs
800-1500 DAU
25% D1 retention
15% D7 retention
150-300 withdrawals/month
₹20K-50K monthly revenue
4.2+ app rating
Phase 3 (Month 7-12):
10,000+ installs
2000-5000 DAU
30% D1 retention
20% D7 retention
500-1000 withdrawals/month
₹50K-150K monthly revenue
Break-even or profitable

⚠️ RISKS & MITIGATION
Risk 1: Users call it "too slow"
Mitigation: Clear expectations in onboarding, show realistic timelines, add IAP for impatient users
Risk 2: Ad revenue lower than projected
Mitigation: Monitor CPMs weekly, adjust payouts dynamically, add ad mediation
Risk 3: Withdrawal processing overwhelming
Mitigation: Start with daily batches, hire VA at 50+ withdrawals/day, automate via Razorpay X later
Risk 4: Fraud/bot attacks
Mitigation: Strong server validation, behavior analysis, swift bans, require email verification
Risk 5: Google Play policy violation
Mitigation: Clear disclaimers, no guaranteed earnings claims, follow rewarded product guidelines
Risk 6: Negative reviews tank rating
Mitigation: Excellent onboarding, responsive support, in-app feedback before Play Store review prompt

📅 DEVELOPMENT PHASES
Phase 1: Core Mechanics (Week 1-2)
Authentication (Google, Phone)
Main mining screen
Tap functionality (local + server sync)
Passive mining (calculation + claim)
Basic UI/UX
Phase 2: Progression (Week 3-4)
Upgrades system (all tiers)
Daily login bonus
Achievements system
Local storage (Hive)
State management
Phase 3: Monetization (Week 5-6)
AdMob integration (all formats)
Ad viewing validation
Rewarded ad claim flow
Razorpay IAP setup
Purchase flow
Phase 4: Social & Withdrawals (Week 7-8)
Referral system
Wallet screen
Withdrawal request flow
Email verification
Transaction history
Phase 5: Anti-Cheat (Week 9)
Cloudflare Workers validation
Device fingerprinting
Ban system
Rate limiting
Behavioral analysis
Phase 6: Polish (Week 10-11)
Animations & transitions
Sound effects (optional)
Haptic feedback
Tutorial flow
Error handling
Offline mode
Phase 7: Testing (Week 12)
Beta testing (50-100 users)
Bug fixes
Performance optimization
Security audit
Analytics validation
Phase 8: Launch (Week 13-14)
Play Store listing
Soft launch (limited regions)
Monitor metrics
Process first withdrawals
Iterate based on feedback

🎨 UI/UX GUIDELINES
Design Language:
Theme: Dark mode with neon accents (crypto/tech aesthetic)
Material 3 design (physics based UI)
Primary color: Electric blue (#00D4FF)
Secondary: Purple (#8B5CF6)
Accent: Green (#10B981) for earnings, Red (#EF4444) for spending
Typography: Sans-serif, Manrope, bold headers(google fonts)
Animations:
Tap: Scale + haptic + floating number
Claim: Confetti + coin shower
Upgrade: Power-up glow effect
Achievement: Badge reveal with shine
Transitions: Smooth 200-300ms
Iconography:
Material Icons or Lucide Icons
Consistent 24dp size
Filled style for primary actions
Spacing:
Padding: 16dp standard, 24dp headers
Card radius: 12dp
Button radius: 8dp
Elevation: 2dp cards, 8dp modals
Accessibility:
Minimum touch target: 48x48dp
Contrast ratio: 4.5:1 text, 3:1 UI
Font sizes: 14sp body, 16sp buttons, 24sp headers
Screen reader support (Semantics widgets)
Responsiveness:
Support: 5" to 7" screens
Safe area: Account for notches/navigation gestures
Landscape: Disable or adapt main screen

📱 MINIMUM VIABLE PRODUCT (MVP)
MVP Features (Launch with these ONLY):
✅ Login (Google + Phone)
✅ Tap mining (with ad gate every 100 taps)
✅ Passive mining (6-hour cap)
✅ 4 tap upgrades + 4 passive upgrades (basic tiers)
✅ Daily login bonus (7-day streak)
✅ 10 achievements (basic milestones)
✅ Wallet with coin → INR conversion
✅ Withdrawal request (manual processing)
✅ AdMob: Rewarded + Banner + App Open
✅ Email verification
✅ Basic anti-cheat (tap speed, daily caps)
Post-MVP (Add later):
Full 8-tier upgrade trees
20 achievements
Referral system
IAP (Razorpay)
Interstitial + Native ads
Advanced anti-cheat
Leaderboard
Social features

🔐 SECURITY REQUIREMENTS
Data Protection:
All API calls over HTTPS only
Certificate pinning for Cloudflare Workers
Encrypt sensitive data in Firestore (payment details)
No PAN/Aadhaar storage (compliance)
Authentication:
Firebase Auth handles tokens
Validate Firebase ID token on every API call
Automatic token refresh
Logout on suspicious activity
Payment Security:
Razorpay handles payment data (PCI compliant)
No credit card storage
UPI/bank details encrypted at rest
Withdrawal requests require email verification
Privacy:
Minimal data collection (email, phone, device ID)
Privacy policy linked in app
User can request data deletion
GDPR compliance (if targeting EU later)

📝 LEGAL REQUIREMENTS
Terms of Service must include:
Earnings are virtual, not guaranteed
Company reserves right to modify rates
Anti-cheat policy and ban conditions
Withdrawal processing time (3-5 days)
Minimum withdrawal (₹50), processing fee (₹10)
Account termination conditions
Dispute resolution (Indian jurisdiction)
Age restriction (18+)
Privacy Policy must include:
Data collected: email, phone, device ID, gameplay data
Third parties: Firebase, AdMob, Razorpay
Data usage: app functionality, ads, fraud prevention
Data retention: 7 years (transaction records)
User rights: access, deletion, correction
Contact email
App Store Listing:
Content rating: Teen/Mature 17+ (real money aspect)
Disclaimer: "Earnings not guaranteed, results vary"
Clear description of earning mechanism
No misleading income claims

