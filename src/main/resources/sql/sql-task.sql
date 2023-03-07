-- 1) Выводит к каждому самолету класс обслуживания и количество мест этого класса
SELECT s.aircraft_code, s.fare_conditions, COUNT(s.seat_no) AS seat_count FROM aircrafts_data ad
LEFT JOIN seats s ON s.aircraft_code = ad.aircraft_code
GROUP BY s.aircraft_code, s.fare_conditions;

-- 2) Находит 3 самых вместительных самолета (модель + кол-во мест)
SELECT ad.model, COUNT(s.aircraft_code) as seats_count FROM aircrafts_data ad
LEFT JOIN seats s ON s.aircraft_code = ad.aircraft_code
GROUP BY ad.model, s.aircraft_code
ORDER BY seats_count DESC
LIMIT 3;

-- 3) Выводит код,модель самолета и места не эконом класса для самолета 'Аэробус A321-200' с сортировкой по местам
SELECT ad.aircraft_code, ad.model, s.seat_no, s.fare_conditions FROM aircrafts_data ad
LEFT JOIN seats s ON s.aircraft_code = ad.aircraft_code
WHERE ad.model = '{"en": "Airbus A321-200", "ru": "Аэробус A321-200"}' AND
NOT s.fare_conditions = 'Economy';

-- 4) Выводит города в которых больше 1 аэропорта ( код аэропорта, аэропорт, город)
SELECT airport_code, airport_name, city FROM airports_data
GROUP BY airport_code, city
HAVING COUNT(city) > 1;

-- 5) Находит ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация
SELECT
    f.flight_id,
    departure.city as departure_city,
    arrival.city as arrival_city,
    f.status as status,
    f.scheduled_departure as scheduled_departure
FROM flights f
         JOIN airports_data departure ON f.departure_airport = departure.airport_code
         JOIN airports_data arrival ON f.arrival_airport = arrival.airport_code
WHERE arrival.city = '{"en": "Moscow", "ru": "Москва"}'
  AND departure.city = '{"en": "Yekaterinburg", "ru": "Екатеринбург"}'
  AND status = 'Scheduled'
ORDER BY scheduled_departure;

-- 6) Выводит самый дешевый и дорогой билет и стоимость ( в одном результирующем ответе)
SELECT
    (SELECT MIN(amount) FROM ticket_flights) as cheap,
    (SELECT MAX(amount) FROM ticket_flights) as expensive;

-- 7) Создание таблицы в котором хранится информация о покупателях, и проверкой на валидность этих данных
CREATE TABLE Customers (
                           id SERIAL PRIMARY KEY,
                           firstName VARCHAR(50) NOT NULL,
                           lastName VARCHAR(50) NOT NULL,
                           email VARCHAR(100) UNIQUE NOT NULL,
                           phone VARCHAR(20) UNIQUE NOT NULL,
                           CONSTRAINT chk_firstName CHECK (firstName <> ''),
                           CONSTRAINT chk_lastName CHECK (lastName <> ''),
                           CONSTRAINT chk_email_format CHECK (email ~* '^[A-Za-z0-9._-]+@[a-z._-]+\.[a-z]{2,}$'),
    CONSTRAINT chk_phone_format CHECK (phone ~* '^(\s*)?(\+)?([- _():=+]?\d[- _():=+]?){10,14}(\s*)?$')
);

-- 8) Создание таблицы, в котором хранится заказы покупателей. Присутствует ссылка на покупателя, и проверка на quantity
CREATE TABLE Orders (
                        id SERIAL PRIMARY KEY,
                        customerId INTEGER NOT NULL REFERENCES Customers(id) ON DELETE CASCADE,
                        quantity INTEGER NOT NULL,
                        CONSTRAINT chk_quantity CHECK (quantity > 0)
);

-- 9) Добавляет данные в Customers и Orders
INSERT INTO Customers (firstName, lastName, email, phone)
VALUES
    ('Zoe', 'Foster', 'zoe.foster@example.com', '+7(357)549-5499'),
    ('Daniel', 'Shaw', 'daniel.shaw@example.com', '+8(467)599-5999'),
    ('Peter', 'Garrett', 'peter.garrett@example.com', '+9(497)109-1009'),
    ('Lloyd', 'Hart', 'lloyd.hart@example.com', '+10(150)777-7777'),
    ('June', 'Collins', 'june.collins@example.com', '+11(222)666-6666');

INSERT INTO Orders (customerId, quantity)
VALUES
    (1, 5),
    (2, 2),
    (3, 3),
    (4, 1),
    (5, 4);

-- 10) Удаляет таблицы
DROP TABLE Orders;
DROP TABLE Customers;


-- 11) Выводит топ 10 аэропортов по популярности бизнес класса
SELECT
    departure.airport_name,
    COUNT(f.flight_no) as flight_count
FROM flights f
         JOIN airports_data departure ON f.departure_airport = departure.airport_code
         JOIN aircrafts_data ar ON f.aircraft_code = ar.aircraft_code
         JOIN seats s ON s.aircraft_code = ar.aircraft_code
WHERE f.status = 'Arrived' AND s.fare_conditions = 'Business'
GROUP BY departure.airport_name
ORDER BY flight_count DESC
    LIMIT 10;