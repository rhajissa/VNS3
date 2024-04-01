#!/bin/bash

# RAM erfassen
# memoryMax=$(free -m | head -2 | tail -1 | tr -s " " | cut -d" " -f2)
# memoryUse=$(free -m | head -2 | tail -1 | tr -s " " | cut -d" " -f3)

memoryUse=$(docker stats --no-stream --format "{{.MemUsage}}" $(hostname) | awk '{print $1}' | sed 's/...$//')

#CPU erfassen
# cpuFree=$(mpstat | tail -1 | tr -s ' ' | cut -d' ' -f12)
# cpuUse=$( echo "100 - $cpuFree" | bc -l | sed 's/^\./0./' )
cpuUse=$(docker stats --no-stream --format "{{.CPUPerc}}" $(hostname) | awk '{print $1}'| sed 's/.$//')


# Werte in Datenbank schreiben
mariadb -h cluster-data -u"dbuser" -p"dideldaddeldu" -D"dbdemo" -e"
INSERT INTO container_stats(container_identifier, ram_usage, cpu_usage, timestamp)
VALUES('$(hostname)', $memoryUse, $cpuUse, '$(date +'%F %T')')
;"