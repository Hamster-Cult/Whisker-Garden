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
from unittest.mock import patch, MagicMock
from fastapi import HTTPException
from sqlmodel import create_engine, SQLModel, Session, select, delete
from sqlalchemy import text, inspect
from sqlalchemy.orm import sessionmaker
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm.exc import NoResultFound
from lib.database import *
import lib.app
from fastapi.testclient import TestClient

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
        self.engine_patcher = patch('lib.app.engine', self.engine)
        self.engine_patcher.start()

        SQLModel.metadata.create_all(self.engine)

        self.session = Session(self.engine)

    # tearDown is run after each test case
    # tearDown is used to clean up after each test case
    def tearDown(self):
        """Clean up after each test"""
        self.session.rollback()
        self.session.close()
        self.engine_patcher.stop()
        self.engine.dispose()

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

            for table in expected_tables:
                if table not in expected_tables:
                    self.fail(f"Unexpected column found: {table}")

    def test_get_session(self):
        """Get a session for the database"""
        generator = lib.app.get_session()
        session = next(generator)
        assert session is not None

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
        """Test error when gaining user experience."""
        mock_session.return_value.__enter__.return_value.exec.side_effect = SQLAlchemyError("Database error")

        dummy_user = AppUser(user_level=1, level=2, exp=100, spendable_exp=50)

        with self.assertRaises(HTTPException) as context:
            lib.app.gain_exp(dummy_user, None)

        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error updating user data: ", context.exception.detail)

class TestGetPlantDetails(BaseTestCase):
    def setUp(self):
        super().setUp()

        # create a in memory database with check_same_thread=False cause this was causing issues for some wonderful reason
        self.engine = create_engine("sqlite:///:memory:", connect_args={"check_same_thread": False})

        # creates table cause it was not being created in the setUp method for some wonderful reason
        SQLModel.metadata.create_all(self.engine)

        with Session(self.engine) as session:
            plant1 = Garden(
                garden_slot=1,
                plant_id=1,
                name="Rose",
                archived=False,
                maturity=5,
                plant_exp=50,
                last_watered=date.today()
            )
            plant2 = Garden(
                garden_slot=2,
                plant_id=2,
                name="Tulip",
                archived=True,
                maturity=3,
                plant_exp=30,
                last_watered=date.today()
            )
            session.add_all([plant1, plant2])
            session.commit()

    def test_get_plant_details(self):
        """Test retrieval of plant details."""
        with patch('lib.app.engine', self.engine):
            results = lib.app.get_plant_details()

            self.assertEqual(len(results), 1)
            self.assertEqual(results[0]['plant_id'], 1)
            self.assertEqual(results[0]['archived'], False)

class TestGetEntries(BaseTestCase):
    from datetime import date, time
    def test_get_entries_success(self):
        """Test successful retrieval of entries."""
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

    def test_get_entries_no_entries(self):
        """Test getting entries when no entries exist"""
        result = lib.app.get_entries(page_number=1, session=self.session)
        self.assertEqual(len(result), 0, "Expected no entries but found some")

class TestGetExp(BaseTestCase):
    def setUp(self):
        super().setUp()
        lib.app.create_user("test_user")

        with Session(self.engine) as session:
            user = session.exec(select(AppUser).where(AppUser.username == "test_user")).first()
            user.level = 5
            user.exp = 1200
            session.add(user)
            session.commit()

    def test_get_exp_success(self):
        """Test successful retrieval of experience."""
        results = lib.app.get_exp()
        self.assertIsInstance(results, list)
        self.assertEqual(len(results), 1)
        user_data = results[0]
        self.assertEqual(user_data["level"], 5)
        self.assertEqual(user_data["exp"], 1200)

    def test_update_and_get_exp(self):
        """Test updating and retrieving user experience."""
        with Session(self.engine) as session:
            user = session.exec(select(AppUser).where(AppUser.username == "test_user")).first()
            user.level = 10
            session.commit()

            results = lib.app.get_exp()
            self.assertIsInstance(results, list)
            self.assertEqual(len(results), 1)
            user_data = results[0]
            self.assertEqual(user_data["level"], 10)
            self.assertEqual(user_data["exp"], 1200)

    @patch("lib.app.Session")
    def test_get_exp_db_error(self, mock_session):
        """Test database error during experience retrieval."""
        mock_session.return_value.__enter__.return_value.exec.side_effect = SQLAlchemyError("DB error")

        with self.assertRaises(HTTPException) as context:
            lib.app.get_exp()

        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error retrieving User EXP", context.exception.detail)

class TestGetGardenShelves(BaseTestCase):
    def setUp(self):
        super().setUp()
        # Create 20 plants in the Garden table to test pagination
        for i in range(1, 11):
            plant = Garden(
                garden_slot=i,
                plant_id=i,
                name=f"Plant {i}",
                archived=False,
                maturity=1,
                plant_exp=10,
                last_watered=date.today()
            )
            self.session.add(plant)
        self.session.commit()

    def test_first_page_returns_all_plants(self):
        """Test first page returns all plants."""
        plants = lib.app.get_garden_shelves(1, self.session)
        self.assertEqual(len(plants), 10)
        self.assertEqual(plants[0].plant_id, 1)
        self.assertEqual(plants[-1].plant_id, 10)

    def test_second_page_returns_empty_list(self):
        """Test second page returns empty list."""
        plants = lib.app.get_garden_shelves(2, self.session)
        self.assertEqual(len(plants), 0)

class TestGetLockedAndUnlocked(BaseTestCase):
    def setUp(self):
        super().setUp()

        self.plant_unlocked = Plant(
            plant_id=1,
            plant_type="flower",
            unlocked=True,
            price=100
        )
        self.plant_locked = Plant(
            plant_id=2,
            plant_type="shrub",
            unlocked=False,
            price=50
        )

        self.session.add(self.plant_unlocked)
        self.session.add(self.plant_locked)
        self.session.commit()

    def test_get_unlocked_success(self):
        """Test successful retrieval of unlocked items."""
        result = lib.app.get_unlocked(self.session)

        self.assertEqual(len(result), 1)
        self.assertEqual(result[0].plant_id, self.plant_unlocked.plant_id)
        self.assertTrue(result[0].unlocked)

    def test_get_locked_success(self):
        """Test successful retrieval of locked items."""
        result = lib.app.get_locked(self.session)

        self.assertEqual(len(result), 1)
        self.assertEqual(result[0].plant_id, self.plant_locked.plant_id)
        self.assertFalse(result[0].unlocked)

    @patch("lib.app.Session")
    def test_get_unlocked_error(self, mock_session):
        """Test error retrieving unlocked items."""
        mock_session.return_value.__enter__.return_value.exec.side_effect = SQLAlchemyError("Database error")

        with self.assertRaises(HTTPException) as context:
            lib.app.get_unlocked(None)

        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error retrieving unlocked plants:", context.exception.detail)

    @patch("lib.app.Session")
    def test_get_locked_error(self, mock_session):
        """Test error retrieving locked items."""
        mock_session.return_value.__enter__.return_value.exec.side_effect = SQLAlchemyError("Database error")

        with self.assertRaises(HTTPException) as context:
            lib.app.get_locked(None)

        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error retrieving locked plants:", context.exception.detail)

class TestGetUserData(BaseTestCase):
    def setUp(self):
        super().setUp()
        self.engine = create_engine("sqlite:///:memory:", connect_args={"check_same_thread": False})
        SQLModel.metadata.create_all(self.engine)

        with Session(self.engine) as session:
            user = AppUser(
                user_id=1,
                username="test_user",
                level=2,
                exp=100,
                spendable_exp=25,
                garden_slot=0
            )
            session.add(user)
            session.commit()

    def test_get_user_data_success(self):
        """Test successful retrieval of user data."""
        with patch("lib.app.engine", self.engine):
            result = lib.app.get_user_data()

            self.assertEqual(len(result), 1)
            self.assertEqual(result[0].user_id, 1)
            self.assertEqual(result[0].username, "test_user")

    def test_get_user_data_not_found(self):
        """Test error handling when no user found."""
        with Session(self.engine) as session:
            session.exec(delete(AppUser))
            session.commit()

        with patch("lib.app.engine", self.engine):
            with self.assertRaises(HTTPException) as context:
                lib.app.get_user_data()

            self.assertEqual(context.exception.status_code, 404)
            self.assertIn("User not found", context.exception.detail)

class TestEntries(BaseTestCase):
    def setUp(self):
        super().setUp()
        # creating some entries for testing

        self.valid_entry = Entries(
            entry="Valid entry",
            entry_date=date(2024, 10, 1),
            entry_time=time(12, 0, 0),
            rating=3
        )

        self.valid_entry_lower_limit = Entries(
            entry="Lower limit entry",
            entry_date=date(2024, 9, 1),
            entry_time=time(4, 6, 0),
            rating=1
        )

        self.valid_entry_upper_limit = Entries(
            entry="Upper limit entry",
            entry_date=date(2025, 2, 1),
            entry_time=time(17, 2, 0),
            rating=5
        )

        self.invalid_entry_text = Entries(
            entry="Invalid rating",
            entry_date=date(2024, 10, 1),
            entry_time=time(12, 0, 0),
            rating="hello"
        )

        self.invalid_entry_lower_limit = Entries(
            entry="Invalid lower limit rating",
            entry_date=date(2024, 10, 1),
            entry_time=time(12, 0, 0),
            rating=0
        )

        self.invalid_entry_upper_limit = Entries(
            entry="Invalid upper limit rating",
            entry_date=date(2024, 10, 1),
            entry_time=time(12, 0, 0),
            rating=6
        )

        self.invalid_entry_null = Entries(
            entry="Invalid null rating",
            entry_date=date(2024, 10, 1),
            entry_time=time(12, 0, 0),
            rating=None
        )

    def test_create_entry_valid_rating(self):
        """Test creating entry with valid rating."""
        self.session.add(self.valid_entry)
        self.session.commit()
        logger.debug(f"Created entry: {self.valid_entry.entry} with rating {self.valid_entry.rating}")

        db_entry = self.session.exec(select(Entries).where(Entries.entry == "Valid entry")).first()

        self.assertIsNotNone(db_entry)
        self.assertEqual(db_entry.rating, 3)

    def test_create_entry_valid_rating_lower_limit(self):
        """Test creating entry with rating at lower limit."""
        self.session.add(self.valid_entry_lower_limit)
        self.session.commit()
        logger.debug(f"Created entry: {self.valid_entry_lower_limit.entry} with rating {self.valid_entry_lower_limit.rating}")

        db_entry = self.session.exec(select(Entries).where(Entries.entry == self.valid_entry_lower_limit.entry)).first()

        self.assertIsNotNone(db_entry)
        self.assertEqual(db_entry.rating, 1)

    def test_create_entry_valid_rating_upper_limit(self):
        """Test creating entry with rating at upper limit."""
        self.session.add(self.valid_entry_upper_limit)
        self.session.commit()
        logger.debug(f"Created entry: {self.valid_entry_upper_limit.entry} with rating {self.valid_entry_upper_limit.rating}")

        db_entry = self.session.exec(select(Entries).where(Entries.entry == self.valid_entry_upper_limit.entry)).first()

        self.assertIsNotNone(db_entry)
        self.assertEqual(db_entry.rating, 5)

    def test_create_entry_invalid_rating_text(self):
        """Test creating entry with an invalid rating using text."""
        with self.assertRaises(HTTPException) as context:
            lib.app.create_entry(self.invalid_entry_text, self.session)

        exception = context.exception
        logger.debug(f"HTTPException raised with status code {exception.status_code} and detail: {exception.detail}")

    def test_create_entry_invalid_lower_limit_rating(self):
        """Test creating entry with rating below lower limit."""
        with self.assertRaises(HTTPException) as context:
            lib.app.create_entry(self.invalid_entry_lower_limit, self.session)

        exception = context.exception
        logger.debug(f"HTTPException raised with status code {exception.status_code} and detail: {exception.detail}")

    def test_create_entry_invalid_upper_limit_rating(self):
        """Test creating entry with rating above upper limit."""
        with self.assertRaises(HTTPException) as context:
            lib.app.create_entry(self.invalid_entry_upper_limit, self.session)

        exception = context.exception
        logger.debug(f"HTTPException raised with status code {exception.status_code} and detail: {exception.detail}")

    def test_create_entry_invalid_null_rating(self):
        """Test creating entry with null rating."""

        with self.assertRaises(HTTPException) as context:
            lib.app.create_entry(self.invalid_entry_null, self.session)

        exception = context.exception
        logger.debug(f"HTTPException raised with status code {exception.status_code} and detail: {exception.detail}")

class TestAssignPlant(BaseTestCase):
    def setUp(self):
        super().setUp()

        plant = Plant(
        plant_id=1,
        plant_type="TestType",
        unlocked=True,
        price=10)
        self.session.add(plant)
        self.session.commit()

        self.valid_plant = Garden(
            garden_slot=1,
            plant_id=1,
            name="Valid Garden Plant",
            archived=False,
            maturity=10,
            plant_exp=100,
            last_watered=date.today()
        )

        self.invalid_plant_id = Garden(
            garden_slot=2,
            plant_id=999,
            name="Invalid Garden Plant",
            archived=False,
            maturity=10,
            plant_exp=100,
            last_watered=date.today()
        )

    def test_assign_plant_valid(self):
        """Test assigning a valid plant."""
        try:
            lib.app.assign_plant(self.valid_plant, self.session)
        except HTTPException:
            self.fail("assign_plant raised HTTPException unexpectedly!")

        db_plant = self.session.exec(select(Garden).where(Garden.garden_slot == 1)).first()
        self.assertIsNotNone(db_plant)
        self.assertEqual(db_plant.name, "Valid Garden Plant")

    def test_assign_plant_invalid_plant_id(self):
        """Test assigning plant with invalid plant ID."""
        with self.assertRaises(HTTPException) as context:
            lib.app.assign_plant(self.invalid_plant_id, self.session)

        exception = context.exception
        logger.debug(f"HTTPException raised with status code {exception.status_code} and detail: {exception.detail}")
        self.assertEqual(exception.status_code, 404)
        self.assertIn("Plant not found", exception.detail)

@patch("lib.app.Session")
class TestErrorHandlingDatabase(BaseTestCase):
    def test_get_session_error(self, mock_session):
        """Test error while getting DB session."""
        mock_session.side_effect = SQLAlchemyError("Session DB")

        with self.assertRaises(HTTPException) as context:
            list(lib.app.get_session())

        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error creating session", context.exception.detail)

    @patch("lib.app.SQLModel.metadata.create_all")
    def test_creating_db_tables_error(self, mock_create_all, mock_session):
        """Test error while creating DB tables."""
        mock_create_all.side_effect = SQLAlchemyError("Database error")

        with self.assertRaises(HTTPException) as context:
            lib.app.create_db_and_tables()

        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error creating tables", context.exception.detail)

    def test_creating_plants_error(self, mock_session):
        """Test error while creating plants."""
        mock_session.return_value.__enter__.return_value.commit.side_effect = SQLAlchemyError("Database error")

        with self.assertRaises(HTTPException) as context:
            lib.app.create_plants()

        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error creating plants: ", context.exception.detail)

    def test_creating_garden_error(self, mock_session):
        """Test error while creating garden."""
        mock_session.return_value.__enter__.return_value.commit.side_effect = SQLAlchemyError("Database error")

        with self.assertRaises(HTTPException) as context:
            lib.app.create_garden()

        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error creating garden: ", context.exception.detail)

    def test_creating_user_error(self, mock_session):
        """Test error while creating user."""
        mock_session.return_value.__enter__.return_value.commit.side_effect = SQLAlchemyError("Database error")

        with self.assertRaises(HTTPException) as context:
            lib.app.create_user("oiiaoiia")

        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error creating user: ", context.exception.detail)

    def test_creating_goals_error(self, mock_session):
        """Test error while creating goals."""
        mock_session.return_value.__enter__.return_value.commit.side_effect = SQLAlchemyError("Database error")

        with self.assertRaises(HTTPException) as context:
            lib.app.create_goals()

        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error creating goals: ", context.exception.detail)

@patch("lib.app.Session")
class TestErrorHandlingPlant(BaseTestCase):
    # Three outcomes, plants are found, no plants found, SQLAlchemyError
    def test_get_plant_asset_no_plants(self, mock_session):
        """Test getting plant assets when no plants exist."""
        mock_session.return_value.__enter__.return_value.exec.return_value.all.return_value = []

        with self.assertRaises(HTTPException) as context:
            lib.app.get_plant_info()

        self.assertEqual(context.exception.status_code, 404)
        logger.debug(context.exception.status_code)
        self.assertIn("Error 404: Plants not found", context.exception.detail)

    def test_get_plant_asset_db_error(self, mock_session):
        """Test DB error while getting plant assets."""
        mock_session.return_value.__enter__.return_value.exec.side_effect = SQLAlchemyError("Database error")

        with self.assertRaises(HTTPException) as context:
            lib.app.get_plant_info()

        self.assertEqual(context.exception.status_code, 500)
        logger.debug(context.exception.status_code)
        self.assertIn("Error retrieving plant assets: ", context.exception.detail)

    def test_garden_not_found(self, mock_session):
        """Test error for garden not found."""
        mock_session.return_value.__enter__.return_value.exec.return_value.all.return_value = []

        with self.assertRaises(HTTPException) as context:
            lib.app.get_plant_details()

        self.assertEqual(context.exception.status_code, 404)
        logger.debug(context.exception.status_code)
        self.assertIn("Error 404: Garden not found", context.exception.detail)

    def test_get_plant_details_fail(self, mock_session):
        """Test failure when getting plant details."""

        mock_session.return_value.__enter__.return_value.exec.side_effect = SQLAlchemyError("Database error")

        with self.assertRaises(HTTPException) as context:
            lib.app.get_plant_details()

        self.assertEqual(context.exception.status_code, 500)
        logger.debug(context.exception.status_code)
        self.assertIn("Error retrieving garden progress: ", context.exception.detail)

    def test_buy_plant_error(self, mock_session):
        """Test error during plant purchase."""
        dummy_plant = lib.app.Plant(plant_id=999)
        logger.debug(f"Testing buy_plant with plant_id: {dummy_plant.plant_id}")

        # patch Session used within buy_plant
        with patch("lib.app.Session") as mock_session_class:
            mock_session = MagicMock()
            mock_exec = MagicMock()
            mock_exec.one.side_effect = SQLAlchemyError("DB error")

            mock_session.__enter__.return_value.exec.return_value = mock_exec
            mock_session_class.return_value = mock_session

            with self.assertRaises(HTTPException) as cm:
                lib.app.buy_plant(dummy_plant, session=None)

            logger.debug(f"HTTPException caught with status: {cm.exception.status_code} and detail: {cm.exception.detail}")
            self.assertEqual(cm.exception.status_code, 500)
            self.assertIn("Error buying plant", cm.exception.detail)

    def test_water_plant_error(self, mock_session):
        """Test error while watering a plant."""
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
        logger.debug(context.exception.status_code)
        self.assertIn("Error updating plant values: ", context.exception.detail)

    def test_get_garden_shelves_error(self, mock_session):
        """Test error getting garden shelves."""
        mock_session.return_value.__enter__.return_value.exec.side_effect = SQLAlchemyError("Database error")

        with self.assertRaises(HTTPException) as context:
            lib.app.get_garden_shelves(page_number=1, session=None)

        self.assertEqual(context.exception.status_code, 500)
        logger.debug(context.exception.status_code)
        self.assertIn("Error retrieving garden shelves: ", context.exception.detail)

@patch("lib.app.Session")
class TestErrorHandlingEntries(BaseTestCase):
    def test_get_entries_sqlalchemy_error(self, mock_session):
        """Test SQLAlchemy error while getting entries."""
        mock_session.return_value.__enter__.return_value.exec.side_effect = SQLAlchemyError("DB failed")

        with self.assertRaises(HTTPException) as context:
            lib.app.get_entries(1, None)

        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error retrieving entries", context.exception.detail)

# this is how you ditctate the order of the tests cause they run alphabetical by default for some reason
def suite():
    """Define the order of test execution"""
    suite = unittest.TestSuite()
    # inital setup
    suite.addTests(unittest.TestLoader().loadTestsFromTestCase(TestDatabaseSetup))
    suite.addTests(unittest.TestLoader().loadTestsFromTestCase(TestPlantTable))
    suite.addTests(unittest.TestLoader().loadTestsFromTestCase(TestGardenTable))
    suite.addTests(unittest.TestLoader().loadTestsFromTestCase(TestGoalsTable))
    suite.addTests(unittest.TestLoader().loadTestsFromTestCase(TestAppUserTable))
    # get functions
    suite.addTests(unittest.TestLoader().loadTestsFromTestCase(TestGetEntries))
    suite.addTests(unittest.TestLoader().loadTestsFromTestCase(TestGetPlantDetails))
    suite.addTests(unittest.TestLoader().loadTestsFromTestCase(TestGetExp))
    suite.addTests(unittest.TestLoader().loadTestsFromTestCase(TestGetGardenShelves))
    suite.addTests(unittest.TestLoader().loadTestsFromTestCase(TestGetLockedAndUnlocked))
    suite.addTests(unittest.TestLoader().loadTestsFromTestCase(TestGetUserData))
    # general functions
    suite.addTests(unittest.TestLoader().loadTestsFromTestCase(TestEntries))
    suite.addTests(unittest.TestLoader().loadTestsFromTestCase(TestAssignPlant))
    # error handling tests - jodie
    suite.addTests(unittest.TestLoader().loadTestsFromTestCase(TestErrorHandlingDatabase))
    suite.addTests(unittest.TestLoader().loadTestsFromTestCase(TestErrorHandlingPlant))
    suite.addTests(unittest.TestLoader().loadTestsFromTestCase(TestErrorHandlingEntries))


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
