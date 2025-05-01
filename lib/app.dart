import 'package:postgres/postgres.dart';

Future<List> query(String query) async {
  final connection = PostgreSQLConnection(
    'localhost', // host
    5432,        // port
    'whisker', // database name
    username: 'kirra',
    password: '',
  );

  await connection.open();

  final results = await connection.query(query);
  // insert into entries values(1, 'text', '01-01-2025', '10:00', 4);
  // insert into users values(1, 1, 'user', 5, 500);

  await connection.close();
  return results;
}

Future<List> main() async {
  final connection = PostgreSQLConnection(
    'localhost', // host
    5432,        // port
    'whisker', // database name
    username: 'kirra',
    password: '',
  );

  await connection.open();

  final results = await connection.query('SELECT users.exp, users.level FROM users');
  // insert into entries values(1, 'text', '01-01-2025', '10:00', 4);
  // insert into users values(1, 1, 'user', 5, 500);
  print(results[0][0]);
  await connection.close();
  return results;
}