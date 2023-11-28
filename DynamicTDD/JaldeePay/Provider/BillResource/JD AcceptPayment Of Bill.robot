*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Bill
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           Process
Library           OperatingSystem
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
@{multiples}  10  20  30   40   50
${a}   0
${start}         20

*** Test Cases ***
  
JD-TC-Accept payment of bill -1

    [Documentation]   payment for bill valid provider  correct amount
    ${description}=  FakerLibrary.sentence
    ${resp}=   Billable
    clear_location  ${PUSERNAME_PH}
    clear_customer   ${PUSERNAME_PH}
    ${GST_num}    ${pan_num}=  db.Generate_gst_number  ${Container_id}
    Log   ${GST_num}
    ${resp}=  Update Tax Percentage  18   ${GST_num} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME166}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${notifytype}    Random Element     ['none','pushMsg','email']
    ${notify}    Random Element     ['True','False'] 
    ${SERVICE1}=    FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE1}  ${description}   2  ACTIVE  Waitlist  ${notify}   ${notifytype}  0  500  False  True
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()}
    ${SERVICE2}=    FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE2}  ${description}   2  ACTIVE  Waitlist  ${notify}   ${notifytype}  0  500  False  True
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid2}  ${resp.json()}
    ${SERVICE3}=    FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE3}  ${description}   2  ACTIVE  Waitlist  ${notify}   ${notifytype}  0  500  False  True
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${sid3}  ${resp.json()}
    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List   1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  1  30  
    ${eTime}=  add_timezone_time  ${tz}  3  00  
    ${queue1}=    FakerLibrary.name
    Set Suite Variable    ${queue1}
    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}  ${sid1}  ${sid2}  ${sid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${sid1}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    ${resp}=  Accept Payment  ${wid}  cash  590 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Payment By UUId  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  cash
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  590.0
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY1}

JD-TC-Accept payment of bill -2    

    [Documentation]   payment for Bill multiple time
    ${resp}=  Encrypted Provider Login   ${PUSERNAME_PH}   ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Add To Waitlist  ${cid}  ${sid2}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid} 
    ${resp}=  Accept Payment  ${wid}  other  500  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Payment By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  other
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  500.0
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY1}
    ${resp}=  Accept Payment  ${wid}  cash  90  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Payment By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  other
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  500.0
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()[1]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[1]['status']}  SUCCESS  
    Should Be Equal As Strings  ${resp.json()[1]['acceptPaymentBy']}  cash
    Should Be Equal As Strings  ${resp.json()[1]['amount']}  90.0
    Should Be Equal As Strings  ${resp.json()[1]['paymentOn']}  ${DAY1}
    
JD-TC-Accept payment of bill -3

    [Documentation]  self pay
    ${resp}=  Encrypted Provider Login   ${PUSERNAME_PH}   ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Add To Waitlist  ${cid}  ${sid3}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid3}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    ${resp}=  Accept Payment  ${wid}  self_pay  500  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Payment By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []


JD-TC-Accept payment of bill -UH1

    [Documentation]  payment  amount greater than bill amount
    ${resp}=  Encrypted Provider Login   ${PUSERNAME_PH}   ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
    ${resp}=  AddCustomer  ${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${sid3}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Accept Payment  ${wid}  self_pay  1000  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CANNOT_ACCEPT_PAY_SINCE_AMOUNT_IS_HIGH}"


JD-TC-Accept payment of bill -UH2
    
    [Documentation]   payment for Bill multiple time
    ${resp}=  Encrypted Provider Login   ${PUSERNAME_PH}   ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME9}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
    ${resp}=  AddCustomer  ${CUSERNAME9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${sid3}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Accept Payment  ${wid}  cash  500  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Payment By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  cash
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  500.0
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY1}
    ${resp}=  Accept Payment  ${wid}  cash  500  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CANNOT_ACCEPT_PAY_SINCE_AMOUNT_WILL_BE_GREATER}"

JD-TC-Accept payment of bill -UH4  

    [Documentation]   Consumer check to Accept payment of bill
    ${resp}=   ConsumerLogin  ${CUSERNAME9}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${resp}=  Accept Payment   ${wid}  cash  90  
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 

JD-TC-Accept payment of bill -UH5

    [Documentation]  without login to Accept payment of bill
    ${resp}=  Accept Payment   ${wid}   cash  90  
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-Accept payment of bill -UH6

    [Documentation]   payment for already settled Bill 
    ${resp}=  Encrypted Provider Login   ${PUSERNAME_PH}   ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
    ${resp}=  AddCustomer  ${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${s_id3}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}   
    ${resp}=  Accept Payment  ${wid}  cash  590
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Accept Payment  ${wid}  cash  590 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CANNOT_ACCEPT_PAY}"

JD-TC-Accept payment of bill -UH7

    [Documentation]  Provider accept payment for future
    ${resp}=  Encrypted Provider Login   ${PUSERNAME_PH}   ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
    
    ${DAY2}=  db.add_timezone_date  ${tz}  2  
    ${resp}=  Add To Waitlist  ${cid}  ${sid1}  ${qid1}  ${DAY2}  hi  True  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['netTotal']}  500.0
    ${resp}=  Accept Payment  ${wid}  cash  590  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Payment By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  cash
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  590.0
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY1}


JD-TC-Accept payment of bill -UH8

    [Documentation]   provider pays prepay amount
    ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_queue      ${PUSERNAME25}
    clear_location   ${PUSERNAME25}
    clear_service    ${PUSERNAME25}
    clear waitlist   ${PUSERNAME25}
    ${list}=  Create List   1  2  3  4  5  6  7
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    #${resp}=   Disable Search Data
    #Should Be Equal As Strings    ${resp.status_code}    200
    #clear_queue  ${lic_1_0_PUSERNAME8}
    ${notifytype}    Random Element     ['none','pushMsg','email']
    ${notify}    Random Element     ['True','False'] 
    ${SERVICE4}=    FakerLibrary.name
    ${resp}=  Create Service  ${SERVICE4}  Description   2  ACTIVE  Waitlist  ${notify}   ${notifytype}  200  500  True  True
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${sid4}  ${resp.json()}
    ${resp}=   Create Sample Location
    Set Suite Variable  ${lid}  ${resp}
    ${list}=  Create List   1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  1  30  
    ${eTime}=  add_timezone_time  ${tz}  4  00  
    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}    ${sid4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${resp}=  Get queues
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid}=  get_acc_id  ${PUSERNAME25}
    Set Suite Variable  ${pid}
    #${resp}=   Enable Search Data
   # Log   ${resp.json()}
    #Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ConsumerLogin  ${CUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME7}
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid1}  ${DAY1}  ${sid4}  i need  False  0
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid1[0]}
    sleep  02s
    ${resp}=  Consumer Logout       
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Encrypted Provider Login    ${PUSERNAME25}    ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Bill By UUId  ${wid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid1}
    ${resp}=  Accept Payment  ${wid1}  cash  200
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION_TO_DO}"

*** Keywords ***
Billable

    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
     
    FOR   ${a}  IN RANGE  ${start}   ${length}
            
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Suite Variable  ${PUSERNAME_PH}  ${decrypted_data['primaryPhoneNumber']}
        # Set Suite Variable  ${PUSERNAME_PH}  ${resp.json()['primaryPhoneNumber']}
        clear_location   ${PUSERNAME${a}}
        ${acc_id}=  get_acc_id  ${PUSERNAME${a}}
        Set Suite Variable   ${acc_id}
        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}
        ${resp}=   Get Active License
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=   Get Queues
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=   Get Service
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  View Waitlist Settings
	    Run Keyword If  ${resp.json()['filterByDept']}==${bool[1]}   Toggle Department Disable  
        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}    200
        delete_donation_service  ${PUSERNAME${a}}
        Set Suite Variable  ${check}    ${resp2.json()['serviceBillable']} 
        Run Keyword IF   '${check}' == 'True'   clear_service       ${PUSERNAME${a}}
        Exit For Loop IF     '${check}' == 'True'

    END  