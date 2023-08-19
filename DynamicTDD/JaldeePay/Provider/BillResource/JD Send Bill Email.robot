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
${SERVICE1}   CONSULTATON1
${SERVICE2}   CONSULTATON2
${SERVICE3}   CONSULTATON3
${queue1}  QUEUE1
${CUSERPH}   1234567890
@{service_duration}  10  20  30   40   50
*** Test Cases ***

JD-TC-Send Bill Email -1

    [Documentation]  Create bill and sent Email
    clear_service       ${PUSERNAME166}
    clear_customer   ${PUSERNAME166}
    ${data}=  FakerLibrary.Word
    ${dis}=  FakerLibrary.sentence
    ${reason}=  FakerLibrary.Word
    ${resp}=  ProviderLogin  ${PUSERNAME166}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${GST_num}  ${pan_num}=  db.Generate_gst_number  ${Container_id}
    ${Percentage}    Random Element     [5.0,12.0,18.0,28.0] 
    Set Suite Variable  ${Percentage}
    ${resp}=  Update Tax Percentage  ${Percentage}   ${GST_num} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    Set Suite Variable  ${email}  ${firstname}${CUSERNAME7}${C_Email}.ynwtest@netvarth.com
    ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email}  ${gender}  ${dob}  ${CUSERNAME7}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}
     
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    #${dis}   ${service_duration[2]}  ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}   0  500  ${bool[0]}  ${bool[1]}
    ${resp}=  Create Service  ${SERVICE1}   ${dis}   ${service_duration[2]}  ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}    0   500   ${bool[0]}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE2}   ${dis}   2  ACTIVE  Waitlist   True   email   0  500  False  True
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid2}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE3}   ${dis}   2  ACTIVE  Waitlist   True   email   0  500  False  True
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${sid3}  ${resp.json()}
    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
    ${list}=  Create List   1  2  3  4  5  6  7
    ${sTime}=  add_time  0  30
    ${eTime}=  add_time   2  00 
    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}  ${sid1}  ${sid2}  ${sid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${resp}=  Add To Waitlist  ${cid}  ${sid1}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid}   
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid}
    Log  ${resp.json()}
    Set Suite Variable  ${amt_due}   ${resp.json()['amountDue']}
    ${resp}=  Send Bill Email  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200    

JD-TC-Send Bill Email -2

    [Documentation]   Update bill and send email
    ${reason}=  FakerLibrary.Word
    ${resp}=  ProviderLogin  ${PUSERNAME166}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${service}=  Service Bill  ${reason}  ${sid2}  1 
    ${resp}=  Update Bill   ${wid}  addService   ${service}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Send Bill Email  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Send Bill Email -3
    
    [Documentation]   Accept payment and sent mail
    ${resp}=  ProviderLogin  ${PUSERNAME166}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Accept Payment  ${wid}   cash   ${amt_due}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Send Bill Email  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Send Bill Email -4

    [Documentation]   Change status and sent mail
    ${resp}=  ProviderLogin  ${PUSERNAME166}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ptype}    Random Element     ['other','cash','self_pay']
    ${resp}=  Accept Payment  ${wid}   cash   ${amt_due} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Settl Bill   ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Send Bill Email  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Send Bill Email -UH1

    [Documentation]  Create bill AND  Send Bill To consumer do not  have  Email 
    ${CUSERNAME}=  Evaluate  ${CUSERNAME}+112
    Set Global Variable  ${CUSERNAME}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${businessname}=  FakerLibrary.address
    ${bod}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${businessname}  ${CUSERNAME}  ${EMPTY}  ${bod}  ${gender}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERNAME}  1
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERNAME}  ${PASSWORD}  1
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERNAME}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERNAME}${\n}
    ${resp}=  ProviderLogin  ${PUSERNAME166}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
    ${resp}=  AddCustomer  ${CUSERNAME}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}   
    ${resp}=  Add To Waitlist  ${cid}  ${sid1}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid1}   
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uuid']}  ${wid1}   
    ${resp}=  Send Bill Email  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${CONSUMER_DOESNT_HAVE_AN_EMAIL_ID}"

JD-TC-Send Bill Email -UH2

    [Documentation]   Send Bill Email using another providres uuid
    ${resp}=  ProviderLogin  ${PUSERNAME8}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Send Bill Email  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  403
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

JD-TC-Send Bill Email -UH3
    
    [Documentation]   Send Bill Email using  without login
    ${resp}=  Send Bill Email  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-Send Bill Email -UH4

    [Documentation]   Send Bill Email using consumer
    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Send Bill Email  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 