# VM Health Analyzer

This repository contains a Bash script that checks the health of an Ubuntu-based virtual machine by monitoring:

- CPU utilization
- Memory utilization
- Disk space utilization

The script reports the VM as:
- Healthy, when all three metrics are below 60%
- Not healthy, when any one of the three metrics reaches or exceeds 60%

It also supports an optional explain mode that prints a reason for the health status.

## Why this repository exists

This project is useful for system administrators and developers who want a quick, terminal-based health check for Ubuntu VMs. It avoids the need for a heavy monitoring system and works directly from the Ubuntu machine itself.

## Files in this repository

- vm_health.sh: The main shell script that performs the health checks
- README.md: Documentation for the repository and script usage

## Script behavior

The script checks the following:

1. CPU usage
   - Measures the live CPU utilization from /proc/stat
2. Memory usage
   - Measures used memory as a percentage of total memory using free -m
3. Disk usage
   - Measures root filesystem usage using df -P /

Then it applies the health rule:

- If any metric is 60% or more, the status is Not healthy
- If all three metrics are below 60%, the status is Healthy

## Command-line usage

Run the script normally:

```bash
./vm_health.sh
```

This prints:

- Health status
- CPU utilization
- Memory utilization
- Disk utilization

Run the script with explanation:

```bash
./vm_health.sh explain
```

This prints the health status and also explains which resource(s) caused the final result.

Show help:

```bash
./vm_health.sh --help
```

## Example output

Normal output:

```bash
VM Health Status: Healthy
CPU utilization: 42%
Memory utilization: 33%
Disk utilization: 48%
```

Explanation mode output:

```bash
VM Health Status: Not healthy
CPU utilization: 72%
Memory utilization: 41%
Disk utilization: 50%

Health Status: Not healthy

Explanation:
------------
- CPU utilization is 72% (>= 60%), which makes the VM Not healthy.
- Memory utilization is 41% (< 60%), which keeps the VM in a healthy state.
- Disk utilization is 50% (< 60%), which keeps the VM in a healthy state.

Overall: The VM is Not healthy because at least one metric has reached or exceeded 60% utilization.
```

## Requirements

This script is designed for Ubuntu virtual machines and uses standard Ubuntu/Linux utilities such as:

- /proc
- free
- df
- awk
- bash

## How to make it executable

After saving the script, run:

```bash
chmod +x vm_health.sh
```

Then execute it:

```bash
./vm_health.sh
```

## Notes

- This script checks the root filesystem for disk usage
- It is intended for Ubuntu-based VMs
- The threshold is fixed at 60% as requested

## Summary

This repository provides a lightweight and simple tool for checking whether an Ubuntu VM is healthy based on CPU, memory, and disk usage. It supports both quick status checks and a detailed explanation mode.
