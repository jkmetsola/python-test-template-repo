import os


def obtainenv():
    if os.path.isfile(".env"):
        with open(".env") as f:
            lines = [line.strip() for line in f]
        for key, value in [line.split("=", 1) for line in lines]:
            if key == "HSL_API_KEY":
                os.environ[key] = value


def get_variables():
    obtainenv()
    return {
        "HSL_GRAPHQL_API": "https://api.digitransit.fi/routing/v1/routers/hsl/index/graphql",
        "HSL_API_KEY": os.environ["HSL_API_KEY"],
    }
