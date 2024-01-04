*** Settings ***

Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      Queue
Library         Collections
Library         String
Library         json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${SERVICE1}  Makeup  
${SERVICE2}  Hair makeup

*** Test Cases ***

JD-TC-Get Queue By Location Id-1
	[Documentation]  Get Queues by Location Id valid  provider
    ${f_name}=  FakerLibrary.first_name
    ${l_name}=  FakerLibrary.last_name
    ${resp}=    get_mutilocation_domains
    Log   ${resp}
    Set Test Variable   ${sector}        ${resp[0]['domain']}
    Set Test Variable   ${sub_sector}    ${resp[0]['subdomains'][0]}
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}+224456
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME}${\n}   
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=   Account SignUp  ${f_name}  ${l_name}  ${None}   ${sector}   ${sub_sector}  ${PUSERNAME}  ${pkg_id[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${PUSERNAME}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
    ${24hours}    Random Element    ['True','False']
    ${sTime}=  add_timezone_time  ${tz}  1  15  
    Set Suite Variable  ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  1  30  
    Set Suite Variable  ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid1}  ${resp.json()}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable  ${s_id}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}
    ${sTime1}=  add_timezone_time  ${tz}  2  15  
    Set Suite Variable  ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  2  30  
    Set Suite Variable  ${eTime1}
    ${queue_name1}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name1}
    ${resp}=  Create Queue  ${queue_name1}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid1}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id1}  ${resp.json()}
    ${sTime2}=  add_timezone_time  ${tz}  3  15  
    Set Suite Variable  ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz}  3  30  
    Set Suite Variable  ${eTime2}
    ${city1}=   FakerLibrary.state
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
    ${24hours}    Random Element    ['True','False']
    ${resp}=  Create Location  ${city1}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid2}  ${resp.json()}
        
JD-TC-Get Queue By Location Id-UH1
	[Documentation]  Get Queue by Location Id by consumer
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queue Location  ${lid2}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"	
    
JD-TC-Get Queue By Location Id-UH2
	[Documentation]  Get Queues by Location Id without login
    ${resp}=  Get Queue Location  ${lid2}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
    
JD-TC-Get Queue By Location Id-UH3
	[Documentation]  Get Queues by Location Id using another  provider's id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Get Queue Location  ${lid2}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUES_NOT_FOUND_WITH_LOCATION}" 
   
JD-TC-Get Queue By Location Id-UH4
	[Documentation]  Get Queues by Location Id using invalid id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME147}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${resp}=  Get Queue Location  0
    Should Be Equal As Strings  ${resp.status_code}  422 
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUES_NOT_FOUND_WITH_LOCATION}"   
    sleep  04s


JD-TC-Verify Get Queue By Location Id-1
	[Documentation]  Verification of Get Queues by Location Id and Date by valid  provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${sTime3}=  add_timezone_time  ${tz}  4  15  
    ${eTime3}=  add_timezone_time  ${tz}  4  30  
    ${queue_name2}=  FakerLibrary.bs
    ${resp}=  Get Queues
    Log  ${resp.json()}
    ${resp}=  Create Queue  ${queue_name2}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime3}  ${eTime3}  1  5  ${lid2}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id2}  ${resp.json()}
    ${resp}=  Get Queue Location  ${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
        
    Should Be Equal As Strings  ${resp.json()[0]['name']}   ${queue_name1}
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['recurringType']}  Weekly
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()[0]['capacity']}  5
    Should Be Equal As Strings  ${resp.json()[0]['services'][0]['id']}  ${sid}  
    Should Be Equal As Strings  ${resp.json()[0]['services'][1]['id']}  ${s_id1}      
    
    ${resp}=  Get Queue Location  ${lid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['name']}   ${queue_name2}
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['recurringType']}  Weekly
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime3}
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime3}
    Should Be Equal As Strings  ${resp.json()[0]['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()[0]['capacity']}  5
    Should Be Equal As Strings  ${resp.json()[0]['services'][0]['id']}  ${sid}
    Should Be Equal As Strings  ${resp.json()[0]['services'][1]['id']}  ${s_id1}    