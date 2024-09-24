*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Location
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource        /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py
# Suite Setup       Run Keyword  clear_location  ${PUSERNAME7}


*** Test Cases ***

JD-TC-GetLocationById-1
      [Documentation]  Get a Location by provider login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${latti}  ${longi}  ${postcode}  ${city}  ${address}=  get_random_location_data
      ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
      ${parking}    Random Element     ${parkingType} 
      ${24hours}    Random Element    ${bool}
      ${url}=   FakerLibrary.url
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}  googleMapUrl=${url}  parkingType=${parking}  open24hours=${24hours}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${lid}  ${resp.json()}

      ${resp}=  Get Location ById  ${lid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['place']}  ${city}
      Should Be Equal As Strings  ${resp.json()['longitude']}  ${longi}
      Should Be Equal As Strings  ${resp.json()['lattitude']}  ${latti}
      Should Be Equal As Strings  ${resp.json()['pinCode']}  ${postcode}
      Should Be Equal As Strings  ${resp.json()['address']}  ${address}
      Should Be Equal As Strings  ${resp.json()['googleMapUrl']}  ${url}
      Should Be Equal As Strings  ${resp.json()['status']}  ${status[0]}
      Should Be Equal As Strings  ${resp.json()['baseLocation']}  ${bool[0]}
      Should Be Equal As Strings  ${resp.json()['open24hours']}  ${24hours}
      Should Be Equal As Strings  ${resp.json()['parkingType']}  ${parking}
      Should Be Equal As Strings  ${resp.json()['searchable']}  ${bool[1]}
      Should Be Equal As Strings  ${resp.json()['timezone']}  ${tz}



JD-TC-GetLocationById-2
	[Documentation]  Get a location by user login

      ${multiusers}=    Multiple Users Accounts
      Log   ${multiusers}
      ${PUSER}=  Random Element    ${multiusers}
      Set Suite Variable  ${PUSER}

      ${resp}=   Encrypted Provider Login  ${PUSER}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}   200

      ${latti}  ${longi}  ${postcode}  ${city}  ${address}=  get_random_location_data
      ${resp}=  Create Location   ${city}  ${longi}  ${latti}  ${postcode}  ${address}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid}  ${resp.json()}

      ${PUSERNAME_U1}  ${u_id} =  Create and Configure Sample User

      ${resp}=    Provider Logout
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  Encrypted Provider Login     ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings             ${resp.status_code}   200

      ${resp}=  Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      


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
      ${account_id}=    get_acc_id       ${PUSER}

      ${primaryMobileNo}  ${token}  Create Sample Customer  ${account_id}  primaryMobileNo=${CUSERNAME3}

      ${resp}=    ProviderConsumer Login with token   ${CUSERNAME3}  ${account_id}  ${token} 
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${resp}=  Get Location ById  ${lid}
      Should Be Equal As Strings    ${resp.status_code}   401
      Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

*** COMMENTS ***
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



