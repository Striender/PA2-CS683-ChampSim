#!/bin/bash

# traces list
TRACES=("trace1.champsimtrace.xz" "trace2.champsimtrace.xz" "trace3.champsimtrace.xz" "trace4.champsimtrace.xz")
# output file
BIN_NAME=champsim-offset_prefetcher
OUTFILE=$(echo "./results/$BIN_NAME-results.csv")

#mkdir -p "$OUTFILE"

echo "Trace, IPC,Total Access,Total Hits,Total Misses,Total MPKI,Load Access,Load Hit,Load Miss,Load MPKI,Data Load MPKI,Prefetch Requested,Prefetch Issued,Prefetch Useful,Prefetch Useless,Useful Load Prefetches,Timely Prefetches,Late Prefetches,Dropped Prefetches,Average Miss Latency" > "$OUTFILE"

for TRACE in "${TRACES[@]}"; do
    echo "Running $TRACE ..."

    # Run ChampSim and capture output
    OUTPUT=$(./bin/champsim-offset_prefetcher -warmup_instructions 25000000 -simulation_instructions 25000000 -traces trace/$TRACE)

    # extract data
    IPC=$(echo "$OUTPUT" | grep "CPU 0 cumulative IPC" | awk '{print $5}')
    L2_TOTAL_ACCESS=$(echo "$OUTPUT" | grep "L2C TOTAL" | awk '{print $4}')
    L2_TOTAL_HIT=$(echo "$OUTPUT" | grep "L2C TOTAL" | awk '{print $6}')
    L2_TOTAL_MISS=$(echo "$OUTPUT" | grep "L2C TOTAL" | awk '{print $8}')
    L2_TOTAL_MPKI=$(echo "$OUTPUT" | grep "L2C TOTAL" | awk '{print $16}')
    
    L2_LOAD_ACCESS=$(echo "$OUTPUT" | grep "L2C LOAD      ACCESS" | awk '{print $4}')
    L2_LOAD_HIT=$(echo "$OUTPUT" | grep "L2C LOAD      ACCESS" | awk '{print $6}')
    L2_LOAD_MISS=$(echo "$OUTPUT" | grep "L2C LOAD      ACCESS" | awk '{print $8}')
    L2_LOAD_MPKI=$(echo "$OUTPUT" | grep "L2C LOAD      ACCESS" | awk '{print $16}')

    L2_DATA_LOAD_MPKI=$(echo "$OUTPUT" | grep "L2C DATA LOAD MPKI" | awk '{print $5}')

    L2C_PREFETCH_REQUESTED=$(echo "$OUTPUT" | grep "L2C PREFETCH  REQUESTED" | awk '{print $4}')
    L2C_PREFETCH_ISSUED=$(echo "$OUTPUT" | grep "L2C PREFETCH  REQUESTED" | awk '{print $6}')
    L2C_PREFETCH_USEFUL=$(echo "$OUTPUT" | grep "L2C PREFETCH  REQUESTED" | awk '{print $8}')
    L2C_PREFETCH_USELESS=$(echo "$OUTPUT" | grep "L2C PREFETCH  REQUESTED" | awk '{print $10}')

    L2C_PREFETCH_USEFUL_LOAD_PREFETCHES=$(echo "$OUTPUT" | grep "L2C USEFUL LOAD PREFETCHES" | awk '{print $5}')

    L2C_TIMELY_PREFETCHES=$(echo "$OUTPUT" | grep "L2C TIMELY PREFETCHES" | awk '{print $4}')
    L2C_LATE_PREFETCHES=$(echo "$OUTPUT" | grep "L2C TIMELY PREFETCHES" | awk '{print $7}')
    L2C_DROPPED_PREFETCHES=$(echo "$OUTPUT" | grep "L2C TIMELY PREFETCHES" | awk '{print $10}')

    L2C_AVERAGE_MISS_LATENCY=$(echo "$OUTPUT" | grep "L2C AVERAGE MISS LATENCY" | awk '{print $5}')
    
    # Build row
    echo "$TRACE,$IPC,$L2_TOTAL_ACCESS,$L2_TOTAL_HIT,$L2_TOTAL_MISS,$L2_TOTAL_MPKI,$L2_LOAD_ACCESS,$L2_LOAD_HIT,$L2_LOAD_MISS,$L2_LOAD_MPKI,$L2_DATA_LOAD_MPKI,$L2C_PREFETCH_REQUESTED,$L2C_PREFETCH_ISSUED,$L2C_PREFETCH_USEFUL,$L2C_PREFETCH_USELESS,$L2C_PREFETCH_USEFUL_LOAD_PREFETCHES,$L2C_TIMELY_PREFETCHES,$L2C_LATE_PREFETCHES,$L2C_DROPPED_PREFETCHES,$L2C_AVERAGE_MISS_LATENCY" >> "$OUTFILE"
done

echo "Done! Results saved in $OUTFILE"