*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Provider Bill
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***

@{empty_list}

*** Keywords ***



Get Service
    [Arguments]  &{param}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/services  params=${param}  expected_status=any
    [Return]  ${resp}

    
Get Bill Count

    [Arguments]      &{param}
    Check And Create YNW Session
    ${resp}=    Get On Session    ynw    /provider/bill/count      params=${param}   expected_status=any  
    [Return]  ${resp}


*** Test Cases ***

JD-TC-GetBillCount-1

    [Documentation]  Take an online checkin and do thepre payment, then provider verify the get bill count details.

    clear_queue      ${PUSERNAME48}
    clear_location   ${PUSERNAME48}
    clear_service    ${PUSERNAME48}
    clear_customer   ${PUSERNAME48}
    clear_Coupon     ${PUSERNAME48}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    
    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}  

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${description}=  FakerLibrary.sentence
    ${ser_durtn}=   Random Int   min=2   max=10
    ${ser_amount}=   Random Int   min=150   max=1000
    ${ser_amount1}=   Convert To Number   ${ser_amount}
    ${SERVICE1}=    FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE1}   ${description}   ${ser_durtn}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${ser_amount1}  ${bool[0]}   ${bool[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${sid1}  ${resp.json()}

    ${description1}=  FakerLibrary.sentence
    ${ser_durtn1}=   Random Int   min=2   max=10
    ${ser_amount}=   Random Int   min=150   max=1000
    ${ser_amount2}=   Convert To Number   ${ser_amount}
    ${SERVICE2}=    FakerLibrary.word
    ${resp}=  Create Service  ${SERVICE2}   ${description1}   ${ser_durtn1}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${ser_amount2}  ${bool[0]}   ${bool[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${sid2}  ${resp.json()}
    
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${strt_time}=   subtract_timezone_time  ${tz}  1  55
    ${end_time}=    add_timezone_time  ${tz}  4  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20

    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${sid1}  ${sid2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}  
    
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${sid1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['netTotal']}         ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['amountDue']}        ${ser_amount1}   
    Should Be Equal As Strings  ${resp.json()['netRate']}          ${ser_amount1}   
    
    ${resp}=  Update Bill   ${wid}  ${action[12]}    ${cupn_code}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${total_amount}=  Evaluate  ${ser_amount1} - ${amount}
    ${total_amount}=  Convert To Number  ${total_amount}  2

    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['netTotal']}         ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()['amountDue']}        ${total_amount}   
    Should Be Equal As Strings  ${resp.json()['netRate']}          ${total_amount} 
