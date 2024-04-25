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


*** Test Cases ***

JD-TC-GetLocations-1
      [Documentation]  Get Locations by provider login
      ${domresp}=  Get BusinessDomainsConf
      Should Be Equal As Strings  ${domresp.status_code}  200
      ${len}=  Get Length  ${domresp.json()}
      FOR  ${domindex}  IN RANGE  ${len}
            Set Test Variable  ${multi}  ${domresp.json()[${domindex}]['multipleLocation']}
            Run Keyword If  '${multi}'=='True'  Multiple Location  ${domindex}  ${domresp.json()}
      END
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${PUSERNAME_D}=  Evaluate  ${PUSERNAME}+440010
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_D}    2
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${PUSERNAME_D}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${PUSERNAME_D}  ${PASSWORD}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_D}${\n}
      Set Suite Variable  ${PUSERNAME_D}
      # ${city1}=   get_place
      # Set Suite Variable  ${city1}
      # ${latti1}=  get_latitude
      # Set Suite Variable  ${latti1}
      # ${longi1}=  get_longitude
      # Set Suite Variable  ${longi1}
      # ${postcode1}=  FakerLibrary.postcode
      # Set Suite Variable  ${postcode1}
      # ${address1}=  get_address
      # Set Suite Variable  ${address1}
      ${latti1}  ${longi1}  ${postcode1}  ${city1}  ${district}  ${state}  ${address1}=  get_loc_details
      ${tz}=   db.get_Timezone_by_lat_long   ${latti1}  ${longi1}
      Set Suite Variable  ${tz}
      Set Suite Variable  ${address1}
      Set Suite Variable  ${city1}
      Set Suite Variable  ${latti1}
      Set Suite Variable  ${longi1}
      Set Suite Variable  ${postcode1}
      Set Suite Variable  ${address1}
      ${parking_type1}    Random Element     ['none','free','street','privatelot','valet','paid']
      Set Suite Variable  ${parking_type1}
      ${24hours1}    Random Element    ['True','False']
      Set Suite Variable  ${24hours1}
      ${sTime1}=  add_timezone_time  ${tz}  0  35  
      Set Suite Variable   ${sTime1}
      ${eTime1}=  add_timezone_time  ${tz}  0  30  
      Set Suite Variable   ${eTime1}
      ${list}=  Create List  1  2  3  4  5  6  7
    	Set Suite Variable  ${list}
      ${DAY}=  db.get_date_by_timezone  ${tz}
    	Set Suite Variable  ${DAY}
      ${resp}=  Create Location  ${city1}  ${longi1}  ${latti1}  www.${city1}.com  ${postcode1}  ${address1}  ${parking_type1}  ${24hours1}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      # ${city2}=   get_place
      # Set Suite Variable  ${city2}
      # ${latti2}=  get_latitude
      # Set Suite Variable  ${latti2}
      # ${longi2}=  get_longitude
      # Set Suite Variable  ${longi2}
      # ${postcode2}=  FakerLibrary.postcode
      # Set Suite Variable  ${postcode2}
      # ${address2}=  get_address
      # Set Suite Variable  ${address2}
      ${latti2}  ${longi2}  ${postcode2}  ${city2}  ${district}  ${state}  ${address2}=  get_loc_details
      ${tz2}=   db.get_Timezone_by_lat_long   ${latti2}  ${longi2}
      Set Suite Variable  ${tz2}
      Set Suite Variable  ${city2}
      Set Suite Variable  ${latti2}
      Set Suite Variable  ${longi2}
      Set Suite Variable  ${postcode2}
      Set Suite Variable  ${address2}
      ${parking_type2}    Random Element     ['none','free','street','privatelot','valet','paid']
      Set Suite Variable  ${parking_type2}
      ${24hours2}    Random Element    ['True','False']
      Set Suite Variable   ${24hours2}
      ${d1}=  get_timezone_weekday  ${tz2} 
      ${d1}=  Create List  ${d1}
      Set Suite Variable  ${d1} 
      ${sTime2}=  add_timezone_time  ${tz2}  0  45  
      Set Suite Variable   ${sTime2}
      ${eTime2}=  add_timezone_time  ${tz2}  0  50  
      Set Suite Variable   ${eTime2}
      ${resp}=  Create Location  ${city2}  ${longi2}  ${latti2}  www.${city2}.com  ${postcode2}  ${address2}  ${parking_type2}  ${24hours2}  Once  ${d1}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetLocations-2
	[Documentation]  Get locations by a branch login
      ${iscorp_subdomains}=  get_iscorp_subdomains  1
      Log  ${iscorp_subdomains}
      Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
      Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+450037
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    2
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${MUSERNAME_E}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${MUSERNAME_E}  ${PASSWORD}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${MUSERNAME_E}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${MUSERNAME_E}${\n}
      Set Suite Variable  ${MUSERNAME_E}
      ${uid}=  get_uid  ${MUSERNAME_E}
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
      ${parking_type8}    Random Element     ['none','free','street','privatelot','valet','paid']
      Set Suite Variable  ${parking_type8}
      ${DAY}=  db.get_date_by_timezone  ${tz8}
    	Set Suite Variable  ${DAY}
      ${DAY2}=  db.add_timezone_date  ${tz8}  10  
    	Set Suite Variable  ${DAY2}
	${list}=  Create List  1  2  3  4  5  6  7
    	Set Suite Variable  ${list}
      ${sTime3}=  add_timezone_time  ${tz8}  0  35  
      Set Suite Variable   ${sTime3}
      ${eTime3}=  add_timezone_time  ${tz8}  0  60  
      Set Suite Variable   ${eTime3}
      ${resp}=  Create Location  ${city8}  ${longi8}  ${latti8}  www.${city8}.com  ${postcode8}  ${address1}  ${parking_type8}  ${24hours8}  Weekly  ${list}  ${DAY}  ${DAY2}  ${EMPTY}  ${sTime3}  ${eTime3}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid8}  ${resp.json()}

      # ${city9}=   FakerLibrary.last_name
      # Set Suite Variable  ${city9}
      # ${latti9}=  get_latitude
      # Set Suite Variable  ${latti9}
      # ${longi9}=  get_longitude
      # Set Suite Variable  ${longi9}
      # ${postcode9}=  FakerLibrary.postcode
      # Set Suite Variable  ${postcode9}
      ${latti9}  ${longi9}  ${city9}  ${postcode9}=  get_lat_long_city_pin
      ${tz9}=   db.get_Timezone_by_lat_long   ${latti9}  ${longi9}
      Set Suite Variable  ${tz9}
      Set Suite Variable  ${city9}
      Set Suite Variable  ${latti9}
      Set Suite Variable  ${longi9}
      Set Suite Variable  ${postcode9}
      ${24hours9}    Random Element    ${bool}
      Set Suite Variable  ${24hours9}
      ${parking_type9}    Random Element     ['none','free','street','privatelot','valet','paid']
      Set Suite Variable  ${parking_type9}
      ${DAY}=  db.get_date_by_timezone  ${tz9}
    	Set Suite Variable  ${DAY}
      ${DAY2}=  db.add_timezone_date  ${tz9}  10  
    	Set Suite Variable  ${DAY2}
	${list}=  Create List  1  2  3  4  5  6  7
    	Set Suite Variable  ${list}
      ${sTime4}=  add_timezone_time  ${tz9}  0  35  
      Set Suite Variable   ${sTime4}
      ${eTime4}=  add_timezone_time  ${tz9}  0  60  
      Set Suite Variable   ${eTime4}
      ${resp}=  Create Location  ${city9}  ${longi9}  ${latti9}  www.${city9}.com  ${postcode9}  ${address2}  ${parking_type9}  ${24hours9}  Weekly  ${list}  ${DAY}  ${DAY2}  ${EMPTY}  ${sTime4}  ${eTime4}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid9}  ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  422
      # Should Be Equal As Strings  "${resp.json()}"  "${BRANCH_LOCATION_CREATION_NOT_ALLOWED}"


     
      
JD-TC-GetLocations -UH2
      [Documentation]   Provider create a location without login  
      ${resp}=  Get Locations
      Should Be Equal As Strings    ${resp.status_code}   419
      Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-GetLocations -UH3
      [Documentation]   Consumer create a location
      ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Get Locations
      Should Be Equal As Strings    ${resp.status_code}   401
      Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

      sleep  02s
JD-TC-VerifyGetLocations-1
	[Documentation]  Verify location details by provider login ${PUSERNAME_D}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Locations
      Log  ${resp.json()}
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
      Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['recurringType']}  Weekly
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
      Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['recurringType']}  Once
      Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['repeatIntervals'][0]}  ${d1[0]}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['startDate']}  ${DAY}
      Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['terminator']['endDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime2}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime2}

JD-TC-VerifyGetLocations-2
	[Documentation]  Verify location details by provider login ${PUSERNAME_D}
      ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Locations
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()[0]['place']}  ${city8}
      Should Be Equal As Strings  ${resp.json()[0]['longitude']}  ${longi8}
      Should Be Equal As Strings  ${resp.json()[0]['lattitude']}  ${latti8}
      Should Be Equal As Strings  ${resp.json()[0]['pinCode']}  ${postcode8}
      Should Be Equal As Strings  ${resp.json()[0]['address']}  ${address1}
      Should Be Equal As Strings  ${resp.json()[0]['googleMapUrl']}  www.${city8}.com
      Should Be Equal As Strings  ${resp.json()[0]['status']}  ACTIVE
      Should Be Equal As Strings  ${resp.json()[0]['parkingType']}  ${parking_type8}
      Should Be Equal As Strings  ${resp.json()[0]['open24hours']}  ${24hours8}
      Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['recurringType']}  Weekly
      Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime3}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime3}
      # Should Be Equal As Strings  ${resp.json()[1]['place']}   ${city9}
      # Should Be Equal As Strings  ${resp.json()[1]['longitude']}  ${longi9}
      # Should Be Equal As Strings  ${resp.json()[1]['lattitude']}  ${latti9}
      # Should Be Equal As Strings  ${resp.json()[1]['pinCode']}  ${postcode9}
      # Should Be Equal As Strings  ${resp.json()[1]['address']}  ${address2}
      # Should Be Equal As Strings  ${resp.json()[1]['googleMapUrl']}  www.${city9}.com
      # Should Be Equal As Strings  ${resp.json()[1]['status']}  ACTIVE
      # Should Be Equal As Strings  ${resp.json()[1]['parkingType']}  ${parking_type9}
      # Should Be Equal As Strings  ${resp.json()[1]['open24hours']}  ${24hours9}
      # Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['recurringType']}  Weekly
      # Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
	# Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['startDate']}  ${DAY}
      # Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['terminator']['endDate']}  ${DAY2}
	# Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime4}
	# Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime4}

*** Keywords ***

Multiple Location
      [Arguments]  ${index}  ${business_conf}
      # ${business_conf}=  json.loads  ${business_conf}
      Set Suite Variable  ${dom}  ${business_conf[${index}]['domain']}
      Set Suite Variable  ${sub_dom}  ${business_conf[${index}]['subDomains'][0]['subDomain']}
      RETURN  ${dom}  ${sub_dom}

                                                     

