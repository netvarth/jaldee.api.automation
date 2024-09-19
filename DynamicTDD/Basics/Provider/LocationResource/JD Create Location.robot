*** Settings ***

Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      Location
Library         Collections
Library         String
Library         json
Library         FakerLibrary
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Resource        /ebs/TDD/ProviderConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Test Cases ***

JD-TC-CreateLocation-1
	[Documentation]  Create a location by provider login ${PUSERNAME5}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${latti}  ${longi}  ${postcode}  ${city}  ${address}=  get_random_location_data
      ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
      ${url}=   FakerLibrary.url
      ${resp}=  Create Location   ${city}  ${longi}  ${latti}  ${postcode}  ${address}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid}  ${resp.json()}
      ${resp}=  Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['place']}  ${city}
      Should Be Equal As Strings  ${resp.json()['longitude']}  ${longi}
      Should Be Equal As Strings  ${resp.json()['lattitude']}  ${latti}
      Should Be Equal As Strings  ${resp.json()['pinCode']}  ${postcode}
      Should Be Equal As Strings  ${resp.json()['address']}  ${address}
      Should Be Equal As Strings  ${resp.json()['status']}  ACTIVE
      Should Be Equal As Strings  ${resp.json()['baseLocation']}  ${bool[0]}
      Should Be Equal As Strings  ${resp.json()['open24hours']}  ${bool[0]}
      Should Be Equal As Strings  ${resp.json()['searchable']}  ${bool[1]}
      Should Be Equal As Strings  ${resp.json()['timezone']}  ${tz}


JD-TC-CreateLocation-2
      [Documentation]  Create a location which provider has no business profile
      ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+4400034
      ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_A}=  Provider Signup without Profile  PhoneNumber=${PUSERNAME_A}
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
      Log  ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}    200
      Set Suite Variable  ${PUSERNAME_A}

      ${latti}  ${longi}  ${postcode}  ${city}  ${address}=  get_random_location_data
      ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}      
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}  
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateLocation-3
	[Documentation]  Create multiple locations by provider login
      ${PUSERNAME_B}=  Evaluate  ${PUSERNAME}+4400001
      ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_B}=  Provider Signup without Profile  PhoneNumber=${PUSERNAME_B}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
      Log  ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}    200
      Set Suite Variable  ${PUSERNAME_B}
      
      ${latti1}  ${longi1}  ${postcode1}  ${city1}  ${address1}=  get_random_location_data
      ${tz1}=   db.get_Timezone_by_lat_long   ${latti1}  ${longi1}
      ${resp}=  Create Location  ${city1}  ${longi1}  ${latti1}  ${postcode1}  ${address1}  
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${latti2}  ${longi2}  ${postcode2}  ${city2}  ${address2}=  get_random_location_data
      ${tz2}=   db.get_Timezone_by_lat_long   ${latti2}  ${longi2}
      ${resp}=  Create Location  ${city2}  ${longi2}  ${latti2}  ${postcode2}  ${address2}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateLocation-4
      [Documentation]  Create a location which has same longittude and lattitude
      ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+4400012
      ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_C}=  Provider Signup without Profile  PhoneNumber=${PUSERNAME_C}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
      Log  ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}    200
      Set Suite Variable  ${PUSERNAME_C}

      ${latti3}  ${longi3}  ${postcode3}  ${city3}  ${address3}=  get_random_location_data
      ${tz3}=   db.get_Timezone_by_lat_long   ${latti3}  ${longi3}
      ${resp}=  Create Location  ${city3}  ${longi3}  ${latti3}  ${postcode3}  ${address3} 
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${city4}=   FakerLibrary.last_name
      ${postcode4}=  FakerLibrary.postcode
      ${address4}=  get_address
      ${resp}=  Create Location  ${city4}  ${longi3}  ${latti3}  ${postcode4}  ${address4}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateLocation-5
      [Documentation]  Create a location which has same pincode
      ${PUSERNAME_D}=  Evaluate  ${PUSERNAME}+4400023
      ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_D}=  Provider Signup without Profile  PhoneNumber=${PUSERNAME_D}
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
      Log  ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}    200
      Set Suite Variable  ${PUSERNAME_D}
      
      ${latti5}  ${longi5}  ${postcode5}  ${city5}  ${address5}=  get_random_location_data
      ${tz5}=   db.get_Timezone_by_lat_long   ${latti5}  ${longi5}
      ${resp}=  Create Location  ${city5}  ${longi5}  ${latti5}  ${postcode5}  ${address5}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${latti6}  ${longi6}  ${postcode6}  ${city6}  ${address6}=  get_random_location_data
      Set Suite Variable  ${city6}
      ${resp}=  Create Location  ${city6}  ${longi6}  ${latti6}  ${postcode5}  ${address6}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateLocation-6
      [Documentation]  Create a location with all attributes.
      ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_E}=  Provider Signup without Profile
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Log  ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}    200
      Set Suite Variable  ${PUSERNAME_E}
      
      ${latti}  ${longi}  ${postcode}  ${city}  ${address}=  get_random_location_data
      ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
      ${parking}    Random Element     ${parkingType} 
      ${24hours}    Random Element    ${bool}
      ${url}=   FakerLibrary.url
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}  googleMapUrl=${url}  parkingType=${parking}  open24hours=${24hours}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateLocation-7
      [Documentation]  Create a location with schedule data.
      ...  Not needed since there is no auto queue or schedule creation with this now.
      ...  Redundant data but not removed from create location.
      ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_F}=  Provider Signup without Profile
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
      Log  ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}    200
      Set Suite Variable  ${PUSERNAME_F}
      
      ${latti}  ${longi}  ${postcode}  ${city}  ${address}=  get_random_location_data
      ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
      ${list}=  Create List  1  2  3  4  5  6  7
      ${sTime1}=  db.get_time_by_timezone  ${tz}
      ${delta}=  FakerLibrary.Random Int  min=10  max=60
      ${eTime1}=  add_two   ${sTime1}  ${delta}
      ${DAY}=  db.get_date_by_timezone  ${tz}
      ${DAY2}=  db.add_timezone_date  ${tz}  10   
      ${parking}    Random Element     ${parkingType} 
      ${24hours}    Random Element    ${bool}
      ${url}=   FakerLibrary.url
      ${bschedule}=  BusinessSchedule  ${recurringtype[1]}  ${list}  ${DAY}  ${DAY2}  ${sTime1}  ${eTime1}
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}  googleMapUrl=${url}  parkingType=${parking}  open24hours=${24hours}  bSchedule=${bschedule}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateLocation-8
      [Documentation]  Create a location by an admin user login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${PUSERNAME_U1}  ${u_id} =  Create and Configure Sample User  admin=${bool[1]}

      ${resp}=    Provider Logout
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  Encrypted Provider Login     ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings             ${resp.status_code}   200

      ${latti8}  ${longi8}  ${postcode8}  ${city8}  ${address}=  get_random_location_data
      ${tz8}=   db.get_Timezone_by_lat_long   ${latti8}  ${longi8}
      ${resp}=  Create Location  ${city8}  ${longi8}  ${latti8}  ${postcode8}  ${address}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid8}  ${resp.json()}

      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateLocation-9
	[Documentation]  Create a location using another provider's location details
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${city}  ${resp.json()[0]['place']}  
      Set Test Variable  ${longi}  ${resp.json()[0]['longitude']}  
      Set Test Variable  ${latti}  ${resp.json()[0]['lattitude']}  
      Set Test Variable  ${postcode}  ${resp.json()[0]['pinCode']}  
      Set Test Variable  ${address}  ${resp.json()[0]['address']}

      ${resp}=  Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      # clear_location   ${PUSERNAME7}

      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid9}  ${resp.json()}

      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateLocation-10
	[Documentation]  Create a location with empty postcode
      ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${latti10}  ${longi10}  ${postcode10}  ${city10}  ${address10}=  get_random_location_data
      ${resp}=  Create Location  ${city10}  ${longi10}  ${latti10}  ${EMPTY}  ${address10}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid10}  ${resp.json()}

JD-TC-CreateLocation-11
	[Documentation]  Create a location with empty address
      ${resp}=  Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${latti14}  ${longi14}  ${postcode14}  ${city14}  ${address14}=  get_random_location_data
      ${resp}=  Create Location  ${city14}  ${longi14}  ${latti14}  ${postcode14}  ${EMPTY}  
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid11}  ${resp.json()}

JD-TC-CreateLocation -UH1
      [Documentation]   Provider create a location without login 
      ${latti}  ${longi}  ${postcode}  ${city}  ${address}=  get_random_location_data 
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}
      Should Be Equal As Strings    ${resp.status_code}   419
      Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"

 
JD-TC-CreateLocation -UH2
      [Documentation]   Consumer create a location
      ${account_id}=    get_acc_id       ${PUSERNAME_B}

      ${primaryMobileNo}  ${token}  Create Sample Customer  ${account_id}  primaryMobileNo=${CUSERNAME1}

      ${resp}=    ProviderConsumer Login with token   ${CUSERNAME1}  ${account_id}  ${token} 
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${latti}  ${longi}  ${postcode}  ${city}  ${address}=  get_random_location_data 
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}
      Should Be Equal As Strings    ${resp.status_code}   401
      Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"


JD-TC-CreateLocation-UH3
      [Documentation]  Create a location which is already created
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${city}  ${resp.json()[0]['place']}  
      Set Test Variable  ${longi}  ${resp.json()[0]['longitude']}  
      Set Test Variable  ${latti}  ${resp.json()[0]['lattitude']}  
      Set Test Variable  ${postcode}  ${resp.json()[0]['pinCode']}  
      Set Test Variable  ${address}  ${resp.json()[0]['address']}  

      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${postcode}  ${address}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${LOCATION_EXISTS}"


JD-TC-CreateLocation-UH4
	[Documentation]  Create a location with empty longitude
      ${resp}=  Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      # clear_location   ${PUSERNAME9}

      ${latti11}  ${longi11}  ${postcode11}  ${city11}  ${address11}=  get_random_location_data
      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Create Location  ${city11}  ${EMPTY}  ${latti11}  ${postcode11}  ${address11}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  ${resp.json()}  ${INVALID_LOGITUDE}

JD-TC-CreateLocation-UH5
	[Documentation]  Create a location with empty lattitude 
      ${resp}=  Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      clear_location   ${PUSERNAME9}

      ${latti12}  ${longi12}  ${postcode12}  ${city12}  ${address12}=  get_random_location_data
      
      ${resp}=  Create Location  ${city12}  ${longi12}  ${EMPTY}  ${postcode12}  ${address12}  
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${INVALID_LATTITUDE}"

JD-TC-CreateLocation-UH6
	[Documentation]  User without admin privilege try to create location
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${PUSERNAME_U1}  ${u_id} =  Create and Configure Sample User

      ${resp}=    Provider Logout
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  Encrypted Provider Login     ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings             ${resp.status_code}   200

      ${latti8}  ${longi8}  ${postcode8}  ${city8}  ${address}=  get_random_location_data
      ${tz8}=   db.get_Timezone_by_lat_long   ${latti8}  ${longi8}
      ${resp}=  Create Location  ${city8}  ${longi8}  ${latti8}  ${postcode8}  ${address}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${NOT_PERMITTED_TO_CREATE_LOCATION}"


JD-TC-CreateLocation-UH7
	[Documentation]  Disable one location then try to create disabled location .
      ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      # clear_location   ${PUSERNAME11}

      ${latti15}  ${longi15}  ${postcode15}  ${city15}  ${address15}=  get_random_location_data
      ${resp}=  Create Location  ${city15}  ${longi15}  ${latti15}  ${postcode15}  ${address15}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${lid12}  ${resp.json()}

      ${resp}=  Disable Location  ${lid12}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Create Location  ${city15}  ${longi15}  ${latti15}  ${postcode15}  ${address15}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${LOCATION_EXISTS}"


JD-TC-CreateLocation-8
	[Documentation]   Auto detect your location then create location using that data.
      ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${latti16}  ${longi16}  ${city16}  ${postcode16}=  get_lat_long_city_pin

      ${resp}=   Get Address using lat & long   ${latti16}   ${longi16}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable   ${state}  ${resp.json()['state']['state']}
      Set Test Variable   ${country}  ${resp.json()['country']['country']}


      ${resp}=  Create Location  ${city16}  ${longi16}  ${latti16}  ${postcode16}  ${state}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid12}  ${resp.json()}





