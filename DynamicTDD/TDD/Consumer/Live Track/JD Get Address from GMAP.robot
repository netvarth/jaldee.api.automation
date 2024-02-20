*** Settings ***
Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      gmap
Library         Collections
Library         String
Library         json
Library         FakerLibrary
Library         /ebs/TDD/db.py
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 



*** Test Cases ***

JD-TC-Get location using lattitde and longitude
    [Documentation]  Get location from google map using lattitude and longitude
    ${resp}=  Encrypted Provider Login  ${PUSERNAME189}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
*** Comments ***

    ${latti}  ${longi}  ${place}=  get_lat_long_city
    ${resp}=   Get Address using lat & long   ${latti}   ${longi}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}  ${place}

JD-TC-Get location using postal code
    [Documentation]  Get location from google map using postal code
    ${resp}=  Encrypted Provider Login  ${PUSERNAME189}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pin}=  get_pincode
    ${resp}=   Get Address from zipcode   ${pin}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}

JD-TC-Get location from city
    [Documentation]  Get location from google map from part of address like city
    ${resp}=  Encrypted Provider Login  ${PUSERNAME189}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${latti}  ${longi}  ${city}=  get_lat_long_city
    ${resp}=   Get Address from city   ${city}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['latitude']}   ${latti}
    # Should Be Equal As Strings  ${resp.json()['longitude']}   ${longi}
    Log  ${resp.json()}