from DdManager import DBManager
from hh_load_class import HeadHunterAPI
from utils import vacancy_data_db, employer_data_db

if __name__ == '__main__':

    db = DBManager()

    db.create_tables()
    api_HH = HeadHunterAPI()
    vacancy_list = api_HH.get_vacancies()
    employers_list = api_HH.get_employer()

    employer_data_db(employers_list, db)
    vacancy_data_db(vacancy_list, db)

    print(db.get_companies_and_vacancies_count())
    print(db.get_all_vacancies())
    print(db.get_avg_salary())
    print(db.get_vacancies_with_higher_salary())
    print(db.get_vacancies_with_keyword('стажер'))

    if not db.conn.closed:
        db.conn.close()
