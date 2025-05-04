import unittest
from sqlmodel import create_engine, SQLModel
from sqlalchemy.exc import SQLAlchemyError
from lib.database import *
from lib.app import create_db_and_tables

class TestCreateDbAndTables(unittest.TestCase):
    def setUp(self):
        """Set up an SQL database for testing"""
        self.engine = create_engine("sqlite:///:memory:")

    def test_create_db_and_tables(self):
        """Test if the tables are created correctly"""
        try:
            # Call the create_db_and_tables function
            create_db_and_tables(self.engine)

        except Exception as e:
            self.fail(f"create_db_and_tables raised an exception: {e}")

    def tearDown(self):
        """Tear down the database session after each test"""
        self.engine.dispose()

if __name__ == '__main__':
    unittest.main()
