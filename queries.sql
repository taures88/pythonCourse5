"""создание таблицы с вакансиями"""
def vacancy_data_db(data, db):
    with db.conn.cursor() as cur:
        for vacancy in data:
            cur.execute("""
            INSERT INTO vacancies (id, name, company_id, salary_min, salary_max, url)
            VALUES (%s, %s, %s, %s, %s, %s)
            """, (
                vacancy['id'],
                vacancy['name'],
                vacancy['employer']['id'],
                vacancy['salary']['from'],
                vacancy['salary']['to'],
                vacancy['url']
            )
                        )
            db.conn.commit()

"""создание таблицы с работодателем"""
def employer_data_db(data, db):
    with db.conn.cursor() as cur:
        for employer in data:
            cur.execute("""
            INSERT INTO companies (id, name, url)
            VALUES (%s, %s, %s)
            """, (
                employer['id'],
                employer['name'],
                employer['url']

            )
                        )
            db.conn.commit()


"""создание и определнеие таблиц"""
    def create_tables(self):
        with self.conn.cursor() as cur:
            cur.execute("""
                    CREATE TABLE IF NOT EXISTS companies (
                    id INT PRIMARY KEY,
                    name TEXT NOT NULL,
                    url VARCHAR(100)
                    );
                """)
            cur.execute("""
                    CREATE TABLE IF NOT EXISTS vacancies (
                    id INT PRIMARY KEY,
                    name TEXT NOT NULL,
                    company_id INT REFERENCES companies(id) on DELETE CASCADE,
                    salary_min INT,
                    salary_max INT,
                    url VARCHAR(100)
                    );
                """)
            self.conn.commit()

    def get_companies_and_vacancies_count(self):
        """получает список всех компаний и количество вакансий у каждой компании"""
        with self.conn.cursor() as cur:
            cur.execute("""
                    SELECT companies.name, COUNT(vacancies.id)
                    FROM companies
                    JOIN vacancies ON companies.id = vacancies.company_id
                    GROUP BY companies.name;
                """)
            return cur.fetchall()

    def get_all_vacancies(self):
        """получает список всех вакансий с указанием названия компании, названия вакансии и зарплаты и ссылки на вакансию"""
        with self.conn.cursor() as cur:
            cur.execute("""
                    SELECT companies.name, vacancies.name, vacancies.salary_max, vacancies.url
                    FROM vacancies
                    JOIN companies ON vacancies.company_id = company_id;
                """)
            return cur.fetchall()

    def get_avg_salary(self):
        """получает среднюю зарплату по вакансиям"""
        with self.conn.cursor() as cur:
            cur.execute("""
                    SELECT AVG(salary_min + salary_max) / 2
                    FROM vacancies;
                """)
            return cur.fetchone()[0]

    def get_vacancies_with_higher_salary(self):
        """получает список всех вакансий, у которых зарплата выше средней по всем вакансиям"""

        with self.conn.cursor() as cur:
            cur.execute(f"""
                    SELECT companies.name, vacancies.name, vacancies.salary_min, vacancies.salary_max, vacancies.url
                    FROM vacancies
                    JOIN companies ON vacancies.company_id = company_id
                    WHERE ((vacancies.salary_min + vacancies.salary_min) / 2) > {self.get_avg_salary()};
                """)
            return cur.fetchall()


    def get_vacancies_with_keyword(self, keyword):
        """получает список всех вакансий, в названии которых содержатся переданные в метод слово"""
        with self.conn.cursor() as cur:
            cur.execute(f"""
                    SELECT companies.name, vacancies.name, vacancies.salary_min, vacancies.salary_max, vacancies.url
                    FROM vacancies
                    JOIN companies ON vacancies.company_id = company_id
                    WHERE vacancies.name ILIKE '%{keyword}%' OR companies.name ILIKE '%{keyword}%';
                """)
            return cur.fetchall()