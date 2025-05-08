# to run this go to the root folder (Whisker-Garden)
# python -m lib.apptest
# python -m lib.apptest --debug

import unittest
from unittest.mock import patch
from fastapi import HTTPException
from sqlmodel import create_engine, SQLModel
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy import text
from sqlalchemy.orm import sessionmaker
from lib.database import *
# from lib.app import *
import lib.app

# this is all for logging so i dont comment print statements
import logging

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)  # Default to INFO level
handler = logging.StreamHandler()
formatter = logging.Formatter('%(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)



# each test case sets up, tests and tears down
# unittest.main checks for all functions that start with test_ and runs them
# connects to the database and says hello world

# this will be the formula for all the tests

class TestDatabaseSetup(unittest.TestCase):
    @patch('lib.app.engine')
    # setUp is run before each test case
    # setUp and tearDown needing different cases to the usual is so annoying
    def setUp(self, mock_engine):
        """Set up an in-memory SQLite database for the tests"""
        self.engine = create_engine("sqlite:///:memory:", echo=False) # change to echo=True to see the tables being created
        # this runs the function but as an in memory database that we will have to scrap
        mock_engine.return_value = self.engine

        # create tables using SQLModel directly instead of calling create_db_and_tables
        SQLModel.metadata.create_all(self.engine)

        Session = sessionmaker(bind=self.engine)
        self.session = Session()

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
            expected_tables = ['plant', 'entries', 'goals', 'garden', 'appuser']
            for table in expected_tables:
                self.assertIn(table, tables)

    # tearDown is run after each test case
    def tearDown(self):
        self.session.rollback()
        self.session.close()
        self.engine.dispose()

class TestPlantTable(unittest.TestCase):
    @patch('lib.app.engine')
    def setUp(self, mock_engine):
        """Set up an in-memory SQLite database for the tests"""
        # this runs the function but as an in-memory database that we will have to scrap
        # in-memory so we dont risk damage to the actual database
        self.engine = create_engine("sqlite:///:memory:", echo=False) # change to echo=True to see the tables being created
        mock_engine.return_value = self.engine

        # no idea what this is doing but it works so im not touching it
        SQLModel.metadata.create_all(self.engine)
        Session = sessionmaker(bind=self.engine)
        self.session = Session()

        # i cant remember why i needed the patch but it's needed
        # just runs the function that creates the plants in the database for the rest of this class to use
        with patch('lib.app.engine', self.engine):
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

    def tearDown(self):
        self.session.rollback()
        self.session.close()
        self.engine.dispose()

class TestGardenTable(unittest.TestCase):

    @patch('lib.app.engine')
    def setUp(self, mock_engine):
        """Set up an in-memory SQLite database for the tests"""
        self.engine = create_engine("sqlite:///:memory:", echo=False)
        mock_engine.return_value = self.engine

        SQLModel.metadata.create_all(self.engine)
        Session = sessionmaker(bind=self.engine)
        self.session = Session()

        with patch('lib.app.engine', self.engine):
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

    def tearDown(self):
        self.session.rollback()
        self.session.close()
        self.engine.dispose()

<<<<<<< Updated upstream
# this is how you dictate the order of the tests cause they run alphabetical by default for some reason
=======
# Testing for SQLAlchemy Error
class ExceptionTesting(unittest.TestCase):
    @patch("lib.app.SQLModel.metadata.create_all")
    def test_creating_db_tables(self, mock_create_all):
        mock_create_all.side_effect = SQLAlchemyError("DB error")

        with self.assertRaises(HTTPException) as context:
            lib.app.create_db_and_tables()
        
        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error creating tables", context.exception.detail)

    @patch("lib.app.Session")
    def test_get_session(self, mock_session):
        mock_session.side_effect = SQLAlchemyError("Session DB")

        with self.assertRaises(HTTPException) as context:
            list(lib.app.get_session())
        
        self.assertEqual(context.exception.status_code, 500)
        self.assertIn("Error creating session", context.exception.detail)

# this is how you ditctate the order of the tests cause they run alphabetical by default for some reason
>>>>>>> Stashed changes
def suite():
    """Define the order of test execution"""
    suite = unittest.TestSuite()
    suite.addTest(TestDatabaseSetup('test_hello_world'))
    suite.addTest(TestDatabaseSetup('test_list_tables'))
    suite.addTest(TestPlantTable('test_columns'))
    suite.addTest(TestPlantTable('test_plant_data'))
    suite.addTest(TestPlantTable('test_create_plant'))
    suite.addTest(TestPlantTable('test_delete_plant'))
    suite.addTest(TestGardenTable('test_columns'))
    suite.addTest(TestGardenTable('test_garden_data'))
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
