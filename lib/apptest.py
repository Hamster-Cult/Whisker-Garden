# if you're chloe and it isn't working use
# py -m lib.apptest

# to run this go to the root folder (Whisker-Garden)
# steps for everything
# python -m venv venv
# venv\Scripts\activate
# pip install fastapi "fastapi[standard]" "uvicorn[standard]" sqlmodel psycopg2 sqlalchemy
# deactivate
# venv\Scripts\activate
# python -m lib.apptest
# python -m lib.apptest --debug


import unittest
from unittest.mock import patch
from fastapi import HTTPException
from sqlmodel import create_engine, SQLModel
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy import text, inspect
from sqlalchemy.orm import sessionmaker
# import asyncio # for async functions
from lib.database import *
# from lib.app import *
import lib.app

# this is all for logging so i dont comment print statements
import logging

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)  # defaults to INFO level
handler = logging.StreamHandler()
formatter = logging.Formatter('%(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

# each test case sets up, tests and tears down
# unittest.main checks for all functions that start with test_ and runs them

class BaseTestCase(unittest.TestCase):
    """Base class for all test cases, providing common setup and teardown methods."""
    # setUp is run before each test case
    # setUp and tearDown needing different cases to the usual is so annoying
    def setUp(self):
        """Set up an in-memory SQLite database for tests"""
        self.engine = create_engine("sqlite:///:memory:", echo=False)

        # patch the app engine to use our test engine
        self.engine_patcher = patch('lib.app.engine', self.engine)
        self.mock_engine = self.engine_patcher.start()

        # create tables and session
        SQLModel.metadata.create_all(self.engine)
        Session = sessionmaker(bind=self.engine)
        self.session = Session()

    # tearDown is run after each test case
    # tearDown is used to clean up after each test case
    def tearDown(self):
        """Clean up after each test"""
        self.session.rollback()
        self.session.close()
        self.engine.dispose()
        self.engine_patcher.stop()

# this will be the formula for all the tests
# connects to the database and says hello world
class TestDatabaseSetup(BaseTestCase):
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
            logger.debug("Tables in database:", tables)

            # check that the expected tables exist
            expected_tables = ['plant', 'entries', 'goals', 'garden','appuser']
            for table in expected_tables:
                self.assertIn(table, tables)

    @patch("lib.app.Session")
    def test_get_session_error(self, mock_session):
        mock_session.side_effect = SQLAlchemyError("Session DB")

        with self.assertRaises(HTTPException) as context:
            list(lib.app.get_session())

        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error creating session", context.exception.detail)

    @patch("lib.app.Session")
    def test_creating_db_tables_error(self, mock_create_all):
        mock_create_all.side_effect = SQLAlchemyError("Database error")

        with self.assertRaises(HTTPException) as context:
            lib.app.create_db_and_tables()

        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error creating tables", context.exception.detail)

    @patch("lib.app.Session")
    def test_creating_plants_error(self, mock_session):
        mock_session.return_value.__enter__.return_value.commit.side_effect = SQLAlchemyError("Database error")

        with self.assertRaises(HTTPException) as context:
            lib.app.create_plants()

        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error creating plants: ", context.exception.detail)

    @patch("lib.app.Session")
    def test_creating_garden_error(self, mock_session):
        mock_session.return_value.__enter__.return_value.commit.side_effect = SQLAlchemyError("Database error")

        with self.assertRaises(HTTPException) as context:
            lib.app.create_garden()

        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error creating garden: ", context.exception.detail)

    @patch("lib.app.Session")
    def test_creating_user_error(self, mock_session):
        mock_session.return_value.__enter__.return_value.commit.side_effect = SQLAlchemyError("Database error")

        with self.assertRaises(HTTPException) as context:
            lib.app.create_user("oiiaoiia")

        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error creating user: ", context.exception.detail)

    @patch("lib.app.Session")
    def test_creating_goals_error(self, mock_session):
        mock_session.return_value.__enter__.return_value.commit.side_effect = SQLAlchemyError("Database error")

        with self.assertRaises(HTTPException) as context:
            lib.app.create_goals()

        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error creating goals: ", context.exception.detail)

class TestPlantTable(BaseTestCase):
    # so when we need more setup for a specific test class we will call the original setUp method and then add specific setup
    def setUp(self):
        """Additional setup for plant tests"""
        # calls the BaseTestCase setUp method
        super().setUp()
        # does extra setup
        lib.app.create_plants()

    def test_columns(self):
        """Checking if the plant table exists and has the correct columns"""
        with self.engine.connect() as conn:
            # basically asking sqlite to give us the columns of the mentioned table (plant)
            result = conn.execute(text("PRAGMA table_info(plant)"))
            # fetchall gets all the rows from the result of the query
            # row[1] gets the column's name.
            columns = [row[1] for row in result.fetchall()]

            # just debugging to see the columns in the plant table, fills up the screen so much
            logger.debug(f"Columns in plant table: {columns}")

            # check that the expected columns exist
            expected_columns = ['plant_id', 'plant_type', 'unlocked', 'price']
            for column in expected_columns:
                self.assertIn(column, columns)

            # check for unexpected columns
            # eg if this table had a column called 'plant_name' for some reason it would fail the test
            for column in columns:
                if column not in expected_columns:
                    self.fail(f"Unexpected column found: {column}")

    def test_plant_data(self,):
        """Checking if the plant table has the correct data"""

        with self.engine.connect() as conn:
            result = conn.execute(text("SELECT * FROM plant"))
            rows = result.fetchall()

        # just debugging to see the columns in the plant table, fills up the screen so much
        logger.debug(f"Rows in plant table: {rows}")

        # check that the expected data exists
        plant_types = [row[1] for row in rows]  # Extract plant types

        # Check for specific plant types that should be created
        expected_plants = ['tulips', 'hibiscus', 'hydrengea' ,'wisteria' ,'cherry blossom' ,'rose', 'bluebell', 'lily of the valley', 'spider lily', 'aster']
        for plant in expected_plants:
                self.assertIn(plant, plant_types)

            # Check we have the expected number of plants (10 based on your create_plants function)
        self.assertEqual(len(rows), 10)#

    def test_create_plant(self):
        # this also tests reading a plant
        """Test creating a plant"""
        plant = Plant(plant_type = "test_plant")
        self.session.add(plant)
        self.session.commit()

        result = self.session.execute(select(Plant).where(Plant.plant_type == "test_plant")).scalar_one()
        logger.debug(f"Created plant: {result.plant_type}")
        self.assertEqual(result.plant_type, "test_plant")

    def test_delete_plant(self):
        """Test deleting a plant"""
        plant = Plant(plant_type="to_delete")
        self.session.add(plant)
        self.session.commit()

        # Store the plant_id before deletion
        plant_id = plant.plant_id

        # Delete the plant
        self.session.delete(plant)
        self.session.commit()

        # Try to query for the deleted plant
        result = self.session.execute(
            select(Plant).where(Plant.plant_id == plant_id)
        ).scalars().all()

        # Assert that no results were found (plant was deleted)
        self.assertEqual(len(result), 0, f"Plant with ID {plant_id} was not deleted")

    def test_column_types(self):
        """Test the data types of columns in the Plant table"""
        # inspector to check specific column types
        inspector = inspect(self.engine)

        # column information for the plant table
        columns = inspector.get_columns('plant')

        # log column information
        for column in columns:
            logger.debug(f"Column: {column['name']}, Type: {column['type']}")

        column_types = {col['name']: col['type'].__class__.__name__ for col in columns}

        # check specific columns
        self.assertIn('plant_id', column_types)
        self.assertEqual(column_types['plant_id'], 'INTEGER')

        self.assertIn('plant_type', column_types)
        self.assertEqual(column_types['plant_type'], 'VARCHAR')

        self.assertIn('unlocked', column_types)
        self.assertEqual(column_types['unlocked'], 'BOOLEAN')

        self.assertIn('price', column_types)
        self.assertEqual(column_types['price'], 'INTEGER')

    # Three outcomes, plants are found, no plants found, SQLAlchemyError
    @patch("lib.app.Session")
    def test_get_plant_asset_no_plants(self, mock_session):
        mock_session.return_value.__enter__.return_value.exec.return_value.all.return_value = []

        with self.assertRaises(HTTPException) as context:
            lib.app.get_plant_asset()

        self.assertEqual(context.exception.status_code, 404)
        self.assertIn("Error 404: Plants not found", context.exception.detail)

    @patch("lib.app.Session")
    def test_get_plant_asset_db_error(self, mock_session):
        mock_session.return_value.__enter__.return_value.exec.side_effect = SQLAlchemyError("Database error")

        with self.assertRaises(HTTPException) as context:
            lib.app.get_plant_asset()

        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error retrieving plant assets: ", context.exception.detail)

    @patch("lib.app.Session")
    def test_garden_not_found(self, mock_session):
        mock_session.return_value.__enter__.return_value.exec.return_value.all.return_value = []

        with self.assertRaises(HTTPException) as context:
            lib.app.get_plant_details()

        self.assertEqual(context.exception.status_code, 404)
        self.assertIn("Error 404: Garden not found", context.exception.detail)

    @patch("lib.app.Session")
    def test_get_plant_details_fail(self, mock_session):
        mock_session.return_value.__enter__.return_value.exec.side_effect = SQLAlchemyError("Database error")

        with self.assertRaises(HTTPException) as context:
            lib.app.get_plant_details()

        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error retrieving garden progress: ", context.exception.detail)

    @patch("lib.app.Session")
    def test_buy_plant_error(self, mock_session):
        mock_session.return_value.__enter__.return_value.add.side_effect = SQLAlchemyError("Database error")

        dummy_plant = lib.app.Plant()

        with self.assertRaises(HTTPException) as context:
            list(lib.app.buy_plant(dummy_plant, mock_session))

        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error buying plant: ", context.exception.detail)

    @patch("lib.app.Session")
    def test_water_plant_error(self, mock_session):
        mock_session.return_value.__enter__.return_value.exec.side_effect = SQLAlchemyError("Database error")

        dummy_plant = Garden(
            plant_id=1,
            last_watered="2025-05-11T00:00:00",
            maturity=10,
            plant_exp=30,
            garden_slot=1,
            archived=False
        )

        with self.assertRaises(HTTPException) as context:
            lib.app.water_plant(dummy_plant, None)

        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error updating plant values: ", context.exception.detail)

    @patch("lib.app.Session")
    def test_get_garden_shelves_error(self, mock_session):
        mock_session.return_value.__enter__.return_value.exec.side_effect = SQLAlchemyError("Database error")

        with self.assertRaises(HTTPException) as context:
            lib.app.get_garden_shelves(page_number=1, session=None)

        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error retrieving garden shelves: ", context.exception.detail)

class TestGardenTable(BaseTestCase):
    def setUp(self):
        super().setUp()
        lib.app.create_garden()

    def test_columns(self):
        """Checking if the garden table exists and has the correct columns"""
        with self.engine.connect() as conn:
            result = conn.execute(text("PRAGMA table_info(garden)"))
            columns = [row[1] for row in result.fetchall()]

            logger.debug(f"Columns in garden table: {columns}")

            expected_columns = ['garden_slot', 'plant_id', 'name', 'archived', 'maturity', 'plant_exp', 'last_watered']
            for column in expected_columns:
                self.assertIn(column, columns)

            # check for unexpected columns
            for column in columns:
                if column not in expected_columns:
                    self.fail(f"Unexpected column found: {column}")

    def test_garden_data(self):
        """Checking if the garden table has the correct data"""
        with self.engine.connect() as conn:
            result = conn.execute(text("SELECT * FROM garden"))
            rows = result.fetchall()

        logger.debug(f"Rows in garden table: {rows}")
        self.assertTrue(len(rows) > 0, "No rows found in garden table")

    def test_column_types(self):
        """Test the data types of columns in the Garden table"""  # Updated docstring
        from sqlalchemy import inspect

        # inspector to check specific column types
        inspector = inspect(self.engine)

        # column information for the garden table
        columns = inspector.get_columns('garden')

        # log column information
        for column in columns:
            logger.debug(f"Column: {column['name']}, Type: {column['type']}")

        column_types = {col['name']: col['type'].__class__.__name__ for col in columns}

        # remove plant_type assertion and only check for garden columns
        self.assertIn('garden_slot', column_types)
        self.assertEqual(column_types['garden_slot'], 'INTEGER')

        self.assertIn('plant_id', column_types)
        self.assertEqual(column_types['plant_id'], 'INTEGER')

        self.assertIn('name', column_types)
        self.assertEqual(column_types['name'], 'VARCHAR')

        self.assertIn('archived', column_types)
        self.assertEqual(column_types['archived'], 'BOOLEAN')

        self.assertIn('maturity', column_types)
        self.assertEqual(column_types['maturity'], 'INTEGER')

        self.assertIn('plant_exp', column_types)
        self.assertEqual(column_types['plant_exp'], 'INTEGER')

        self.assertIn('last_watered', column_types)
        self.assertEqual(column_types['last_watered'], 'DATE')

        self.session.rollback()
        self.session.close()
        self.engine.dispose()

class TestGoalsTable(BaseTestCase):
    def setUp(self):
        super().setUp()
        lib.app.create_plants()
        lib.app.create_goals()

    def test_columns(self):
        """Checking if the goals table exists and has the correct columns"""
        with self.engine.connect() as conn:
            result = conn.execute(text("PRAGMA table_info(goals)"))
            columns = [row[1] for row in result.fetchall()]

            logger.debug(f"Columns in goals table: {columns}")

            expected_columns = ['goal_id', 'plant_id', 'name', 'desc', 'achieved', 'exp_increase']
            for column in expected_columns:
                self.assertIn(column, columns)

            for column in columns:
                if column not in expected_columns:
                    self.fail(f"Unexpected column found: {column}")

    def test_goals_data(self):
        """Checking if the goals table has the correct data"""
        with self.engine.connect() as conn:
            result = conn.execute(text("SELECT * FROM goals"))
            rows = result.fetchall()

        logger.debug(f"Rows in goals table: {rows}")
        self.assertTrue(len(rows) > 0, "No rows found in goals table")

    def test_column_types(self):
        """Test the data types of columns in the Goals table"""
        # inspector to check specific column types
        inspector = inspect(self.engine)

        # column information for the goals table
        columns = inspector.get_columns('goals')

        # log column information
        for column in columns:
            logger.debug(f"Column: {column['name']}, Type: {column['type']}")

        column_types = {col['name']: col['type'].__class__.__name__ for col in columns}

        self.assertIn('goal_id', column_types)
        self.assertEqual(column_types['goal_id'], 'INTEGER')

        self.assertIn('plant_id', column_types)
        self.assertEqual(column_types['plant_id'], 'INTEGER')

        self.assertIn('name', column_types)
        self.assertEqual(column_types['name'], 'VARCHAR')

        self.assertIn('desc', column_types)
        self.assertEqual(column_types['desc'], 'VARCHAR')

        self.assertIn('achieved', column_types)
        self.assertEqual(column_types['achieved'], 'BOOLEAN')

        self.assertIn('exp_increase', column_types)
        self.assertEqual(column_types['exp_increase'], 'INTEGER')

class TestAppUserTable(BaseTestCase):
    def setUp(self):
        super().setUp()
        lib.app.create_user("test_user")

    def test_columns(self):
        """Checking if the appuser table exists and has the correct columns"""
        with self.engine.connect() as conn:
            result = conn.execute(text("PRAGMA table_info(appuser)"))
            columns = [row[1] for row in result.fetchall()]

            logger.debug(f"Columns in appuser table: {columns}")

            expected_columns = ['user_id','garden_slot','username', 'level', 'exp', 'spendable_exp']
            for column in expected_columns:
                self.assertIn(column, columns)

            for column in columns:
                if column not in expected_columns:
                    self.fail(f"Unexpected column found: {column}")

    def test_column_types(self):
        """Test the data types of columns in the Users table"""
        # inspector to check specific column types
        inspector = inspect(self.engine)

        # column information for the goals table
        columns = inspector.get_columns('appuser')

        # log column information
        for column in columns:
            logger.debug(f"Column: {column['name']}, Type: {column['type']}")

        column_types = {col['name']: col['type'].__class__.__name__ for col in columns}

        self.assertIn('user_id', column_types)
        self.assertEqual(column_types['user_id'], 'INTEGER')

        self.assertIn('garden_slot', column_types)
        self.assertEqual(column_types['garden_slot'], 'INTEGER')

        self.assertIn('username', column_types)
        self.assertEqual(column_types['username'], 'VARCHAR')

        self.assertIn('level', column_types)
        self.assertEqual(column_types['level'], 'INTEGER')

        self.assertIn('exp', column_types)
        self.assertEqual(column_types['exp'], 'INTEGER')

    def test_user_data(self):
        """Checking if the appuser table has the correct data"""
        with self.engine.connect() as conn:
            result = conn.execute(text("SELECT * FROM appuser"))
            rows = result.fetchall()

        logger.debug(f"Rows in appuser table: {rows}")
        logger.debug(f"Result from auppusertable: {result}")
        self.assertTrue(len(rows) > 0, "No rows found in appuser table")

    @patch("lib.app.Session")
    def test_gain_user_exp_error(self, mock_session):
        mock_session.return_value.__enter__.return_value.exec.side_effect = SQLAlchemyError("Database error")

        dummy_user = AppUser(user_level=1, level=2, exp=100, spendable_exp=50)

        with self.assertRaises(HTTPException) as context:
            lib.app.gain_exp(dummy_user, None)

        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error updating user data: ", context.exception.detail)

class TestGetEntries(BaseTestCase):
    from datetime import date, time
    def test_get_entries_success(self):
        entries = [
            Entries(entry="Test entry 1", entry_date=date(2024, 10, 1), entry_time=time(19, 0, 23), rating=5),
            Entries(entry="Test entry 2", entry_date=date(2024, 10, 2), entry_time=time(14, 20, 42), rating=4),
            Entries(entry="Test entry 3", entry_date=date(2024, 10, 3), entry_time=time(14, 0, 31), rating=3),
            Entries(entry="Test entry 4", entry_date=date(2024, 10, 4), entry_time=time(18, 3, 20), rating=4),
            Entries(entry="Test entry 5", entry_date=date(2024, 10, 5), entry_time=time(12, 15, 45), rating=5)
        ]
        self.session.add_all(entries)
        self.session.commit()

        result = lib.app.get_entries(page_number=1, session=self.session)
        self.assertEqual(len(result), 4)
        self.assertEqual(result[0].entry, "Test entry 1")
        self.assertEqual(result[-1].entry, "Test entry 4")

        result = lib.app.get_entries(page_number=2, session=self.session)
        self.assertEqual(len(result), 1)
        self.assertEqual(result[0].entry, "Test entry 5")


# this is how you ditctate the order of the tests cause they run alphabetical by default for some reason
def suite():
    """Define the order of test execution"""
    suite = unittest.TestSuite()
    suite.addTest(TestDatabaseSetup('test_hello_world'))
    suite.addTest(TestDatabaseSetup('test_list_tables'))
    suite.addTest(TestPlantTable('test_columns'))
    suite.addTest(TestPlantTable('test_column_types'))
    suite.addTest(TestPlantTable('test_plant_data'))
    suite.addTest(TestPlantTable('test_create_plant'))
    suite.addTest(TestPlantTable('test_delete_plant'))
    suite.addTest(TestGardenTable('test_columns'))
    suite.addTest(TestGardenTable('test_garden_data'))
    suite.addTest(TestGardenTable('test_column_types'))
    suite.addTest(TestGoalsTable('test_columns'))
    suite.addTest(TestGoalsTable('test_goals_data'))
    suite.addTest(TestGoalsTable('test_column_types'))
    suite.addTest(TestAppUserTable('test_columns'))
    suite.addTest(TestAppUserTable('test_column_types'))
    suite.addTest(TestAppUserTable('test_user_data'))
    suite.addTest(TestGetEntries('test_get_entries_success'))
    # add more tests as needed

    return suite

if __name__ == '__main__':
    import sys

    # check for --debug flag
    if '--debug' in sys.argv:
        logger.setLevel(logging.DEBUG)
        # Remove the flag so unittest doesn't try to interpret it
        sys.argv.remove('--debug')

    # Use the suite to run tests instead of unittest.main()
    runner = unittest.TextTestRunner()
    runner.run(suite())
