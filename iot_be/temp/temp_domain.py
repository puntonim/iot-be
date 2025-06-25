from . import temp_models as models


class TempDomain:
    @classmethod
    def get_temps(cls, n: int) -> list[models.TempDbModel]:
        temps: list[models.TempDbModel] = list(models.TempDbModel.read_from_disk())
        temps.reverse()
        return temps[:n]

    @classmethod
    def create_temp(
        cls, temp: float, humidity: float, room_id: str, sensor_id: str, sensor_ip: str
    ) -> models.TempDbModel:
        temp = models.TempDbModel(
            temp=temp,
            humidity=humidity,
            room_id=room_id,
            sensor_id=sensor_id,
            sensor_ip=sensor_ip,
        )
        temp.save_to_disk()
        return temp
