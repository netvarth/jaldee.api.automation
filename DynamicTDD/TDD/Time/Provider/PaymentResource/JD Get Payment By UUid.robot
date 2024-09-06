*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Payment
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
***Variables***
${a}  30

*** Test Cases ***

JD-TC-Get Payment by UUId -1
    [Documentation]  payment for bill valid provider  correct amount
    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
    
    FOR   ${a}  IN RANGE   ${length}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    ${domain}=   Set Variable    ${decrypted_data['sector']}
    ${subdomain}=    Set Variable      ${decrypted_data['subSector']}
    # ${domain}=   Set Variable    ${resp.json()['sector']}
    # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
    ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${check}  ${resp2.json()['pos']}
    Exit For Loop IF     "${check}" == "True"
    END
    
    clear_location  ${PUSERNAME${a}}
    ${resp}=  Create Sample Queue
    Set Suite Variable  ${qid1}   ${resp['queue_id']}
    Set Suite Variable  ${s_id1}   ${resp['service_id']}
    Set Suite Variable  ${lid}   ${resp['location_id']}
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    
    ${gstper}=  Random Element  ${gstpercentage}
    ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    ${cid}=  get_id  ${CUSERNAME3}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
	${desc}=    FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Set Test Variable  ${amount}  ${resp.json()['amountDue']}
    ${resp}=  Accept Payment  ${wid}  ${payment_modes[0]}  ${amount}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Payment By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['ynwUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  ${payment_modes[0]}
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${amount}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY1}

JD-TC-Get Payment by UUId -UH1
    [Documentation]  Payment by UUId using another provider  
    ${resp}=   Encrypted Provider Login  ${PUSERNAME121}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200    
    ${resp}=  Get Payment By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-Get Payment by UUId -UH2
    [Documentation]  Payment by UUId using consumer
    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${resp}=  Get Payment By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  401   
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"
*** Comments ***    
JD-TC-Get Payment by UUId -2
    change_system_date  1
    [Documentation]   Payment by UUId  using next day
    ${resp}=   Encrypted Provider Login  ${PUSERNAME12}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${resp}=  Get Payment By UUId  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['JDUuid']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[0]['status']}  SUCCESS  
    Should Be Equal As Strings  ${resp.json()[0]['acceptPaymentBy']}  cash
    Should Be Equal As Strings  ${resp.json()[0]['amount']}  ${amount}
    Should Be Equal As Strings  ${resp.json()[0]['paymentOn']}  ${DAY1}
