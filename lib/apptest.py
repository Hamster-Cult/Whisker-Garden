import unittest
from unittest.mock import patch
from sqlmodel import create_engine, SQLModel
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from lib.database import *
from lib.app import on_startup, create_plants

# each test case sets up, tests and tears down
# setUp and tearDown needing different cases to the usual is so annoying


# this will be the formula for all the tests

# connect to the database and says hello world
class TestDatabaseInit(unittest.TestCase):
    # setup is run before each test case
    @patch('lib.app.engine')
    def setUp(self, mock_engine):
        """Set up an in-memory SQLite database for the tests"""
        self.engine = create_engine("sqlite:///:memory:", echo=False) # change to echo=True to see the tables being created
        # this runs the function but as an in memory database that we will have to scrap
        mock_engine.return_value = self.engine

        # create tables using SQLModel directly instead of calling create_db_and_tables
        SQLModel.metadata.create_all(self.engine)

        Session = sessionmaker(bind=self.engine)
        self.session = Session()

    # unittest.main checks for all functions that start with test_ and runs them
    def test_hello_world(self):
        """Test basic connection to the database"""
        # connects to the database and runs a simple query
        with self.engine.connect() as conn:
            result = conn.execute(text("SELECT 'hello world'"))
            # fetches the result of the query
            rows = result.fetchall()
        # checks if the result is what we executed
        self.assertEqual(rows, [('hello world',)])

    def test_list_tables(self):
        """Listing all tables in the database"""
        with self.engine.connect() as conn:

            result = conn.execute(text("SELECT name FROM sqlite_master WHERE type='table'"))
            tables = [row[0] for row in result.fetchall()]

            # print all table names
            print("Tables in database:", tables)

            # check that the expected tables exist
            expected_tables = ['plant', 'moodlog', 'entries', 'goals', 'garden', 'appuser', 'userentries']
            for table in expected_tables:
                self.assertIn(table, tables)

    # tearDown is run after each test case
    def tearDown(self):
        self.session.rollback()
        self.session.close()


class TestPlantTable(unittest.TestCase):
    @patch('lib.app.engine')
    def setUp(self, mock_engine):
        """Set up an in-memory SQLite database for the tests"""
        self.engine = create_engine("sqlite:///:memory:", echo=False) # change to echo=True to see the tables being created
        # this runs the function but as an in memory database that we will have to scrap
        mock_engine.return_value = self.engine

        # create tables using SQLModel directly instead of calling create_db_and_tables
        SQLModel.metadata.create_all(self.engine)

        Session = sessionmaker(bind=self.engine)
        self.session = Session()

    def test_columns(self):
        """Checking if the plant table exists and has the correct columns"""
        with self.engine.connect() as conn:
            # basically asking sqlite to give us the columns of the mentioned table (plant)
            result = conn.execute(text("PRAGMA table_info(plant)"))
            # fetchall gets all the rows from the result of the query
            # row[1] gets the column's name.
            columns = [row[1] for row in result.fetchall()]

            # just debugging to see the columns in the plant table, fills up the screen so much
            print("Columns in plant table:", columns)

            # check that the expected columns exist
            expected_columns = ['plant_id', 'plant_type', 'unlocked']
            for column in expected_columns:
                self.assertIn(column, columns)

            # check for unexpected columns
            # eg if this table had a column called 'plant_name' for some reason it would fail the test
            for column in columns:
                if column not in expected_columns:
                    self.fail(f"Unexpected column found: {column}")

    def test_plant_data(self,):
        """Checking if the plant table has the correct data"""
        with patch('lib.app.engine', self.engine):
            create_plants()

        with self.engine.connect() as conn:
            result = conn.execute(text("SELECT * FROM plant"))
            rows = result.fetchall()

        # just debugging to see the columns in the plant table, fills up the screen so much
        if print
        print("Rows in plant table:", rows)

        # check that the expected data exists
        plant_types = [row[1] for row in rows]  # Extract plant types

        # Check for specific plant types that should be created
        for plant in expected_plants:
                self.assertIn(plant, plant_types)

            # Check we have the expected number of plants (10 based on your create_plants function)
        self.assertEqual(len(rows), 10)

    def tearDown(self):
        self.session.rollback()
        self.session.close()

class TestAppUserTable(unittest.TestCase):
    pass

# this is how you ditctate the order of the tests cause they run alphabetical by default for some reason
def suite():
    """Define the order of test execution"""
    suite = unittest.TestSuite()
    suite.addTest(TestDatabaseInit('test_hello_world'))
    suite.addTest(TestDatabaseInit('test_list_tables'))
    suite.addTest(TestPlantTable('test_columns'))
    suite.addTest(TestPlantTable('test_plant_data'))
    #suite.addTest(TestDatabaseInit('test_appuser_table'))

    # add more below

    return suite

if __name__ == '__main__':
    # Use the suite to run tests instead of unittest.main()
    runner = unittest.TextTestRunner()
    runner.run(suite())