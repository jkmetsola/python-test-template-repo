*** Settings ***
Documentation       This test case is for demo-testing the HSL GraphQL API.
...                 The test case sends a query to the API and checks that the response contains the desired stops.

Library             Collections
Library             requests
Library             helpers


*** Variables ***
&{HEADERS}          Content-Type=application/graphql    digitransit-subscription-key=${HSL_API_KEY}
${QUERY}            {stops {name}}
@{DESIRED_STOPS}    Maisala    Jalavatie    Nihtisillanportti    Joupinkallio    Jokitie


*** Test Cases ***
Test Stops
    [Documentation]    Test that the HSL GraphQL API returns the desired stops
    ${response}=    requests.Post    url=${HSL_GRAPHQL_API}    headers=${HEADERS}    data=${QUERY}
    Should Be Equal As Strings    ${response.status_code}    200
    ${data}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${data}    data
    Dictionary Should Contain Key    ${data["data"]}    stops
    Check That All Items Are Found    ${DESIRED_STOPS}    ${data["data"]["stops"]}
