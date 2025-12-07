BASE_DEFAULT_CONFIG = {
    "_comment_theme": "Set the display theme. Options: 'sleek', 'dashboard', 'tree', 'minimal', 'json', 'grid', 'markdown', 'compact'.",
    "theme": "sleek",
    "style": {
        "header": "bold white on blue",
        "field_name": "cyan",
        "field_value": "white",
        "error": "bold red",
        "panel_border": "blue"
    },
    "_comment_fields": "Default fields to display. Add or remove fields from the list below. Use 'all' to see everything.",
    "_all_possible_fields": [
        "continent", "continentCode", "country", "countryCode", "region", "regionName", "city",
        "district", "zip", "lat", "lon", "timezone", "offset", "currency", "isp", "org", "as",
        "asname", "reverse", "mobile", "proxy", "hosting", "query"
    ],
    "default_fields": [
        "country",
        "countryCode",
        "region",
        "regionName",
        "city",
        "zip",
        "lat",
        "lon",
        "timezone",
        "isp",
        "org",
        "as",
        "query"
    ]
}

CATEGORIES = {
    "Location": ["continent", "continentCode", "country", "countryCode", "region", "regionName", "city", "district", "zip", "lat", "lon", "timezone", "offset"],
    "Network": ["isp", "org", "as", "asname", "reverse"],
    "Details": ["currency", "mobile", "proxy", "hosting"]
}
