***Settings***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Customer
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Variables***
${self}        0

*** Test Cases ***

JD-TC-ActivateCustomer-1
     [Documentation]  Activate a deleted customer
     ${resp}=  ProviderLogin  ${PUSERNAME101}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${dob}=  FakerLibrary.Date
     ${gender}=  Random Element    ${Genderlist}
     ${ph}=  Evaluate  ${PUSERNAME230}+1424
     ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${gender}  ${dob}  ${ph}  ${EMPTY} 
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${customerId}  ${resp.json()}
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph}${\n}
     ${resp}=  DeleteCustomer  ${customerId}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  GetCustomer  firstName-eq=${firstname}  phoneNo-eq=${ph}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Not Contain   ${resp.json()}  "id":"${customerId}"
     ${resp}=  ActivateCustomer  ${customerId}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  GetCustomer ById  ${customerId}
     Should Be Equal As Strings  ${resp.status_code}  200
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response   ${resp}    firstName=${firstname}  lastName=${lastname}  phoneNo=${ph}  dob=${dob}  gender=${gender}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${customerId}  favourite=${bool[0]}
      
 
JD-TC-ActivateCustomer-UH1
      [Documentation]  Again Activate a activated customer 
      ${resp}=  ProviderLogin  ${PUSERNAME101}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ActivateCustomer  ${customerId}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${CONSUMER_ALREADY_ACTIVATED}"
     
JD-TC-ActivateCustomer-UH2
      [Documentation]  Activate a customer with invalid customer id
      ${resp}=  ProviderLogin  ${PUSERNAME101}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ActivateCustomer  0
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${CONSUMER_NOT_FOUND}"

JD-TC-ActivateCustomer-UH3
      [Documentation]  Activate a customer without login
      ${resp}=  ActivateCustomer  ${customerId}
      Should Be Equal As Strings    ${resp.status_code}   419
      Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"
         
JD-TC-ActivateCustomer-UH4
      [Documentation]  Activate a customer with consumer login
      ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  ActivateCustomer  ${customerId}
      Should Be Equal As Strings    ${resp.status_code}   401
      Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
    
    
JD-TC-ActivateCustomer-2  
      [Documentation]  Adding a customer to waitlist after activate customer
      ${resp}=   ProviderLogin  ${PUSERNAME174}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}   200
      clear_location  ${PUSERNAME174}
      clear_queue  ${PUSERNAME174}
      ${resp}=   ProviderKeywords.Get Queues
      Should Be Equal As Strings  ${resp.status_code}  200
      Log   ${resp.json()}
      ${resp}=  Create Sample Queue
      Set Test Variable  ${s_id}  ${resp['service_id']}
      Set Test Variable  ${qid}   ${resp['queue_id']}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${ph2}=  Evaluate  ${PUSERNAME1}+1587
      ${gender}=  Random Element    ${Genderlist}
      ${DAY}=  get_date
      ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${gender}  ${dob}   ${ph2}  ${EMPTY} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cId}  ${resp.json()}
      Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph2}${\n}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cId}  ${s_id}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${cId} 
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY}  waitlistStatus=arrived
      ${resp}=  DeleteCustomer  ${cId}  
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${CANNOT_DEL_CUSTOMER}"
      ${resp}=  GetCustomer  firstName-eq=${firstname}  phoneNo-eq=${ph2}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response List  ${resp}  0  firstName=${firstname}  lastName=${lastname}  phoneNo=${ph2}  dob=${dob}  gender=${gender}
      ${desc}=   FakerLibrary.word
      ${resp}=  Waitlist Action Cancel  ${wid}  ${waitlist_cancl_reasn[4]}   ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist State Changes  ${wid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  DeleteCustomer  ${cId}  
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  ActivateCustomer  ${cId}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cId}  ${s_id}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${cId} 
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[1]}

