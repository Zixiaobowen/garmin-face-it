#!/usr/bin/env python3
"""Build Garmin PRGs or export a signed Connect IQ store package."""
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
from configure import write_configuration

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_KEY = Path.home() / ".local/share/garmin-face-it/developer_key.der"


def sdk_path(explicit):
    if explicit:
        sdk = Path(explicit).expanduser()
    elif os.environ.get("CIQ_SDK_HOME"):
        sdk = Path(os.environ["CIQ_SDK_HOME"]).expanduser()
    else:
        home = Path.home() / "Library/Application Support/Garmin/ConnectIQ"
        active = home / "current-sdk.cfg"
        if active.is_file():
            sdk = Path(active.read_text().strip())
        else:
            installed = [p for p in (home / "Sdks").glob("*") if (p / "bin/monkeyc").is_file()]
            if len(installed) != 1:
                raise RuntimeError("Specify --sdk or CIQ_SDK_HOME; no unique installed SDK")
            sdk = installed[0]
    if not (sdk / "bin/monkeyc").is_file():
        raise RuntimeError(f"Invalid SDK path: {sdk}")
    return sdk


def package_app(sdk, key, targets, version):
    output = ROOT / "artifacts" / f"release-{version}"
    config = output / "config"
    devices = write_configuration(targets, config)
    package = output / f"reference-face-configurable-{version}.iq"
    command = [str(sdk / "bin/monkeyc"), "-e", "-r", "-f", str(config / "monkey.jungle"),
               "-y", str(key), "-o", str(package), "-O", "2z", "-w", "--build-stats", "0"]
    completed = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
    log = output / "package.log"
    log.write_text("$ " + shlex.join(command) + "\n" + completed.stdout + completed.stderr)
    result = {"observed_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
              "sdk": str(sdk), "store_version": version, "targets": devices,
              "exit_code": completed.returncode, "compiled": completed.returncode == 0,
              "package": str(package.relative_to(ROOT)), "log": str(log.relative_to(ROOT))}
    if result["compiled"]:
        result["bytes"] = package.stat().st_size
        with package.open("rb") as stream:
            result["sha256"] = hashlib.file_digest(stream, "sha256").hexdigest()
    else:
        print(completed.stdout + completed.stderr, end="", flush=True)
    (output / "package-report.json").write_text(json.dumps(result, indent=2) + "\n")
    print(f"PACKAGE {'COMPILED' if result['compiled'] else 'FAILED'}: {package.relative_to(ROOT)}", flush=True)
    return 0 if result["compiled"] else 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sdk")
    parser.add_argument("--key", type=Path, default=DEFAULT_KEY)
    selection = parser.add_mutually_exclusive_group()
    selection.add_argument("--device", help="Single target; defaults to enduro3")
    selection.add_argument("--all", action="store_true", help="Build every manifest target")
    selection.add_argument("--package", metavar="VERSION", help="Export all manifest targets as a store .iq")
    parser.add_argument("--test", action="store_true", help="Include Monkey C unit tests for one target")
    parser.add_argument("--run", action="store_true", help="Run the single result in an already running simulator")
    parser.add_argument("--simulator", action="store_true", help="Compile for the official simulator device variant")
    args = parser.parse_args()
    if args.all and (args.test or args.run):
        parser.error("Use one device for --test / --run")
    if args.package is not None:
        if args.test or args.run or args.simulator:
            parser.error("--package cannot be combined with simulator or test modes")
        if not re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", args.package):
            parser.error("Store version must use MAJOR.MINOR.PATCH, for example 1.0.0")
    simulator = args.simulator or args.run or args.test
    suffix = "-tests" if args.test else "-sim" if simulator else ""
    sdk = sdk_path(args.sdk)
    if not args.key.is_file():
        parser.error(f"Signing key missing: {args.key}; see README.md. Keys stay outside this repository.")
    ns = {"iq": "http://www.garmin.com/xml/connectiq"}
    products = [p.attrib["id"] for p in ET.parse(ROOT / "manifest.xml").findall(".//iq:product", ns)]
    devices = products if args.all or args.package is not None else [args.device or "enduro3"]
    if any(device not in products for device in devices):
        parser.error("Device is not in the verified manifest")
    targets = {t["ciq_product_id"]: t for t in json.loads((ROOT / "docs/compatibility.json").read_text())["targets"]}
    if args.package is not None:
        return package_app(sdk, args.key, [targets[device] for device in devices], args.package)
    output = ROOT / "bin"
    logs = output / "logs"
    logs.mkdir(parents=True, exist_ok=True)
    results = []
    for device in devices:
        compiler_device = device + "_sim" if simulator else device
        prg = output / f"reference-face-configurable-{device}{suffix}.prg"
        config = output / "config" / device
        write_configuration([targets[device]], config)
        command = [str(sdk / "bin/monkeyc"), "-f", str(config / "monkey.jungle"), "-d", compiler_device,
                   "-y", str(args.key), "-o", str(prg), "-w", "--build-stats", "0"]
        if args.test:
            command.append("-t")
        else:
            command += ["-O", "2z"]
            if not simulator:
                command.append("-r")
        completed = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
        log = logs / f"{device}{suffix}.log"
        log.write_text("$ " + shlex.join(command) + "\n" + completed.stdout + completed.stderr)
        result = {"device": device, "compiler_device": compiler_device, "simulator_build": simulator,
                  "exit_code": completed.returncode, "compiled": completed.returncode == 0,
                  "program": str(prg.relative_to(ROOT)), "log": str(log.relative_to(ROOT)), "unit_tests_included": args.test}
        if completed.returncode == 0:
            result["bytes"] = prg.stat().st_size
        results.append(result)
        print(f"{device}: {'COMPILED' if result['compiled'] else 'FAILED'} ({log.relative_to(ROOT)})", flush=True)
        if not result["compiled"]:
            print(completed.stdout + completed.stderr, end="", flush=True)
        if args.run and result["compiled"]:
            run_command = [str(sdk / "bin/monkeydo"), str(prg), device]
            if args.test:
                run_command.append("-t")
            run = subprocess.run(run_command, cwd=ROOT, capture_output=True, text=True)
            (logs / f"{device}{suffix}-simulator.log").write_text(run.stdout + run.stderr)
            result["simulator_exit_code"] = run.returncode
            print(run.stdout + run.stderr, end="", flush=True)
    report = output / f"build-{'all' if args.all else devices[0]}{suffix}.json"
    report.write_text(json.dumps({"observed_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
                                  "sdk": str(sdk), "results": results}, indent=2) + "\n")
    return 0 if all(r["compiled"] and r.get("simulator_exit_code", 0) == 0 for r in results) else 1


if __name__ == "__main__":
    sys.exit(main())
