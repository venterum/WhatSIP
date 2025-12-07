import unittest
from unittest.mock import Mock, patch
import sys
import os
from rich.console import Console

# Add the parent directory to the path so that we can import the display and config modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from display import DisplayManager, SleekDisplay
from config import BASE_DEFAULT_CONFIG

class TestDisplayManager(unittest.TestCase):
    """Test cases for the DisplayManager class."""

    def test_get_display(self):
        """Test that get_display returns the correct display class."""
        console = Console()
        display_manager = DisplayManager(console)
        
        display = display_manager.get_display("sleek", {}, {}, [])
        self.assertIsInstance(display, SleekDisplay)

        # Test fallback to SleekDisplay
        display = display_manager.get_display("non_existent_theme", {}, {}, [])
        self.assertIsInstance(display, SleekDisplay)

class TestSleekDisplay(unittest.TestCase):
    """Test cases for the SleekDisplay class."""

    def test_display(self):
        """Test that the display method prints a table to the console."""
        console = Mock(spec=Console)
        config = BASE_DEFAULT_CONFIG
        data = {
            "query": "8.8.8.8",
            "status": "success",
            "country": "United States",
            "city": "Mountain View",
            "isp": "Google LLC",
            "display_ip": "8.8.8.8"
        }
        fields_to_show = ["country", "city", "isp"]
        
        display = SleekDisplay(console, config, data, fields_to_show)
        display.display()

        console.print.assert_called_once()

if __name__ == '__main__':
    unittest.main()
