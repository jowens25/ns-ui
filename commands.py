

import subprocess


def runCmd(args: list[str]) -> tuple[str, str]:
    print(f"running: {args}")
    result = subprocess.run(args, capture_output=True, text=True)
    return result.stdout