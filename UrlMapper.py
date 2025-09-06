#!/usr/bin/env python
import sys
import re

def extract_urls(line):
    pattern = r'href=["\']([^"\']*)["\']'   
    matches = re.finditer(pattern, line, re.IGNORECASE)
    urls = []
    for i in matches:
        url = i.group(1).strip()
        if url and len(url) > 0:
            urls.append(url)  
    return urls

def main():
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue 
        urls = extract_urls(line)
        for url in urls:
            print(f"{url}\t1")

if __name__ == "__main__":
    main()