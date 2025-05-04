import unittest
from sqlmodel import create_engine, SQLModel
from sqlalchemy.exc import SQLAlchemyError
from lib.database import *
from lib.app import create_db_and_tables, get_session

# each test case sets up, tests and tears down

class TestCreateDbAndTables(unittest.TestCase):
    def setUp(self):
        """Set up an SQL database for testing"""
        self.engine = create_engine("sqlite:///:memory:")

    def test_create_db_and_tables(self):
        """Test if the tables are created correctly"""
        try:
            create_db_and_tables(self.engine)

        except Exception as e:
            self.fail(f"create_db_and_tables raised an exception: {e}")

    def tearDown(self):
        """Delete database session after each test"""
        self.engine.dispose()

class TestGetSession(unittest.TestCase):
    def setUp(self):
        """Set up an SQL database for testing"""
        self.engine = create_engine("sqlite:///:memory:")
        create_db_and_tables(self.engine)

    def test_get_session(self):
        """Test if the session is created correctly"""
        try:
            session = get_session(self.engine)
            session_generator = get_session(self.engine)
            session = next(session_generator)
            self.assertIsNotNone(session, "Session should not be None")
            session.close()

        except SQLAlchemyError as e:
            self.fail(f"get_session raised an exception: {e}")

    def tearDown(self):
        """Delete database session after each test"""
        self.engine.dispose()


if __name__ == '__main__':
    unittest.main()
