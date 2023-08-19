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

JD-TC-UpdateLocation-1
      [Documentation]  Update a location by provider login without schedule and verify location updated with previous schedule
      ${domresp}=  Get BusinessDomainsConf
      Should Be Equal As Strings  ${domresp.status_code}  200
      ${len}=  Get Length  ${domresp.json()}
      FOR  ${domindex}  IN RANGE  ${len}
            Set Test Variable  ${multi}  ${domresp.json()[${domindex}]['multipleLocation']}
            Run Keyword If  '${multi}'=='True'  Multiple Location  ${domindex}  ${domresp.json()}
      END
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${PUSERNAME_D}=  Evaluate  ${PUSERNAME}+4500115
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_D}    1
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${PUSERNAME_D}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${PUSERNAME_D}  ${PASSWORD}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_D}${\n}
      Set Suite Variable  ${PUSERNAME_D}
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
      ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
      Set Suite Variable  ${parking_type}
      ${24hours}    Random Element    ['True','False']
      Set Suite Variable  ${24hours}
      ${DAY}=  db.get_date_by_timezone  ${tz}
    	Set Suite Variable  ${DAY}
	${list}=  Create List  1  2  3  4  5  6  7
    	Set Suite Variable  ${list}
      ${sTime}=  add_timezone_time  ${tz}  0  15  
      Set Suite Variable   ${sTime}
      ${eTime0}=  add_timezone_time  ${tz}  0  30  
      Set Suite Variable   ${eTime0}
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime0}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid1}  ${resp.json()}
      sleep  02s
      ${resp}=  UpdateBaseLocation  ${lid1}
      Should Be Equal As Strings  ${resp.status_code}  200
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
      ${tz}=   db.get_Timezone_by_lat_long   ${latti2}  ${longi2}
      Set Suite Variable  ${tz}
      ${parking_type1}    Random Element     ['none','free','street','privatelot','valet','paid']
      Set Suite Variable  ${parking_type1}
      ${24hours1}    Random Element    ['True','False']
      Set Suite Variable  ${24hours1}
      ${resp}=  Update Location  ${city1}  ${longi1}  ${latti1}  www.${city1}.com  ${postcode1}  ${address1}  ${parking_type1}  ${24hours1}  ${lid1} 
      Should Be Equal As Strings  ${resp.status_code}  200
      
JD-TC-UpdateLocation-2
      [Documentation]  Update a base location by provider login  with schedule details (Base location has no schedule details)
      ${domresp}=  Get BusinessDomainsConf
      Should Be Equal As Strings  ${domresp.status_code}  200
      ${len}=  Get Length  ${domresp.json()}
      FOR  ${domindex}  IN RANGE  ${len}
            Log  ${len}
            Log  ${domindex}
            Log  ${domresp.json()[0]['multipleLocation']}
            Run Keyword If  ${domresp.json()[${domindex}]['multipleLocation']}=='True'  MultipleLocation  ${domindex}  ${domresp.json()}
      END
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+4500116
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_E}    1
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${PUSERNAME_E}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${PUSERNAME_E}  ${PASSWORD}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_E}${\n}
      Set Suite Variable  ${PUSERNAME_E}
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
      ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
      Set Suite Variable  ${parking_type}
      ${24hours}    Random Element    ['True','False']
      Set Suite Variable  ${24hours}
      ${DAY}=  db.get_date_by_timezone  ${tz}
    	Set Suite Variable  ${DAY}
	${list}=  Create List  1  2  3  4  5  6  7
    	Set Suite Variable  ${list}
      ${sTime2}=  add_timezone_time  ${tz}  0  15  
      Set Suite Variable   ${sTime2}
      ${eTime}=  add_timezone_time  ${tz}  0  30  
      Set Suite Variable   ${eTime}
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid2}  ${resp.json()}
      ${resp}=  UpdateBaseLocation  ${lid2}
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
      ${parking_type2}    Random Element     ['none','free','street','privatelot','valet','paid']
      Set Suite Variable  ${parking_type2}
      ${24hours2}    Random Element    ['True','False']
      Set Suite Variable  ${24hours2}
      ${DAY1}=  db.add_timezone_date  ${tz}  10  
    	Set Suite Variable  ${DAY1}
	${list1}=  Create List  1  2  3  4
    	Set Suite Variable  ${list1}
      ${sTime4}=  add_timezone_time  ${tz}  0  15  
      Set Suite Variable   ${sTime4}
      ${eTime4}=  add_timezone_time  ${tz}  0  30  
      Set Suite Variable   ${eTime4}
      ${resp}=  Update Location with schedule  ${city2}  ${longi2}  ${latti2}  www.${city2}.com  ${postcode2}  ${address2}  ${parking_type2}  ${24hours2}  Weekly  ${list1}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime4}  ${eTime4}   ${lid2} 
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UpdateLocation-3
      [Documentation]  Update a location by changing the location schedule when schedule not exist
      ${domresp}=  Get BusinessDomainsConf
      Should Be Equal As Strings  ${domresp.status_code}  200
      ${len}=  Get Length  ${domresp.json()}
      FOR  ${domindex}  IN RANGE  ${len}
            Run Keyword If  ${domresp.json()[${domindex}]['multipleLocation']}=='True'  MultipleLocation  ${domindex}  ${domresp.json()}
      END
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${PUSERNAME_F}=  Evaluate  ${PUSERNAME}+4500117
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_F}    1
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${PUSERNAME_F}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${PUSERNAME_F}  ${PASSWORD}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_F}${\n}
      Set Suite Variable  ${PUSERNAME_F}
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
      ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
      Set Suite Variable  ${parking_type}
      ${24hours}    Random Element    ['True','False']
      Set Suite Variable  ${24hours}
      ${DAY}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${DAY}
      ${list}=  Create List  1  2  3  4  5  6  7
      Set Suite Variable  ${list}
      ${resp}=  Create Location without schedule  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid3}  ${resp.json()}
      ${city3}=   get_place
      Set Suite Variable  ${city3}
      ${latti3}=  get_latitude
      Set Suite Variable  ${latti3}
      ${longi3}=  get_longitude
      Set Suite Variable  ${longi3}
      ${postcode3}=  FakerLibrary.postcode
      Set Suite Variable  ${postcode3}
      ${address3}=  get_address
      Set Suite Variable  ${address3}
      ${parking_type3}    Random Element     ['none','free','street','privatelot','valet','paid']
      Set Suite Variable  ${parking_type3}
      ${24hours3}    Random Element    ['True','False']
      Set Suite Variable  ${24hours3}
      ${DAY1}=  db.add_timezone_date  ${tz}  10  
    	Set Suite Variable  ${DAY1}
	${list1}=  Create List  1  2  3  4
    	Set Suite Variable  ${list1}
      ${sTime4}=  add_timezone_time  ${tz}  0  15  
      Set Suite Variable   ${sTime4}
      ${eTime4}=  add_timezone_time  ${tz}  0  30  
      Set Suite Variable   ${eTime4}
      ${resp}=  Update Location with schedule  ${city3}  ${longi3}  ${latti3}  www.${city3}.com  ${postcode3}  ${address3}  ${parking_type3}  ${24hours3}  Weekly  ${list1}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime4}  ${eTime4}   ${lid3} 
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UpdateLocation-4
	[Documentation]  Update location by a branch login
      ${iscorp_subdomains}=  get_iscorp_subdomains  1
      Log  ${iscorp_subdomains}
      Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
      Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+4500118
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
      Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
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
      ${DAY}=  db.get_date_by_timezone  ${tz}
    	Set Suite Variable  ${DAY}
      ${DAY2}=  db.add_timezone_date  ${tz}  10  
    	Set Suite Variable  ${DAY2}
	${list}=  Create List  1  2  3  4  5  6  7
    	Set Suite Variable  ${list}
      ${sTime3}=  add_timezone_time  ${tz}  0  35  
      Set Suite Variable   ${sTime3}
      ${eTime3}=  add_timezone_time  ${tz}  0  60  
      Set Suite Variable   ${eTime3}
      ${resp}=  Create Location  ${city8}  ${longi8}  ${latti8}  www.${city8}.com  ${postcode8}  ${address1}  ${parking_type8}  ${24hours8}  Weekly  ${list}  ${DAY}  ${DAY2}  ${EMPTY}  ${sTime3}  ${eTime3}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid8}  ${resp.json()}
      ${city9}=   get_place
      Set Suite Variable  ${city9}
      ${latti9}=  get_latitude
      Set Suite Variable  ${latti9}
      ${longi9}=  get_longitude
      Set Suite Variable  ${longi9}
      ${postcode9}=  FakerLibrary.postcode
      Set Suite Variable  ${postcode9}
      ${address9}=  get_address
      Set Suite Variable  ${address9}
      ${parking_type9}    Random Element     ['none','free','street','privatelot','valet','paid']
      Set Suite Variable  ${parking_type9}
      ${24hours9}    Random Element    ['True','False']
      Set Suite Variable  ${24hours9}
      ${resp}=  Update Location  ${city9}  ${longi9}  ${latti9}  www.${city9}.com  ${postcode9}  ${address9}  ${parking_type9}  ${24hours9}  ${lid8} 
      Should Be Equal As Strings  ${resp.status_code}  200
      
JD-TC-UpdateLocation-UH1
      [Documentation]  Update a location with already created location name
      ${domresp}=  Get BusinessDomainsConf
      Should Be Equal As Strings  ${domresp.status_code}  200
      ${len}=  Get Length  ${domresp.json()}
      ${len}=  Evaluate  ${len}-1
      ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+4500119
      Set Test Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
      ${sublen}=  Get Length  ${domresp.json()[${len}]['subDomains']}
      ${sublen}=  Evaluate  ${sublen}-1
      Set Test Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][${sublen}]['subDomain']} 
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME_A}    1
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${PUSERNAME_A}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_A}${\n}
      Set Suite Variable  ${PUSERNAME_A}
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
      ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
      Set Suite Variable  ${parking_type}
      ${24hours}    Random Element    ['True','False']
      Set Suite Variable  ${24hours}
      ${DAY}=  db.get_date_by_timezone  ${tz}
    	Set Suite Variable  ${DAY}
	${list}=  Create List  1  2  3  4  5  6  7
    	Set Suite Variable  ${list}
      ${sTime7}=  add_timezone_time  ${tz}  0  15  
      Set Suite Variable   ${sTime7}
      ${eTime7}=  add_timezone_time  ${tz}  0  30  
      Set Suite Variable   ${eTime7}
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime7}  ${eTime7}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid4}  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${city6}=   get_place
      Set Suite Variable  ${city6}
      ${latti6}=  get_latitude
      Set Suite Variable  ${latti6}
      ${longi6}=  get_longitude
      Set Suite Variable  ${longi6}
      ${postcode6}=  FakerLibrary.postcode
      Set Suite Variable  ${postcode6}
      ${address6}=  get_address
      Set Suite Variable  ${address6}
      ${parking_type6}    Random Element     ['none','free','street','privatelot','valet','paid']
      Set Suite Variable  ${parking_type6}
      ${24hours6}    Random Element    ['True','False']
      Set Suite Variable  ${24hours6}
      ${resp}=  Create Location  ${city6}  ${longi6}  ${latti6}  www.${city6}.com  ${postcode6}  ${address6}  ${parking_type6}  ${24hours6}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid4}  ${resp.json()}
      ${resp}=  Update Location  ${city}  ${longi6}  ${latti6}  www.${city6}.com  ${postcode6}  ${address6}  ${parking_type6}  ${24hours6}  ${lid4} 
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${LOCATION_EXISTS}"
      

JD-TC-UpdateLocation-5
      [Documentation]  Update a location by changing the location schedule with already existing schedule
      ${domresp}=  Get BusinessDomainsConf
      Should Be Equal As Strings  ${domresp.status_code}  200
      ${len}=  Get Length  ${domresp.json()}
      FOR  ${domindex}  IN RANGE  ${len}
            Set Test Variable  ${multi}  ${domresp.json()[${domindex}]['multipleLocation']}
            Run Keyword If  '${multi}'=='True'  Multiple Location  ${domindex}  ${domresp.json()}
      END
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${PUSERNAME_B}=  Evaluate  ${PUSERNAME}+4500120
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_B}    2
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${PUSERNAME_B}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${PUSERNAME_B}  ${PASSWORD}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_B}${\n}
      Set Suite Variable  ${PUSERNAME_B}
      ${city4}=   get_place
      Set Suite Variable  ${city4}
      ${latti4}=  get_latitude
      Set Suite Variable  ${latti4}
      ${longi4}=  get_longitude
      Set Suite Variable  ${longi4}
      ${postcode4}=  FakerLibrary.postcode
      Set Suite Variable  ${postcode4}
      ${address4}=  get_address
      Set Suite Variable  ${address4}
      ${parking_type4}    Random Element     ['none','free','street','privatelot','valet','paid']
      Set Suite Variable  ${parking_type4}
      ${24hours4}    Random Element    ['True','False']
      Set Suite Variable  ${24hours4}
      ${sTime1}=  add_timezone_time  ${tz}  0  35  
      Set Suite Variable   ${sTime1}
      ${eTime1}=  add_timezone_time  ${tz}  0  30  
      Set Suite Variable   ${eTime1}
      ${resp}=  Create Location  ${city4}  ${longi4}  ${latti4}  www.${city4}.com  ${postcode4}  ${address4}  ${parking_type4}  ${24hours4}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${city5}=   get_place
      Set Suite Variable  ${city5}
      ${latti5}=  get_latitude
      Set Suite Variable  ${latti5}
      ${longi5}=  get_longitude
      
      Set Suite Variable  ${longi5}
      ${postcode5}=  FakerLibrary.postcode
      Set Suite Variable  ${postcode5}
      ${address5}=  get_address
      Set Suite Variable  ${address5}
      ${parking_type5}    Random Element     ['none','free','street','privatelot','valet','paid']
      Set Suite Variable  ${parking_type5}
      ${24hours5}    Random Element    ['True','False']
      Set Suite Variable   ${24hours5}
      ${d1}=  get_timezone_weekday  ${tz} 
      ${d1}=  Create List  ${d1}
      Set Suite Variable  ${d1} 
      ${sTime2}=  add_timezone_time  ${tz}  0  45  
      Set Suite Variable   ${sTime2}
      ${eTime2}=  add_timezone_time  ${tz}  0  50  
      Set Suite Variable   ${eTime2}
      ${resp}=  Create Location  ${city5}  ${longi5}  ${latti5}  www.${city5}.com  ${postcode5}  ${address5}  ${parking_type5}  ${24hours5}  Once  ${d1}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid5}  ${resp.json()}
      
JD-TC-UpdateLocation -UH2
       [Documentation]   Provider Update a location without login  
       ${resp}=  Update Location  Kochi  ${longi}  ${latti}  www.sampleurl.com  680010  Thadathil House  free  True  ${lid1}
       Should Be Equal As Strings    ${resp.status_code}   419
       Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-UpdateLocation -UH3
       [Documentation]   Consumer Update a location
       ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Update Location  Kochi  ${longi}  ${latti}  www.sampleurl.com  680010  Thadathil House  free  True  ${lid1}
       Should Be Equal As Strings    ${resp.status_code}   401
       Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"
      
      sleep  03s
JD-TC-VerifyUpdateLocation-1
      [Documentation]  Verifications of update location case 1
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Location ById  ${lid1}      
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  place=${city1}  longitude=${longi1}  lattitude=${latti1}  pinCode=${postcode1}  address=${address1}   open24hours=${24hours1}  parkingType=${parking_type1}  googleMapUrl=www.${city1}.com  status=ACTIVE
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['recurringType']}  Weekly
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
   	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime0}

JD-TC-VerifyUpdateLocation-2
      [Documentation]  Verifications of update location case 2
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Location ById  ${lid2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  place=${city2}  longitude=${longi2}  lattitude=${latti2}  pinCode=${postcode2}  address=${address2}   open24hours=${24hours2}  parkingType=${parking_type2}  googleMapUrl=www.${city2}.com  status=ACTIVE
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['recurringType']}  Weekly
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['repeatIntervals']}  ${list1}
   	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['startDate']}  ${DAY1}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime4}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime4}

JD-TC-VerifyUpdateLocation-3
      [Documentation]  Verifications of update location case 3
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Location ById  ${lid3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  place=${city3}  longitude=${longi3}  lattitude=${latti3}  pinCode=${postcode3}  address=${address3}   open24hours=${24hours3}  parkingType=${parking_type3}  googleMapUrl=www.${city3}.com  status=ACTIVE
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['recurringType']}  Weekly
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['repeatIntervals']}  ${list1}
   	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['startDate']}  ${DAY1}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime4}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime4}

JD-TC-VerifyUpdateLocation-4
      [Documentation]  Verifications of update location case 4
      ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Location ById  ${lid8}      
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  place=${city9}  longitude=${longi9}  lattitude=${latti9}  pinCode=${postcode9}  address=${address9}   open24hours=${24hours9}  parkingType=${parking_type9}  googleMapUrl=www.${city9}.com  status=ACTIVE
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['recurringType']}  Weekly
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
   	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime3}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime3}

JD-TC-VerifyUpdateLocation-5
      [Documentation]  Verifications of update location case UH2
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Update Location with schedule  ${city5}  ${longi5}  ${latti5}  www.${city5}.com  ${postcode5}  ${address5}  ${parking_type5}  ${24hours5}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${lid5} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Location ById  ${lid5}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  place=${city5}  longitude=${longi5}  lattitude=${latti5}  pinCode=${postcode5}  address=${address5}   open24hours=${24hours5}  parkingType=${parking_type5}  googleMapUrl=www.${city5}.com  status=ACTIVE
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['recurringType']}  Weekly
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
   	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime1}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime1}
     

*** Keywords ***

Multiple Location
      [Arguments]  ${index}  ${business_conf}
      # ${business_conf}=  json.loads  ${business_conf}
      Set Suite Variable  ${dom}  ${business_conf[${index}]['domain']}
      Set Suite Variable  ${sub_dom}  ${business_conf[${index}]['subDomains'][0]['subDomain']}
      [Return]  ${dom}  ${sub_dom}