#!/bin/bash

echo "🧪 RAID 健康檢查開始..."

# btrfs scrub
echo "🔄 執行 btrfs scrub /mnt/raid10"
sudo btrfs scrub start -Bd /mnt/raid10

# btrfs 狀態檢查
echo "📊 btrfs filesystem df:"
sudo btrfs filesystem df /mnt/raid10

# S.M.A.R.T 健康狀態
for dev in sdb sdc sdd sde; do
  echo "💽 SMART: /dev/$dev"
  sudo smartctl -a /dev/$dev | grep -E "Model|Serial|Temperature|Reallocated|Pending|Offline"
done

echo "✅ RAID10 + 磁碟健康檢查完成"

