from dataclasses import dataclass, field
from typing import List


@dataclass
class CRUMBSMessage:
    """
    Represents a fixed-size CRUMBS message.
    Structure:
      - typeID:       1 byte (int)
      - commandType:  1 byte (int)
      - data:         6 floats (6 * 4 = 24 bytes)
      - errorFlags:   1 byte (int)
    Total size: 27 bytes.
    """

    typeID: int = 0
    commandType: int = 0
    data: List[float] = field(default_factory=lambda: [0.0] * 6)
    errorFlags: int = 0

    def __str__(self):
        data_str = ", ".join(f"{d:.2f}" for d in self.data)
        return f"CRUMBSMessage(typeID={self.typeID}, commandType={self.commandType}, data=[{data_str}], errorFlags={self.errorFlags})"
