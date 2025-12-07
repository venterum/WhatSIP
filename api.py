import requests

class IPInfoProvider:
    """A class to provide IP information from an API."""

    def __init__(self, base_url="http://ip-api.com/json/"):
        self.base_url = base_url

    def get_ip_info(self, ip_address, fields_to_request=None):
        """
        Gets IP information from the API.

        Args:
            ip_address (str): The IP address to get information for.
            fields_to_request (list, optional): A list of fields to request from the API. Defaults to None.

        Returns:
            dict: A dictionary containing the IP information.
        """
        url = f"{self.base_url}{ip_address}"
        params = {}
        if fields_to_request:
            fields = [f for f in fields_to_request if f not in ["status", "message"]]
            if fields:
                params['fields'] = ",".join(fields)
                
        response = requests.get(url, params=params, timeout=6)
        response.raise_for_status()
        data = response.json()
        if not ip_address and data.get("status") == "success":
            data["display_ip"] = data.get("query", "Unknown")
        else:
            data["display_ip"] = ip_address or data.get("query", "Unknown")
        return data
