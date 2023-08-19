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
${item1}       ITEM1
${itemCode1}   itemCode1
${SERVICE1}    SERVICE1
${queue1}      queue1
@{service_duration}  10  20  30   40   50
${DisplayName1}   item1_DisplayName


*** Test Cases ***

JD-TC-Get Bill By Status -1

    [Documentation]   Get bill Bill by Status for valid provider   Status=New
    clear_Item    ${PUSERNAME1}
    clear_customer   ${PUSERNAME1}
    ${data}=  FakerLibrary.Word
    ${dis}=  FakerLibrary.sentence
    ${notify}    Random Element     ['True','False']  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}
    
    ${GST_num}  ${pan_num}=  db.Generate_gst_number  ${Container_id}
    ${Percentage}    Random Element     [5.0,12.0,18.0,28.0] 
    Set Suite Variable  ${Percentage}
    ${resp}=  Update Tax Percentage  ${Percentage}   ${GST_num} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
   
    # ${resp}=  Create Item   ${item1}  ${data}  ${dis}  500  True  
    ${resp}=  Create Sample Item   ${DisplayName1}   ${item1}  ${itemCode1}  500  ${bool[1]}         
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${itemId}  ${resp.json()}
   
    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}   
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    clear_service       ${PUSERNAME1}
    ${resp}=  Create Service  ${SERVICE1}  ${dis}   ${service_duration[2]}  ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}   0  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${sid1}  ${resp.json()}
    Set Suite Variable  ${sid1}  ${resp.json()}
    ${lid}=  Create Sample Location 
    ${list}=  Create List   1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  0  30  
    ${eTime}=  add_timezone_time  ${tz}  2  00  
    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}  ${s_id1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${resp}=  Add To Waitlist  ${cid}  ${sid1}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${item}=  Item Bill  ${data}  ${itemId}  1
    ${resp}=  Update Bill   ${wid}  addItem   ${item}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By Status  New
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    #${count}=  Get Length  ${resp.json()}
    #Should Be Equal As Strings  ${count}  1

JD-TC-Get Bill By Status -2

    [Documentation]  Get bill Bill by Status for valid provider  Status=Settle
    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  AddCustomer  ${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}   
    ${resp}=  Add To Waitlist  ${cid}  ${sid1}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${item}=  Item Bill  my Item  ${itemId}  1
    ${resp}=  Update Bill   ${wid}  addItem   ${item}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Set Suite Variable  ${amt_due}     ${resp.json()['amountDue']}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Accept Payment   ${wid}    cash   ${amt_due}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  5s
    ${resp}=  Settl Bill  ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By Status  Settled
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    #${count}=  Get Length  ${resp.json()}
    #Should Be Equal As Strings  ${count}  1
    Verify Response  ${resp}   billStatus=Settled
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}   ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${Percentage} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  500.0 
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId}  
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}  ${DisplayName1}  
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['items'][0]['GSTpercentage']}   ${Percentage}

JD-TC-Get Bill By Status -UH1

    [Documentation]  Consumer check to Get Bill By Status
    ${resp}=  ConsumerLogin  ${CUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}  
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Get Bill By Status -UH2  

    [Documentation]   without login to Get Bill By Status 
    ${resp}=  Get Bill By UUId  ${wid}    
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"  

    