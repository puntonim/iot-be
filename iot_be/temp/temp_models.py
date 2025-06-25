import csv
from collections.abc import Generator
from datetime import datetime
from typing import Annotated

import datetime_utils
import pydantic_utils
from pydantic import Field
from pydantic.networks import IPvAnyAddress

from ..conf import settings


class TempDbModel(pydantic_utils.BasePydanticSchema):
    temp: float
    humidity: float
    date: Annotated[datetime, Field(default_factory=datetime_utils.now)]
    room_id: str
    sensor_id: str
    sensor_ip: IPvAnyAddress

    def save_to_disk(self) -> None:
        with open(settings.CSV_DB_PATH, "a", newline="") as csvfile:
            w = csv.writer(csvfile)
            w.writerow(
                [
                    self.temp,
                    self.humidity,
                    self.date.isoformat(),
                    self.room_id,
                    self.sensor_id,
                    self.sensor_ip,
                ]
            )

    @classmethod
    def read_from_disk(cls) -> Generator["TempDbModel"]:
        with open(settings.CSV_DB_PATH, newline="") as csvfile:
            r = csv.DictReader(csvfile)
            for row in r:
                yield cls(**row)
