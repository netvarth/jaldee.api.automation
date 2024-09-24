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
Resource        /ebs/TDD/ProviderConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 



*** Test Cases ***

JD-TC-UpdateLocation-1
      [Documentation]  Update a location by provider
      ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+4500115
      ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_A}=  Provider Signup  PhoneNumber=${PUSERNAME_A}
      Set Suite Variable  ${PUSERNAME_A}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
      Should Be Equal As Strings    ${resp.status_code}    200
      
      ${latti}  ${longi}  ${postcode}  ${city}  ${address}=  get_random_location_data
      ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
      
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid1}  ${resp.json()}
      
      ${latti1}  ${longi1}  ${postcode1}  ${city1}  ${address1}=  get_random_location_data
      ${tz}=   db.get_Timezone_by_lat_long   ${latti1}  ${longi1}
      ${parking}    Random Element     ${parkingType} 
      ${24hours}    Random Element    ${bool}
      ${g_url}=   FakerLibrary.url

      ${resp}=  Update Location  ${lid1}  place=${city1}  longitude=${longi1}  lattitude=${latti1}  googleMapUrl=${g_url}  pinCode=${postcode1}  address=${address1}  parkingType=${parking}  open24hours=${24hours}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Location ById  ${lid1}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['place']}  ${city1}
      Should Be Equal As Strings  ${resp.json()['longitude']}  ${longi1}
      Should Be Equal As Strings  ${resp.json()['lattitude']}  ${latti1}
      Should Be Equal As Strings  ${resp.json()['pinCode']}  ${postcode1}
      Should Be Equal As Strings  ${resp.json()['address']}  ${address1}
      Should Be Equal As Strings  ${resp.json()['googleMapUrl']}  ${g_url}
      Should Be Equal As Strings  ${resp.json()['status']}  ACTIVE
      Should Be Equal As Strings  ${resp.json()['baseLocation']}  ${bool[0]}
      Should Be Equal As Strings  ${resp.json()['open24hours']}  ${24hours}
      Should Be Equal As Strings  ${resp.json()['parkingType']}  ${parking}
      Should Be Equal As Strings  ${resp.json()['searchable']}  ${bool[1]}
      Should Be Equal As Strings  ${resp.json()['timezone']}  ${tz}
      Should Be Equal As Strings  ${resp.json()['locationType']}  ${locationType[0]}


JD-TC-UpdateLocation-2
	[Documentation]  Update location by an admin user

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${PUSERNAME_U1}  ${u_id} =  Create and Configure Sample User  admin=${bool[1]}

      ${resp}=    Provider Logout
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  Encrypted Provider Login     ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings             ${resp.status_code}   200

      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${lid1}  ${resp.json()[1]['id']}

      # ${latti2}  ${longi2}  ${postcode2}  ${city2}  ${address}=  get_random_location_data
      ${latti2}  ${longi2}  ${city2}=   get_lat_long_city
      ${resp}=  Update Location  ${lid1}  place=${city2}  longitude=${longi2}  lattitude=${latti2}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Location ById  ${lid1}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['place']}  ${city2}
      Should Be Equal As Strings  ${resp.json()['longitude']}  ${longi2}
      Should Be Equal As Strings  ${resp.json()['lattitude']}  ${latti2}

      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UpdateLocation-3
	[Documentation]  Update location after disabling that location

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${lid1}  ${resp.json()[1]['id']}

      ${resp}=  Disable Location  ${lid1}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Location ById  ${lid1}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${city}=   get_place
      ${resp}=  Update Location  ${lid1}  place=${city}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${resp}=  Get Location ById  ${lid1}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['place']}  ${city}

      ${resp}=  Enable Location  ${lid1}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Location ById  ${lid1}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-UpdateLocation-UH1
      [Documentation]  Update a location with already created location name

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${city1}  ${resp.json()[0]['place']}
      Set Test Variable  ${city2}  ${resp.json()[1]['place']}
      Set Suite Variable  ${lid2}  ${resp.json()[1]['id']}
      
      ${resp}=  Update Location  ${lid2}  place=${city1}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()[0]['place']}  ${city1}
      Should Be Equal As Strings  ${resp.json()[1]['place']}  ${city2}

JD-TC-UpdateLocation-UH2
      [Documentation]   Provider Update a location without login  
      ${city}=   get_place
      ${resp}=  Update Location  ${lid2}  place=${city}
      Should Be Equal As Strings    ${resp.status_code}   419
      Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-UpdateLocation-UH3
      [Documentation]   Consumer Update a location
      ${account_id}=    get_acc_id       ${PUSERNAME_A}
      ${primaryMobileNo}  ${token}  Create Sample Customer  ${account_id}  primaryMobileNo=${CUSERNAME1}

      ${resp}=    ProviderConsumer Login with token   ${CUSERNAME1}  ${account_id}  ${token} 
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${city}=   get_place
      ${resp}=  Update Location  ${lid2}  place=${city}
      Should Be Equal As Strings    ${resp.status_code}   401
      Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-UpdateLocation-UH4
      [Documentation]   Update a location by a non-admin user.

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${PUSERNAME_U1}  ${u_id} =  Create and Configure Sample User

      ${resp}=  Get User
      Log   ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=    Provider Logout
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  Encrypted Provider Login     ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings             ${resp.status_code}   200

      ${city}=   get_place
      ${resp}=  Update Location  ${lid2}  place=${city}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()[1]['place']}  ${city}


JD-TC-UpdateLocation-UH5
      [Documentation]   Update a location after creating a schedule in that location.

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${lid1}  ${resp.json()[1]['id']}
      Set Suite Variable  ${tz}  ${resp.json()[1]['timezone']}

      ${resp}=  Get Service
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable   ${s_id}   ${resp.json()[0]['id']}

      ${resp}=  Create Sample Schedule   ${lid1}   ${s_id}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${sch_id}  ${resp.json()}

      ${city}=   get_place
      ${resp}=  Update Location  ${lid1}  place=${city}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()[1]['place']}  ${city}


