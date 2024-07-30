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
Resource          /ebs/TDD/ProviderConsumerKeywords.robot



*** Variables ***

@{empty_list}
${self}         0


*** Test Cases ***

JD-TC-GetBillCount-1

    [Documentation]  Take an online checkin and do the pre payment, then provider verify the get bill count details.

    clear_queue      ${PUSERNAME48}
    clear_location   ${PUSERNAME48}
    clear_service    ${PUSERNAME48}
    clear_customer   ${PUSERNAME48}
    clear_Coupon     ${PUSERNAME48}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=   Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}  

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${description}=  FakerLibrary.sentence
    ${ser_durtn}=   Random Int   min=2   max=10
    ${pre_amount}=   Random Int   min=50   max=100
    ${pre_amount1}=   Convert To Number   ${pre_amount}
    Set Suite Variable   ${pre_amount1}
    ${ser_amount}=   Random Int   min=150   max=1000
    ${ser_amount1}=   Convert To Number   ${ser_amount}
    ${SERVICE1}=    FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE1}   ${description}   ${ser_durtn}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${pre_amount1}  ${ser_amount1}  ${bool[1]}   ${bool[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${sid1}  ${resp.json()}

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${CUR_DAY}
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${strt_time}=   db.subtract_timezone_time  ${tz}  0  15
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20

    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${sid1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}  
    
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()['id']}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${account_id}  ${que_id1}  ${CUR_DAY}  ${sid1}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id  ${wid1}  ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    ${resp}=  Make payment Consumer Mock  ${account_id}  ${pre_amount1}  ${purpose[0]}  ${wid1}  ${sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment Details   account-eq=${account_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}          ${wid1}
    Should Be Equal As Strings  ${resp.json()[0]['status']}           ${cupnpaymentStatus[0]}  
    Should Be Equal As Numbers  ${resp.json()[0]['amount']}           ${pre_amount1}
    Should Contain  ${resp.json()[0]['paymentOn']}                    ${CUR_DAY} 

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Bill By UUId  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Bill Count
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}          1


JD-TC-GetBillCount-2

    [Documentation]  Take an online checkin and do the pre payment, then provider verify the get bill count details with account id filter.

    
    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()['id']}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${account_id}  ${que_id1}  ${CUR_DAY}  ${sid1}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id  ${wid2}  ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    ${resp}=  Make payment Consumer Mock  ${account_id}  ${pre_amount1}  ${purpose[0]}  ${wid2}  ${sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment Details   account-eq=${account_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}          ${wid2}
    Should Be Equal As Strings  ${resp.json()[0]['status']}           ${cupnpaymentStatus[0]}  
    Should Be Equal As Numbers  ${resp.json()[0]['amount']}           ${pre_amount1}
    Should Contain  ${resp.json()[0]['paymentOn']}                    ${CUR_DAY} 

    ${resp}=  ConsumerLogout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Bill By UUId  ${wid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Bill Count
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}          2


    ${resp}=   Get Bill Count   account-eq=${account_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}          2


JD-TC-GetBillCount-3

    [Documentation]  provider consumer Take an online checkin and do the pre payment, 
    ...   then provider verify the get bill count details with account id filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${prov_cons_no}=  Evaluate  ${PUSERNAME0}+30231

    ${resp}=  AddCustomer  ${prov_cons_no}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=    Send Otp For Login    ${prov_cons_no}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${prov_cons_no}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${prov_cons_no}    ${account_id}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${cid1}  ${resp.json()['id']}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${account_id}  ${que_id1}  ${CUR_DAY}  ${sid1}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid3}  ${wid[0]}

    ${resp}=  Get consumer Waitlist By Id  ${wid3}  ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  paymentStatus=${paymentStatus[0]}   waitlistStatus=${wl_status[3]}

    ${resp}=  Make payment Consumer Mock  ${account_id}  ${pre_amount1}  ${purpose[0]}  ${wid3}  ${sid1}  ${bool[0]}   ${bool[1]}  ${cid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Payment Details   account-eq=${account_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}          ${wid3}
    Should Be Equal As Strings  ${resp.json()[0]['status']}           ${cupnpaymentStatus[0]}  
    Should Be Equal As Numbers  ${resp.json()[0]['amount']}           ${pre_amount1}
    Should Contain  ${resp.json()[0]['paymentOn']}                    ${CUR_DAY} 

    ${resp}=  Customer Logout
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Bill By UUId  ${wid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Bill Count
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}          3


    ${resp}=   Get Bill Count   account-eq=${account_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}          3


JD-TC-GetBillCount-4

    [Documentation]  Take an online checkin and do the pre payment, then provider verify the get bill count details with id filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Bill By UUId  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${id1}  ${resp.json()['id']}

    ${resp}=  Get Bill By UUId  ${wid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${id2}  ${resp.json()['id']}

    ${resp}=  Get Bill By UUId  ${wid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${id3}  ${resp.json()['id']}

    ${resp}=   Get Bill Count
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}          3


    ${resp}=   Get Bill Count   id-eq=${id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}    1

    ${resp}=   Get Bill Count   id-eq=${id2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}    1

    ${resp}=   Get Bill Count   id-eq=${id3}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}    1


JD-TC-GetBillCount-5

    [Documentation]  Take an online checkin and do the pre payment, then provider verify the get bill count details with id filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME48}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Get Bill By UUId  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${id1}  ${resp.json()['id']}

    ${resp}=  Get Bill By UUId  ${wid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${id2}  ${resp.json()['id']}

    ${resp}=  Get Bill By UUId  ${wid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${id3}  ${resp.json()['id']}

    ${resp}=   Get Bill Count
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}          3


    ${resp}=   Get Bill Count   id-eq=${id1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}    1

    ${resp}=   Get Bill Count   id-eq=${id2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}    1

    ${resp}=   Get Bill Count   id-eq=${id3}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()}    1