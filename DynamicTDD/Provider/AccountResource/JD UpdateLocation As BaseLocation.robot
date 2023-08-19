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
Suite Setup     Run Keyword  clear_location  ${PUSERNAME8}

*** Test Cases ***

JD-TC-UpdateBaseLocation-1
      [Documentation]  Update a base location by provider login
      ${resp}=  ProviderLogin  ${PUSERNAME8}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${city}=   get_place
      Set Suite Variable  ${city}
      ${latti}=  get_latitude
      Set Suite Variable  ${latti}
      ${longi}=  get_longitude
      Set Suite Variable  ${longi}
      ${postcode}=  FakerLibrary.postcode
      Set Suite Variable  ${postcode}
      ${address}=  get_address
      Set Suite Variable  ${address}
      ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
      Set Suite Variable  ${parking_type}
      ${24hours}    Random Element    ['True','False']
      Set Suite Variable  ${24hours}
      ${DAY}=  get_date
    	Set Suite Variable  ${DAY}
	${list}=  Create List  1  2  3  4  5  6  7
    	Set Suite Variable  ${list}
      ${sTime}=  add_time  0  15
      Set Suite Variable   ${sTime}
      ${eTime}=  add_time   0  30
      Set Suite Variable   ${eTime}
      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid}  ${resp.json()}

JD-TC-UpdateBaseLocation-2

	[Documentation]  Create 2nd  locations and set 2nd location as base location by provider login
      ${domresp}=  Get BusinessDomainsConf
      Should Be Equal As Strings  ${domresp.status_code}  200
      ${len}=  Get Length  ${domresp.json()}
      FOR  ${domindex}  IN RANGE  ${len}
            Set Test Variable  ${multi}  ${domresp.json()[${domindex}]['multipleLocation']}
            Run Keyword If  '${multi}'=='True'  Multiple Location  ${domindex}  ${domresp.json()}
      END
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${PUSERNAME_D}=  Evaluate  ${PUSERNAME}+4400089
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_D}    1
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${PUSERNAME_D}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${PUSERNAME_D}  ${PASSWORD}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Provider Login  ${PUSERNAME_D}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_D}${\n}
      Set Suite Variable  ${PUSERNAME_D}
      ${city1}=   FakerLibrary.state
      Set Suite Variable  ${city1}
      ${latti1}=  get_latitude
      Set Suite Variable  ${latti1}
      ${longi1}=  get_longitude
      Set Suite Variable  ${longi1}
      ${postcode1}=  FakerLibrary.postcode
      Set Suite Variable  ${postcode1}
      ${address1}=  get_address
      Set Suite Variable  ${address1}
      ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
      Set Suite Variable  ${parking_type}
      ${24hours1}    Random Element    ${bool}
      Set Suite Variable  ${24hours1}
      ${sTime1}=  add_time  0  35
      Set Suite Variable   ${sTime1}
      ${eTime1}=  add_time   0  40
      Set Suite Variable   ${eTime1}
      ${resp}=  Create Location  ${city1}  ${longi1}  ${latti1}  www.${city1}.com  ${postcode1}  ${address1}  ${parking_type}  ${24hours1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${city2}=   FakerLibrary.last_name
      Set Suite Variable  ${city2}
      ${latti2}=  get_latitude
      Set Suite Variable  ${latti2}
      ${longi2}=  get_longitude
      Set Suite Variable  ${longi2}
      ${postcode2}=  FakerLibrary.postcode
      Set Suite Variable  ${postcode2}
      ${address2}=  get_address
      Set Suite Variable  ${address2}
      ${parking_type2}    Random Element     ['none','free','street','privatelot','valet','paid']
      Set Suite Variable  ${parking_type2}
      ${24hours2}    Random Element    ${bool}
      Set Suite Variable   ${24hours2}
     # ${d1}=  get_weekday 
     # ${d1}=  Create List  ${d1}
     # Set Suite Variable  ${d1} 
      ${sTime2}=  add_time  0  45
      Set Suite Variable   ${sTime2}
      ${eTime2}=  add_time   0  50
      Set Suite Variable   ${eTime2}
      ${resp}=  Create Location  ${city2}  ${longi2}  ${latti2}  www.${city2}.com  ${postcode2}  ${address2}  ${parking_type2}  ${24hours2}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid2}  ${resp.json()}
      ${resp}=  UpdateBaseLocation  ${lid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}

JD-TC-VerifyUpdateBaseLocation-3
	[Documentation]  Verify location details by provider login ${PUSERNAME_D}
      ${resp}=  ProviderLogin    ${PUSERNAME_D}   ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  UpdateBaseLocation  ${lid2} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Business Profile
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['baseLocation']['id']}  ${lid2}
      ${resp}=  Get Location ById  ${lid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  baseLocation=True
       

    
JD-TC-UpdateBaseLocation-UH1
      [Documentation]  Consumer update a base location
      ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  UpdateBaseLocation  ${lid} 
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"
       
JD-TC-UpdateBaseLocation-UH2
	[Documentation]  Update a base location without login   
	${resp}=  UpdateBaseLocation  ${lid}    
      Should Be Equal As Strings    ${resp.status_code}   419
      Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}
       
JD-TC-UpdateBaseLocation-UH3
      [Documentation]  Update a base location by provider login using another providers  location id
      ${resp}=  ProviderLogin  ${PUSERNAME7}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200    
      ${resp}=  UpdateBaseLocation  ${lid}   
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"   
      
JD-TC-UpdateBaseLocation-UH4
      [Documentation]  Update a base location by provider login invalid location id
      ${resp}=  ProviderLogin  ${PUSERNAME8}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200   
      ${resp}=  UpdateBaseLocation  0    
      Should Be Equal As Strings    ${resp.status_code}   422
      Should Be Equal As Strings   ${resp.json()}   ${NO_LOCATION_FOUND}  

JD-TC-VerifyUpdateBaseLocation-1
	[Documentation]  Verify location details by provider login ${PUSERNAME8}
      ${resp}=  ProviderLogin  ${PUSERNAME8}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  UpdateBaseLocation  ${lid} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Business Profile
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['baseLocation']['id']}  ${lid}
      ${resp}=  Get Location ById  ${lid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  baseLocation=True
       
       
       
*** Keywords ***

Multiple Location
      [Arguments]  ${index}  ${business_conf}
      # ${business_conf}=  json.loads  ${business_conf}
      Set Suite Variable  ${dom}  ${business_conf[${index}]['domain']}
      Set Suite Variable  ${sub_dom}  ${business_conf[${index}]['subDomains'][0]['subDomain']}
      [Return]  ${dom}  ${sub_dom}
