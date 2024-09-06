*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Location
Library           Collections
Library           String
Library           json
Library           requests
Library         FakerLibrary
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

${queue1}   Morning queue
${queue2}   Evening queue
${SERVICE1}	   Bridal MakeupW1

*** Test Cases ***
JD-TC-DisableLocation-1
      [Documentation]  Disable a location by provider login and check the corresponding queues are disabled
      ${domresp}=  Get BusinessDomainsConf
      Should Be Equal As Strings  ${domresp.status_code}  200
      ${len}=  Get Length  ${domresp.json()}
      FOR  ${domindex}  IN RANGE  ${len}
            Set Test Variable  ${multi}  ${domresp.json()[${domindex}]['multipleLocation']}
            Run Keyword If  '${multi}'=='True'  Multiple Location  ${domindex}  ${domresp.json()}
      END
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${PUSERNAME_D}=  Evaluate  ${PUSERNAME}+450001
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_D}    1
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${PUSERNAME_D}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${PUSERNAME_D}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_D}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_D}${\n}
      Set Suite Variable  ${PUSERNAME_D}
      ${lid1}=  Create Sample Location
      ${resp}=   Get Location ById  ${lid1}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['timezone']}

      ${DAY}=  db.get_date_by_timezone  ${tz}
    	Set Suite Variable  ${DAY}
      ${DAY2}=  db.add_timezone_date  ${tz}  10  
    	Set Suite Variable  ${DAY2}
	${list1}=  Create List  1  2  3  4
    	Set Suite Variable  ${list1}
      # ${city2}=   FakerLibrary.state
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
      ${parking_type2}    Random Element     ['none','free','street','privatelot','valet','paid']
      Set Suite Variable  ${parking_type2}
      ${24hours2}    Random Element    ['True','False']
      Set Suite Variable   ${24hours2}
      ${sTime2}=  add_timezone_time  ${tz}  2  15  
      Set Suite Variable  ${sTime2}
      ${eTime2}=  add_timezone_time  ${tz}  2  45  
      Set Suite Variable  ${eTime2}
      ${resp}=  Create Location  ${city2}  ${longi2}  ${latti2}  www.${city2}.com  ${postcode2}  ${address2}  ${parking_type2}  ${24hours2}  Weekly  ${list1}  ${DAY}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid}  ${resp.json()}

      ${resp}=   Get Service
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      Set Suite Variable   ${p1_s1}   ${resp.json()[0]['id']}
      Set Suite Variable   ${P1SERVICE1}   ${resp.json()[0]['name']}

      ${sTime1}=  add_timezone_time  ${tz}  2  15  
      Set Suite Variable  ${sTime1}
      ${eTime1}=  add_timezone_time  ${tz}  2  30  
      Set Suite Variable  ${eTime1}
      ${queue_name1}=  FakerLibrary.bs
      Set Suite Variable  ${queue_name1}
      ${resp}=  Create Queue  ${queue_name1}  Weekly  ${list1}  ${DAY}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${p1_s1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${q_id1}  ${resp.json()}

      ${resp}=  Disable Location  ${lid}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-DisableLocation-2
      [Documentation]  Create more queues on a location and disable the location and check the corresponding queues are disabled
      ${domresp}=  Get BusinessDomainsConf
      Should Be Equal As Strings  ${domresp.status_code}  200
      ${len}=  Get Length  ${domresp.json()}
      FOR  ${domindex}  IN RANGE  ${len}
            Set Test Variable  ${multi}  ${domresp.json()[${domindex}]['multipleLocation']}
            Run Keyword If  '${multi}'=='True'  Multiple Location  ${domindex}  ${domresp.json()}
      END
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+450002
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_E}    3
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${PUSERNAME_E}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${PUSERNAME_E}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_E}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_E}${\n}
      Set Suite Variable  ${PUSERNAME_E}
      ${uid}=  get_uid  ${PUSERNAME_E}
      ${lid}=  Create Sample Location
      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['timezone']}

      ${DAY}=  db.get_date_by_timezone  ${tz}
    	Set Suite Variable  ${DAY}
      ${DAY2}=  db.add_timezone_date  ${tz}  10  
    	Set Suite Variable  ${DAY2}
	${list1}=  Create List  1  2  3  4
    	Set Suite Variable  ${list1}
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
      ${resp}=  Create Location  ${city2}  ${longi2}  ${latti2}  www.${city2}.com  ${postcode2}  ${address2}  ${parking_type2}  ${24hours2}  Weekly  ${list1}  ${DAY}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid2}  ${resp.json()}

      
JD-TC-DisableLocation-UH1
      [Documentation]  Disable a location which is already disabled
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Disable Location  ${lid}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${LOCATION_ALREADY_DISABLED}"
   
JD-TC-DisableLocation-UH2
      [Documentation]  Disable a location of another provider
      ${domresp}=  Get BusinessDomainsConf
      Should Be Equal As Strings  ${domresp.status_code}  200

      ${len}=  Get Length  ${domresp.json()}
      FOR  ${domindex}  IN RANGE  ${len}
            Set Test Variable  ${multi}  ${domresp.json()[${domindex}]['multipleLocation']}
            Run Keyword If  '${multi}'=='True'  Multiple Location  ${domindex}  ${domresp.json()}
      END
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${PUSERNAME_G}=  Evaluate  ${PUSERNAME}+450003
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_G}    1
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${PUSERNAME_G}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${PUSERNAME_G}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_G}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_G}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_G}${\n}
      ${lid3}=  Create Sample Location
      Set Suite Variable  ${lid3}
      ${resp}=   Get Location ById  ${lid3}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz3}  ${resp.json()['timezone']}
      ${resp}=   ProviderLogout
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Disable Location  ${lid3}
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"
      
JD-TC-DisableLocation -UH3
       [Documentation]   Provider disable a location without login  
       ${resp}=  Disable Location  ${lid3}
       Should Be Equal As Strings    ${resp.status_code}   419
       Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-DisableLocation -UH5
       [Documentation]   Consumer disable a location
       ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Disable Location  ${lid3}
       Should Be Equal As Strings    ${resp.status_code}   401
       Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-DisableLocation-UH6
      [Documentation]  Disable base location
      ${domresp}=  Get BusinessDomainsConf
      Should Be Equal As Strings  ${domresp.status_code}  200
      ${len}=  Get Length  ${domresp.json()}
      FOR  ${domindex}  IN RANGE  ${len}
            Set Test Variable  ${multi}  ${domresp.json()[${domindex}]['multipleLocation']}
            Run Keyword If  '${multi}'=='True'  Multiple Location  ${domindex}  ${domresp.json()}
      END
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${PUSERNAME_F}=  Evaluate  ${PUSERNAME}+450004
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_F}    1
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${PUSERNAME_F}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${PUSERNAME_F}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_F}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_F}${\n}
      Set Suite Variable  ${PUSERNAME_F}
      ${lid4}=  Create Sample Location
      ${resp}=   Get Location ById  ${lid4}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz4}  ${resp.json()['timezone']}
      ${resp}=  Disable Location  ${lid4}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${BASE_LOCATION_CANNOT_BE_DISABLED}"



JD-TC-DisableLocation-UH7
	[Documentation]  Disable base location by a branch login
      ${iscorp_subdomains}=  get_iscorp_subdomains  1
      Log  ${iscorp_subdomains}
      Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
      Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+450005
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E}    2
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${PUSERNAME_E}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${PUSERNAME_E}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_E}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Log  ${resp.json()}
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
      ${parking8}    Random Element   ${parkingType}
      Set Suite Variable  ${parking8}
      ${24hours8}    Random Element    ${bool}
      Set Suite Variable  ${24hours8}
      ${DAY}=  db.get_date_by_timezone  ${tz}
    	Set Suite Variable  ${DAY}
	${list}=  Create List  1  2  3  4  5  6  7
    	Set Suite Variable  ${list}
      ${sTime}=  add_timezone_time  ${tz}  0  15  
      Set Suite Variable   ${sTime}
      ${eTime}=  add_timezone_time  ${tz}  0  30  
      Set Suite Variable   ${eTime}
      ${lid_A}=  Create Sample Location
      ${resp}=   Get Location ById  ${lid_A}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tzA}  ${resp.json()['timezone']}
      # ${resp}=  Get Locations
      # Log  ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # ${resp}=  Create Location  ${city8}  ${longi8}  ${latti8}  www.${city8}.com  ${postcode8}  ${address2}  ${parking8}  ${24hours8}  Weekly  ${list1}  ${DAY}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}
      # Log  ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Set Suite Variable  ${lid8}  ${resp.json()}


      # ${resp}=  Disable Location  ${lid8}
      # Log  ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Locations
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid8}  ${resp.json()[0]['id']}

      ${resp}=  Disable Location  ${lid8}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${BASE_LOCATION_CANNOT_BE_DISABLED}"
      


JD-TC-VerifyDisableLocation-2
      [Documentation]  Verification of Disable location
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep  04s
      ${s_id}=  Create Sample Service  ${SERVICE1}
      ${sTime3}=  add_timezone_time  ${tz}  0  55  
      ${eTime3}=  add_timezone_time  ${tz}  0  60  
      ${resp}=  Create Queue  ${queue1}  Weekly  ${list1}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid2}  ${s_id}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${q1}  ${resp.json()}
      ${resp}=  Create Queue  ${queue2}  Weekly  ${list1}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime3}  ${eTime3}  1  5  ${lid2}  ${s_id}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${q2}  ${resp.json()}
      ${resp}=  Disable Location  ${lid2}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep  02s
      ${resp}=  Get Queue ById  ${q1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['queueState']}  DISABLED
      ${resp}=  Get Queue ById  ${q2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['queueState']}  DISABLED
      ${resp}=  Get Location ById  ${lid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  status=INACTIVE

JD-TC-VerifyDisableLocation-1
      [Documentation]  Verification of Disable location
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get queues
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()[0]['queueState']}  DISABLED
      ${resp}=  Get Location ById  ${lid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  status=INACTIVE

JD-TC-VerifyDisableLocation-3
      [Documentation]  Verification of Disable location
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      # ${resp}=  Get queues
      # Log  ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Should Be Equal As Strings  ${resp.json()[1]['queueState']}  DISABLED
      ${resp}=  Get Location ById  ${lid8}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  status=ACTIVE

                                                
*** Keywords ***

Multiple Location
      [Arguments]  ${index}  ${business_conf}
      # ${business_conf}=  json.loads  ${business_conf}
      Set Suite Variable  ${dom}  ${business_conf[${index}]['domain']}
      Set Suite Variable  ${sub_dom}  ${business_conf[${index}]['subDomains'][0]['subDomain']}
      RETURN  ${dom}  ${sub_dom}