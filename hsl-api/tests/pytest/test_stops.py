import requests
from ..init_vars import get_variables

vars = get_variables()


def test_stops():
    # Following stops are randomly selected from known stops in the API.
    desired_stops = [
        "Maisala",
        "Jalavatie",
        "Nihtisillanportti",
        "Joupinkallio",
        "Jokitie",
    ]
    query = """
    {
        stops {
            name
        }
    }
    """
    headers = {
        "Content-Type": "application/graphql",
        "digitransit-subscription-key": vars["HSL_API_KEY"],
    }
    response = requests.post(vars["HSL_GRAPHQL_API"], headers=headers, data=query)
    data = response.json()

    assert response.status_code == 200
    assert "data" in data
    assert "stops" in data["data"]
    assert isinstance(data["data"]["stops"], list)
    stops_acquired = [stop["name"] for stop in data["data"]["stops"]]
    assert all(stop in stops_acquired for stop in desired_stops)
