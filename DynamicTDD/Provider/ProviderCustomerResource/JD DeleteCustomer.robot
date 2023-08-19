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

JD-TC-DeleteCustomer-1
     [Documentation]  Delete a customer with valid customerid and verify its deleted
     ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${dob}=  FakerLibrary.Date
     ${gender}=  Random Element    ${Genderlist}
     ${ph}=  Evaluate  ${PUSERNAME230}+71007
     ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${gender}  ${dob}  ${ph}  ${EMPTY} 
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${customerId}  ${resp.json()}
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph}${\n}
     ${resp}=  DeleteCustomer  ${customerId}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  GetCustomer  firstName-eq=${firstname}  phoneNo-eq=${ph}
     Should Not Contain   ${resp.json()}  "id":"${customerId}"
 
JD-TC-DeleteCustomer-UH1
      [Documentation]  Delete a customer with already deleted customerid
      ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  DeleteCustomer  ${customerId}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${CONSUMER_ALREADY_DEACTIVATED }"
     
JD-TC-DeleteCustomer-UH2
      [Documentation]  Delete a customer with invalid customer id
      ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  DeleteCustomer  0
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${CONSUMER_NOT_FOUND}"

JD-TC-DeleteCustomer-UH3
      [Documentation]  Delete a customer without login
      ${resp}=  DeleteCustomer  ${customerId}
      Should Be Equal As Strings    ${resp.status_code}   419
      Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"
         
JD-TC-DeleteCustomer-UH4
      [Documentation]  Delete a customer with consumer login
      ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  DeleteCustomer  ${customerId}
      Should Be Equal As Strings    ${resp.status_code}   401
      Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
    
    
JD-TC-DeleteCustomer-UH5  
      [Documentation]  Delete a customer after waitlisted in a queue(Here we can't delete the waitlisted customer is in arrived or checkin state customer is in  cancel state we can delete )
      ${resp}=   Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}   200
      clear_location  ${PUSERNAME8}
      clear_queue  ${PUSERNAME8}
      ${resp}=   ProviderKeywords.Get Queues
      Should Be Equal As Strings  ${resp.status_code}  200
      Log   ${resp.json()}
      ${resp} =  Create Sample Queue
      Set Test Variable  ${s_id}  ${resp['service_id']}
      Set Test Variable  ${qid}   ${resp['queue_id']}
      Set Suite Variable   ${lid}   ${resp['location_id']}

      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${ph2}=  Evaluate  ${PUSERNAME1}+71008
      ${gender}=  Random Element    ${Genderlist}
      ${DAY}=  db.get_date_by_timezone  ${tz}
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
      Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[1]}
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

      # ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid}
      # Log   ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # ${resp}=  DeleteCustomer  ${cId}  
      # Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-DeleteCustomer-2
     [Documentation]  Delete a customer with valid customerid and verify its deleted
     ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${ph}=  Evaluate  ${PUSERNAME230}+71006
     ${resp}=  AddCustomer  ${ph}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid}  ${resp.json()}
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph}${\n}
     ${resp}=  DeleteCustomer  ${cid}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  GetCustomer    phoneNo-eq=${ph}
     Should Not Contain   ${resp.json()}  "id":"${customerId}"
 