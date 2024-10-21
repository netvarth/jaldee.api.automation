*** Settings ***

Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      Queue
Library         Collections
Library         String
Library         json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
*** Variables ***
${SERVICE1}  Makeup  
${SERVICE2}  Hair makeup

*** Test Cases ***

JD-TC-Get Queue By Location Id-1
	[Documentation]  Get Queues by Location Id valid  provider
  
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
    
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
    ${24hours}    Random Element    ['True','False']
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${sTime}=  add_timezone_time  ${tz}  1  15  
    Set Suite Variable  ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  1  30  
    Set Suite Variable  ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}    ${postcode}  ${address}  
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

    ${latti}  ${longi}  ${postcode}  ${city1}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz1}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz1}
    ${sTime2}=  add_timezone_time  ${tz1}  3  15  
    Set Suite Variable  ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz1}  3  30  
    Set Suite Variable  ${eTime2}
    ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
    ${24hours}    Random Element    ['True','False']

    ${resp}=  Create Location  ${city1}  ${longi}  ${latti}   ${postcode}  ${address}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid2}  ${resp.json()}

    ${resp}=  Get Queue Location  ${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${lid1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}   ${queue_name1}
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['recurringType']}  Weekly
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()[0]['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()[0]['capacity']}  5
    Should Be Equal As Strings  ${resp.json()[0]['services'][0]['id']}  ${s_id}  
    Should Be Equal As Strings  ${resp.json()[0]['services'][1]['id']}  ${s_id1}  

        
JD-TC-Get Queue By Location Id-UH1
	[Documentation]  Get Queue by Location Id by provider consumer
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${account_id}=  get_acc_id  ${HLPUSERNAME4}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}

    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Send Otp For Login    ${PCPHONENO}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}
   
    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

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
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Get Queue Location  ${lid2}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}" 
   
JD-TC-Get Queue By Location Id-UH4
	[Documentation]  Get Queues by Location Id using invalid id
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME12}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${resp}=  Get Queue Location  0
    Should Be Equal As Strings  ${resp.status_code}  422 
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUES_NOT_FOUND_WITH_LOCATION}"   

JD-TC-Verify Get Queue By Location Id-1
	[Documentation]  Verification of Get Queues by Location Id and Date by valid  provider
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME12}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${sTime3}=  add_timezone_time  ${tz1}  4  15  
    ${eTime3}=  add_timezone_time  ${tz1}  4  30  
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