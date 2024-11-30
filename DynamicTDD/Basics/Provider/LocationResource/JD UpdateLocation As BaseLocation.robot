*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Location
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
# Suite Setup     Run Keyword  clear_location  ${PUSERNAME8}

*** Test Cases ***

JD-TC-UpdateBaseLocation-1
      [Documentation]  Update a base location by provider login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${base_lid}  ${resp.json()[0]['id']}  
      
      ${latti}  ${longi}  ${postcode}  ${city}  ${address}=  get_random_location_data
      ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
      ${DAY}=  db.get_date_by_timezone  ${tz}
      ${list}=  Create List  1  2  3  4  5  6  7
      ${stime}=  add_timezone_time  ${tz}  0  15  
      ${etime}=  add_timezone_time  ${tz}  0  30  
      ${bs}=  TimeSpec  Weekly  ${list}  ${DAY}  ${EMPTY}  ${stime}  ${etime}
      ${bs}=  Create List  ${bs}
      ${bs}=  Create Dictionary  timespec=${bs}
      ${url}=   FakerLibrary.url
      ${resp}=  Create Location   ${city}  ${longi}  ${latti}  ${postcode}  ${address}  bSchedule=${bs}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid1}  ${resp.json()}

      ${resp}=  UpdateBaseLocation  ${lid1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()[0]['id']}  ${base_lid}  
      Should Be Equal As Strings  ${resp.json()[0]['baseLocation']}  ${bool[0]}    

      Should Be Equal As Strings  ${resp.json()[1]['id']}  ${lid1}
      Should Be Equal As Strings  ${resp.json()[1]['baseLocation']}  ${bool[1]}

JD-TC-UpdateBaseLocation-2

	[Documentation]  Create 2nd  locations and set 2nd location as base location by provider login
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${latti}  ${longi}  ${postcode}  ${city}  ${address}=  get_random_location_data
      ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
      ${DAY}=  db.get_date_by_timezone  ${tz}
      ${list}=  Create List  1  2  3  4  5  6  7
      ${stime}=  add_timezone_time  ${tz}  0  15  
      ${etime}=  add_timezone_time  ${tz}  0  30  
      ${bs}=  TimeSpec  Weekly  ${list}  ${DAY}  ${EMPTY}  ${stime}  ${etime}
      ${bs}=  Create List  ${bs}
      ${bs}=  Create Dictionary  timespec=${bs}
      ${url}=   FakerLibrary.url
      ${resp}=  Create Location   ${city}  ${longi}  ${latti}  ${postcode}  ${address}  bSchedule=${bs}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid2}  ${resp.json()}

      ${resp}=  UpdateBaseLocation  ${lid2}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()[0]['id']}  ${base_lid}  
      Should Be Equal As Strings  ${resp.json()[0]['baseLocation']}  ${bool[0]}    

      Should Be Equal As Strings  ${resp.json()[1]['id']}  ${lid1}
      Should Be Equal As Strings  ${resp.json()[1]['baseLocation']}  ${bool[0]}

      Should Be Equal As Strings  ${resp.json()[2]['id']}  ${lid2}
      Should Be Equal As Strings  ${resp.json()[2]['baseLocation']}  ${bool[1]}
      
       
JD-TC-UpdateBaseLocation-UH1
      [Documentation]  Consumer update a base location
      ${account_id}=    get_acc_id       ${PUSERNAME8}

      ${primaryMobileNo}  ${token}  Create Sample Customer  ${account_id}  primaryMobileNo=${CUSERNAME1}

      ${resp}=    ProviderConsumer Login with token   ${CUSERNAME1}  ${account_id}  ${token} 
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${resp}=  UpdateBaseLocation  ${base_lid} 
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"
       
JD-TC-UpdateBaseLocation-UH2
	[Documentation]  Update a base location without login   
	${resp}=  UpdateBaseLocation  ${base_lid}    
      Should Be Equal As Strings    ${resp.status_code}   419
      Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}
       
JD-TC-UpdateBaseLocation-UH3
      [Documentation]  Update a base location by provider login using another providers location id
      ${resp}=  Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200    
      ${resp}=  UpdateBaseLocation  ${base_lid}   
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"   
      
JD-TC-UpdateBaseLocation-UH4
      [Documentation]  Update a base location by provider login invalid location id
      ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200   
      ${invalid_lid}=     Random Int  min=1000   max=9999
      ${resp}=  UpdateBaseLocation  ${invalid_lid}   
      Should Be Equal As Strings    ${resp.status_code}   422
      Should Be Equal As Strings   ${resp.json()}   ${NO_LOCATION_FOUND}  


