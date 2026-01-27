# Download Speed A/B Testing Results
## Date: 2026-01-27

## Test Methodology:
- Change ONE variable at a time
- Test for 2-3 minutes per configuration
- Record average speed
- Revert before next test

---

## BASELINE (Control)
**Configuration:**
- Downloads: `/mnt/nas/downloads`
- Connections: 30
- VPN: United States (IP: 84.17.41.78) - BAD SERVER!

**Results:**
- Speed: **8 MB/s** ❌ SLOW
- VPN test: 6 MB/s (terrible server)
- Notes: Got bad VPN server after restart - this was the problem!

**REVISED BASELINE (Good VPN Server):**
- VPN: United States (IP: 149.40.50.197) - 16.6 MB/s VPN speed
- Expected SABnzbd: ~13-15 MB/s
- Notes: Restarted Gluetun 5 times to find fast server

---

## TEST 1: Increase Connections Only
**Configuration:**
- Downloads: `/mnt/nas/downloads` (unchanged)
- Connections: 30 → **50**
- VPN: Same server (no restart)

**Results:**
- Speed: _________ MB/s
- Change vs baseline: _________
- Notes: _________

**Conclusion:**
- [ ] Faster - keep 50 connections
- [ ] Same - connections don't matter
- [ ] Slower - revert to 30

---

## TEST 2: Local Downloads Only
**Configuration:**
- Downloads: `/mnt/nas/downloads` → **`./data/downloads`**
- Connections: 30 (unchanged)
- VPN: Same server (no restart)

**Results:**
- Speed: _________ MB/s
- Change vs baseline: _________
- Notes: _________

**Conclusion:**
- [ ] Faster - local is better
- [ ] Same - location doesn't matter
- [ ] Slower - NAS is better (WSL2 overhead)

---

## TEST 3: VPN Server Change (Optional)
**Configuration:**
- Downloads: `/mnt/nas/downloads` (unchanged)
- Connections: 30 (unchanged)
- VPN: United States → **Specific fast server**

**Results:**
- Speed: _________ MB/s
- Change vs baseline: _________
- Notes: _________

**Conclusion:**
- [ ] Faster - use specific server
- [ ] Same - random is fine
- [ ] Slower - bad server picked

---

## FINAL CONFIGURATION

Based on test results, optimal config is:
- Downloads: _________
- Connections: _________
- VPN: _________
- Expected speed: _________ MB/s

---

## Notes:
- VPN speed varies 17-24 MB/s depending on server
- Usenet speed depends on time of day
- WSL2 may have filesystem overhead
- More connections can trigger throttling
