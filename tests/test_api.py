import unittest
from unittest.mock import patch, Mock
import sys
import os

# Add the parent directory to the path so that we can import the api module
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from api import IPInfoProvider

class TestIPInfoProvider(unittest.TestCase):
    """Test cases for the IPInfoProvider class."""

    @patch('api.requests.get')
    def test_get_ip_info_success(self, mock_get):
        """Test that get_ip_info returns the correct data on a successful request."""
        mock_response = Mock()
        expected_data = {
            "query": "8.8.8.8",
            "status": "success",
            "country": "United States",
            "countryCode": "US",
            "region": "CA",
            "regionName": "California",
            "city": "Mountain View",
            "zip": "94043",
            "lat": 37.422,
            "lon": -122.084,
            "timezone": "America/Los_Angeles",
            "isp": "Google LLC",
            "org": "Google LLC",
            "as": "AS15169 Google LLC",
            "display_ip": "8.8.8.8"
        }
        mock_response.json.return_value = expected_data
        mock_response.raise_for_status.return_value = None
        mock_get.return_value = mock_response

        ip_info_provider = IPInfoProvider()
        ip_info = ip_info_provider.get_ip_info("8.8.8.8")

        self.assertEqual(ip_info, expected_data)

    @patch('api.requests.get')
    def test_get_ip_info_failure(self, mock_get):
        """Test that get_ip_info returns an error message on a failed request."""
        mock_get.side_effect = Exception("Test error")

        ip_info_provider = IPInfoProvider()
        with self.assertRaises(Exception):
            ip_info_provider.get_ip_info("8.8.8.8")


if __name__ == '__main__':
    unittest.main()
