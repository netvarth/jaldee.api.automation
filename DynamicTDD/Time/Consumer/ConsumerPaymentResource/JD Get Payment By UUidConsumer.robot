*** Settings ***
Suite Teardown    Delete All Sessions  
Test Teardown     Run Keywords   Delete All Sessions  resetsystem_time
Force Tags        Bill
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Test Cases ***

JD-TC-Get Payment by UUId -1

    [Documentation]  payment for bill valid provider  correct amount
    
    change_system_date  -4

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    clear_queue    ${PUSERNAME103}
    clear_service  ${PUSERNAME103}
    clear_customer   ${PUSERNAME103}
    clear_Item   ${PUSERNAME103}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME103}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  18  ${GST_num}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${cid}=  get_id  ${CUSERNAME0}
    # Set Suite Variable  ${cid}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   2  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  500  ${bool[0]}  ${bool[1]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}

    ${SERVICE2}=    FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${SERVICE2}  ${desc}   2  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  500  ${bool[0]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}

    ${SERVICE3}=    FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${SERVICE3}  ${desc}   2  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  500  ${bool[0]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${s_id3}  ${resp.json()}

    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()[0]['id']}

    ${list}=  Create List   1  2  3  4  5  6  7
    ${queue1}=    FakerLibrary.word
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  30  
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  ${capacity}  ${lid}  ${s_id1}  ${s_id2}  ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    
    ${resp}=  AddCustomer  ${CUSERNAME30}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${msg}=  FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${msg}  ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}  netTotal=500.0  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=590.0  billPaymentStatus=${paymentStatus[0]}  totalAmountPaid=0.0  amountDue=590.0  taxableTotal=500.0  totalTaxAmount=90.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  500.0

    ${resp}=  Accept Payment  ${wid}  ${payment_modes[0]}  590  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Payment By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  590.0
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY1}
    
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Payment Details By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  590.0
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY1}   

JD-TC-Get Payment by UUId -2

    [Documentation]   Payment by UUId  using next day

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Payment Details By UUId  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  ${cupnpaymentStatus[0]}  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  590.0
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY1}
    
    