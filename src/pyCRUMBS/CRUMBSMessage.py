from __future__ import annotations

from dataclasses import dataclass, field
from typing import List

CRUMBS_DATA_LENGTH = 7
CRUMBS_MESSAGE_SIZE = 31  # 1 + 1 + (7*4) + 1


@dataclass
class CRUMBSMessage:
    """
    Fixed-size CRUMBS message.
      - typeID:       1 byte
      - commandType:  1 byte
      - data:         7 floats (28 bytes)
      - crc8:         1 byte
    Total: 31 bytes (sliceAddress excluded).
    """

    typeID: int = 0
    commandType: int = 0
    data: List[float] = field(default_factory=lambda: [0.0] * CRUMBS_DATA_LENGTH)
    crc8: int = 0

    def __post_init__(self) -> None:
        if len(self.data) != CRUMBS_DATA_LENGTH:
            values: List[float] = list(self.data)
            if len(values) < CRUMBS_DATA_LENGTH:
                values.extend([0.0] * (CRUMBS_DATA_LENGTH - len(values)))
            else:
                values = values[:CRUMBS_DATA_LENGTH]
            self.data = values
        self.crc8 &= 0xFF

    def __str__(self) -> str:
        data_str = ", ".join(f"{d:.2f}" for d in self.data)
        return (
            f"CRUMBSMessage(typeID={self.typeID}, "
            f"commandType={self.commandType}, data=[{data_str}], crc8={self.crc8})"
        )
