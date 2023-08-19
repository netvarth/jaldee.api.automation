*** Settings ***
Suite Teardown    resetsystem_time
Test Teardown     Delete All Sessions
Force Tags        Bill Status
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
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***

${SERVICE1}   SERVICE1
${item1}  ITEM1
${queue1}  Morning
@{service_duration}  10  20  30   40   50

*** Test Cases ***


JD-TC-Change Bill Status -1

    [Documentation]   check status of a bill after Settl
    clear_Item    ${PUSERNAME14}
    clear_service      ${PUSERNAME14} 
    clear_location   ${PUSERNAME14}
    clear_customer   ${PUSERNAME14}
    ${description}=  FakerLibrary.sentence
    ${des}=  FakerLibrary.Word
    ${notify}    Random Element     ['True','False']
    ${resp}=   ConsumerLogin  ${CUSERNAME9}  ${PASSWORD}
    Log   ${resp.json()}
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${GST_num}   ${PAN_NUM}=  db.Generate_gst_number  ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}   ${GST_num} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    
    # ${resp}=  Create Item   ${item1}  ${des}  ${description}  500  ${bool[1]}    
    # Log  ${resp.status_code}      
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${itemId}  ${resp.json()}
    # Set Suite Variable  ${cid}
    
    ${item1}=     FakerLibrary.word
    ${itemCode1}=     FakerLibrary.word
    ${price1}=     Random Int   min=400   max=500
    ${price}=  Convert To Number  ${price1}  1 
    ${resp}=  Create Sample Item   ${item1}DName   ${item1}  ${itemCode1}  ${price}  ${bool[1]} 
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${itemId}  ${resp.json()}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${service_duration}=   Random Int   min=5   max=10
    Set Suite Variable    ${service_duration}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${SERVICE1}   ${description}   ${service_duration}   ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()}
    ${list}=  Create List   1  2  3  4  5  6  7
    ${longi}=  db.Get Latitude
    ${latti}=  db.Get Longitude
    ${LsTime}=  db.get_time_by_timezone  ${tz}
    ${LeTime}=  add_timezone_time  ${tz}  2  00  
    ${address}=  get_address
    Set Suite Variable  ${address}
    ${postcode}=  FakerLibrary.postcode
    ${hr}    Random Element     ['True','False']
    ${parking}    Random Element     ['none','free','street','privatelot','valet','paid']
    ${url}=   FakerLibrary.url
    ${city}=   fakerLibrary.state
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  ${url}  ${postcode}  ${address}  ${parking}   ${hr}   Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${LsTime}  ${LeTime}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()}
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${sTime}=  db.get_time_by_timezone  ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  2  00  
    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}  ${sid1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${resp}=  AddCustomer  ${CUSERNAME9}   firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}
    ${resp}=  Add To Waitlist  ${cid}  ${sid1}  ${qid1}  ${DAY1}  hi  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${item}=  Item Bill  ${des}  ${itemId}  1
    ${resp}=  Update Bill   ${wid}  ${action[3]}   ${item}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${tax1}=  Evaluate  ${servicecharge}*${gstpercentage[2]}
    ${tax}=   Evaluate  ${tax1}/100
    ${totalamt}=  Evaluate  ${servicecharge}+${tax}
    # ${balamount}=  Evaluate  ${totalamt}-${min_pre1}
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}  billStatus=${billStatus[0]}
    change_system_date  1
    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Accept Payment  ${wid}  ${payment_modes[0]}  ${totalamt}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Settl Bill  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}    
    Should Be Equal As Strings  ${resp.json()['billStatus']}  ${billStatus[1]} 

