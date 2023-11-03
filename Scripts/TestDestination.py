#!/usr/bin/env python3

import subprocess
import json
from pkg_resources import parse_version

# Constants
min_version = parse_version("17")

# Get valid runtime
def is_valid_runtime(runtime):
  version = parse_version(runtime["version"])
  return runtime["platform"] == "iOS" and version >= min_version

runtimes_description = subprocess.check_output("xcrun simctl list runtimes -j", shell=True).decode("utf-8")
runtimes = json.loads(runtimes_description)["runtimes"]

valid_runtimes = filter(is_valid_runtime, runtimes)
valid_runtime_id = next(valid_runtimes)["identifier"]

# Get valid device
devices_description = subprocess.check_output("xcrun simctl list devices -j", shell=True).decode("utf-8")
devices = json.loads(devices_description)["devices"]

valid_device_id = devices[valid_runtime_id][0]["udid"]

# Write output
print("platform=iOS Simulator,id=" + valid_device_id)
