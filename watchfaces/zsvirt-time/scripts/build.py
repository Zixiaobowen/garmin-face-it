#!/usr/bin/env python3
"""Build ZSvirt Time for Enduro 3, run its simulator, or export a store package."""
import argparse
import datetime
import hashlib
import json
import os
from pathlib import Path
import re
import shlex
import subprocess
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_KEY = Path.home() / ".local/share/garmin-face-it/developer_key.der"


def sdk_path(explicit):
    if explicit:
        sdk = Path(explicit).expanduser()
    elif os.environ.get("CIQ_SDK_HOME"):
        sdk = Path(os.environ["CIQ_SDK_HOME"]).expanduser()
    else:
        directory = Path.home() / "Library/Application Support/Garmin/ConnectIQ"
        active = directory / "current-sdk.cfg"
        if active.is_file():
            sdk = Path(active.read_text().strip())
        else:
            installed = [p for p in (directory / "Sdks").glob("*") if (p / "bin/monkeyc").is_file()]
            if len(installed) != 1:
                raise RuntimeError("Specify --sdk or CIQ_SDK_HOME; no unique installed SDK")
            sdk = installed[0]
    if not (sdk / "bin/monkeyc").is_file():
        raise RuntimeError(f"Invalid SDK path: {sdk}")
    return sdk


def package_app(sdk, key, devices, version):
    output = ROOT / "artifacts" / f"release-{version}"
    output.mkdir(parents=True, exist_ok=True)
    package = output / f"zsvirt-time-{version}.iq"
    command = [str(sdk / "bin/monkeyc"), "-e", "-r", "-f", str(ROOT / "monkey.jungle"),
               "-y", str(key), "-o", str(package), "-O", "2z", "-w", "--build-stats", "0"]
    build = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
    (output / "package.log").write_text("$ " + shlex.join(command) + "\n" + build.stdout + build.stderr)
    print(build.stdout + build.stderr, end="", flush=True)
    result = {"observed_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
              "sdk": str(sdk), "store_version": version, "targets": devices,
              "compiled": build.returncode == 0, "exit_code": build.returncode,
              "package": str(package.relative_to(ROOT))}
    if build.returncode == 0:
        result["bytes"] = package.stat().st_size
        with package.open("rb") as stream:
            result["sha256"] = hashlib.file_digest(stream, "sha256").hexdigest()
    (output / "package-report.json").write_text(json.dumps(result, indent=2) + "\n")
    return 0 if result["compiled"] else 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sdk")
    parser.add_argument("--key", type=Path, default=DEFAULT_KEY)
    selection = parser.add_mutually_exclusive_group()
    selection.add_argument("--device", default="enduro3")
    selection.add_argument("--package", metavar="VERSION", help="Export all manifest targets as a signed store IQ")
    parser.add_argument("--simulator", action="store_true", help="Build the official simulator target")
    parser.add_argument("--run", action="store_true", help="Run in an already running simulator")
    parser.add_argument("--test", action="store_true", help="Include clock boundary tests")
    parser.add_argument("--release", action="store_true", help="Strip debug data from a simulator build")
    args = parser.parse_args()
    if args.test and args.release:
        parser.error("--release cannot be combined with --test")
    if args.package is not None:
        if args.run or args.test or args.simulator:
            parser.error("--package cannot be combined with simulator or test modes")
        if not re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", args.package):
            parser.error("Store version must use MAJOR.MINOR.PATCH, for example 1.0.0")
    ns = {"iq": "http://www.garmin.com/xml/connectiq"}
    devices = [p.attrib["id"] for p in ET.parse(ROOT / "manifest.xml").findall(".//iq:product", ns)]
    if args.device not in devices:
        parser.error(f"Unsupported device: {args.device}; supported: {', '.join(devices)}")
    if not args.key.is_file():
        parser.error(f"Signing key missing: {args.key}; keep signing keys outside this repository")
    sdk = sdk_path(args.sdk)
    if args.package is not None:
        return package_app(sdk, args.key, devices, args.package)
    simulator = args.simulator or args.run or args.test
    suffix = "-tests" if args.test else "-sim" if simulator else ""
    if simulator and args.release:
        suffix += "-release"
    compiler_device = args.device + "_sim" if simulator else args.device
    output = ROOT / "bin"
    logs = output / "logs"
    logs.mkdir(parents=True, exist_ok=True)
    stem = f"zsvirt-time-{args.device}{suffix}"
    program = output / f"{stem}.prg"
    command = [str(sdk / "bin/monkeyc"), "-f", str(ROOT / "monkey.jungle"),
               "-d", compiler_device, "-y", str(args.key), "-o", str(program),
               "-w", "--build-stats", "0"]
    if args.test:
        command.append("-t")
    else:
        command += ["-O", "2z"]
        if not simulator or args.release:
            command.append("-r")
    build = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
    (logs / f"{stem}.log").write_text("$ " + shlex.join(command) + "\n" + build.stdout + build.stderr)
    print(build.stdout + build.stderr, end="", flush=True)
    result = {"observed_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
              "sdk": str(sdk), "device": args.device, "compiler_device": compiler_device,
              "compiled": build.returncode == 0, "exit_code": build.returncode,
              "program": str(program.relative_to(ROOT)), "unit_tests_included": args.test}
    if build.returncode == 0:
        result["bytes"] = program.stat().st_size
        with program.open("rb") as stream:
            result["sha256"] = hashlib.file_digest(stream, "sha256").hexdigest()
        if args.run:
            run_command = [str(sdk / "bin/monkeydo"), str(program), args.device]
            if args.test:
                run_command.append("-t")
            run = subprocess.run(run_command, cwd=ROOT, capture_output=True, text=True)
            (logs / f"{stem}-simulator.log").write_text(run.stdout + run.stderr)
            print(run.stdout + run.stderr, end="", flush=True)
            result["simulator_exit_code"] = run.returncode
    (output / f"build-{args.device}{suffix}.json").write_text(json.dumps(result, indent=2) + "\n")
    return 0 if result["compiled"] and result.get("simulator_exit_code", 0) == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
