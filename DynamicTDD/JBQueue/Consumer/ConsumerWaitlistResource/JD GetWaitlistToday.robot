*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${SERVICE1}    SERVICE1
${SERVICE2}    SERVICE2
${self}        0

*** Keywords ***

Get Waitlist Consumer Today

    [Arguments]    &{kwargs}
    Check And Create YNW Session
    ${cons_headers}=  Create Dictionary  &{headers} 
    ${cons_params}=  Create Dictionary
    ${tzheaders}  ${kwargs}  ${locparam}=  db.Set_TZ_Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${kwargs}   &{locparam}
    ${resp}=  GET On Session  ynw  /consumer/waitlist/today  params=${kwargs}   expected_status=any   headers=${cons_headers}
    Check Deprication  ${resp}  Get Waitlist Consumer Today
    RETURN  ${resp}


*** Test Cases ***
JD-TC-Get waitlist Today count-1

	[Documentation]  Add To Waitlist By Consumer valid  provider
    
    # clear_service   ${HLPUSERNAME9}
    # clear_location   ${HLPUSERNAME9}
    # clear_queue     ${HLPUSERNAME9}
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME9}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid}=  get_acc_id  ${HLPUSERNAME9}
    Set Suite Variable  ${pid} 

    ${lid1}=   Create Sample Location
    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    
    ${sId_1}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${sId_1}
    ${sId_2}=   Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${sId_2}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY}
    ${q_name1}=    FakerLibrary.name
    Set Suite Variable    ${q_name1}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${strt_time}=   db.subtract_timezone_time  ${tz}  3  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}  0  10   
    Set Suite Variable    ${end_time}  
    ${capacity}=  Random Int  min=8   max=20
    ${parallel}=  Random Int   min=1   max=2
    Set Suite Variable   ${parallel}
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid1}  ${sId_1}  ${sId_2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q1_l1}   ${resp.json()}
    ${q_name2}=    FakerLibrary.name
    Set Suite Variable    ${q_name2}
    ${strt_time1}=   add_timezone_time  ${tz}  0  10  
    Set Suite Variable    ${strt_time1}
    ${end_time1}=    add_timezone_time  ${tz}  0  29   
    Set Suite Variable    ${end_time1}
    ${resp}=  Create Queue    ${q_name2}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${strt_time1}  ${end_time1}   ${parallel}   ${capacity}    ${lid1}  ${sId_1}  ${sId_2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q2_l1}   ${resp.json()}
    ${list}=  UpdateBaseLocation  ${lid1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${duration}=   Random Int  min=2  max=10
    Set Suite Variable   ${duration}  
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${Empty}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${resp}=  Get Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${CUSERNAME20}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${CUSERNAME20}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME20}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable   ${cid}   ${resp.json()['id']}

    ${cnote}=   FakerLibrary.word
    Set Suite Variable   ${cnote}
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid}  ${q1_l1}  ${DAY}  ${sId_1}  ${cnote}  ${bool[0]}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid1}  ${wid[0]}
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid}  ${q1_l1}  ${DAY}  ${sId_2}  ${cnote}  ${bool[0]}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid2}  ${wid[0]}
    ${resp}=  Add To Waitlist Consumers  ${cid}  ${pid}  ${q2_l1}  ${DAY}  ${sId_1}  ${cnote}  ${bool[0]}  ${self}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid3}  ${wid[0]}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable   ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname}
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${f1}   ${resp.json()}
    ${resp}=  Add To Waitlist Consumers  ${f1}  ${pid}  ${q1_l1}  ${DAY}  ${sId_2}  ${cnote}  ${bool[0]}  ${f1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME9}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${uuid1}
    Should Be Equal As Strings  ${resp.status_code}  200       

JD-TC-Get waitlist Today count-2

	[Documentation]  Get Waitlist Today
    
    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME20}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Waitlist Consumer Today
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
 
JD-TC-Get waitlist Today count-3

	[Documentation]  Get Waitlist today after rescheduling one of the waitlist

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME9}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action multiple account  ${waitlist_actions[4]}    ${uuid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${DAY3}=  db.add_timezone_date  ${tz}  4

    # ${resp}=  Reschedule Consumer Checkin   ${uuid1}  ${DAY3}  ${q1_l1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Get Waitlist Consumer Today
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
 
JD-TC-Get waitlist Today count-4

	[Documentation]  Get Waitlist today without login

    ${resp}=  Get Waitlist Consumer Today
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}     419
    Should Be Equal As Strings  ${resp.json()}          ${SESSION_EXPIRED}
    