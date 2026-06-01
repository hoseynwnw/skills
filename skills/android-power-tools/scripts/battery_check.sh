#!/bin/sh
echo "=== 🔋 电池与充电深度检查 (多节点) ==="

android-shizuku-cli exec "su -c 'for n in battery wireless usb dc main-charger tcpm-source-psy-i2c-max77759tcpc; do if ls /sys/class/power_supply/\$n/uevent >/dev/null 2>&1; then echo \"=== \$n ===\"; cat /sys/class/power_supply/\$n/uevent 2>/dev/null; fi; done'" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    stdout = data.get('data', {}).get('stdout', '')
    nodes = {}
    current = None
    for line in stdout.strip().split('\n'):
        if line.startswith('=== '):
            current = line.replace('===', '').strip()
            nodes[current] = {}
        elif '=' in line and current:
            k, v = line.split('=', 1)
            nodes[current][k] = v

    # 电池状态
    bat = nodes.get('battery', {})
    if bat:
        cap = bat.get('POWER_SUPPLY_CAPACITY', '?')
        temp = float(bat.get('POWER_SUPPLY_TEMP', '0')) / 10
        cycle = bat.get('POWER_SUPPLY_CYCLE_COUNT', '?')
        health = bat.get('POWER_SUPPLY_HEALTH', '?')
        vol = float(bat.get('POWER_SUPPLY_VOLTAGE_NOW', '0')) / 1e6
        cur = float(bat.get('POWER_SUPPLY_CURRENT_NOW', '0')) / 1e6
        power = abs(vol * cur)
        print(f'🟢 [电池端] {cap}% | {temp}°C | 循环:{cycle} | 状态:{health}')
        print(f'   电压:{vol:.2f}V | 电流:{cur:.2f}A | 电池端功率: {power:.2f}W')

    # 输入端状态
    for n in ['wireless', 'usb', 'dc', 'main-charger', 'tcpm-source-psy-i2c-max77759tcpc']:
        info = nodes.get(n, {})
        if info and info.get('POWER_SUPPLY_ONLINE') == '1':
            v = float(info.get('POWER_SUPPLY_VOLTAGE_NOW', '0')) / 1e6
            c = float(info.get('POWER_SUPPLY_CURRENT_NOW', '0')) / 1e6
            p = abs(v * c)
            ptype = info.get('POWER_SUPPLY_TYPE', info.get('POWER_SUPPLY_USB_TYPE', '?'))
            print(f'🔌 [输入端: {n}] 协议:{ptype} | {v:.2f}V {c:.2f}A | 输入功率: {p:.2f}W')

except Exception as e:
    print('解析数据失败:', str(e))
"
