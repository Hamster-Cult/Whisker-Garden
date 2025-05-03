import unittest
from app import *

"""
Structure to testing:
    - Since every function has try-except error handling, we need to test for the exception raises
    - Group the functions (unit testing):
        setup: creating db, get session
        functionality: create entry/user/garden/plant 
    Add more if u think other functions can be grouped ^^ 
"""


# class appSetup(unittest.TestCase): 
#     def testEXAMPLE(self):