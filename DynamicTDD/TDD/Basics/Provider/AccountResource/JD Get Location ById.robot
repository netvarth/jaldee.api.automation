*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Location
Library           Collections
Library           String
Library           json
Library         FakerLibrary
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py
Suite Setup       Run Keyword  clear_location  ${PUSERNAME7}


*** Test Cases ***

JD-TC-GetLocationById-1
      [Documentation]  Get a Location by provider login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      # ${city}=   get_place
      # Set Suite Variable  ${city}
      # ${latti}=  get_latitude
      # Set Suite Variable  ${latti}
      # ${longi}=  get_longitude
      # Set Suite Variable  ${longi}
      # ${postcode}=  FakerLibrary.postcode
      # Set Suite Variable  ${postcode}
      # ${address}=  get_address
      # Set Suite Variable  ${address}
      ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
      ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
      Set Suite Variable  ${tz}
      Set Suite Variable  ${city}
      Set Suite Variable  ${latti}
      Set Suite Variable  ${longi}
      Set Suite Variable  ${postcode}
      Set Suite Variable  ${address}
      ${park_type}    Random Element     ['none','free','street','privatelot','valet','paid']
      Set Suite Variable  ${park_type}
      ${24hours}    Random Element    ['True','False']
      Set Suite Variable  ${24hours}
      ${DAY}=  db.get_date_by_timezone  ${tz}
    	Set Suite Variable  ${DAY}
	${list}=  Create List  1  2  3  4  5  6  7
    	Set Suite Variable  ${list}
      ${sTime}=  add_timezone_time  ${tz}  0  15  
      Set Suite Variable   ${sTime}
      ${eTime}=  add_timezone_time  ${tz}  0  30  
      Set Suite Variable   ${eTime}
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${park_type}  ${24hours}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid}  ${resp.json()}

JD-TC-GetLocationById-2
	[Documentation]  Get a location by a branch login
      ${iscorp_subdomains}=  get_iscorp_subdomains  1
      Log  ${iscorp_subdomains}
      Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
      Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+450027
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E}    2
      Log  ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${PUSERNAME_E}  0
      Log  ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${PUSERNAME_E}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_E}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Log  ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}    200
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_E}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${PUSERNAME_E}${\n}
      Set Suite Variable  ${PUSERNAME_E}
      ${uid}=  get_uid  ${PUSERNAME_E}
      # ${city8}=   get_place
      # Set Suite Variable  ${city8}
      # ${latti8}=  get_latitude
      # Set Suite Variable  ${latti8}
      # ${longi8}=  get_longitude
      # Set Suite Variable  ${longi8}
      # ${postcode8}=  FakerLibrary.postcode
      # Set Suite Variable  ${postcode8}
      ${latti8}  ${longi8}  ${city8}  ${postcode8}=  get_lat_long_city_pin
      ${tz8}=   db.get_Timezone_by_lat_long   ${latti8}  ${longi8}
      Set Suite Variable  ${tz8}
      Set Suite Variable  ${city8}
      Set Suite Variable  ${latti8}
      Set Suite Variable  ${longi8}
      Set Suite Variable  ${postcode8}
      ${24hours8}    Random Element    ${bool}
      Set Suite Variable  ${24hours8}
      ${DAY}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${DAY}
      ${DAY2}=  db.add_timezone_date  ${tz}  10  
      Set Suite Variable  ${DAY2}
	${list}=  Create List  1  2  3  4  5  6  7
      Set Suite Variable  ${list}
      ${sTime2}=  add_timezone_time  ${tz}  0  35  
      Set Suite Variable   ${sTime2}
      ${eTime2}=  add_timezone_time  ${tz}  0  60  
      Set Suite Variable   ${eTime2}

      ${lid8}=  Create Sample Location
      Set Suite Variable  ${lid8}
      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      # ${resp}=  Create Location  ${city8}  ${longi8}  ${latti8}  www.${city8}.com  ${postcode8}  ${address}  ${parking_type}  ${24hours8}  Weekly  ${list}  ${DAY}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}
      # Log  ${resp.content}
      # Should Be Equal As Strings  ${resp.status_code}  200
      


JD-TC-GetLocationById-UH1
      [Documentation]  Get a Location by id by another provider
      ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Location ById  ${lid}
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"     

JD-TC-GetLocationById -UH2
      [Documentation]   Provider Get a Location by id without login  
      ${resp}=  Get Location ById  ${lid}
      Should Be Equal As Strings    ${resp.status_code}   419
      Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-GetLocationById -UH3
      [Documentation]   Consumer Get a Location by id
      ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Get Location ById  ${lid}
      Should Be Equal As Strings    ${resp.status_code}   401
      Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

      sleep  01s                                  
JD-TC-VerifyGetLocationById-1
	[Documentation]  Verify location details by provider login ${PUSERNAME5}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  place=${city}  longitude=${longi}  lattitude=${latti}  pinCode=${postcode}  address=${address}  parkingType=${park_type}  open24hours=${24hours}  googleMapUrl=www.${city}.com  status=ACTIVE
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['recurringType']}  Weekly
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
   	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime}

JD-TC-VerifyGetLocationById-2
	[Documentation]  Verify location details by provider login ${PUSERNAME5}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Location ById  ${lid8}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      # Verify Response  ${resp}  place=${city8}  longitude=${longi8}  lattitude=${latti8}  pinCode=${postcode8}  address=${address}  parkingType=${parking_type}  open24hours=${24hours8}  googleMapUrl=www.${city8}.com  status=ACTIVE
      # Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['recurringType']}  Weekly
      # Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
      # Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	# Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime2}
	# Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime2}



