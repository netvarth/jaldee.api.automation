*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags  NextAvailableSchedule
Library     Collections
Library     String
Library     json
Library     requests
# Library     FakerLibrary
Library    FakerLibrary    locale=en_IN
Library     /ebs/TDD/db.py
Resource    /ebs/TDD/ProviderKeywords.robot
Resource    /ebs/TDD/ConsumerKeywords.robot
Resource    /ebs/TDD/SuperAdminKeywords.robot
Variables   /ebs/TDD/varfiles/providers.py
Variables   /ebs/TDD/varfiles/hl_musers.py
Variables   /ebs/TDD/varfiles/consumerlist.py
Variables   /ebs/TDD/varfiles/consumermail.py

*** Keywords ***

Get Date Time via Timezone
    [Arguments]    ${timezone}
    ${zone}  @{loc}=  Split String    ${timezone}  /
    ${type}=    Evaluate     type($loc).__name__
    ${loc}=  Random Element    ${loc}
    # IF  type($loc).__name__ == 'list'
    #     ${loc}=  Random Element    ${loc}
    # END
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  provider/location/date/${zone}/${loc}  expected_status=any
    [Return]  ${resp}


*** Test Cases ***  
Testing timezones

    ${resp}=  Get Date Time via Timezone   America/Indiana/Indianapolis
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Date Time via Timezone   Asia/Kolkata
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${str} = 	Replace String Using Regexp 	America/Indiana/Indianapolis 	\\/\(\.+\){2} 	${EMPTY} 	count=1
    # ${str} = 	Replace String Using Regexp 	America/Indiana/Indianapolis  \(\\/.*\)\{2\}  ${EMPTY}
    # ${matches} = 	Get Regexp Matches 	America/Indiana/Indianapolis 	^.*/
    # ${ts} =  Evaluate  1523126888080/1000
    # ${start_time}=    DateTime.Convert Date    ${ts}   result_format="%a, %d %b %Y"
    
*** comment ***
    ${rand_loc}=  FakerLibrary.Local Latlng
    ${rand_loc}=  FakerLibrary.Local Latlng  country_code=US  coords_only=True
    ${rand_loc}=  FakerLibrary.Local Latlng  country_code=IN  
    ${rand_loc}=  FakerLibrary.Local Latlng  country_code=IN  coords_only=True
    ${rand_loc}=  FakerLibrary.Local Latlng  country_code=IE  coords_only=False
    ${rand_loc}=  FakerLibrary.Local Latlng  country_code=IE  coords_only=True
    ${Locale} =  FakerLibrary.Locale
    ${latti}  ${longi}  ${city}  ${country_abbr}  ${tz}=  FakerLibrary.Local Latlng  country_code=US  coords_only=False
    ${pin}=  FakerLibrary.postcode

    ${resp}=  Get Date Time by Timezone  ${tz}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get LocationsByPincode  ${pin}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${zone} 	${loc}=  Split String    Pacific/Apia   /
    # ${zone} 	${loc}=  Split String    US/Samoa   /
    # ${zone} 	${loc}=  Split String    America/Atka  /
    # ${zone} 	${loc}=  Split String    Asia/Kolkata  /
    # ${zone} 	${loc}=  Split String    Asia/Kuwait   /

    # Get Date Time via Timezone  
    # ${resp}=  Get Date Time via Timezone   Pacific/Apia
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Date Time via Timezone   Asia/Kolkata
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Date Time via Timezone   Asia/Kuwait
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Date Time via Timezone   America/Atka
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Date Time via Timezone   US/Samoa
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${time}=   db.get_time_by_timezone   Pacific/Apia
    # ${time}=   db.get_time_by_timezone   Asia/Kolkata
    # ${time}=   db.get_time_by_timezone   Asia/Kuwait
    # ${time}=   db.get_time_by_timezone   America/Atka
    # ${time}=   db.get_time_by_timezone   US/Samoa

    # ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    # ${tz1}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}

    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${tz2}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}

    # ${latti}  ${longi}=  get_lat_long
    # ${tz3}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}

    # ${foreign_tz}=   db.get_Timezone_by_lat_long   42.58765  1.74028
    # ${time}=   db.get_time_by_timezone   ${foreign_tz}
    # ${resp}=  Get Date Time via Timezone   ${foreign_tz}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${sTime}=  add_timezone_time  ${tz1}  0  15  
    # ${sTime}=  add_timezone_time  ${tz2}  0  15  
    # ${sTime}=  add_timezone_time  ${tz3}  0  15

    # ${sTime}=  add_timezone_time  ${foreign_tz}  0  15

    # ${rand_tz}=  FakerLibrary.Timezone
    # ${rand_tz}=  FakerLibrary.Timezone
    # ${rand_tz}=  FakerLibrary.Timezone
    # ${rand_tz}=  FakerLibrary.Timezone
    # ${time}=   db.get_time_by_timezone   ${rand_tz}
    # ${resp}=  Get Date Time via Timezone   ${rand_tz}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${sTime}=  add_timezone_time  ${rand_tz}  0  15  

    # ${time}=   db.get_time_by_timezone   thrissur/kerala