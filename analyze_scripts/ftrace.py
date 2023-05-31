def is_line(line: str) -> bool:
    return "kvm_" in line

def parse_line(line: str) -> list[str]:
    line = line.strip()
    return list(filter(lambda x: len(x) > 0, line.split(" ")))

def get_event(line_parts: list[str]) -> str:
    return line_parts[4].strip(':')

def get_timestamp(line_parts: list[str]) -> str:
    stamp = float(line_parts[3][:-1])
    return stamp, float.__floor__(stamp)

MISSING_PART = "NA"
def get_part(parts, key):
    try:
        i = parts.index(key)
        return parts[i+1].strip(':')
    except:
        return MISSING_PART