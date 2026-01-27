# Download Optimization Test - Local vs NAS

## Date: 2026-01-27

## Problem:
- Downloads only reaching 13-16 MB/s
- VPN capable of 20-22 MB/s (Dallas server)
- Internet: 500 Mbps (62 MB/s)
- **Not maxing out VPN throughput**

## Bottleneck Investigation:

### Test 1: VPN Speed ✅
- **Result**: VPN can do 20-22 MB/s consistently
- **Conclusion**: VPN is the ceiling, but SABnzbd isn't reaching it

### Test 2: Download Optimizations 🔄
Changed two variables:

**A. Storage Location:**
- **Before**: `/mnt/nas/downloads` (NAS over network)
- **After**: `./data/downloads` (local disk in WSL2)

**B. Connection Count:**
- **Before**: 30 connections to news.newsgroup.ninja
- **After**: 50 connections

## Expected Results:

### If LOCAL is faster:
- Download speed: 20-22 MB/s (hitting VPN limit) ✅
- **Bottleneck was**: NAS write speed over network
- **Trade-off**: Files copied to NAS after processing (adds time)

### If NO improvement:
- Download speed: Still 13-16 MB/s
- **Bottleneck is**: Usenet server or VPN throttling specific traffic
- **Action**: Switch back to NAS (simpler setup)

## How to Switch Back to NAS:

If local doesn't help, revert with:

```bash
cd /home/joe/Parachini-HomeLab

# Stop SABnzbd
docker-compose stop sabnzbd

# Change back to NAS
sed -i 's|^DOWNLOADS_PATH=.*|DOWNLOADS_PATH=/mnt/nas/downloads|' .env

# Restart
docker-compose up -d sabnzbd
```

Connection count can stay at 50 either way.

## Test Results:

### Download Speed During Test:
- Max speed observed: SLOWER than baseline
- Average speed: Below 13-16 MB/s baseline
- Consistent or spikey: N/A - Reverted immediately

### Decision:
- [ ] Keep local downloads (faster)
- [x] **Revert to NAS** (local was SLOWER)

### Notes:
**Test Date:** 2026-01-27

**Result:** Local downloads + 50 connections were SLOWER than original setup.

**Why local was slower:**
1. **WSL2 filesystem overhead** - Writing to Windows filesystem from Linux containers adds translation layer
2. **50 connections triggered throttling** - Either Usenet server or VPN provider limiting
3. **Bad VPN server in random pool** - United States (random) picked slower server

**Conclusion:**
- **Original NAS setup is OPTIMAL** for this environment
- NAS is NOT the bottleneck (VPN is)
- 13-16 MB/s is excellent for 30-connection Usenet through VPN
- VPN ceiling varies 17-24 MB/s depending on server selection

---

## Workflow Comparison:

### Current Setup (Local Downloads):
```
Internet → VPN → SABnzbd → Local Disk
                              ↓
                    Sonarr/Radarr process
                              ↓
                    Copy to NAS → /media
```

### Previous Setup (NAS Downloads):
```
Internet → VPN → SABnzbd → NAS /downloads
                              ↓
                    Sonarr/Radarr process
                              ↓
                    Move on NAS → /media (fast, same filesystem)
```

## Key Difference:
- **Local**: Faster downloads, slower final placement (network copy)
- **NAS**: Slower downloads, faster final placement (local move)

Total time to "ready to watch" might be similar!
