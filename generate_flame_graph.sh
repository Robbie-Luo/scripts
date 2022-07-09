#!/bin/bash
pid=$1
perf record -F 99 -p $pid -g -- sleep 10 >/dev/null
perf script | stackcollapse-perf.pl | flamegraph.pl  > /var/www/html/flame-graph/$2
