

import subprocess


def exec(args: list[str]) -> tuple[str, str]:

    result = subprocess.run(args, capture_output=True, text=True, check=True)
    return result.stdout, result.stderr