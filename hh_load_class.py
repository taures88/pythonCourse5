from abc import ABC, abstractmethod
import requests
from hh_load_id import hh_id


class get_service_API(ABC):

    @abstractmethod
    def get_vacancies(self):
        pass

    @abstractmethod
    def get_employer(self):
        pass


class HeadHunterAPI(get_service_API):

    def __init__(self, page: int = 0) -> None:
        self.url = 'https://api.hh.ru/vacancies'
        self.params = {
            'page': page,
            'employer_id': hh_id.get('employer_ids'),
            'per_page': hh_id.get('vacancies_per_page'),
            'area': hh_id.get('area'),
            'only_with_salary': hh_id.get('only_with_salary'),
        }

    def get_vacancies(self) -> list[dict]:
        response = requests.get(self.url, params=self.params)
        if not response.status_code == 200:
            raise Exception
        return response.json()['items']

    def get_employer(self) -> list[dict]:
        return [
            {
                'id': uid,
                'name': requests.get(f"https://api.hh.ru/employers/{uid}").json().get('name'),
                'url': requests.get(f"https://api.hh.ru/employers/{uid}").json().get('alternate_url')
            }
            for uid in self.params.get('employer_id') if uid is not None
        ]