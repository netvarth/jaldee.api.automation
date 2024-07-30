*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

${waitlistedby}           PROVIDER

*** Test Cases ***    
JD-TC-GetFollowUpDetailsWl-1
    [Documentation]  Get Waitlist followUp

    clear_location    ${PUSERNAME117}
    clear_service     ${PUSERNAME117}
    clear_queue       ${PUSERNAME117} 
    clear_customer    ${PUSERNAME117}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME117}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']} 
    Set Suite Variable  ${businessName}     ${resp.json()['businessName']}

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY} 
    Should Be Equal As Strings  ${resp.status_code}  200
     
    ${PH_Number}    Random Number 	       digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable    ${consumerPhone}  555${PH_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${consumerPhone}${\n}
    ${consumerFirstName}=   FakerLibrary.first_name
    Set Suite Variable      ${consumerFirstName}
    ${consumerLastName}=    FakerLibrary.last_name  
    Set Suite Variable      ${consumerLastName}
    ${dob}=    FakerLibrary.Date
    Set Suite Variable      ${dob}
    ${permanentAddress1}=  FakerLibrary.address
    Set Suite Variable      ${permanentAddress1}
    ${gender}=  Random Element    ${Genderlist}
    Set Suite Variable      ${gender}
    Set Suite Variable  ${consumerEmail}  ${C_Email}${consumerPhone}${consumerFirstName}.${test_mail}

    ${resp}=  AddCustomer  ${consumerPhone}  firstName=${consumerFirstName}   lastName=${consumerLastName}  address=${permanentAddress1}   gender=${gender}  dob=${dob}  email=${consumerEmail}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${consumerPhone}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${cid}   ${resp.json()[0]['id']}
    Set Suite Variable  ${jcid}  ${resp.json()[0]['jaldeeConsumerDetails']['id']}

    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}  
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id2}    ${resp}
    ${resp}=   Get Location ById  ${loc_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${tz2}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${ser_name1}=   FakerLibrary.word
    Set Suite Variable    ${ser_name1} 
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Suite Variable    ${ser_id1}    ${resp}  
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${CUR_DAY}
    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${strt_time}=   db.add_timezone_time  ${tz}  1  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    db.add_timezone_time  ${tz}  3  00 
    Set Suite Variable    ${end_time}  
    ${parallel}=   Random Int  min=1   max=2
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity} 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id2}  ${ser_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}  
    # sleep  2s  
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby}      personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${ser_name1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${cid}

    ${ageyrs}  ${agemonths}=  db.calculate_age_years_months     ${dob}
    Set Suite Variable  ${ageyrs}
    Set Suite Variable  ${agemonths}

    ${resp}=    GetFollowUpDetailsofwl  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${ser_name1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}    ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}     ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['phoneNo']}      ${consumerPhone}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['dob']}          ${dob}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['gender']}       ${gender}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['age']}          ${ageyrs}

JD-TC-GetFollowUpDetailsWl-2

    [Documentation]  Get Waitlist followUp - where waitlist is Cancelled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME117}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${msg}=  Fakerlibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid}  ${waitlist_cancl_reasn[4]}  ${msg}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    GetFollowUpDetailsofwl  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${ser_name1}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}    ${consumerFirstName}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}     ${consumerLastName}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['phoneNo']}      ${consumerPhone}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['dob']}          ${dob}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['gender']}       ${gender}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['age']}          ${ageyrs}


JD-TC-GetFollowUpDetailsWl-UH1

    [Documentation]     Get GetFollowUp Details of appointment where appointment id is invalid
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME117}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     FakerLibrary.Random Int 

    ${resp}=    GetFollowUpDetailsofwl  ${inv}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  ${resp.json()}       ${INVALID_WAITLIST}

JD-TC-GetFollowUpDetailsWl-UH2

    [Documentation]     Get GetFollowUp Details - without login

    ${resp}=    GetFollowUpDetailsofwl  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}       ${SESSION_EXPIRED}

JD-TC-GetFollowUpDetailsWl-UH3

    [Documentation]     Get GetFollowUp Details - consumer login
    
    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    GetFollowUpDetailsofwl  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}       ${NoAccess}


JD-TC-GetFollowUpDetailsWl-UH4

    [Documentation]     Get GetFollowUp Details - with another provider login
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME145}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    GetFollowUpDetailsofwl  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}       ${NO_PERMISSION}

JD-TC-GetFollowUpDetailsWl-UH5

    [Documentation]     Get GetFollowUp Details - with provider consumer login
    
    ${resp}=    Send Otp For Login    ${consumerPhone}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${pid}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${cid}    ${resp.json()['providerConsumer']}
    Set Test Variable    ${PCid}   ${resp.json()['id']}

    ${resp}=    GetFollowUpDetailsofwl  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  400
    Should Be Equal As Strings  ${resp.json()}       ${LOGIN_INVALID_URL}