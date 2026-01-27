# VPN Server Performance Test Results

## Test Date: 2026-01-27

### Tested Servers (10 locations):

| Rank | Server       | Speed     | Notes |
|------|--------------|-----------|-------|
| 🥇   | Atlanta      | 23.2 MB/s | Fastest peak |
| 🥈   | Phoenix      | 21.1 MB/s | |
| 🥉   | Dallas       | 20-22 MB/s | **SELECTED** - Most consistent |
| 4    | Miami        | 19.6 MB/s | |
| 5    | Seattle      | 18.2 MB/s | |
| 6    | United States| 17.9 MB/s | Random US server |
| 7    | Los Angeles  | 16.0 MB/s | |
| 8    | New York     | 12.3 MB/s | |
| 9    | Canada       | 11.7 MB/s | |
| -    | Chicago      | Failed    | Connection issue |

### Selected: Dallas
- **Consistent**: 20-22 MB/s across multiple tests
- **Reliable**: Less variance than Atlanta (15-23 MB/s)
- **Good enough**: 200 Mbps vs 500 Mbps internet still limited by VPN

### Recommendation:
- **Top 3 servers**: Atlanta, Phoenix, Dallas (~20-23 MB/s)
- **Avoid**: New York, Canada (~12 MB/s)
- Re-test servers if speeds degrade over time

### Configuration:
```bash
# In .env file:
SERVER_COUNTRIES=Dallas
```

### Re-testing:
```bash
cd /home/joe/Parachini-HomeLab
./scripts/test-vpn-speed.sh  # Full test (~15 min)
```

