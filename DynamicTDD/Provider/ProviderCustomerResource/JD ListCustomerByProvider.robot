*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        ListCustomer
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 


*** Test Cases ***
      
JD-TC-ListCustomerByProvider-1
      [Documentation]    List a Customer details by provider login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${pid}  ${resp.json()['id']}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${ph2}=  Evaluate  ${PUSERNAME23}+73003
      Set Suite Variable  ${email2}  ${firstname}${ph2}${C_Email}.ynwtest@netvarth.com
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${CUSERNAME18}  ${EMPTY}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${pcid}  ${resp.json()}
      # Log  ${resp.json()}
      Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERNAME18}${\n}
      ${resp}=  GetCustomer ById  ${pcid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response   ${resp}    firstName=${firstname}  lastName=${lastname}  phoneNo=${CUSERNAME18}  dob=${dob}  gender=${gender}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${pcid}  favourite=${bool[0]}
      
JD-TC-ListCustomerByProvider-2
      [Documentation]    List more customer details by provider login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${gender}  ${dob}  ${CUSERNAME8}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Set Test Variable  ${pcid1}  ${resp.json()}
      Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERNAME8}${\n}
      ${resp}=  GetCustomer ById  ${pcid1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response   ${resp}    firstName=${firstname}  lastName=${lastname}  phoneNo=${CUSERNAME8}  dob=${dob}  gender=${gender}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${pcid1}  favourite=${bool[0]}
     
JD-TC-ListCustomerByProvider-3
      [Documentation]    Add a customer by provider own his customer then list customer details
      ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${pid}  ${resp.json()['id']}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${ph2}=  Evaluate  ${PUSERNAME23}+73003
      Set Suite Variable  ${email}  ${firstname}${ph2}${C_Email}.ynwtest@netvarth.com
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email}  ${gender}  ${dob}  ${PUSERNAME3}  ${EMPTY}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      Set Suite Variable  ${pcid2}  ${resp.json()}
      Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME3}${\n}
      ${resp}=  GetCustomer ById  ${pcid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response   ${resp}    firstName=${firstname}  lastName=${lastname}  phoneNo=${PUSERNAME3}   dob=${dob}  gender=${gender}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${pcid2}  favourite=${bool[0]}
     

JD-TC-ListCustomerByProvider-UH1
      [Documentation]  List a customer  details without login
      ${resp}=  GetCustomer ById  ${pcid}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings  "${resp.json()}"    	"${SESSION_EXPIRED}"
      

JD-TC-ListCustomerByProvider-UH2
      [Documentation]    invalid id using in ListcustomerByProvider
      ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  GetCustomer ById   0
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"   "${CONSUMER_NOT_FOUND}"

JD-TC-ListCustomerByProvider-4
      [Documentation]    List a Customer details by provider login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${pid}  ${resp.json()['id']}
      ${ph2}=  Evaluate  ${PUSERNAME23}+73053
      ${resp}=  AddCustomer  ${ph2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${pcid}  ${resp.json()}
      Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph2}${\n}
      ${resp}=  GetCustomer ById  ${pcid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response   ${resp}      phoneNo=${ph2}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${pcid}  favourite=${bool[0]}
      