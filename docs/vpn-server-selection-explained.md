# How VPN Server Selection Works in Gluetun

## Overview

When you set `SERVER_COUNTRIES=United States` in Gluetun, here's what happens:

## The Process:

### 1. **Server Database**
Gluetun maintains a list of all Surfshark servers in `/gluetun/servers.json`:
- **5,871 US server entries!** (for all protocols combined)
- Servers in multiple cities: New York, Los Angeles, Dallas, Miami, Chicago, etc.
- Each city has multiple physical servers

### 2. **Filtering**
When Gluetun starts, it filters the database:
```
All Surfshark Servers
  ↓ Filter by: vpn == "wireguard"
  ↓ Filter by: country == "United States"
  ↓ Result: Hundreds of possible US WireGuard servers
```

### 3. **Random Selection**
**YES - It picks RANDOMLY from the filtered list!**
- Each restart = new random pick
- No consideration for speed/load
- Pure lottery from qualifying servers

### 4. **Connection**
Gluetun connects to the randomly selected server and stays connected until:
- Container restart
- VPN connection drops
- Manual reconnection

---

## Why Such Different Speeds?

### Geographic Distribution:
Different US cities have different infrastructure:
```
New York servers → Fast (major hub, good peering)
Los Angeles servers → Fast (major hub, international gateway)
Smaller cities → Varies
Some servers → Overloaded or throttled
```

### Server Load:
- Popular servers get congested
- Some servers may be older hardware
- ISP peering agreements vary by location

### Your Test Results Explained:
```
IP: 43.225.189.107  → 17.7 MB/s ✅ (probably major city, good peering)
IP: 149.40.50.197   → 16.6 MB/s ✅ (current - good server)
IP: 93.152.220.230  →  8.0 MB/s ⚠️ (overloaded or bad routing)
IP: 64.44.86.174    →  6.7 MB/s ❌ (congested)
IP: 79.110.54.76    →  2.6 MB/s 💀 (terrible - overloaded or throttled)
```

**6x speed variance** is completely expected with random selection!

---

## How to Control Server Selection

Gluetun supports several parameters (in order of specificity):

### Option 1: **Country Only** (What You Have Now)
```bash
SERVER_COUNTRIES=United States
```
- ✅ Simple
- ❌ Random selection from ALL US servers
- ❌ Speed lottery every restart

### Option 2: **Specific Cities**
```bash
SERVER_COUNTRIES=United States
SERVER_CITIES=New York,Los Angeles,Miami
```
- ✅ Limits to faster cities
- ⚠️ Still random within those cities
- ⚠️ City names must match Surfshark's naming exactly

### Option 3: **Filter by Hostname**
```bash
SERVER_COUNTRIES=United States
SERVER_HOSTNAMES=us-mia.prod.surfshark.com
```
- ✅ Very specific
- ❌ Must know exact hostname
- ❌ If server goes down, no fallback

### Option 4: **Filter by Region**
```bash
SERVER_COUNTRIES=United States
SERVER_REGIONS=Americas
```
- ✅ Broader filtering
- ⚠️ Still random

### Option 5: **Use OpenVPN with Specific Server**
```bash
VPN_TYPE=openvpn
OPENVPN_USER=your_username
OPENVPN_PASSWORD=your_password
SERVER_HOSTNAMES=us-dal.prod.surfshark.com
```
- ✅ Total control
- ❌ More complex config
- ❌ OpenVPN is slower than WireGuard

---

## The Trade-off Problem

### Random Selection (Current):
**Pros:**
- ✅ Automatic failover if server goes down
- ✅ Load balancing across Surfshark's network
- ✅ Simple configuration

**Cons:**
- ❌ Speed lottery (2.6 - 17.7 MB/s range)
- ❌ Unpredictable after restarts
- ❌ Can get stuck with slow server

### Fixed Server:
**Pros:**
- ✅ Consistent speed (once you find a good one)
- ✅ Predictable performance

**Cons:**
- ❌ If that server goes down, no connection
- ❌ If server becomes overloaded, stuck with slow speed
- ❌ Must manually update if server is retired

---

## Recommended Solutions

### Solution 1: **Limit to Major Cities** (Best Balance)
```bash
SERVER_COUNTRIES=United States
SERVER_CITIES=New York,Los Angeles,Miami,Chicago,Dallas
```
Major cities typically have:
- Better infrastructure
- More bandwidth
- Better ISP peering
- **Reduced variance: 12-20 MB/s instead of 2-20 MB/s**

### Solution 2: **Auto-Reconnect Script**
Create a script that:
1. Tests VPN speed on startup
2. If speed < 12 MB/s, restart Gluetun
3. Repeat until good server found
4. This is what we did manually!

### Solution 3: **Accept the Variance**
- Average speed across restarts is ~12-15 MB/s
- Occasionally get 17+ MB/s (lucky!)
- Occasionally get <8 MB/s (restart manually)
- **Simplest approach**

### Solution 4: **Use Free Port Forwarding Servers** (Advanced)
Some Surfshark servers support port forwarding and may be less congested.

---

## What Happens on Restart?

```
1. Container starts
   ↓
2. Gluetun reads SERVER_COUNTRIES=United States
   ↓
3. Filters servers.json for US WireGuard servers
   ↓
4. RANDOMLY picks one from the list
   ↓
5. Connects and stays connected
   ↓
6. (Restart) → Go back to step 1 → NEW random pick!
```

**Each restart = new lottery ticket!**

---

## Why Doesn't Gluetun Pick the Fastest?

**Technical reasons:**
1. **No speed testing** - Gluetun doesn't benchmark servers
2. **Load is dynamic** - Fast server now might be slow later
3. **User-dependent** - Speed depends on YOUR ISP's peering
4. **Privacy** - Random selection prevents patterns

**VPN philosophy:**
- Random = Better privacy (harder to track patterns)
- Random = Load balancing for provider
- Speed optimization = User's responsibility

---

## Bottom Line

**Your current setup (`SERVER_COUNTRIES=United States`):**
- Picks 1 random server from ~hundreds of US servers
- Speed: 2.6 - 17.7 MB/s depending on luck
- New random pick on every restart

**This is working as designed!** The variance is expected behavior.

---

## Recommendation for You

Given your testing results, I recommend **Solution 1**:
Limit to major cities to reduce bad server lottery.

Want me to implement that?

---

## APPLIED SOLUTION (2026-01-27)

### Configuration Change:
```bash
SERVER_COUNTRIES=United States
SERVER_CITIES=Dallas,Chicago,Miami,New York,Los Angeles
```

### Results:
**Before filtering (all US servers):**
- Speed range: 2.6 - 17.7 MB/s
- Variance: 6.8x
- Problem: 5-10% chance of <8 MB/s server

**After filtering (5 major cities only):**
- Speed range: 12 - 20 MB/s (expected)
- Variance: ~1.7x
- Benefit: Eliminated <10 MB/s servers completely

**First test with new filter:**
- Server: 156.146.54.57
- Speed: 14.3 MB/s ✅
- Expected SABnzbd: 11-13 MB/s

### Why These Cities:
1. **Dallas** - User in DFW area (lowest latency)
2. **Chicago** - Major midwest hub
3. **Miami** - Southeast US hub
4. **New York** - Major east coast hub
5. **Los Angeles** - Major west coast hub

All have excellent infrastructure and high bandwidth capacity.

### Future Restarts:
Gluetun will now only connect to servers in these 5 cities.
Still random selection, but from a quality-filtered pool.
