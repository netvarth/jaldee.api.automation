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
      
      ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
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

      ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
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
      
      ${latti1}  ${longi1}  ${postcode1}  ${city1}  ${district}  ${state}  ${address1}=  get_loc_details
      ${tz1}=   db.get_Timezone_by_lat_long   ${latti1}  ${longi1}
      ${resp}=  Create Location  ${city1}  ${longi1}  ${latti1}  ${postcode1}  ${address1}  
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${latti2}  ${longi2}  ${postcode2}  ${city2}  ${district}  ${state}  ${address2}=  get_loc_details
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

      ${latti3}  ${longi3}  ${postcode3}  ${city3}  ${district}  ${state}  ${address3}=  get_loc_details
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
      
      ${latti5}  ${longi5}  ${postcode5}  ${city5}  ${district}  ${state}  ${address5}=  get_loc_details
      ${tz5}=   db.get_Timezone_by_lat_long   ${latti5}  ${longi5}
      ${resp}=  Create Location  ${city5}  ${longi5}  ${latti5}  ${postcode5}  ${address5}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${latti6}  ${longi6}  ${postcode6}  ${city6}  ${district}  ${state}  ${address6}=  get_loc_details
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
      
      ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
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
      
      ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
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
      [Documentation]  Create a location by a user login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${PUSERNAME_U1}=  Create and Configure Sample User

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


JD-TC-CreateLocation -UH1
      [Documentation]   Provider create a location without login 
      ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details 
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

      ${resp}=  Consumer Logout
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
      Log  ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details 
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

*** COMMENTS ***



JD-TC-CreateLocation-UH4
      [Documentation]  Check location limit(only 5 locations can create under each account)
      ${PUSERNAME_G}=  Evaluate  ${PUSERNAME}+4400044
      ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_G}=  Provider Signup without Profile  PhoneNumber=${PUSERNAME_G}
      
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
      Log  ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}    200
      
      ${sTime3}=  add_timezone_time  ${tz}  1  05  
      Set Suite Variable   ${sTime3}
      ${eTime3}=  add_timezone_time  ${tz}  1  50  
      Set Suite Variable   ${eTime3}
      ${sTime4}=  add_timezone_time  ${tz}  2  05  
      Set Suite Variable   ${sTime4}
      ${eTime4}=  add_timezone_time  ${tz}  2  50  
      Set Suite Variable   ${eTime4}
      ${sTime5}=  add_timezone_time  ${tz}  3  05  
      Set Suite Variable   ${sTime5}
      ${eTime5}=  add_timezone_time  ${tz}  3  50  
      Set Suite Variable   ${eTime5}

      ${resp}=  Create Location without schedule  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking}  ${24hours}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Create Location without schedule  ${city1}  ${longi1}  ${latti1}  www.${city1}.com  ${postcode1}  ${address1}  ${parking_type1}  ${24hours1}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Create Location without schedule  ${city2}  ${longi2}  ${latti2}  www.${city2}.com  ${postcode2}  ${address2}  ${parking_type2}  ${24hours2}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Create Location without schedule  ${city3}  ${longi3}  ${latti3}  www.${city3}.com  ${postcode3}  ${address3}  ${parking_type3}  ${24hours3}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Create Location without schedule  ${city4}  ${longi3}  ${latti3}  www.${city4}.com  ${postcode4}  ${address4}  ${parking_type3}  ${24hours3}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Create Location without schedule  ${city5}  ${longi5}  ${latti5}  www.${city5}.com  ${postcode5}  ${address5}  ${parking_type5}  ${24hours5}
      Log  ${resp.content}
      Log     ${resp.status_code}
      Log     ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      # Should Be Equal As Strings  "${resp.json()}"  "${LOCATION_LIMIT_REACHED}"

# JD-TC-CreateLocation-UH5
#       [Documentation]   Try to Create more than one location in multipleLocation false domain 
#       ${domains}=  get_notiscorp_subdomains_with_no_multilocation  0
#       Log  ${domains}
#       Set Test Variable  ${dom}  ${domains[0]['domain']}
#       Set Test Variable  ${sub_dom}   ${domains[0]['subdomains']}
#       ${firstname}=  FakerLibrary.first_name
#       ${lastname}=  FakerLibrary.last_name
#       ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+4300055
#       ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_C}    1
#       Log  ${resp.content}
#       Should Be Equal As Strings    ${resp.status_code}    200
#       ${resp}=  Account Activation  ${PUSERNAME_C}  0
#       Should Be Equal As Strings    ${resp.status_code}    200
#       ${resp}=  Account Set Credential  ${PUSERNAME_C}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_C}
#       Should Be Equal As Strings    ${resp.status_code}    200
#       ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
#       Log  ${resp.content}
#       Should Be Equal As Strings    ${resp.status_code}    200
#       Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_C}${\n}

#       ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime0}  ${eTime0}
#       Log  ${resp.content}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       ${resp}=  Create Location  ${city1}  ${longi1}  ${latti1}  www.${city1}.com  ${postcode1}  ${address1}  ${parking_type1}  ${24hours1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
#       Log  ${resp.content}
#       Should Be Equal As Strings  ${resp.status_code}  422
#       Should Be Equal As Strings  "${resp.json()}"  "${LOCATION_CREATION_NOT_ALLOWED}"  

#       sleep  02s

JD-TC-CreateLocation-7
	[Documentation]  Create a location using another provider longitude and lattitude details
      ${resp}=  Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      clear_location   ${PUSERNAME7}

      ${latti9}  ${longi9}  ${city9}  ${postcode9}=  get_lat_long_city_pin
      ${tz9}=   db.get_Timezone_by_lat_long   ${latti9}  ${longi9}
      Set Suite Variable  ${tz9}
      Set Suite Variable  ${city9}
      Set Suite Variable  ${latti9}
      Set Suite Variable  ${longi9}
      Set Suite Variable  ${postcode9}
      ${parking9}    Random Element   ${parkingType}
      Set Suite Variable  ${parking9}
      ${24hours9}    Random Element    ${bool}
      Set Suite Variable  ${24hours9}
      ${DAY}=  db.get_date_by_timezone  ${tz}
    	Set Suite Variable  ${DAY}
	${list}=  Create List  1  2  3  4  5  6  7
    	Set Suite Variable  ${list}
      ${BsTime}=  add_timezone_time  ${tz}  0  15  
      Set Suite Variable   ${BsTime}
      ${eTime}=  add_timezone_time  ${tz}  0  30  
      Set Suite Variable   ${eTime}
      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Create Location  ${city9}  ${longi8}  ${latti8}  www.${city8}.com  ${postcode8}  ${address}  ${parking8}  ${24hours8}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${BsTime}  ${eTime}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid9}  ${resp.json()}

      ${resp}=  Get Location ById  ${lid9}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateLocation-UH5
	[Documentation]  Create a location with empty  longitude
      ${resp}=  Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      clear_location   ${PUSERNAME9}

      ${latti11}  ${longi11}  ${city11}  ${postcode11}=  get_lat_long_city_pin
      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Create Location  ${city11}  ${EMPTY}  ${latti8}  www.${city8}.com  ${postcode8}  ${address}  ${parking8}  ${24hours8}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${BsTime}  ${eTime}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${INVALID_LOGITUDE}"

JD-TC-CreateLocation-UH6
	[Documentation]  Create a location with empty lattitude 
      ${resp}=  Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      clear_location   ${PUSERNAME9}

      ${latti12}  ${longi12}  ${city12}  ${postcode12}=  get_lat_long_city_pin
      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Create Location  ${city12}  ${longi8}  ${EMPTY}  www.${city8}.com  ${postcode8}  ${address}  ${parking8}  ${24hours8}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${BsTime}  ${eTime}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${INVALID_LATTITUDE}"

JD-TC-CreateLocation-UH7
	[Documentation]  User without admin privilege try to create location
      ${resp}=  Encrypted Provider Login  ${PUSERNAME10}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      clear_location   ${PUSERNAME10}
      
      ${latti13}  ${longi13}  ${city13}  ${postcode13}=  get_lat_long_city_pin
      Set Suite Variable  ${city13}
      ${tz13}=   db.get_Timezone_by_lat_long   ${latti13}  ${longi13}
      Set Suite Variable  ${tz13}
      Set Suite Variable  ${city13}
      Set Suite Variable  ${latti13}
      Set Suite Variable  ${longi13}
      Set Suite Variable  ${postcode13}
      ${parking13}    Random Element   ${parkingType}
      Set Suite Variable  ${parking13}
      ${24hours13}    Random Element    ${bool}
      Set Suite Variable  ${24hours13}
      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
 
      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Business Profile
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${account_id1}  ${resp.json()['id']}
      Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

      ${resp}=  Get Waitlist Settings
      Log  ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}    200
      IF  ${resp.json()['filterByDept']}==${bool[0]}
            ${resp}=  Toggle Department Enable
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
      END

      sleep  2s
      ${resp}=  Get Departments
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

      ${resp}=  Get User
      Log  ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}    200
      IF   not '${resp.content}' == '${emptylist}'
            ${len}=  Get Length  ${resp.json()}
            FOR   ${i}  IN RANGE   0   ${len}
                  Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
                  IF   not '${user_phone}' == '${PUSERNAME10}'
                        clear_users  ${user_phone}
                  END
            END
      END

      ${u_id1}=  Create Sample User  admin=${bool[0]}
      Set Suite Variable  ${u_id1}

      ${resp}=  Get User By Id  ${u_id1}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${PUSERNAME_U1}  ${resp.json()['mobileNo']}

      ${resp}=  Provider Logout
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
      Should Be Equal As Strings  ${resp.status_code}  200

      @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
      Should Be Equal As Strings  ${resp[0].status_code}  200
      Should Be Equal As Strings  ${resp[1].status_code}  200

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  Create Location  ${city13}  ${longi13}  ${latti13}  www.${city13}.com  ${EMPTY}  ${address}  ${parking13}  ${24hours13}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${BsTime}  ${eTime}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${NOT_PERMITTED_TO_CREATE_LOCATION}"

JD-TC-CreateLocation-UH8
	[Documentation]  Disable one location then try to create disabled location .
      ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      clear_location   ${PUSERNAME11}

      ${latti15}  ${longi15}  ${city15}  ${postcode15}=  get_lat_long_city_pin
      ${tz15}=   db.get_Timezone_by_lat_long   ${latti15}  ${longi15}
      Set Suite Variable  ${tz15}
      Set Suite Variable  ${city15}
      Set Suite Variable  ${latti15}
      Set Suite Variable  ${longi15}
      Set Suite Variable  ${postcode15}
      ${parking15}    Random Element   ${parkingType}
      Set Suite Variable  ${parking15}
      ${24hours15}    Random Element    ${bool}
      Set Suite Variable  ${24hours15}
      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Create Location  ${city13}  ${longi15}  ${latti15}  www.${city15}.com  ${postcode15}  ${EMPTY}  ${parking15}  ${24hours15}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${BsTime}  ${eTime}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Create Location  ${city15}  ${longi15}  ${latti15}  www.${city15}.com  ${postcode15}  ${EMPTY}  ${parking15}  ${24hours15}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${BsTime}  ${eTime}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid12}  ${resp.json()}

      ${resp}=  Disable Location  ${lid12}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Create Location  ${city15}  ${longi15}  ${latti15}  www.${city15}.com  ${postcode15}  ${EMPTY}  ${parking15}  ${24hours15}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${BsTime}  ${eTime}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${LOCATION_EXISTS}"



JD-TC-CreateLocation-8
	[Documentation]  Create a location with empty postcode
      ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      clear_location   ${PUSERNAME8}
      
      ${latti10}  ${longi10}  ${city10}  ${postcode10}=  get_lat_long_city_pin
      ${tz10}=   db.get_Timezone_by_lat_long   ${latti10}  ${longi10}
      Set Suite Variable  ${tz10}
      Set Suite Variable  ${city10}
      Set Suite Variable  ${latti10}
      Set Suite Variable  ${longi10}
      Set Suite Variable  ${postcode10}
      ${parking10}    Random Element   ${parkingType}
      Set Suite Variable  ${parking10}
      ${24hours10}    Random Element    ${bool}
      Set Suite Variable  ${24hours10}
      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
 
      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Create Location  ${city10}  ${longi10}  ${latti10}  www.${city10}.com  ${EMPTY}  ${address}  ${parking10}  ${24hours10}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${BsTime}  ${eTime}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid10}  ${resp.json()}

JD-TC-CreateLocation-9
	[Documentation]  Create a location with empty address
      ${resp}=  Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      clear_location   ${PUSERNAME9}

      ${latti14}  ${longi14}  ${city14}  ${postcode14}=  get_lat_long_city_pin
      ${tz14}=   db.get_Timezone_by_lat_long   ${latti14}  ${longi14}
      Set Suite Variable  ${tz14}
      Set Suite Variable  ${city14}
      Set Suite Variable  ${latti14}
      Set Suite Variable  ${longi14}
      Set Suite Variable  ${postcode14}
      ${parking14}    Random Element   ${parkingType}
      Set Suite Variable  ${parking14}
      ${24hours14}    Random Element    ${bool}
      Set Suite Variable  ${24hours14}
      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Create Location  ${city14}  ${longi14}  ${latti14}  www.${city14}.com  ${postcode14}  ${EMPTY}  ${parking14}  ${24hours14}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${BsTime}  ${eTime}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid11}  ${resp.json()}

JD-TC-CreateLocation-10
	[Documentation]   Auto detect your location then create location using that data.
      ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      clear_location   ${PUSERNAME11}

      ${latti16}  ${longi16}  ${city16}  ${postcode16}=  get_lat_long_city_pin
      ${tz16}=   db.get_Timezone_by_lat_long   ${latti16}  ${longi16}
      Set Suite Variable  ${tz16}
      Set Suite Variable  ${city16}
      Set Suite Variable  ${latti16}
      Set Suite Variable  ${longi16}
      Set Suite Variable  ${postcode16}
      ${parking16}    Random Element   ${parkingType}
      Set Suite Variable  ${parking16}
      ${24hours16}    Random Element    ${bool}
      Set Suite Variable  ${24hours16}
      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=   Get Address using lat & long   ${latti16}   ${longi16}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable   ${state}  ${resp.json()['state']['state']}
      Set Test Variable   ${country}  ${resp.json()['country']['country']}



      ${resp}=  Create Location  ${city16}  ${longi16}  ${latti16}  www.${city16}.com  ${postcode16}  ${state}  ${parking16}  ${24hours16}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${BsTime}  ${eTime}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid12}  ${resp.json()}


JD-TC-VerifyCreateLocation-1
	[Documentation]  Verify location details by provider login ${PUSERNAME5}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  place=${city}  longitude=${longi}  lattitude=${latti}  pinCode=${postcode}  address=${address}  parkingType=${parking}  open24hours=${24hours}  googleMapUrl=www.${city}.com  status=ACTIVE
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
   	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime0}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime0}

JD-TC-VerifyCreateLocation-2
	[Documentation]  Verify location details by provider login ${PUSERNAME_D}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()[0]['place']}  ${city1}
      Should Be Equal As Strings  ${resp.json()[0]['longitude']}  ${longi1}
      Should Be Equal As Strings  ${resp.json()[0]['lattitude']}  ${latti1}
      Should Be Equal As Strings  ${resp.json()[0]['pinCode']}  ${postcode1}
      Should Be Equal As Strings  ${resp.json()[0]['address']}  ${address1}
      Should Be Equal As Strings  ${resp.json()[0]['googleMapUrl']}  www.${city1}.com
      Should Be Equal As Strings  ${resp.json()[0]['status']}  ACTIVE
      Should Be Equal As Strings  ${resp.json()[0]['parkingType']}  ${parking_type1}
      Should Be Equal As Strings  ${resp.json()[0]['open24hours']}  ${24hours1}
      Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime1}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime1}
      Should Be Equal As Strings  ${resp.json()[1]['place']}   ${city2}
      Should Be Equal As Strings  ${resp.json()[1]['longitude']}  ${longi2}
      Should Be Equal As Strings  ${resp.json()[1]['lattitude']}  ${latti2}
      Should Be Equal As Strings  ${resp.json()[1]['pinCode']}  ${postcode2}
      Should Be Equal As Strings  ${resp.json()[1]['address']}  ${address2}
      Should Be Equal As Strings  ${resp.json()[1]['googleMapUrl']}  www.${city2}.com
      Should Be Equal As Strings  ${resp.json()[1]['status']}  ACTIVE
      Should Be Equal As Strings  ${resp.json()[1]['parkingType']}  ${parking_type2}
      Should Be Equal As Strings  ${resp.json()[1]['open24hours']}  ${24hours2}
      Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime2}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime2}

JD-TC-VerifyCreateLocation-3
	[Documentation]  Verify location details by provider login ${PUSERNAME_E}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Locations
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()[0]['place']}  ${city3}
      Should Be Equal As Strings  ${resp.json()[0]['longitude']}  ${longi3}
      Should Be Equal As Strings  ${resp.json()[0]['lattitude']}  ${latti3}
      Should Be Equal As Strings  ${resp.json()[0]['pinCode']}  ${postcode3}
      Should Be Equal As Strings  ${resp.json()[0]['address']}  ${address3}
      Should Be Equal As Strings  ${resp.json()[0]['googleMapUrl']}  www.${city3}.com
      Should Be Equal As Strings  ${resp.json()[0]['status']}  ACTIVE
      Should Be Equal As Strings  ${resp.json()[0]['parkingType']}  ${parking_type3}
      Should Be Equal As Strings  ${resp.json()[0]['open24hours']}  ${24hours3}
      Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime1}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime1}
      Should Be Equal As Strings  ${resp.json()[1]['place']}   ${city4}
      Should Be Equal As Strings  ${resp.json()[1]['longitude']}  ${longi3}
      Should Be Equal As Strings  ${resp.json()[1]['lattitude']}  ${latti3}
      Should Be Equal As Strings  ${resp.json()[1]['pinCode']}  ${postcode4}
      Should Be Equal As Strings  ${resp.json()[1]['address']}  ${address4}
      Should Be Equal As Strings  ${resp.json()[1]['googleMapUrl']}  www.${city4}.com
      Should Be Equal As Strings  ${resp.json()[1]['status']}  ACTIVE
      Should Be Equal As Strings  ${resp.json()[1]['parkingType']}  ${parking_type3}
      Should Be Equal As Strings  ${resp.json()[1]['open24hours']}  ${24hours3}
      Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime1}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime1}

JD-TC-VerifyCreateLocation-4
	[Documentation]  Verify location details by provider login ${PUSERNAME_F}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Locations
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()[0]['place']}  ${city5}
      Should Be Equal As Strings  ${resp.json()[0]['longitude']}  ${longi5}
      Should Be Equal As Strings  ${resp.json()[0]['lattitude']}  ${latti5}
      Should Be Equal As Strings  ${resp.json()[0]['pinCode']}  ${postcode5}
      Should Be Equal As Strings  ${resp.json()[0]['address']}  ${address5}
      Should Be Equal As Strings  ${resp.json()[0]['googleMapUrl']}  www.${city5}.com
      Should Be Equal As Strings  ${resp.json()[0]['status']}  ACTIVE
      Should Be Equal As Strings  ${resp.json()[0]['parkingType']}  ${parking_type5}
      Should Be Equal As Strings  ${resp.json()[0]['open24hours']}  ${24hours5}
      Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime1}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime1}
      Should Be Equal As Strings  ${resp.json()[1]['place']}   ${city6}
      Should Be Equal As Strings  ${resp.json()[1]['longitude']}  ${longi5}
      Should Be Equal As Strings  ${resp.json()[1]['lattitude']}  ${latti5}
      Should Be Equal As Strings  ${resp.json()[1]['pinCode']}  ${postcode5}
      Should Be Equal As Strings  ${resp.json()[1]['address']}  ${address5}
      Should Be Equal As Strings  ${resp.json()[1]['googleMapUrl']}  www.${city5}.com
      Should Be Equal As Strings  ${resp.json()[1]['status']}  ACTIVE
      Should Be Equal As Strings  ${resp.json()[1]['parkingType']}  ${parking_type5}
      Should Be Equal As Strings  ${resp.json()[1]['open24hours']}  ${24hours5}
      Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime1}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime1}

JD-TC-VerifyCreateLocation-5
	[Documentation]  Verify location details by provider login ${PUSERNAME_A}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Location ById  ${lid3}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  place=${city7}  longitude=${longi7}  lattitude=${latti7}  pinCode=${postcode7}  address=${address7}  parkingType=${parking_type7}  open24hours=${24hours7}  googleMapUrl=www.${city7}.com  status=ACTIVE
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
   	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime0}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime0}

JD-TC-VerifyCreateLocation-6
	[Documentation]  Verify location details by branch login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Location ById  ${lid8}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  place=${city8}  longitude=${longi8}  lattitude=${latti8}  pinCode=${postcode8}  address=${address}  parkingType=${parking8}  open24hours=${24hours8}  googleMapUrl=www.${city8}.com  status=ACTIVE
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
   	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${BsTime}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime}

JD-TC-VerifyCreateLocation-7
	[Documentation]  Verify location details by branch login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Location ById  ${lid9}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  place=${city9}  longitude=${longi8}  lattitude=${latti8}  pinCode=${postcode8}  address=${address}  parkingType=${parking8}  open24hours=${24hours8}  googleMapUrl=www.${city8}.com  status=ACTIVE
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
   	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${BsTime}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime}

JD-TC-VerifyCreateLocation-8
	[Documentation]  Verify location details by branch login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Location ById  ${lid10}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  place=${city10}  longitude=${longi10}  lattitude=${latti10}  pinCode=${EMPTY}  address=${address}  parkingType=${parking10}  open24hours=${24hours10}  googleMapUrl=www.${city10}.com  status=ACTIVE
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
   	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${BsTime}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime}

JD-TC-VerifyCreateLocation-9
	[Documentation]  Verify location details by branch login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Location ById  ${lid11}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  place=${city14}  longitude=${longi14}  lattitude=${latti14}  pinCode=${postcode14}  address=${EMPTY}  parkingType=${parking14}  open24hours=${24hours14}  googleMapUrl=www.${city14}.com  status=ACTIVE
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
   	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${BsTime}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime}

JD-TC-VerifyCreateLocation-10
	[Documentation]  Verify location details by branch login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Location ById  ${lid12}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  place=${city16}  longitude=${longi16}  lattitude=${latti16}  pinCode=${postcode16}  address=${state}  parkingType=${parking16}  open24hours=${24hours16}  googleMapUrl=www.${city16}.com  status=ACTIVE
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
   	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${BsTime}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime}






