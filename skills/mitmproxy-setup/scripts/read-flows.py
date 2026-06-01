#!/usr/bin/env python3
"""读取 mitmdump 保存的流量文件"""
import sys
from mitmproxy import io
from mitmproxy.exceptions import FlowReadException

if len(sys.argv) < 2:
    print("用法: python3 read-flows.py <flows文件>")
    sys.exit(1)

flow_file = sys.argv[1]

with open(flow_file, "rb") as f:
    reader = io.FlowReader(f)
    try:
        for flow in reader.stream():
            if hasattr(flow, 'request'):
                req = flow.request
                resp = flow.response
                url = req.pretty_url
                method = req.method
                status = resp.status_code if resp else 'N/A'
                print(f"{method} {status} {url}")
    except FlowReadException as e:
        print(f"读取错误: {e}")
