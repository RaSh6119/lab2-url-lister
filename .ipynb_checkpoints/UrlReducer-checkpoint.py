#!/usr/bin/env python
from operator import itemgetter
import sys

def main():
    previous_url = None
    total_count = 0

    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            url, count_str = line.split('\t', 1)
            count = int(count_str)
        except ValueError:
            continue
        if url == previous_url:
            total_count += count
        else:
            if previous_url is not None and total_count > 5:
                print(f"{previous_url}\t{total_count}")
            previous_url = url
            total_count = count
    if previous_url is not None and total_count > 5:
        print(f"{previous_url}\t{total_count}")

if __name__ == "__main__":
    main()