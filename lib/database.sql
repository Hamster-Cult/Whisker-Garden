
/*Chloe's code*/
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    plant_id INT NOT NULL,
    username VARCHAR(20) NOT NULL,
    level INT NOT NULL CHECK (level >= 0),
    exp INT NOT NULL CHECK (exp >= 0)
);

CREATE TABLE mood_log (
    mood_id SERIAL PRIMARY KEY,
    mood_date DATE NOT NULL CHECK (mood_date <= CURRENT_DATE),
    mood_time TIME NOT NULL,
    mood_rating SMALLINT NOT NULL CHECK (mood_rating BETWEEN 1 AND 5),
    mood_text TEXT NULL
);

CREATE TABLE goals (
    goal_id SERIAL PRIMARY KEY,
    plant_id INT NOT NULL,
    goal_name VARCHAR(50) NOT NULL,
    goal_desc TEXT NULL,
    goal_achievement BOOLEAN NOT NULL
);

/*Keita's code*/
CREATE TABLE entries (
    entry_id SERIAL PRIMARY KEY,
    entry VARCHAR(255) NULL,
    entry_date DATE NOT NULL,
    entry_time TIME NOT NULL,
    rating INT NULL CHECK (rating >= 0 AND rating <= 5)
);

CREATE TABLE plant (
    plant_id SERIAL PRIMARY KEY,
    plant_type VARCHAR(20) NOT NULL
);

CREATE TABLE user_entries (
    user_id INT NOT NULL,
    entry_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (entry_id) REFERENCES entries(entry_id)
);

CREATE TABLE garden (
    garden_slot SERIAL PRIMARY KEY,
    plant_id INT NOT NULL,
    name VARCHAR(20) NOT NULL,
    archived BOOLEAN NOT NULL,
    maturity INT NOT NULL,
    last_watered DATE NOT NULL,
    FOREIGN KEY (plant_id) REFERENCES plant(plant_id)
); 

/*Dart Code, need to double check if this is correct with val*/

/*import 'package:postgres/postgres.dart';

Future<void> main() async {
  try {
    final conn = await Connection.open(Endpoint(
      host: 'localhost',
      database: 'GardenWhiskers',
      username: 'postgres',
      password: 'password',
    ));
    print('Connected to the database');

    await conn.execute('''
    CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    plant_id INT NOT NULL,
    username VARCHAR(20) NOT NULL,  
    level INT NOT NULL CHECK (level >= 0),
    exp INT NOT NULL CHECK (exp >= 0)
);''');

    await conn.execute('''
    CREATE TABLE mood_log (
    mood_id SERIAL PRIMARY KEY, 
    mood_date DATE NOT NULL CHECK (mood_date <= CURRENT_DATE),
    mood_time TIME NOT NULL,
    mood_rating SMALLINT NOT NULL CHECK (mood_rating BETWEEN 1 AND 5),
    mood_text TEXT NULL
);''');

    await conn.execute('''
    CREATE TABLE goals (
    goal_id SERIAL PRIMARY KEY,
    plant_id INT NOT NULL,
    goal_name VARCHAR(50) NOT NULL,
    goal_desc TEXT NULL,
    goal_achievement BOOLEAN NOT NULL
);''');

    await conn.execute('''
    CREATE TABLE entries (
    entry_id SERIAL PRIMARY KEY,
    entry VARCHAR(255) NULL,
    entry_date DATE NOT NULL,
    entry_time TIME NOT NULL,
    rating INT NULL CHECK (rating >= 0 AND rating <= 5)
);''');

    await conn.execute('''
    CREATE TABLE plant (
    plant_id SERIAL PRIMARY KEY,
    plant_type VARCHAR(20) NOT NULL
);''');

    await conn.execute('''
    CREATE TABLE user_entries (
    user_id INT NOT NULL,
    entry_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (entry_id) REFERENCES entries(entry_id)
);''');

    await conn.execute('''
    CREATE TABLE garden (
    garden_slot SERIAL PRIMARY KEY,
    plant_id INT NOT NULL,
    name VARCHAR(20) NOT NULL,
    archived BOOLEAN NOT NULL,
    maturity INT NOT NULL,
    last_watered DATE NOT NULL,
    FOREIGN KEY (plant_id) REFERENCES plant(plant_id)
);''');

    await conn.close();
  } catch (e) {
    print('Failed to connect: $e'); 
    }
  }

Future<void> insertUsers(Connection conn, int plant_id, String username, int level, int exp) async {
  await conn.query('''
    INSERT INTO users (plant_id, username, level, exp)
    VALUES (@plant_id, @username, @level, @exp)
  ''', substitutionValues: {
    'plant_id': plant_id,
    'username': username,
    'level': level,
    'exp': exp,
  });
}

Future<void> getUsers(Connection conn) async {
  final result = await conn.query('SELECT * FROM users');
  for (final row in result) {
    print('user_id: ${row[0]}, plant_id: ${row[1]}, username: ${row[2]}, level: ${row[3]}, exp: ${row[4]}');
  }
} */