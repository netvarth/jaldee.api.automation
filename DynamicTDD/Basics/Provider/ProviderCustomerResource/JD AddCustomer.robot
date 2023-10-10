*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        AddCustomer
Library           String
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Variables***
# ${waitlistedby}           PROVIDER
${SERVICE1}               SERVICE1
${SERVICE2}               SERVICE2
${SERVICE3}               SERVICE3
${SERVICE4}               SERVICE4
${self}                   0
${CUSERPH}                ${CUSERNAME}


***Test Cases***

JD-TC-AddCustomer-1
     [Documentation]  Add a new valid customer without email

     ${resp}=  Encrypted Provider Login  ${PUSERNAME230}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${decrypted_data}=  db.decrypt_data  ${resp.content}
     Log  ${decrypted_data}
     Set Suite Variable  ${p_id}  ${decrypted_data['id']}
     # Set Test Variable  ${p_id}  ${resp.json()['id']}
     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${ph2}=  Evaluate  ${PUSERNAME23}+73009
     ${dob}=  FakerLibrary.Date
     ${gender}=  Random Element    ${Genderlist}
     ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${gender}  ${dob}  ${ph2}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid}  ${resp.json()}
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph2}${\n}
     ${resp}=  GetCustomer ById  ${cid}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['lastName']}  ${lastname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['gender']}  ${gender}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['dob']}  ${dob}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phoneNo']}  ${ph2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['favourite']}  ${bool[0]}
     
     ${resp}=  GetCustomer    phoneNo-eq=${ph2}   status-eq=ACTIVE   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     # Verify Response List  ${resp}  0  firstName=${firstname}  lastName=${lastname}  phoneNo=${ph2}  dob=${dob}  gender=${gender}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${cid}  favourite=${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['phoneNo']}  ${ph2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['favourite']}  ${bool[0]}

JD-TC-AddCustomer-2
     [Documentation]  Add a new valid customer with email
     ${resp}=  Encrypted Provider Login  ${PUSERNAME230}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     # Set Test Variable  ${p_id}  ${resp.json()['id']}
     ${firstname1}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname1}
     ${lastname1}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname1}
     ${dob1}=  FakerLibrary.Date
     Set Suite Variable  ${dob1}
     ${gender1}=  Random Element    ${Genderlist}
     Set Suite Variable  ${gender1}
     ${ph2}=  Evaluate  ${PUSERNAME230}+86233
     Set Suite Variable  ${ph2}
     Set Suite Variable  ${email2}  ${firstname1}${ph2}${C_Email}.${test_mail}
     ${resp}=  AddCustomer with email   ${firstname1}  ${lastname1}  ${EMPTY}  ${email2}  ${gender1}  ${dob1}  ${ph2}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid1}  ${resp.json()}
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph2}${\n}
     ${resp}=  GetCustomer ById  ${cid1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['firstName']}  ${firstname1}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['lastName']}  ${lastname1}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email']}  ${email2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['gender']}  ${gender1}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['dob']}  ${dob1}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phoneNo']}  ${ph2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['favourite']}  ${bool[0]}
     ${resp}=  GetCustomer    phoneNo-eq=${ph2}    status-eq=ACTIVE  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     # Verify Response List  ${resp}  0  firstName=${firstname1}  lastName=${lastname1}  phoneNo=${ph2}  dob=${dob1}  gender=${gender1}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${cid1}  favourite=${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid1}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname1}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname1}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender1}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob1}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['phoneNo']}  ${ph2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['favourite']}  ${bool[0]}
    

JD-TC-AddCustomer-3
     [Documentation]  Consumer signup for already added customer with email
     # ${firstname}=  FakerLibrary.first_name
     # ${lastname}=  FakerLibrary.last_name
     # ${dob}=  FakerLibrary.Date
     # ${gender}=  Random Element    ${Genderlist}
     ${businessname}=  FakerLibrary.address
     ${resp}=  Consumer SignUp  ${firstname1}  ${lastname1}  ${businessname}  ${ph2}  ${EMPTY}   ${dob1}   ${gender1}   ${email2}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Activation  ${email2}  1
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Set Credential  ${email2}  ${PASSWORD}  1
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Login  ${ph2}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-AddCustomer-4
     [Documentation]  Provider signup for already added customer with email  
     ${resp}=  Encrypted Provider Login  ${PUSERNAME230}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${dob}=  FakerLibrary.Date
     ${gender}=  Random Element    ${Genderlist}
     ${ph5}=  Evaluate  ${PUSERNAME233}+72004
     Set Test Variable  ${email}  ${firstname}${ph5}${C_Email}.${test_mail}
     ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email}  ${gender}  ${dob}  ${ph5}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid1}  ${resp.json()}
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph5}${\n}

     ${resp}=  GetCustomer ById  ${cid1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['lastName']}  ${lastname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email']}  ${email}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['gender']}  ${gender}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['dob']}  ${dob}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phoneNo']}  ${ph5}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['favourite']}  ${bool[0]}

     ${resp}=  ProviderLogout
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get BusinessDomainsConf
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
     Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${email}  ${d1}  ${sd1}  ${ph5}    1
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${email}  0
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${email}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${ph5}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-AddCustomer-5
     [Documentation]  Add a customer using already logined provider's phone number then add a family to that customer then add another customer using that family member's ph no
     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}   ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${dob}=  FakerLibrary.Date
     ${gender}=  Random Element    ${Genderlist}
     Set Test Variable  ${email5}  ${firstname}${PUSERNAME231}${C_Email}.${test_mail}
     ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email5}  ${gender}  ${dob}  ${PUSERNAME231}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid}  ${resp.json()}
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME231}${\n}
     ${resp}=  GetCustomer ById  ${cid}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['lastName']}  ${lastname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email']}  ${email5}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['gender']}  ${gender}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['dob']}  ${dob}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phoneNo']}  ${PUSERNAME231}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['favourite']}  ${bool[0]}
     ${firstname1}=  FakerLibrary.first_name
     ${lastname1}=  FakerLibrary.last_name
     ${dob1}=  FakerLibrary.Date
     ${gender1}=  Random Element    ${Genderlist}
     ${ph6}=  Evaluate  ${PUSERNAME230}+72005
     ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${cid}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  ${ph6}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cidfam}  ${resp.json()}
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph6}${\n}
     ${resp}=  ListFamilyMemberByProvider  ${cid}
     Should Be Equal As Strings  ${resp.status_code}  200
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cidfam}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname1}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname1}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob1}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender1} 
     
     ${resp}=  GetCustomer   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  GetCustomer ById  ${cidfam}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['firstName']}  ${firstname1}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['lastName']}  ${lastname1}
     # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email']}  ${email5}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['gender']}  ${gender1}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['dob']}  ${dob1}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phoneNo']}  ${ph6}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['favourite']}  ${bool[0]}
     Set Test Variable  ${email5}  ${firstname}${ph6}${C_Email}.${test_mail}
     ${firstname2}=  FakerLibrary.first_name
     ${lastname2}=  FakerLibrary.last_name
     ${dob2}=  FakerLibrary.Date
     ${gender2}=  Random Element    ${Genderlist}
     ${resp}=  AddCustomer with email   ${firstname2}  ${lastname2}  ${EMPTY}  ${email5}  ${gender2}  ${dob2}  ${ph6}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid1}  ${resp.json()}
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph6}${\n}
     ${resp}=  GetCustomer ById  ${cid1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['firstName']}  ${firstname2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['lastName']}  ${lastname2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email']}  ${email5}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['gender']}  ${gender2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['dob']}  ${dob2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phoneNo']}  ${ph6}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['favourite']}  ${bool[0]}
     ${resp}=  GetCustomer    phoneNo-eq=${ph6}   status-eq=ACTIVE   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     # Verify Response List  ${resp}  0  firstName=${firstname2}  lastName=${lastname2}  phoneNo=${ph6}  dob=${dob2}  gender=${gender2}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${cid1}  favourite=${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid1}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['phoneNo']}  ${ph6}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['favourite']}  ${bool[0]}
    
JD-TC-AddCustomer-6
     [Documentation]  Add a customer which is added by another provider
     ${resp}=  Encrypted Provider Login  ${PUSERNAME232}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${firstname}=  FakerLibrary.first_name
     Set Test Variable  ${firstname}
     ${lastname}=  FakerLibrary.last_name
     Set Test Variable  ${lastname}
     ${dob}=  FakerLibrary.Date
     Set Test Variable  ${dob}
     ${gender}=  Random Element    ${Genderlist}
     Set Test variable  ${gender}
     ${ph3}=  Evaluate  ${PUSERNAME230}+72002
     Set Suite Variable  ${ph3}
     Set Test Variable  ${email}  ${firstname}${ph3}${C_Email}.${test_mail}
     ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email}  ${gender}  ${dob}  ${ph3}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid1}  ${resp.json()}
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph3}${\n}
     ${resp}=  GetCustomer ById  ${cid1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['lastName']}  ${lastname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email']}  ${email}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['gender']}  ${gender}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['dob']}  ${dob}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phoneNo']}  ${ph3}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['favourite']}  ${bool[0]}
     ${resp}=   ProviderLogout
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Encrypted Provider Login  ${PUSERNAME233}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  GetCustomer
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}   ${gender}  ${dob}  ${ph3}  ${EMPTY}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid2}  ${resp.json()}
     ${resp}=  GetCustomer ById  ${cid2}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['lastName']}  ${lastname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['gender']}  ${gender}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['dob']}  ${dob}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phoneNo']}  ${ph3}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['favourite']}  ${bool[0]}
     
     ${resp}=  GetCustomer    phoneNo-eq=${ph3}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     # Verify Response List  ${resp}  0  firstName=${firstname}  lastName=${lastname}  phoneNo=${ph3}  dob=${dob}  gender=${gender}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${cid2}  favourite=${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['phoneNo']}  ${ph3}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['favourite']}  ${bool[0]}
     

JD-TC-AddCustomer-7
     [Documentation]  Add an already existing consumer name
     ${resp}=  Encrypted Provider Login  ${PUSERNAME230}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${ph3}=  Evaluate  ${PUSERNAME230}+72004
     ${dob}=  FakerLibrary.Date
     ${gender}=  Random Element    ${Genderlist}
     Set Test Variable  ${email}  ${firstname1}${ph3}${C_Email}.${test_mail}
     ${resp}=  AddCustomer with email   ${firstname1}  ${lastname1}  ${EMPTY}  ${email}  ${gender}  ${dob}  ${ph3}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid2}  ${resp.json()}
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph3}${\n}
     ${resp}=  GetCustomer    phoneNo-eq=${ph3}    status-eq=ACTIVE  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     # Verify Response List  ${resp}  0  firstName=${firstname1}  lastName=${lastname1}  phoneNo=${ph3}  dob=${dob}  gender=${gender}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${cid2}  favourite=${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname1}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname1}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['phoneNo']}  ${ph3}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['favourite']}  ${bool[0]}
    
JD-TC-AddCustomer-8
     [Documentation]  Add a customer using already existing Provider's phone nember
     ${resp}=  Encrypted Provider Login  ${PUSERNAME230}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${dob}=  FakerLibrary.Date
     ${gender}=  Random Element    ${Genderlist}
     Set Test Variable  ${email}  ${firstname}${PUSERNAME231}${C_Email}.${test_mail}
     ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email}  ${gender}  ${dob}  ${PUSERNAME231}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid2}  ${resp.json()}
     ${resp}=  GetCustomer    phoneNo-eq=${PUSERNAME231}    status-eq=ACTIVE
     Should Be Equal As Strings  ${resp.status_code}  200
     # Verify Response List  ${resp}  0  firstName=${firstname}  lastName=${lastname}  phoneNo=${PUSERNAME231}  dob=${dob}  gender=${gender}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${cid2}  favourite=${bool[0]}
     # Should Be Equal As Strings  "${resp.json()}"  "${PRIMARY_MOB_NO_ALREADY_USED}"
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['phoneNo']}  ${PUSERNAME231}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['favourite']}  ${bool[0]}


JD-TC-AddCustomer-9
     [Documentation]   Set providers jaldeeId format as manual and a consumer added to waitlist, here the consumer is not a provider customer so the jaldeeid is consumer phone number. 
     clear_queue      ${PUSERNAME231}
     clear_location   ${PUSERNAME231}
     clear_service    ${PUSERNAME231}
     clear waitlist   ${PUSERNAME231}
     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${decrypted_data}=  db.decrypt_data  ${resp.content}
     Log  ${decrypted_data}
     Set Test Variable  ${p_id}  ${decrypted_data['id']}
     # Set Test Variable  ${p_id}  ${resp.json()['id']}
     ${pid0}=  get_acc_id  ${PUSERNAME231}

     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     
     ${resp}=   Create Sample Location
     Set Test Variable    ${loc_id1}    ${resp}  
     ${resp}=   Get Location ById  ${loc_id1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 

     ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
     ${resp}=   Create Sample Service  ${SERVICE1}
     Set Test Variable    ${ser_id1}    ${resp}
     ${q_name}=    FakerLibrary.name
     ${list}=  Create List   1  2  3  4  5  6  7
     ${strt_time}=   add_timezone_time  ${tz}  3  00  
     ${end_time}=    add_timezone_time  ${tz}  3  30      
     ${parallel}=   Random Int  min=1   max=1
     ${capacity}=  Random Int   min=10   max=20
     ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${que_id1}   ${resp.json()} 

     ${resp}=  JaldeeId Format   ${customerseries[1]}   ${EMPTY}   ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  ProviderLogout
     Should Be Equal As Strings  ${resp.status_code}  200

     ${CUSERPH0}=  Evaluate  ${CUSERPH}+100100333
     Set Suite Variable   ${CUSERPH0}
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH0}${\n}
     ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1002
     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${address}=  FakerLibrary.address
     ${dob}=  FakerLibrary.Date
     ${gender}    Random Element    ${Genderlist}
     ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Activation  ${CUSERPH0}  1
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Set Credential  ${CUSERPH0}  ${PASSWORD}  1
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${cnote}=   FakerLibrary.word
     ${resp}=  Add To Waitlist Consumers  ${pid0}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200 
     ${wid}=  Get Dictionary Values  ${resp.json()}
     Set Test Variable  ${wid1}  ${wid[0]}

     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid1}  ${resp.json()[0]['id']}

     ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     
     ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable    ${cid}  ${resp.json()['consumer']['id']}
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
     Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}  ${ser_id1}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1} 
     Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id1}
     
     ${resp}=  Consumer Logout
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     # Verify Response List  ${resp}  0  firstName=${firstname}  lastName=${lastname}  phoneNo=${CUSERPH0}  dob=${dob}  gender=${gender}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${cid}  favourite=${bool[0]}  jaldeeId=${CUSERPH0}-0
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['phoneNo']}  ${CUSERPH0}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['favourite']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['jaldeeId']}  ${CUSERPH0}-0


JD-TC-AddCustomer-10
     [Documentation]   Set providers jaldeeId format as manual and provider add a customer after consumer signup with that jaldeeidnumber  and provider  check jaldeeid (it became null)
     clear_queue      ${PUSERNAME231}
     clear_location   ${PUSERNAME231}
     clear_service    ${PUSERNAME231}
     clear waitlist   ${PUSERNAME231}
     clear_customer   ${PUSERNAME231}

     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${decrypted_data}=  db.decrypt_data  ${resp.content}
     Log  ${decrypted_data}
     Set Test Variable  ${p_id}  ${decrypted_data['id']}

     # Set Test Variable  ${p_id}  ${resp.json()['id']}
     ${pid0}=  get_acc_id  ${PUSERNAME231}

     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     
     ${resp}=   Create Sample Location
     Set Test Variable    ${loc_id1}    ${resp}  
     ${resp}=   Get Location ById  ${loc_id1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 

     ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
     ${resp}=   Create Sample Service  ${SERVICE1}
     Set Test Variable    ${ser_id1}    ${resp} 
     ${q_name}=    FakerLibrary.name
     ${list}=  Create List   1  2  3  4  5  6  7
     ${strt_time}=   add_timezone_time  ${tz}  3  00  
     ${end_time}=    add_timezone_time  ${tz}  3  30      
     ${parallel}=   Random Int  min=1   max=1
     ${capacity}=  Random Int   min=10   max=20
     ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${que_id1}   ${resp.json()} 

     ${resp}=  JaldeeId Format   ${customerseries[1]}   ${EMPTY}   ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200


     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     # ${ph5}=  Evaluate  ${PUSERNAME23}+72085
     ${ph6}=  Evaluate  ${PUSERNAME22}+72088
     Set Test Variable  ${email2}  ${firstname}${ph6}${C_Email}.${test_mail}
     ${cust_no}    FakerLibrary.Numerify   text=%####
     ${ph3}=  Evaluate  ${PUSERNAME22}+${cust_no}
     ${gender}=  Random Element    ${Genderlist}
     ${dob}=  FakerLibrary.Date
     ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${ph6}  ${ph3}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid9}  ${resp.json()}
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph6}${\n}

     ${resp}=  GetCustomer ById  ${cid9}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeId']}  ${ph3}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['lastName']}  ${lastname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email']}  ${email2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['gender']}  ${gender}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['dob']}  ${dob}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phoneNo']}  ${ph6}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['favourite']}  ${bool[0]}

     ${resp}=  ProviderLogout
     Should Be Equal As Strings  ${resp.status_code}  200

     ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1012
     ${address}=  FakerLibrary.address
     ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${ph3}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Activation  ${ph3}  1
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Set Credential  ${ph3}  ${PASSWORD}  1
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Login  ${ph3}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${cnote}=   FakerLibrary.word
     ${resp}=  Add To Waitlist Consumers  ${pid0}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200 
     ${wid}=  Get Dictionary Values  ${resp.json()}
     Set Test Variable  ${wid1}  ${wid[0]}

     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  GetCustomer  phoneNo-eq=${ph3}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid1}  ${resp.json()[0]['id']}

     ${resp}=  Consumer Login  ${ph3}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     
     ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable    ${cid}  ${resp.json()['consumer']['id']}
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
     Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}  ${ser_id1}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1} 
     Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id1}
     
     ${resp}=  Consumer Logout
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  GetCustomer  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     # Verify Response List  ${resp}  0  firstName=${firstname}  lastName=${lastname}  phoneNo=${ph3}  dob=${dob}  gender=${gender}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${cid1}  favourite=${bool[0]} 
     Run Keyword And Continue On Failure  Should Not Contain  ${resp.json()}   0   "jaldeeId":"${ph3}"  
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid1}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['phoneNo']}  ${ph3}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['favourite']}  ${bool[0]}


JD-TC-AddCustomer-11
     [Documentation]   Set providers jaldeeId format as manual and a consumer added to waitlist, here the consumer is  a provider customer and check jaldeeid. 
     clear_queue      ${PUSERNAME231}
     clear_location   ${PUSERNAME231}
     clear_service    ${PUSERNAME231}
     clear waitlist   ${PUSERNAME231}
     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${decrypted_data}=  db.decrypt_data  ${resp.content}
     Log  ${decrypted_data}
     Set Test Variable  ${p_id}  ${decrypted_data['id']}

     # Set Test Variable  ${p_id}  ${resp.json()['id']}
     ${pid0}=  get_acc_id  ${PUSERNAME231}

     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     
     ${resp}=   Create Sample Location
     Set Test Variable    ${loc_id1}    ${resp}  
     ${resp}=   Get Location ById  ${loc_id1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 

     ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
     ${resp}=   Create Sample Service  ${SERVICE1}
     Set Test Variable    ${ser_id1}    ${resp}
     
     ${q_name}=    FakerLibrary.name
     ${list}=  Create List   1  2  3  4  5  6  7
     ${strt_time}=   add_timezone_time  ${tz}  3  00  
     ${end_time}=    add_timezone_time  ${tz}  3  30      
     ${parallel}=   Random Int  min=1   max=1
     ${capacity}=  Random Int   min=10   max=20
     ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${que_id2}   ${resp.json()} 

     ${resp}=  JaldeeId Format   ${customerseries[1]}   ${EMPTY}   ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${ph5}=  Evaluate  ${PUSERNAME231}+72064
     Set Test Variable  ${email2}  ${firstname}${ph5}${C_Email}.${test_mail}
     ${gender}=  Random Element    ${Genderlist}
     ${dob}=  FakerLibrary.Date
     ${m_jid}=  Random Int  min=10  max=50
     ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${CUSERNAME5}  ${m_jid}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid9}  ${resp.json()}
     # Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERNAME5}${\n}

     ${resp}=  GetCustomer ById  ${cid9}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['lastName']}  ${lastname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email']}  ${email2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['gender']}  ${gender}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['dob']}  ${dob}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phoneNo']}  ${CUSERNAME5}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['favourite']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeId']}  ${m_jid}

     ${resp}=  ProviderLogout
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${cnote}=   FakerLibrary.word
     ${resp}=  Add To Waitlist Consumers  ${pid0}  ${que_id2}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200 
     ${wid}=  Get Dictionary Values  ${resp.json()}
     Set Test Variable  ${wid1}  ${wid[0]}

     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid1}  ${resp.json()[0]['id']}

     ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable    ${cid}  ${resp.json()['consumer']['id']}
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
     Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}  ${ser_id1}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1} 
     Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id2}
     
     ${resp}=  Consumer Logout
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  GetCustomer ById  ${cid9}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     # Verify Response   ${resp}     firstName=${firstname}  lastName=${lastname}  phoneNo=${CUSERNAME5}  dob=${dob}  gender=${gender}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${cid9}  favourite=${bool[0]}  jaldeeId=${m_jid}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid9}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['lastName']}  ${lastname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email']}  ${email2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['gender']}  ${gender}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['dob']}  ${dob}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phoneNo']}  ${CUSERNAME5}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['favourite']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeId']}  ${m_jid}


JD-TC-AddCustomer-12
     [Documentation]   Set providers jaldeeId format as manual and a provider added to waitlist,  check jaldeeid. 
     clear_queue      ${PUSERNAME231}
     clear_location   ${PUSERNAME231}
     clear_service    ${PUSERNAME231}
     clear waitlist   ${PUSERNAME231}
     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${decrypted_data}=  db.decrypt_data  ${resp.content}
     Log  ${decrypted_data}
     Set Test Variable  ${p_id}  ${decrypted_data['id']}

     # Set Test Variable  ${p_id}  ${resp.json()['id']}
     ${pid0}=  get_acc_id  ${PUSERNAME231}

     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     
     ${resp}=   Create Sample Location
     Set Test Variable    ${loc_id1}    ${resp}  
     ${resp}=   Get Location ById  ${loc_id1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 

     ${CUR_DAY}=  db.get_date_by_timezone  ${tz}

     ${resp}=   Create Sample Service  ${SERVICE1}
     Set Test Variable    ${ser_id1}    ${resp}
     
     ${q_name}=    FakerLibrary.name
     ${list}=  Create List   1  2  3  4  5  6  7
     ${strt_time}=   add_timezone_time  ${tz}  3  00  
     ${end_time}=    add_timezone_time  ${tz}  3  30      
     ${parallel}=   Random Int  min=1   max=1
     ${capacity}=  Random Int   min=10   max=20
     ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${que_id2}   ${resp.json()} 

     ${resp}=  JaldeeId Format   ${customerseries[1]}   ${EMPTY}   ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${ph6}=  Evaluate  ${PUSERNAME23}+72078
     Set Test Variable  ${email2}  ${firstname}${ph6}${C_Email}.${test_mail}
     ${gender}=  Random Element    ${Genderlist}
     ${dob}=  FakerLibrary.Date
     ${m_jid}=  Random Int  min=51  max=60
     ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${ph6}  ${m_jid}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid}  ${resp.json()}
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph6}${\n}    

     ${resp}=  GetCustomer ById  ${cid}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['lastName']}  ${lastname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email']}  ${email2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['gender']}  ${gender}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['dob']}  ${dob}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phoneNo']}  ${ph6}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['favourite']}  ${bool[0]}   
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeId']}  ${m_jid}               

     ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
     ${desc}=   FakerLibrary.word
     ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id2}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
     Should Be Equal As Strings  ${resp.status_code}  200
     ${wid}=  Get Dictionary Values  ${resp.json()}
     Set Test Variable  ${wid4}  ${wid[0]}
     ${resp}=  Get Waitlist By Id  ${wid4} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}  personsAhead=0
     Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
     Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${cid}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${cid}

     ${resp}=  GetCustomer ById  ${cid}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     # Verify Response   ${resp}     firstName=${firstname}  lastName=${lastname}  phoneNo=${ph6}  dob=${dob}  gender=${gender}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${cid}  favourite=${bool[0]}  jaldeeId=${m_jid}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['lastName']}  ${lastname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email']}  ${email2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['gender']}  ${gender}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['dob']}  ${dob}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phoneNo']}  ${ph6}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['favourite']}  ${bool[0]}   
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeId']}  ${m_jid} 

     ${resp}=  ProviderLogout
     Should Be Equal As Strings  ${resp.status_code}  200

     

JD-TC-AddCustomer-13
     [Documentation]   Set providers jaldeeId format as auto and a consumer added to waitlist, here the consumer is not a provider customer and then verify the jaldeeid. 
     clear_queue      ${PUSERNAME231}
     clear_location   ${PUSERNAME231}
     clear_service    ${PUSERNAME231}
     clear waitlist   ${PUSERNAME231}
     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${decrypted_data}=  db.decrypt_data  ${resp.content}
     Log  ${decrypted_data}
     Set Test Variable  ${p_id}  ${decrypted_data['id']}

     # Set Test Variable  ${p_id}  ${resp.json()['id']}
     ${pid0}=  get_acc_id  ${PUSERNAME231}

     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     
     ${resp}=   Create Sample Location
     Set Test Variable    ${loc_id1}    ${resp}  
     ${resp}=   Get Location ById  ${loc_id1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 

     ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
     ${resp}=   Create Sample Service  ${SERVICE1}
     Set Test Variable    ${ser_id1}    ${resp}
     ${q_name}=    FakerLibrary.name
     ${list}=  Create List   1  2  3  4  5  6  7
     ${strt_time}=   add_timezone_time  ${tz}  3  00  
     ${end_time}=    add_timezone_time  ${tz}  3  30      
     ${parallel}=   Random Int  min=1   max=1
     ${capacity}=  Random Int   min=10   max=20
     ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${que_id1}   ${resp.json()} 

     ${resp}=  JaldeeId Format   ${customerseries[0]}   ${EMPTY}   ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  ProviderLogout
     Should Be Equal As Strings  ${resp.status_code}  200

     ${CUSERPH0}=  Evaluate  ${CUSERPH}+100100444
     Set Suite Variable   ${CUSERPH0}
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH0}${\n}
     ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1003
     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${address}=  FakerLibrary.address
     ${dob}=  FakerLibrary.Date
     ${gender}    Random Element    ${Genderlist}
     ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Activation  ${CUSERPH0}  1
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Set Credential  ${CUSERPH0}  ${PASSWORD}  1
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${cnote}=   FakerLibrary.word
     ${resp}=  Add To Waitlist Consumers  ${pid0}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200 
     ${wid}=  Get Dictionary Values  ${resp.json()}
     Set Test Variable  ${wid1}  ${wid[0]}

     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid1}  ${resp.json()[0]['id']}

     ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable    ${cid}  ${resp.json()['consumer']['id']}  
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
     Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}  ${ser_id1}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1} 
     Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id1}
     
     ${resp}=  Consumer Logout
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${jid}  ${resp.json()[0]['jaldeeId']}
     # Verify Response List  ${resp}  0  firstName=${firstname}  lastName=${lastname}  phoneNo=${CUSERPH0}  dob=${dob}  gender=${gender}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${cid}  favourite=${bool[0]}  jaldeeId=${jid}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['phoneNo']}  ${CUSERPH0}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['favourite']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeId']}  ${jid}

JD-TC-AddCustomer-14
     [Documentation]  Add an already existing customer's email
     ${resp}=  Encrypted Provider Login  ${PUSERNAME230}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${dob}=  FakerLibrary.Date
     ${gender}=  Random Element    ${Genderlist}
     ${ph3}=  Evaluate  ${PUSERNAME230}+71002
     ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${ph3}  ${EMPTY}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid2}  ${resp.json()}
     ${resp}=  GetCustomer    phoneNo-eq=${ph3}    status-eq=ACTIVE  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     # Verify Response List  ${resp}  0  firstName=${firstname}  lastName=${lastname}  phoneNo=${ph3}  dob=${dob}  gender=${gender}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${cid2}  favourite=${bool[0]}
     # Should Be Equal As Strings  "${resp.json()}"  "${EMAIL_EXISTS}"
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['email']}  ${email2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['phoneNo']}  ${ph3}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['favourite']}  ${bool[0]}
     # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeId']}  ${jid}

JD-TC-AddCustomer-15
     [Documentation]  Add a customer with empty  details then add to waitlist
     
     clear_queue      ${PUSERNAME231}
     clear_location   ${PUSERNAME231}
     clear_service    ${PUSERNAME231}
     clear waitlist   ${PUSERNAME231}
     
     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${decrypted_data}=  db.decrypt_data  ${resp.content}
     Log  ${decrypted_data}
     Set Test Variable  ${p_id}  ${decrypted_data['id']}

     # Set Test Variable  ${p_id}  ${resp.json()['id']}
     ${resp}=  AddCustomer without email   ${EMPTY}  ${EMPTY}  ${EMPTY}   ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cidE}  ${resp.json()}

     ${resp}=  GetCustomer ById  ${cidE}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['id']}  ${cidE}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['firstName']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['lastName']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['gender']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['dob']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phoneNo']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['countryCode']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['favourite']}  ${bool[0]}
     
     ${pid0}=  get_acc_id  ${PUSERNAME231}

     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     
     ${resp}=   Create Sample Location
     Set Test Variable    ${loc_id1}    ${resp}  
     ${resp}=   Get Location ById  ${loc_id1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 

     ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
     ${resp}=   Create Sample Service  ${SERVICE1}
     Set Test Variable    ${ser_id1}    ${resp}
     ${q_name}=    FakerLibrary.name
     ${list}=  Create List   1  2  3  4  5  6  7
     ${strt_time}=   add_timezone_time  ${tz}  3  00  
     ${end_time}=    add_timezone_time  ${tz}  3  30      
     ${parallel}=   Random Int  min=1   max=1
     ${capacity}=  Random Int   min=10   max=20
     ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${que_id1}   ${resp.json()} 
     ${desc}=   FakerLibrary.word
     ${resp}=  Add To Waitlist  ${cidE}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cidE} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${wid}=  Get Dictionary Values  ${resp.json()}
     Set Test Variable  ${wid5}  ${wid[0]}

     ${resp}=  Get Waitlist By Id  ${wid5} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}  personsAhead=0
     Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
     Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cidE}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cidE}



JD-TC-AddCustomer-UH1
     [Documentation]  Add an already existing customer's phone no
     ${resp}=  Encrypted Provider Login  ${PUSERNAME230}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     clear_customer   ${PUSERNAME230}

     ${resp}=  GetCustomer    phoneNo-eq=${ph2}    status-eq=ACTIVE  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid1}  ${resp.json()}

     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${dob}=  FakerLibrary.Date
     ${gender}=  Random Element    ${Genderlist}
     ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}   ${gender}  ${dob}  ${ph2}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     # Should Be Equal As Strings  ${resp.status_code}  422
     # Should Be Equal As Strings  "${resp.json()}"   "${PRO_CON_ALREADY_EXIST}"
     Set Test Variable  ${cid2}  ${resp.json()}

     Should Not Be Equal As Strings  ${cid1}  ${cid2}

     ${resp}=  GetCustomer ById  ${cid2}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['lastName']}  ${lastname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['gender']}  ${gender}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['dob']}  ${dob}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phoneNo']}  ${ph2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['favourite']}  ${bool[0]}



JD-TC-AddCustomer-UH2
     [Documentation]  Add customer without login
     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${dob}=  FakerLibrary.Date
     ${gender}=  Random Element    ${Genderlist}
     ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${gender}  ${dob}  ${ph2}  ${EMPTY}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
     
JD-TC-AddCustomer-UH3
     [Documentation]  Add a customer using consumer login
     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${dob}=  FakerLibrary.Date
     ${gender}=  Random Element    ${Genderlist}
     ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${gender}  ${dob}  ${ph2}  ${EMPTY}
     Should Be Equal As Strings  ${resp.status_code}  401
     Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-AddCustomer-UH4
     [Documentation]  Provider add a customer, Then that customer trying to login
     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}   ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${dob}=  FakerLibrary.Date
     ${gender}=  Random Element    ${Genderlist}
     ${ph7}=  Evaluate  ${PUSERNAME230}+72006
     Set Test Variable  ${email6}  ${firstname}${ph7}${C_Email}.${test_mail}
     ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email6}  ${gender}  ${dob}  ${ph7}  ${EMPTY}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid}  ${resp.json()}
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph7}${\n}

     ${resp}=  GetCustomer ById  ${cid}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['lastName']}  ${lastname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email']}  ${email6}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['gender']}  ${gender}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['dob']}  ${dob}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phoneNo']}  ${ph7}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['favourite']}  ${bool[0]}

     ${resp}=  Encrypted Provider Login  ${ph7}  ${PASSWORD}
     Should Be Equal As Strings    ${resp.status_code}    401
     Should Be Equal As Strings  ${resp.json()}  ${NOT_REGISTERED_PROVIDER}

     ${resp}=  Consumer Login  ${ph7}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    401
     Should Be Equal As Strings  ${resp.json()}   ${NOT_REGISTERED_CUSTOMER}


#     //NEW CHANGE CASES//


JD-TC-AddCustomer-16
     
     [Documentation]    Add a same customer to three different providers and take waitlist then after consumer signup get waitlist details                 
     ...                (Here first  provider's jaldee integration is true 2nd provider's  jaldee integration is true and 3rd providers jaldee integration is false)
     

     clear_queue      ${PUSERNAME257}
     # clear_location   ${PUSERNAME257}
     clear_service    ${PUSERNAME257}
     clear waitlist   ${PUSERNAME257}

     clear_queue      ${PUSERNAME259}
     # clear_location   ${PUSERNAME259}
     clear_service    ${PUSERNAME259}
     clear waitlist   ${PUSERNAME259}
     
     clear_queue      ${PUSERNAME213}
     # clear_location   ${PUSERNAME213}
     clear_service    ${PUSERNAME213}
     clear waitlist   ${PUSERNAME213}
     
     ${resp}=  Encrypted Provider Login  ${PUSERNAME213}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=   Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
          ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
          Should Be Equal As Strings  ${resp1.status_code}  200
     ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
          ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
          Should Be Equal As Strings  ${resp1.status_code}  200
     END

     ${resp}=   Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

     ${firstname1}=  FakerLibrary.first_name
     ${lastname1}=  FakerLibrary.last_name
     ${phone}=  Evaluate  ${PUSERNAME162}+72003 
     Set Suite Variable    ${phone}     
     ${resp}=  AddCustomer  ${phone}   firstName=${firstname1}   lastName=${lastname1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${cid1}  ${resp.json()}

     ${resp}=  GetCustomer  phoneNo-eq=${phone}
     Log  ${resp.content}
     Should Be Equal As Strings      ${resp.status_code}  200
     Set Test Variable   ${jaldeeid1}    ${resp.json()[0]['jaldeeId']}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['firstname']}  ${firstname1}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname1}

     ${pid1}=  get_acc_id  ${PUSERNAME213}

     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     
     ${resp}=   Create Sample Location
     Set Test Variable    ${loc_id1}    ${resp}  
     ${resp}=   Get Location ById  ${loc_id1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 

     ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
     ${resp}=   Create Sample Service  ${SERVICE1}
     Set Test Variable    ${ser_id1}    ${resp}
     ${q_name}=    FakerLibrary.name
     ${list}=  Create List   1  2  3  4  5  6  7
     ${strt_time}=   add_timezone_time  ${tz}  3  00  
     ${end_time}=    add_timezone_time  ${tz}  3  30      
     ${parallel}=   Random Int  min=1   max=1
     ${capacity}=  Random Int   min=10   max=20
     ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${que_id1}   ${resp.json()} 
     ${desc}=   FakerLibrary.word
     ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${wid}=  Get Dictionary Values  ${resp.json()}
     Set Test Variable  ${wid1}  ${wid[0]}

     ${resp}=  Get Waitlist By Id  ${wid1} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}  personsAhead=0
     Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
     Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid1}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid1}

     ${resp}=  Encrypted Provider Login  ${PUSERNAME259}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=   Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
          ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
          Should Be Equal As Strings  ${resp1.status_code}  200
     ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
          ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
          Should Be Equal As Strings  ${resp1.status_code}  200
     END
     
     ${resp}=  Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

     ${firstname2}=  FakerLibrary.first_name
     ${lastname2}=  FakerLibrary.last_name 
     ${resp}=  AddCustomer  ${phone}   firstName=${firstname2}   lastName=${lastname2}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${cid2}  ${resp.json()}

     ${resp}=  GetCustomer  phoneNo-eq=${phone}
     Log  ${resp.content}
     Should Be Equal As Strings      ${resp.status_code}  200
     Set Test Variable   ${jaldeeid2}    ${resp.json()[0]['jaldeeId']}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstName2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname2}

     ${pid2}=  get_acc_id  ${PUSERNAME259}

     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
     ${resp}=   Create Sample Location
     Set Test Variable    ${loc_id2}    ${resp}  
     ${resp}=   Create Sample Service  ${SERVICE1}
     Set Test Variable    ${ser_id2}    ${resp}
     ${q_name}=    FakerLibrary.name
     ${list}=  Create List   1  2  3  4  5  6  7
     ${strt_time}=   add_timezone_time  ${tz}  3  00  
     ${end_time}=    add_timezone_time  ${tz}  3  30      
     ${parallel}=   Random Int  min=1   max=1
     ${capacity}=  Random Int   min=10   max=20
     ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id2}  ${ser_id2}  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${que_id2}   ${resp.json()} 
     ${desc}=   FakerLibrary.word
     ${resp}=  Add To Waitlist  ${cid2}  ${ser_id2}  ${que_id2}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid2} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     
     ${wid}=  Get Dictionary Values  ${resp.json()}
     Set Test Variable  ${wid2}  ${wid[0]}
     ${resp}=  Get Waitlist By Id  ${wid2} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}  personsAhead=0
     Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id2}
     Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2}

     ${resp}=  Encrypted Provider Login  ${PUSERNAME257}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=   Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[0]}

     ${firstname3}=  FakerLibrary.first_name
     ${lastname3}=  FakerLibrary.last_name   
     ${resp}=  AddCustomer  ${phone}   firstName=${firstname3}   lastName=${lastname3}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid3}  ${resp.json()}

     ${resp}=  GetCustomer  phoneNo-eq=${phone}
     Log  ${resp.content}
     Should Be Equal As Strings      ${resp.status_code}  200
     Set Test Variable   ${jaldeeid3}    ${resp.json()[0]['jaldeeId']}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['firstname']}  ${firstname3}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname3}

     ${pid3}=  get_acc_id  ${PUSERNAME257}

     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
     ${resp}=   Create Sample Location
     Set Test Variable    ${loc_id3}    ${resp}  
     ${resp}=   Create Sample Service  ${SERVICE1}
     Set Test Variable    ${ser_id3}    ${resp}
     ${q_name}=    FakerLibrary.name
     ${list}=  Create List   1  2  3  4  5  6  7
     ${strt_time}=   add_timezone_time  ${tz}  3  00  
     ${end_time}=    add_timezone_time  ${tz}  3  30      
     ${parallel}=   Random Int  min=1   max=1
     ${capacity}=  Random Int   min=10   max=20
     ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id3}  ${ser_id3}  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${que_id3}   ${resp.json()} 
     ${desc}=   FakerLibrary.word
     ${resp}=  Add To Waitlist  ${cid3}  ${ser_id3}  ${que_id3}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid3} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${wid}=  Get Dictionary Values  ${resp.json()}
     Set Test Variable  ${wid3}  ${wid[0]}

     ${resp}=  Get Waitlist By Id  ${wid3} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}  personsAhead=0
     Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id3}
     Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid3}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid3}

     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${address}=  FakerLibrary.Address
     ${alternativeNo}=  Evaluate  ${PUSERNAME23}+73007
     ${dob}=  FakerLibrary.Date
     ${gender}=  Random Element    ${Genderlist}
     ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${phone}    ${alternativeNo}  ${dob}  ${gender}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Activation  ${phone}  1
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Set Credential  ${phone}  ${PASSWORD}  1
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Login   ${phone}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid1}   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1     personsAhead=0
     Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}  ${ser_id1}
     Should Be Equal As Strings  ${resp.json()['consumer']['jaldeeId']}  ${jaldeeid1}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${firstname1}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}  ${lastname1}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['phoneNo']}  ${phone}
     Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id1}     

     ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${pid2}   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1     personsAhead=0
     Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}  ${ser_id2}
     Should Be Equal As Strings  ${resp.json()['consumer']['jaldeeId']}  ${jaldeeid2}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid2}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${firstname2}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}  ${lastname2}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['phoneNo']}  ${phone}
     Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id2}     

     ${resp}=  Get consumer Waitlist By Id   ${wid3}  ${pid3}   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  401
     Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"

     ${resp}=   Get Waitlist Consumer
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     
     Verify Response List  ${resp}  0   date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1    waitlistedBy=${waitlistedby[1]}    personsAhead=0
     Should Be Equal As Strings  ${resp.json()[0]['service']['name']}  ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${ser_id1}
     Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}  ${cid1}
     Should Be Equal As Strings  ${resp.json()[0]['consumer']['jaldeeId']}  ${jaldeeid1}
     Should Be Equal As Strings  ${resp.json()[0]['waitlistingFor'][0]['id']}  ${cid1}
     Should Be Equal As Strings  ${resp.json()[0]['waitlistingFor'][0]['firstName']}  ${firstname1}
     Should Be Equal As Strings  ${resp.json()[0]['waitlistingFor'][0]['lastName']}  ${lastname1}
     Should Be Equal As Strings  ${resp.json()[0]['waitlistingFor'][0]['phoneNo']}  ${phone}
     Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}  ${que_id1}     

     Verify Response List  ${resp}  1   date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1    waitlistedBy=${waitlistedby[1]}    personsAhead=0
     Should Be Equal As Strings  ${resp.json()[1]['service']['name']}  ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()[1]['service']['id']}  ${ser_id2}
     Should Be Equal As Strings  ${resp.json()[1]['consumer']['id']}  ${cid2}
     Should Be Equal As Strings  ${resp.json()[1]['consumer']['jaldeeId']}  ${jaldeeid2}
     Should Be Equal As Strings  ${resp.json()[1]['waitlistingFor'][0]['id']}  ${cid2}
     Should Be Equal As Strings  ${resp.json()[1]['waitlistingFor'][0]['firstName']}  ${firstname2}
     Should Be Equal As Strings  ${resp.json()[1]['waitlistingFor'][0]['lastName']}  ${lastname2}
     Should Be Equal As Strings  ${resp.json()[1]['waitlistingFor'][0]['phoneNo']}  ${phone}
     Should Be Equal As Strings  ${resp.json()[1]['queue']['id']}  ${que_id2}     


     
JD-TC-AddCustomer-17

     [Documentation]    Add a same customer to three different providers and take appointment then after consumer signup get appointment details                 
          ...                (Here first  provider's  jaldee integration is true 2nd provider's jaldee integration is true and 3rd providers jaldee integration is false)
     ${resp}=  Encrypted Provider Login  ${PUSERNAME213}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${pid1}=  get_acc_id  ${PUSERNAME213}

     ${resp}=   Get Appointment Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

     clear_service   ${PUSERNAME213}
     # clear_location  ${PUSERNAME213}
     clear_customer   ${PUSERNAME213}

     ${resp}=   Get Service
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=    Get Locations
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=   Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

     ${resp}=   Get Appointment Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
     Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

     ${lid1}=  Create Sample Location 

     ${resp}=   Get Location ById  ${lid1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 
 
     clear_appt_schedule   ${PUSERNAME213}
     
     ${DAY1}=  db.get_date_by_timezone  ${tz}
     ${DAY2}=  db.add_timezone_date  ${tz}  10        
     ${list}=  Create List  1  2  3  4  5  6  7
     ${sTime1}=  add_timezone_time  ${tz}  0  15  
     ${delta}=  FakerLibrary.Random Int  min=10  max=60
     ${eTime1}=  add_two   ${sTime1}  ${delta}
     ${s_id1}=  Create Sample Service  ${SERVICE2}
     ${schedule_name}=  FakerLibrary.bs
     ${parallel}=  FakerLibrary.Random Int  min=1  max=10
     ${maxval}=  Convert To Integer   ${delta/2}
     ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
     ${bool1}=  Random Element  ${bool}
     ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${sch_id1}  ${resp.json()}

     ${resp}=  Get Appointment Schedule ById  ${sch_id1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id1}
     Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

     ${phone1}=  Evaluate  ${PUSERNAME162}+72004
     Set Suite Variable    ${phone1}   
     ${firstname1}=  FakerLibrary.first_name
     ${lastname1}=  FakerLibrary.last_name 
     ${resp}=  AddCustomer  ${phone1}   firstName=${firstname1}   lastName=${lastname1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${cid1}  ${resp.json()}

     ${resp}=  GetCustomer  phoneNo-eq=${phone1}
     Log  ${resp.content}
     Should Be Equal As Strings      ${resp.status_code}  200
     Set Test Variable   ${jaldeeid1}    ${resp.json()[0]['jaldeeId']}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid1}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname1}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname1}
     
     ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
     ${apptfor}=   Create List  ${apptfor1}
     
     ${cnote}=   FakerLibrary.word
     ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
     Set Test Variable  ${apptid1}  ${apptid[0]}

     ${resp}=  Get Appointment EncodedID   ${apptid1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${encId1}=  Set Variable   ${resp.json()}

     ${resp}=  Get Appointment By Id   ${apptid1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
     Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId1}
     # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jaldeeid1}
     # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${firstname1}
     # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${firstname1}
     Should Be Equal As Strings  ${resp.json()['providerConsumer']['jaldeeId']}   ${jaldeeid1}
     Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${firstname1}
     Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lastname1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id1}
     Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id1}
     Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${firstname1}
     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lastname1}
     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
     Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
     Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
     Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid1}

     ${resp}=  Encrypted Provider Login  ${PUSERNAME259}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${pid2}=  get_acc_id  ${PUSERNAME259}

     ${resp}=   Get Appointment Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

     clear_service   ${PUSERNAME259}
     clear_location  ${PUSERNAME259}
     clear_customer   ${PUSERNAME259}

     ${resp}=   Get Service
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=    Get Locations
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=   Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
          ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
          Should Be Equal As Strings  ${resp1.status_code}  200
     ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
          ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
          Should Be Equal As Strings  ${resp1.status_code}  200
     END
     
     ${resp}=  Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

     ${resp}=   Get Appointment Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
     Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

     ${lid2}=  Create Sample Location  
     clear_appt_schedule   ${PUSERNAME259}
     
     ${DAY1}=  db.get_date_by_timezone  ${tz}
     ${DAY2}=  db.add_timezone_date  ${tz}  10        
     ${list}=  Create List  1  2  3  4  5  6  7
     ${sTime1}=  add_timezone_time  ${tz}  0  15  
     ${delta}=  FakerLibrary.Random Int  min=10  max=60
     ${eTime1}=  add_two   ${sTime1}  ${delta}
     ${s_id2}=  Create Sample Service  ${SERVICE2}
     ${schedule_name}=  FakerLibrary.bs
     ${parallel}=  FakerLibrary.Random Int  min=1  max=10
     ${maxval}=  Convert To Integer   ${delta/2}
     ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
     ${bool1}=  Random Element  ${bool}
     ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid2}  ${duration}  ${bool1}  ${s_id2}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${sch_id2}  ${resp.json()}

     ${resp}=  Get Appointment Schedule ById  ${sch_id2}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name}  apptState=${Qstate[0]}

     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${s_id2}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id2}
     Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}

     ${firstname2}=  FakerLibrary.first_name
     ${lastname2}=  FakerLibrary.last_name 
     ${resp}=  AddCustomer  ${phone1}   firstName=${firstname2}   lastName=${lastname2}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${cid2}  ${resp.json()}

     ${resp}=  GetCustomer  phoneNo-eq=${phone1}
     Log  ${resp.content}
     Should Be Equal As Strings      ${resp.status_code}  200
     Set Test Variable   ${jaldeeid2}    ${resp.json()[0]['jaldeeId']}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname2}
    
     ${apptfor1}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
     ${apptfor}=   Create List  ${apptfor1}
     
     ${cnote}=   FakerLibrary.word
     ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id2}  ${DAY1}  ${cnote}  ${apptfor}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
     Set Test Variable  ${apptid2}  ${apptid[0]}

     ${resp}=  Get Appointment EncodedID   ${apptid2}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${encId2}=  Set Variable   ${resp.json()}

     ${resp}=  Get Appointment By Id   ${apptid2}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid2}
     Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId2}
     # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jaldeeid2}
     # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${firstname2}
     # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${firstname2}
     Should Be Equal As Strings  ${resp.json()['providerConsumer']['jaldeeId']}   ${jaldeeid2}
     Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${firstname2}
     Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lastname2}
     Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id2}
     Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id2}
     Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${firstname2}
     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lastname2}
     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
     Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
     Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot2}
     Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid2}

     ${resp}=  Encrypted Provider Login  ${PUSERNAME257}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${pid3}=  get_acc_id  ${PUSERNAME257}

     ${resp}=   Get Appointment Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

     clear_service   ${PUSERNAME257}
     clear_location  ${PUSERNAME257}
     clear_customer   ${PUSERNAME257}

     ${resp}=   Get Service
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=    Get Locations
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=   Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[0]}

     ${resp}=   Get Appointment Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
     Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

     ${lid3}=  Create Sample Location  
     clear_appt_schedule   ${PUSERNAME257}
     
     ${DAY1}=  db.get_date_by_timezone  ${tz}
     ${DAY2}=  db.add_timezone_date  ${tz}  10        
     ${list}=  Create List  1  2  3  4  5  6  7
     ${sTime1}=  add_timezone_time  ${tz}  0  15  
     ${delta}=  FakerLibrary.Random Int  min=10  max=60
     ${eTime1}=  add_two   ${sTime1}  ${delta}
     ${s_id3}=  Create Sample Service  ${SERVICE2}
     ${schedule_name}=  FakerLibrary.bs
     ${parallel}=  FakerLibrary.Random Int  min=1  max=10
     ${maxval}=  Convert To Integer   ${delta/2}
     ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
     ${bool1}=  Random Element  ${bool}
     ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid3}  ${duration}  ${bool1}  ${s_id3}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${sch_id3}  ${resp.json()}

     ${resp}=  Get Appointment Schedule ById  ${sch_id3}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  id=${sch_id3}   name=${schedule_name}  apptState=${Qstate[0]}

     ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id3}  ${DAY1}  ${s_id3}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id3}
     Set Test Variable   ${slot3}   ${resp.json()['availableSlots'][0]['time']}

     ${firstname3}=  FakerLibrary.first_name
     ${lastname3}=  FakerLibrary.last_name 
     ${resp}=  AddCustomer  ${phone1}   firstName=${firstname3}   lastName=${lastname3}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${cid3}  ${resp.json()}

     ${resp}=  GetCustomer  phoneNo-eq=${phone1}
     Log  ${resp.content}
     Should Be Equal As Strings      ${resp.status_code}  200
     Set Test Variable   ${jaldeeid3}    ${resp.json()[0]['jaldeeId']}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid3}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname3}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname3}
    
     ${apptfor1}=  Create Dictionary  id=${cid3}   apptTime=${slot3}
     ${apptfor}=   Create List  ${apptfor1}
     
     ${cnote}=   FakerLibrary.word
     ${resp}=  Take Appointment For Consumer  ${cid3}  ${s_id3}  ${sch_id3}  ${DAY1}  ${cnote}  ${apptfor}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
     Set Test Variable  ${apptid3}  ${apptid[0]}

     ${resp}=  Get Appointment EncodedID   ${apptid3}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${encId3}=  Set Variable   ${resp.json()}

     ${resp}=  Get Appointment By Id   ${apptid3}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid3}
     Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId3}
     Should Be Equal As Strings  ${resp.json()['providerConsumer']['jaldeeId']}   ${jaldeeid3}
     Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${firstname3}
     Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lastname3}
     Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id3}
     Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id3}
     Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${firstname3}
     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lastname3}
     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot3}
     Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
     Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot3}
     Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid3}

     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${address}=  FakerLibrary.Address
     ${alternativeNo}=  Evaluate  ${PUSERNAME23}+73007
     ${dob}=  FakerLibrary.Date
     ${gender}=  Random Element    ${Genderlist}
     ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${phone1}    ${alternativeNo}  ${dob}  ${gender}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Activation  ${phone1}  1
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Set Credential  ${phone1}  ${PASSWORD}  1
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Login   ${phone1}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${jdconID}   ${resp.json()['id']}

     ${resp}=   Get consumer Appointment By Id   ${pid1}  ${apptid1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
     Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId1}
     # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
     # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${firstname1}
     # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${firstname1}
     Should Be Equal As Strings  ${resp.json()['providerConsumer']['jaldeeId']}   ${jaldeeid1}
     Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${firstname1}
     Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lastname1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id1}
     Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id1}
     Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${firstname1}
     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lastname1}
     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
     Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
     Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
     Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid1}

     
     ${resp}=   Get consumer Appointment By Id   ${pid2}  ${apptid2}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid2}
     Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId2}
     # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
     # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${firstname2}
     # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${firstname2}
     Should Be Equal As Strings  ${resp.json()['providerConsumer']['jaldeeId']}   ${jaldeeid2}
     Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${firstname2}
     Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lastname2}
     Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id2}
     Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id2}
     Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${firstname2}
     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lastname2}
     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
     Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
     Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot2}
     Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid2}

     ${resp}=   Get consumer Appointment By Id   ${pid3}  ${apptid3}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  ${resp.json()}   ${YOU_CANNOT_VIEW_THE_APPT}


     ${resp}=  Get Consumer Appointments 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${apptid1}
     Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}   ${encId1}
     # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
     # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${firstname1}
     # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${firstname1}
     Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['jaldeeId']}   ${jaldeeid1}
     Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['firstName']}   ${firstname1}
     Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['lastName']}   ${lastname1}
     Should Be Equal As Strings  ${resp.json()[0]['service']['id']}   ${s_id1}
     Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}   ${sch_id1}
     Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}   ${apptStatus[1]}
     Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['firstName']}   ${firstname1}
     Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['lastName']}   ${lastname1}
     Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['apptTime']}   ${slot1}
     Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}   ${DAY1}
     Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}   ${slot1}
     Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${lid1}
 
     Should Be Equal As Strings  ${resp.json()[1]['uid']}   ${apptid2}
     Should Be Equal As Strings  ${resp.json()[1]['appointmentEncId']}   ${encId2}
     # Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
     # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${firstname2}
     # Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${firstname2}
     Should Be Equal As Strings  ${resp.json()[1]['providerConsumer']['jaldeeId']}   ${jaldeeid2}
     Should Be Equal As Strings  ${resp.json()[1]['providerConsumer']['firstName']}   ${firstname2}
     Should Be Equal As Strings  ${resp.json()[1]['providerConsumer']['lastName']}   ${lastname2}
     Should Be Equal As Strings  ${resp.json()[1]['service']['id']}   ${s_id2}
     Should Be Equal As Strings  ${resp.json()[1]['schedule']['id']}   ${sch_id2}
     Should Be Equal As Strings  ${resp.json()[1]['apptStatus']}   ${apptStatus[1]}
     Should Be Equal As Strings  ${resp.json()[1]['appmtFor'][0]['firstName']}   ${firstname2}
     Should Be Equal As Strings  ${resp.json()[1]['appmtFor'][0]['lastName']}   ${lastname2}
     Should Be Equal As Strings  ${resp.json()[1]['appmtFor'][0]['apptTime']}   ${slot2}
     Should Be Equal As Strings  ${resp.json()[1]['appmtDate']}   ${DAY1}
     Should Be Equal As Strings  ${resp.json()[1]['appmtTime']}   ${slot2}
     Should Be Equal As Strings  ${resp.json()[1]['location']['id']}   ${lid2}
 
     ${resp}=  Encrypted Provider Login  ${PUSERNAME213}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=   Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[1]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
          ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${EMPTY}
          Should Be Equal As Strings  ${resp1.status_code}  200
     ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
          ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${EMPTY}  ${EMPTY}
          Should Be Equal As Strings  ${resp1.status_code}  200
     END
     
     ${resp}=  Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[0]}



JD-TC-AddCustomer-18

    [Documentation]  Provider takes appointment for a valid jaldee consumer number and get appointment details here jaldeeintegration is true

    ${resp}=  Consumer Login  ${CUSERNAME38}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME259}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid}=  get_acc_id  ${PUSERNAME259}

    ${resp}=  Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME259}
    clear_location  ${PUSERNAME259}
    clear_customer   ${PUSERNAME259}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME259}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id}=  Create Sample Service  ${SERVICE2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name   
    ${resp}=  AddCustomer  ${CUSERNAME38}   firstName=${firstname}   lastName=${lastname} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable   ${jaldeeid1}    ${resp.json()[0]['jaldeeId']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
    
    ${resp}=  Get Consumer By Id  ${CUSERNAME38}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${firstname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lastname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${firstname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lastname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

     ${resp}=  Consumer Login   ${CUSERNAME38}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
     Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId}
     Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${jdconID}
     Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}   ${fname}
     Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}   ${lname}
     Should Be Equal As Strings  ${resp.json()['providerConsumer']['jaldeeId']}   ${jaldeeid1}
     Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${firstname}
     Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lastname}
     Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
     Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
     Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${firstname}
     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lastname}
     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
     Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
     Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
     Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

     

JD-TC-AddCustomer-19

    [Documentation]  Provider takes appointment for a valid jaldee consumer and get the appointment details here jaldeeintegration is false

    ${resp}=  Consumer Login  ${CUSERNAME36}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME259}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid}=  get_acc_id  ${PUSERNAME259}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME259}
    clear_location  ${PUSERNAME259}
    clear_customer   ${PUSERNAME259}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[1]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
          ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${EMPTY}
          Should Be Equal As Strings  ${resp1.status_code}  200
     ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
          ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${EMPTY}  ${EMPTY}
          Should Be Equal As Strings  ${resp1.status_code}  200
     END
     
     ${resp}=  Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[0]}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_appt_schedule   ${PUSERNAME259}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id}=  Create Sample Service  ${SERVICE2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME36}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME36}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable   ${jaldeeid1}    ${resp.json()[0]['jaldeeId']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['phoneNo']}  ${CUSERNAME36}
    
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}   ${CUSERNAME36}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['jaldeeId']}   ${jaldeeid1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${EMPTY}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid}

    ${resp}=  Consumer Login   ${CUSERNAME36}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${YOU_CANNOT_VIEW_THE_APPT}


JD-TC-AddCustomer-20
     [Documentation]   Add a jaldee consumer to the waitlist for the current day here jaldee integration is true

     ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Suite Variable  ${jdconID1}   ${resp.json()['id']}
     Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
     Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

     ${resp}=  Consumer Logout
     Should Be Equal As Strings    ${resp.status_code}    200

     clear_queue      ${PUSERNAME184}
     clear_location   ${PUSERNAME184}
     clear_service    ${PUSERNAME184}
     clear_customer   ${PUSERNAME184}
     
     ${resp}=  Encrypted Provider Login  ${PUSERNAME184}  ${PASSWORD}   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}   200

     ${pid}=  get_acc_id  ${PUSERNAME184}

     ${resp}=   Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
          ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
          Should Be Equal As Strings  ${resp1.status_code}  200
     ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
          ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
          Should Be Equal As Strings  ${resp1.status_code}  200
     END
     
     ${resp}=  Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

     ${resp}=  View Waitlist Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}   200

     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get Consumer By Id  ${CUSERNAME1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name   
     ${resp}=  AddCustomer  ${CUSERNAME1}   firstName=${firstname}   lastName=${lastname}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${cid}  ${resp.json()}

     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
     Log  ${resp.content}
     Should Be Equal As Strings      ${resp.status_code}  200
     Set Test Variable   ${jaldeeid1}    ${resp.json()[0]['jaldeeId']}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
    
     ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
     ${resp}=   Create Sample Location
     Set Test Variable    ${loc_id1}    ${resp}  
     ${resp}=   Get Location ById  ${loc_id1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 
     ${resp}=   Get Location ById  ${loc_id1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
     ${resp}=   Create Sample Service  ${SERVICE1}
     Set Test Variable    ${ser_id1}    ${resp}  
     ${resp}=   Create Sample Service  ${SERVICE2}
     Set Test Variable    ${ser_id2}    ${resp}  
      
     ${q_name}=    FakerLibrary.name
     ${list}=  Create List   1  2  3  4  5  6  7
     ${strt_time}=   add_timezone_time  ${tz}  1  00  
     ${end_time}=    add_timezone_time  ${tz}  3  00   
     ${parallel}=   Random Int  min=1   max=1
     ${capacity}=  Random Int   min=10   max=20
     ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${que_id1}   ${resp.json()}
     ${desc}=   FakerLibrary.word
     ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${wid}=  Get Dictionary Values  ${resp.json()}
     Set Test Variable  ${wid}  ${wid[0]}

     ${resp}=  Get Waitlist By Id  ${wid} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0
     Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
     Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}       ${firstname}   
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}       ${lastname} 
     
     ${resp}=  Consumer Login   ${CUSERNAME1}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get consumer Waitlist By Id   ${wid}  ${pid}   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1     personsAhead=0
     Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}  ${ser_id1}
     Should Be Equal As Strings  ${resp.json()['consumer']['jaldeeId']}  ${jaldeeid1}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${firstname}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}  ${lastname}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['phoneNo']}  ${CUSERNAME1}
     Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id1}     


JD-TC-AddCustomer-21
     [Documentation]   Add a jaldee consumer to the waitlist for the current day here jaldee integration is false

     clear_queue      ${PUSERNAME184}
     # clear_location   ${PUSERNAME161}
     clear_service    ${PUSERNAME184}
     clear_customer   ${PUSERNAME184}
     
     ${resp}=  Encrypted Provider Login  ${PUSERNAME184}  ${PASSWORD}   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}   200

     ${pid}=  get_acc_id  ${PUSERNAME184}

     ${resp}=    Get Locations
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${loc_id1}  ${resp.json()[0]['id']}
     Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

     ${resp}=   Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[1]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
          ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${EMPTY}
          Should Be Equal As Strings  ${resp1.status_code}  200
     ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
          ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${EMPTY}  ${EMPTY}
          Should Be Equal As Strings  ${resp1.status_code}  200
     END
     
     ${resp}=  Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[0]}

     ${resp}=  View Waitlist Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}   200

     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get Consumer By Id  ${CUSERNAME2}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  AddCustomer  ${CUSERNAME2}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${cid}  ${resp.json()}

     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
     Log  ${resp.content}
     Should Be Equal As Strings      ${resp.status_code}  200
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['phoneNo']}  ${CUSERNAME2}
     
     ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
     Set Test Variable  ${CUR_DAY}
     # ${resp}=   Create Sample Location
     # Set Test Variable    ${loc_id1}    ${resp}  
     ${resp}=   Create Sample Service  ${SERVICE1}
     Set Test Variable    ${ser_id1}    ${resp}  
     ${resp}=   Create Sample Service  ${SERVICE2}
     Set Test Variable    ${ser_id2}    ${resp}  
      
     ${q_name}=    FakerLibrary.name
     ${list}=  Create List   1  2  3  4  5  6  7
     ${strt_time}=   add_timezone_time  ${tz}  1  00  
     ${end_time}=    add_timezone_time  ${tz}  3  00   
     ${parallel}=   Random Int  min=1   max=1
     ${capacity}=  Random Int   min=10   max=20
     ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${que_id1}   ${resp.json()}
     ${desc}=   FakerLibrary.word
     ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${wid}=  Get Dictionary Values  ${resp.json()}
     Set Test Variable  ${wid}  ${wid[0]}

     ${resp}=  Get Waitlist By Id  ${wid} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0
     Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
     Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
     # Should Not Contain  ${resp.json()['waitlistingFor'][0]['firstName']}      
     # Should Not Contain  ${resp.json()['waitlistingFor'][0]['lastName']}       
     
     ${resp}=  Consumer Login   ${CUSERNAME2}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get consumer Waitlist By Id   ${wid}  ${pid}   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  401
     Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"



JD-TC-AddCustomer-22
     [Documentation]   Add a new consumer to the waitlist for the current day here jaldee integration is false

     clear_queue      ${PUSERNAME162}
     # clear_location   ${PUSERNAME162}
     clear_service    ${PUSERNAME162}
     clear_customer   ${PUSERNAME162}
     
     ${resp}=  Encrypted Provider Login  ${PUSERNAME162}  ${PASSWORD}   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}   200

     ${resp}=    Get Locations
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${loc_id1}  ${resp.json()[0]['id']}
     Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

     ${resp}=   Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[0]}

     ${phone}=  Evaluate  ${PUSERNAME162}+71002
     ${resp}=  AddCustomer  ${phone}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${cid}  ${resp.json()}

     ${resp}=  GetCustomer  phoneNo-eq=${phone}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['phoneNo']}  ${phone}

     ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
     Set Suite Variable  ${CUR_DAY}
     ${resp}=   Create Sample Service  ${SERVICE1}
     Set Suite Variable    ${ser_id1}    ${resp}  

     ${q_name}=    FakerLibrary.name
     Set Suite Variable    ${q_name}
     ${list}=  Create List   1  2  3  4  5  6  7
     Set Suite Variable    ${list}
     ${strt_time}=   add_timezone_time  ${tz}  1  00  
     Set Suite Variable    ${strt_time}
     ${end_time}=    add_timezone_time  ${tz}  3  00   
     Set Suite Variable    ${end_time}   
     ${parallel}=   Random Int  min=1   max=1
     Set Suite Variable   ${parallel}
     ${capacity}=  Random Int   min=10   max=20
     Set Suite Variable   ${capacity}
     ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${que_id1}   ${resp.json()}
     ${desc}=   FakerLibrary.word
     Set Suite Variable  ${desc}
     ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     
     ${wid}=  Get Dictionary Values  ${resp.json()}
     Set Test Variable  ${wid}  ${wid[0]}
     ${resp}=  Get Waitlist By Id  ${wid} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1    waitlistedBy=${waitlistedby[1]}   personsAhead=0
     Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
     Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['phoneNo']}    ${phone}      

JD-TC-AddCustomer-23
     [Documentation]   Add customer and take both online and walkin checkin and check waitlist details(first jaldee integratration is false and then jaldee integration is true)
    
     ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Test Variable  ${jdconID}   ${resp.json()['id']}
     Set Test Variable  ${fname1}   ${resp.json()['firstName']}
     Set Test Variable  ${lname1}   ${resp.json()['lastName']}

     ${resp}=  Consumer Logout
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Consumer Login  ${CUSERNAME37}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Test Variable  ${jdconID1}   ${resp.json()['id']}
     Set Test Variable  ${fname3}   ${resp.json()['firstName']}
     Set Test Variable  ${lname3}   ${resp.json()['lastName']}

     ${resp}=  Consumer Logout
     Should Be Equal As Strings    ${resp.status_code}    200
    
     ${multilocdoms}=  get_mutilocation_domains
     Log  ${multilocdoms}
     Set Test Variable  ${dom}  ${multilocdoms[0]['domain']}
     Set Test Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+7850019
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_C}    ${highest_package[0]}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${PUSERNAME_C}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${PUSERNAME_C}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${decrypted_data}=  db.decrypt_data  ${resp.content}
     Log  ${decrypted_data}
     Set Suite Variable  ${id}   ${decrypted_data['id']}

     # Set Suite Variable    ${id}    ${resp.json()['id']}       
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_C}${\n}
     Set Suite Variable  ${PUSERNAME_C}

     clear waitlist   ${PUSERNAME_C}
     ${pid}=  get_acc_id  ${PUSERNAME_C}
     Set Suite Variable  ${pid}

     ${DAY1}=  db.get_date_by_timezone  ${tz}
     ${list}=  Create List  1  2  3  4  5  6  7
     ${ph1}=  Evaluate  ${PUSERNAME_C}+15566122
     ${ph2}=  Evaluate  ${PUSERNAME_C}+25566122
     ${views}=  Random Element    ${Views}
     ${name1}=  FakerLibrary.name
     ${name2}=  FakerLibrary.name
     ${name3}=  FakerLibrary.name
     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
     ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
     ${bs}=  FakerLibrary.bs
     ${companySuffix}=  FakerLibrary.companySuffix
     # ${city}=   get_place
     # ${latti}=  get_latitude
     # ${longi}=  get_longitude
     # ${postcode}=  FakerLibrary.postcode
     # ${address}=  get_address
     ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
     ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
     Set Suite Variable  ${tz}
     ${parking}   Random Element   ${parkingType}
     ${24hours}    Random Element    ${bool}
     ${desc}=   FakerLibrary.sentence
     ${url}=   FakerLibrary.url
     ${sTime}=  add_timezone_time  ${tz}  0  15  
     ${eTime}=  add_timezone_time  ${tz}  0  45  
     ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Get Business Profile
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
     Log  ${fields.json()}
     Should Be Equal As Strings    ${fields.status_code}   200

     ${virtual_fields}=  get_Subdomainfields  ${fields.json()}
 
     ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
     Should Be Equal As Strings    ${resp.status_code}   200

     ${spec}=  get_Specializations  ${resp.json()}
     ${resp}=  Update Specialization  ${spec}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}   200

     ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[1]}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Enable Waitlist
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep   01s
    
     ${resp}=  View Waitlist Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}   200

     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=   Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[0]}

     ${resp}=  AddCustomer  ${CUSERNAME1}   firstName=${fname1}   lastName=${lname1} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid1}  ${resp.json()}

     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
     Log  ${resp.content}
     Should Be Equal As Strings      ${resp.status_code}  200
     Set Test Variable  ${pcons_id0}  ${resp.json()[0]['id']}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}

     ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
     ${C_date}=  Convert Date  ${CUR_DAY}  result_format=%d-%m-%Y
     Set Test Variable   ${C_date}
     ${resp}=   Create Sample Location
     Set Test Variable    ${loc_id1}    ${resp}  
     ${resp}=   Get Location ById  ${loc_id1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 
     ${resp}=   Create Sample Service  ${SERVICE1}
     Set Test Variable    ${ser_id1}    ${resp} 
     ${resp}=   Create Sample Service  ${SERVICE2}
     Set Test Variable    ${ser_id2}    ${resp} 
     ${resp}=   Create Sample Service  ${SERVICE3}
     Set Test Variable    ${ser_id3}    ${resp} 
     ${resp}=   Create Sample Service  ${SERVICE4}
     Set Test Variable    ${ser_id4}    ${resp}  
     ${q_name}=    FakerLibrary.name
     ${list}=  Create List   1  2  3  4  5  6  7
     ${strt_time}=   add_timezone_time  ${tz}  1  00  
     Set Test Variable   ${strt_time}
     ${end_time}=    add_timezone_time  ${tz}  3  00    
     ${parallel}=   Random Int  min=1   max=1
     ${capacity}=  Random Int   min=10   max=20
     ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}  ${ser_id3}  ${ser_id4} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${que_id1}   ${resp.json()}
     ${desc}=   FakerLibrary.word
     ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${wid}=  Get Dictionary Values  ${resp.json()}
     Set Test Variable  ${wid1}  ${wid[0]}

     ${resp}=  Get Waitlist By Id  ${wid1} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}    date=${CUR_DAY}   waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}  personsAhead=0
     Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
     Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid1}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid1}

     ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200  

     ${cnote}=   FakerLibrary.word
     ${resp}=  Add To Waitlist Consumers  ${pid}  ${que_id1}  ${CUR_DAY}  ${ser_id2}  ${cnote}  ${bool[0]}  ${self}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200 
     ${wid}=  Get Dictionary Values  ${resp.json()}
     Set Test Variable  ${wid2}  ${wid[0]}

     ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${pid}   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=2  waitlistedBy=CONSUMER  personsAhead=1
     Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE2}
     Should Be Equal As Strings  ${resp.json()['service']['id']}  ${ser_id2}
     Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${jdconID}
     # Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${pcons_id0}
     Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id1}

     ${resp}=   Get Waitlist Consumer
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response List  ${resp}    0    date=${CUR_DAY}    waitlistStatus=${wl_status[0]}   partySize=1     waitlistedBy=${waitlistedby[0]}    personsAhead=1
     Should Be Equal As Strings  ${resp.json()[0]['service']['name']}  ${SERVICE2}
     Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${ser_id2}
     # Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}  ${cid1}
     # Should Be Equal As Strings  ${resp.json()[0]['consumer']['jaldeeId']}  ${jaldeeid1}
     # Should Be Equal As Strings  ${resp.json()[0]['waitlistingFor'][0]['id']}  ${cid1}
     Should Be Equal As Strings  ${resp.json()[0]['waitlistingFor'][0]['firstName']}  ${fname1}
     Should Be Equal As Strings  ${resp.json()[0]['waitlistingFor'][0]['lastName']}  ${lname1}
     Should Be Equal As Strings  ${resp.json()[0]['waitlistingFor'][0]['phoneNo']}  ${CUSERNAME1}
     Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}  ${que_id1}     


     ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=   Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
          ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
          Should Be Equal As Strings  ${resp1.status_code}  200
     ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
          ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
          Should Be Equal As Strings  ${resp1.status_code}  200
     END
     
     ${resp}=  Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

     ${resp}=  AddCustomer  ${CUSERNAME37}   firstName=${fname3}  lastName=${lname3} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid3}  ${resp.json()}

     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME37}
     Log  ${resp.content}
     Should Be Equal As Strings      ${resp.status_code}  200
     Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid3}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${fname3}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lname3}
    
     ${desc}=   FakerLibrary.word
     ${resp}=  Add To Waitlist  ${cid3}  ${ser_id3}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid3} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${wid}=  Get Dictionary Values  ${resp.json()}
     Set Test Variable  ${wid3}  ${wid[0]}

     ${resp}=  Get Waitlist By Id  ${wid3} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}  personsAhead=2
     Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE3}
     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id3}
     Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid3}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid3}

     ${resp}=  Consumer Login  ${CUSERNAME37}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200  

     ${cnote}=   FakerLibrary.word
     ${resp}=  Add To Waitlist Consumers  ${pid}  ${que_id1}  ${CUR_DAY}  ${ser_id4}  ${cnote}  ${bool[0]}  ${self}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200 
     ${wid}=  Get Dictionary Values  ${resp.json()}
     Set Test Variable  ${wid4}  ${wid[0]}

     ${resp}=  Get consumer Waitlist By Id   ${wid4}  ${pid}   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=6  waitlistedBy=CONSUMER  personsAhead=3
     Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE4}
     Should Be Equal As Strings  ${resp.json()['service']['id']}  ${ser_id4}
     Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${jdconID1}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid3}
     Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id1}

     ${resp}=   Get Waitlist Consumer
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     Verify Response List  ${resp}  0   date=${CUR_DAY}  waitlistStatus=${wl_status[0]}  partySize=1    waitlistedBy=${waitlistedby[0]}    personsAhead=3
     Should Be Equal As Strings  ${resp.json()[0]['service']['name']}  ${SERVICE4}
     Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${ser_id4}
     Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}  ${cid3}
     Should Be Equal As Strings  ${resp.json()[0]['consumer']['jaldeeId']}  ${jaldeeId}
     Should Be Equal As Strings  ${resp.json()[0]['waitlistingFor'][0]['id']}  ${cid3}
     Should Be Equal As Strings  ${resp.json()[0]['waitlistingFor'][0]['firstName']}  ${fname3}
     Should Be Equal As Strings  ${resp.json()[0]['waitlistingFor'][0]['lastName']}  ${lname3}
     Should Be Equal As Strings  ${resp.json()[0]['waitlistingFor'][0]['phoneNo']}  ${CUSERNAME37}
     Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}  ${que_id1}     

     Verify Response List  ${resp}  1   date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1    waitlistedBy=${waitlistedby[1]}    personsAhead=2
     Should Be Equal As Strings  ${resp.json()[1]['service']['name']}  ${SERVICE3}
     Should Be Equal As Strings  ${resp.json()[1]['service']['id']}  ${ser_id3}
     Should Be Equal As Strings  ${resp.json()[1]['consumer']['id']}  ${cid3}
     Should Be Equal As Strings  ${resp.json()[1]['consumer']['jaldeeId']}  ${jaldeeId}
     Should Be Equal As Strings  ${resp.json()[1]['waitlistingFor'][0]['id']}  ${cid3}
     Should Be Equal As Strings  ${resp.json()[1]['waitlistingFor'][0]['firstName']}  ${fname3}
     Should Be Equal As Strings  ${resp.json()[1]['waitlistingFor'][0]['lastName']}  ${lname3}
     Should Be Equal As Strings  ${resp.json()[1]['waitlistingFor'][0]['phoneNo']}  ${CUSERNAME37}
     Should Be Equal As Strings  ${resp.json()[1]['queue']['id']}  ${que_id1}     


JD-TC-AddCustomer-UH8
     [Documentation]   Add the same customer twice with same details

     ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     Set Test Variable  ${jdconID}   ${resp.json()['id']}
     Set Test Variable  ${fname2}   ${resp.json()['firstName']}
     Set Test Variable  ${lname2}   ${resp.json()['lastName']}

     ${resp}=  Consumer Logout
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     clear_customer   ${PUSERNAME_C}

     ${resp}=  AddCustomer  ${CUSERNAME2}   firstName=${fname2}  lastName=${lname2} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid2}  ${resp.json()}

     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
     Log  ${resp.content}
     Should Be Equal As Strings      ${resp.status_code}  200
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${fname2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lname2}

     ${resp}=  AddCustomer  ${CUSERNAME2}   firstName=${fname2}  lastName=${lname2} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"    "${PRO_CON_ALREADY_EXIST}"

     # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
     # Log  ${resp.content}
     # Should Be Equal As Strings      ${resp.status_code}  200
     # Set Test Variable  ${pcons_id0}  ${resp.json()[0]['id']}


JD-TC-AddCustomer-UH5
     [Documentation]   Add a new customer and take provider side waitlist and signup that consumer and take waitlist to the same service and queue 


     ${resp}=  Encrypted Provider Login  ${PUSERNAME162}  ${PASSWORD}   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}   200

     ${pid0}=  get_acc_id  ${PUSERNAME162}
     Set Suite Variable  ${pid0}  
     
     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${phone}=  Evaluate  ${PUSERNAME162}+71004    
     ${resp}=  AddCustomer  ${phone}   firstName=${firstname}   lastName=${lastname}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${cid2}  ${resp.json()}

     ${resp}=  GetCustomer  phoneNo-eq=${phone}
     Log  ${resp.content}
     Should Be Equal As Strings   ${resp.status_code}  200
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid2}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}

     ${resp}=  Add To Waitlist  ${cid2}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid2} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${wid}=  Get Dictionary Values  ${resp.json()}
     Set Test Variable  ${wid}  ${wid[0]}

     ${resp}=  Get Waitlist By Id  ${wid} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1    waitlistedBy=${waitlistedby[1]}   personsAhead=1
     Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
     Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['phoneNo']}    ${phone}      
     
     ${address}=  FakerLibrary.Address
     ${alternativeNo}=  Evaluate  ${PUSERNAME23}+73007
     ${dob}=  FakerLibrary.Date
     ${gender}=  Random Element    ${Genderlist}
     ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${phone}    ${alternativeNo}  ${dob}  ${gender}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Activation  ${phone}  1
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Set Credential  ${phone}  ${PASSWORD}  1
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Login   ${phone}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${cnote}=   FakerLibrary.word
     ${resp}=  Add To Waitlist Consumers  ${pid0}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  ${resp.json()}    ${WAITLIST_CUSTOMER_ALREADY_IN}
     
JD-TC-AddCustomer-UH6
     [Documentation]   Take wailist from consumer side and provider Add thats same wailisted consumer 

     ${resp}=  Encrypted Provider Login  ${PUSERNAME162}  ${PASSWORD}   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}   200

     ${pid0}=  get_acc_id  ${PUSERNAME162}
     Set Suite Variable  ${pid0}  
     
     ${resp}=  Consumer Login   ${CUSERNAME2}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${cnote}=   FakerLibrary.word
     ${resp}=  Add To Waitlist Consumers  ${pid0}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200 
     ${wid}=  Get Dictionary Values  ${resp.json()}
     Set Test Variable  ${wid1}  ${wid[0]}

     ${resp}=  Encrypted Provider Login  ${PUSERNAME162}  ${PASSWORD}   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}   200

     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid1}  ${resp.json()[0]['id']}

     ${resp}=  Consumer Login   ${CUSERNAME2}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[0]}  partySize=1    waitlistedBy=CONSUMER  personsAhead=2
     Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}  ${ser_id1}
     # Should Be Equal As Strings  ${resp.json()['jaldeeConsumer']['id']}  ${cid2}           
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid1}  
     Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id1}

     ${resp}=  Encrypted Provider Login  ${PUSERNAME162}  ${PASSWORD}   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}   200

     ${resp}=  AddCustomer  ${CUSERNAME2}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"   "${PRO_CON_ALREADY_EXIST}" 


JD-TC-AddCustomer-UH7
     [Documentation]   Add customer with international phone number

     ${resp}=  Encrypted Provider Login  ${PUSERNAME38}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Get Business Profile
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     # Set Test Variable  ${bname}  ${resp.json()['businessName']}
     # Set Test Variable  ${pid}  ${resp.json()['id']}
     # Set Test Variable  ${uniqueId}  ${resp.json()['uniqueId']}

     ${resp}=   Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
          ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
          Should Be Equal As Strings  ${resp1.status_code}  200
     ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
          ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
          Should Be Equal As Strings  ${resp1.status_code}  200
     END
     
     ${resp}=  Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

     ${PO_Number1}    Generate random string    5    0123456789
     ${PO_Number1}    Convert To Integer  ${PO_Number1}
     ${country_code}    Generate random string    2    0123456789
     ${country_code}    Convert To Integer  ${country_code}
     ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number1}
     # Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH0}${\n}
     ${fname}=  FakerLibrary.first_name
     ${lname}=  FakerLibrary.last_name
     ${resp}=   AddCustomer  ${CUSERPH0}  countryCode=+${country_code}  firstName=${fname}  lastName=${lname}  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  ${resp.json()}   ${INVALID_PHONE} 
     # Set Test Variable  ${cid}  ${resp.json()}
     
     # ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
     # Log  ${resp.content}
     # Should Be Equal As Strings  ${resp.status_code}  200
     # Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid}

     # ${resp}=  Provider Logout
     # Log  ${resp.content}
     # Should Be Equal As Strings    ${resp.status_code}    200

D-TC-AddCustomer-UH8
     [Documentation]  Add a  customer with invalid secondary number
     ${resp}=  ProviderLogin  ${PUSERNAME230}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${p_id}  ${resp.json()['id']}
     ${firstname}=  FakerLibrary.first_name
     ${lname}=  FakerLibrary.last_name
     ${ph2}=  FakerLibrary.RandomNumber  digits=9
     ${dob}=  FakerLibrary.Date
     ${gender}=  Random Element    ${Genderlist}
     ${resp}=  AddCustomer  ${phone1}   firstName=${firstname}   lastName=${lname}  secondaryCountryCode=${countryCodes[0]}  secondaryPhoneNo=${ph2}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  ${resp.json()}   ${INVALID_FOR_SECONDARY_NO}
   
    
JD-TC-AddCustomer-24
     [Documentation]  Add a new valid customer without Secondary phone number
     ${resp}=  ProviderLogin  ${PUSERNAME230}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${p_id}  ${resp.json()['id']}
     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${ph2}=  Evaluate  ${PUSERNAME23}+73009
     ${dob}=  FakerLibrary.Date
     ${gender}=  Random Element    ${Genderlist}
     ${resp}=  AddCustomer  ${phone1}   firstName=${firstname}   lastName=${lastname}  secondaryCountryCode=${countryCodes[0]}  secondaryPhoneNo=${ph2}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid}  ${resp.json()}
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph2}${\n}
     ${resp}=  GetCustomer ById  ${cid}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['firstName']}  ${firstname}
     Should Be Equal As Strings  ${resp.json()['lastName']}  ${lastname}
     Should Be Equal As Strings  ${resp.json()['secondaryCountryCode']}  ${countryCodes[0]}
     Should Be Equal As Strings  ${resp.json()['secondaryPhoneNo']}  ${ph2}
     ${resp}=  GetCustomer    secondaryPhoneNo-eq=${ph2}    status-eq=ACTIVE
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response List  ${resp}  0  firstName=${firstname}  lastName=${lastname}  phoneNo=${phone1}  secondaryCountryCode=${countryCodes[0]}  secondaryPhoneNo=${ph2}


JD-TC-AddCustomer-25
     [Documentation]  Add a customer with manual id.

     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${decrypted_data}=  db.decrypt_data  ${resp.content}
     Log  ${decrypted_data}
     Set Test Variable  ${p_id}  ${decrypted_data['id']}
     
     ${resp}=  Get Accountsettings  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     IF  '${resp.json()['jaldeeIdFormat']['customerSeriesEnum']}' == '${customerseries[0]}'
          ${resp}=  JaldeeId Format   ${customerseries[1]}   ${EMPTY}   ${EMPTY}
          Log  ${resp.content}
          Should Be Equal As Strings  ${resp.status_code}  200
     END

     ${resp}=  Get Accountsettings  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['jaldeeIdFormat']['customerSeriesEnum']}  ${customerseries[1]}

     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${cust_no}    FakerLibrary.Numerify   text=%######
     Set Test Variable  ${cust_no}  555${cust_no}
     ${dob}=  FakerLibrary.Date
     ${gender}=  Random Element    ${Genderlist}
     ${jaldeeid}=  Generate Random String  6  [LETTERS][NUMBERS]
     ${resp}=  AddCustomer  ${cust_no}   countryCode=${countryCodes[0]}  firstName=${firstname}   lastName=${lastname}  jaldeeId=${jaldeeid}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid}  ${resp.json()}
     ${resp}=  GetCustomer ById  ${cid}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['jaldeeId']}  ${jaldeeid}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['lastName']}  ${lastname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['address']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['gender']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['dob']}  ${EMPTY}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phoneNo']}  ${cust_no}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['favourite']}  ${bool[0]}


JD-TC-AddCustomer-26
     [Documentation]  Add a customer by provider and do a provider consumer signup for that customer

     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${decrypted_data}=  db.decrypt_data  ${resp.content}
     Log  ${decrypted_data}
     Set Test Variable  ${p_id}  ${decrypted_data['id']}

     ${resp}=  Get Business Profile
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${acc_id1}  ${resp.json()['id']}
     
     ${resp}=  Get Accountsettings  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     IF  '${resp.json()['jaldeeIdFormat']['customerSeriesEnum']}' == '${customerseries[0]}'
          ${resp}=  JaldeeId Format   ${customerseries[1]}   ${EMPTY}   ${EMPTY}
          Log  ${resp.content}
          Should Be Equal As Strings  ${resp.status_code}  200
     END

     ${resp}=  Get Accountsettings  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['jaldeeIdFormat']['customerSeriesEnum']}  ${customerseries[1]}

     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${cust_no}    FakerLibrary.Numerify   text=%######
     Set Test Variable  ${cust_no}  555${cust_no}
     ${dob}=  FakerLibrary.Date
     ${address}=  FakerLibrary.address
     ${gender}=  Random Element    ${Genderlist}
     ${jaldeeid}=  Generate Random String  6  [LETTERS][NUMBERS]
     Set Test Variable  ${email}  ${C_Email}${primaryMobileNo}.${test_mail}
     ${resp}=  AddCustomer  ${cust_no}   countryCode=${countryCodes[0]}  firstName=${firstname}   lastName=${lastname}  address=${address}   gender=${gender}  dob=${dob}  email=${email}  jaldeeId=${jaldeeid}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid}  ${resp.json()}
     ${resp}=  GetCustomer ById  ${cid}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['jaldeeId']}  ${jaldeeid}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['firstName']}  ${firstname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['lastName']}  ${lastname}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['address']}  ${address}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email']}  ${email}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['gender']}  ${gender}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['dob']}  ${dob}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phoneNo']}  ${cust_no}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['status']}  ${status[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['countryCode']}  ${countryCodes[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['jaldeeConsumerDetails']['SignedUp']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['isSignUpCustomer']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['phone_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['email_verified']}  ${bool[0]}
     Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['favourite']}  ${bool[0]}

     ${resp}=  ProviderLogout
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=    Send Otp For Login    ${cust_no}    ${acc_id1}   countryCode=${CountryCode}
     Log   ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}   200

     ${resp}=    Verify Otp For Login   ${cust_no}   ${OtpPurpose['Authentication']}
     Log   ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}   200
     Set Test Variable  ${token}  ${resp.json()['token']}

     ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${cust_no}  ${acc_id1}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}   200    

     ${resp}=  Customer Logout   
     Should Be Equal As Strings    ${resp.status_code}    200
     
     ${resp}=    ProviderConsumer Login with token   ${cust_no}  ${acc_id1}  ${token} 
     Log   ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}   200
     Set Test Variable    ${cid1}    ${resp.json()['providerConsumer']}

     Should Be Equal As Strings  ${cid}   ${cid1}

JD-TC-AddCustomer-UH9
     [Documentation]  Add a customer without country code

     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${decrypted_data}=  db.decrypt_data  ${resp.content}
     Log  ${decrypted_data}
     Set Test Variable  ${p_id}  ${decrypted_data['id']}

     ${resp}=  Get Business Profile
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${acc_id1}  ${resp.json()['id']}
     
     ${resp}=  Get Accountsettings  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     IF  '${resp.json()['jaldeeIdFormat']['customerSeriesEnum']}' == '${customerseries[0]}'
          ${resp}=  JaldeeId Format   ${customerseries[1]}   ${EMPTY}   ${EMPTY}
          Log  ${resp.content}
          Should Be Equal As Strings  ${resp.status_code}  200
     END

     ${resp}=  Get Accountsettings  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['jaldeeIdFormat']['customerSeriesEnum']}  ${customerseries[1]}

     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${cust_no}    FakerLibrary.Numerify   text=%######
     Set Test Variable  ${cust_no}  555${cust_no}
     ${dob}=  FakerLibrary.Date
     ${address}=  FakerLibrary.address
     ${gender}=  Random Element    ${Genderlist}
     ${jaldeeid}=  Generate Random String  6  [LETTERS][NUMBERS]
     Set Test Variable  ${email}  ${C_Email}${primaryMobileNo}.${test_mail}
     ${resp}=  AddCustomer  ${cust_no}   countryCode=${EMPTY}  firstName=${firstname}   lastName=${lastname}  address=${address}   gender=${gender}  dob=${dob}  email=${email}  jaldeeId=${jaldeeid}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  ${resp.json()}   ${COUNTRY_CODEREQUIRED}


JD-TC-AddCustomer-UH10
     [Documentation]  Add a customer without secondary country code

     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${decrypted_data}=  db.decrypt_data  ${resp.content}
     Log  ${decrypted_data}
     Set Test Variable  ${p_id}  ${decrypted_data['id']}

     ${resp}=  Get Business Profile
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${acc_id1}  ${resp.json()['id']}
     
     ${resp}=  Get Accountsettings  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     IF  '${resp.json()['jaldeeIdFormat']['customerSeriesEnum']}' == '${customerseries[0]}'
          ${resp}=  JaldeeId Format   ${customerseries[1]}   ${EMPTY}   ${EMPTY}
          Log  ${resp.content}
          Should Be Equal As Strings  ${resp.status_code}  200
     END

     ${resp}=  Get Accountsettings  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['jaldeeIdFormat']['customerSeriesEnum']}  ${customerseries[1]}

     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${cust_no}    FakerLibrary.Numerify   text=%######
     Set Test Variable  ${cust_no}  555${cust_no}
     ${dob}=  FakerLibrary.Date
     ${address}=  FakerLibrary.address
     ${gender}=  Random Element    ${Genderlist}
     ${jaldeeid}=  Generate Random String  6  [LETTERS][NUMBERS]
     ${sec_cust_no}=  FakerLibrary.RandomNumber  digits=9
     Set Test Variable  ${email}  ${C_Email}${primaryMobileNo}.${test_mail}
     ${resp}=  AddCustomer  ${cust_no}   countryCode=${countryCodes[0]}  firstName=${firstname}   lastName=${lastname}  address=${address}   gender=${gender}  dob=${dob}  email=${email}  jaldeeId=${jaldeeid}  secondaryCountryCode=${EMPTY}  secondaryPhoneNo=${sec_cust_no}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  ${resp.json()}   ${COUNTRY_CODE_REQUIRED_FOR_SECONDARY_NO}


JD-TC-AddCustomer-UH11
     [Documentation]  Add a customer with invalid country code

     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${decrypted_data}=  db.decrypt_data  ${resp.content}
     Log  ${decrypted_data}
     Set Test Variable  ${p_id}  ${decrypted_data['id']}

     ${resp}=  Get Business Profile
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${acc_id1}  ${resp.json()['id']}
     
     ${resp}=  Get Accountsettings  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     IF  '${resp.json()['jaldeeIdFormat']['customerSeriesEnum']}' == '${customerseries[0]}'
          ${resp}=  JaldeeId Format   ${customerseries[1]}   ${EMPTY}   ${EMPTY}
          Log  ${resp.content}
          Should Be Equal As Strings  ${resp.status_code}  200
     END

     ${resp}=  Get Accountsettings  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['jaldeeIdFormat']['customerSeriesEnum']}  ${customerseries[1]}

     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${cust_no}    FakerLibrary.Numerify   text=%######
     Set Test Variable  ${cust_no}  555${cust_no}
     ${dob}=  FakerLibrary.Date
     ${address}=  FakerLibrary.address
     ${gender}=  Random Element    ${Genderlist}
     ${jaldeeid}=  Generate Random String  6  [LETTERS][NUMBERS]
     ${inv_cc}=  FakerLibrary.RandomNumber  digits=3
     Set Test Variable  ${email}  ${C_Email}${primaryMobileNo}.${test_mail}
     ${resp}=  AddCustomer  ${cust_no}   countryCode=${inv_cc}  firstName=${firstname}   lastName=${lastname}  address=${address}   gender=${gender}  dob=${dob}  email=${email}  jaldeeId=${jaldeeid}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  ${resp.json()}   ${INVALID_COUNTRYCODE}


JD-TC-AddCustomer-UH12
     [Documentation]  Add a customer with invalid secondary country code

     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${decrypted_data}=  db.decrypt_data  ${resp.content}
     Log  ${decrypted_data}
     Set Test Variable  ${p_id}  ${decrypted_data['id']}

     ${resp}=  Get Business Profile
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${acc_id1}  ${resp.json()['id']}
     
     ${resp}=  Get Accountsettings  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     IF  '${resp.json()['jaldeeIdFormat']['customerSeriesEnum']}' == '${customerseries[0]}'
          ${resp}=  JaldeeId Format   ${customerseries[1]}   ${EMPTY}   ${EMPTY}
          Log  ${resp.content}
          Should Be Equal As Strings  ${resp.status_code}  200
     END

     ${resp}=  Get Accountsettings  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['jaldeeIdFormat']['customerSeriesEnum']}  ${customerseries[1]}

     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${cust_no}    FakerLibrary.Numerify   text=%######
     Set Test Variable  ${cust_no}  555${cust_no}
     ${dob}=  FakerLibrary.Date
     ${address}=  FakerLibrary.address
     ${gender}=  Random Element    ${Genderlist}
     ${jaldeeid}=  Generate Random String  6  [LETTERS][NUMBERS]
     ${sec_cust_no}=  FakerLibrary.RandomNumber  digits=10
     ${inv_sec_cc}=  FakerLibrary.RandomNumber  digits=3
     Set Test Variable  ${email}  ${C_Email}${primaryMobileNo}.${test_mail}
     ${resp}=  AddCustomer  ${cust_no}   countryCode=${countryCodes[0]}  firstName=${firstname}   lastName=${lastname}  address=${address}   gender=${gender}  dob=${dob}  email=${email}  jaldeeId=${jaldeeid}  secondaryCountryCode=${inv_sec_cc}  secondaryPhoneNo=${sec_cust_no}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  ${resp.json()}   ${COUNTRY_CODE_INVALID_FOR_SECONDARY_NO}







***Comment***
JD-TC-AddCustomer-5
    [Documentation]  Provider signup for already added customer without email  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME230}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  AddCustomer  Ricky  J  ${ph3}   ${dob}  ${gender}  ${EMPTY}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  Ricky  J  ${None}  ${d1}  ${sd1}  ${ph3}    1
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${email3}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${email3}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${ph3}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-AddCustomer-9
     [Documentation]  Add a new valid customer without phone number
     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${p_id}  ${resp.json()['id']}
     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${dob}=  FakerLibrary.Date
     ${gender}=  Random Element    ${Genderlist}
     Set Test Variable  ${email}  ${firstname}231${C_Email}.${test_mail}
     ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email}  ${gender}  ${dob}  ${EMPTY}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${cid2}  ${resp.json()}
     ${resp}=  GetCustomer     phoneNo-eq=${EMPTY}   status-eq=ACTIVE
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response List  ${resp}  0  firstName=${firstname}  lastName=${lastname}  phoneNo=${EMPTY}  dob=${dob}  gender=${gender}  email_verified=${bool[0]}   phone_verified=${bool[0]}  id=${cid2}  favourite=${bool[0]}
     # Should Be Equal As Strings  "${resp.json()}"  "${ENTER_CON_PHONE_NO}"

JD-TC-AddCustomer-91
     [Documentation]   Set providers jaldeeId format as manual and a consumers family member added to waitlist, here the consumer is not a provider customer so the jaldeeid is consumer phone number. 
     clear_queue      ${PUSERNAME231}
     clear_location   ${PUSERNAME231}
     clear_service    ${PUSERNAME231}
     clear waitlist   ${PUSERNAME231}
     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${p_id}  ${resp.json()['id']}
     ${pid0}=  get_acc_id  ${PUSERNAME231}

     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
     ${resp}=   Create Sample Location
     Set Test Variable    ${loc_id1}    ${resp}  
     ${resp}=   Get Location ById  ${loc_id1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 
     ${resp}=   Create Sample Service  ${SERVICE1}
     Set Test Variable    ${ser_id1}    ${resp}
     ${q_name}=    FakerLibrary.name
     ${list}=  Create List   1  2  3  4  5  6  7
     ${strt_time}=   add_timezone_time  ${tz}  3  00  
     ${end_time}=    add_timezone_time  ${tz}  3  30      
     ${parallel}=   Random Int  min=1   max=1
     ${capacity}=  Random Int   min=10   max=20
     ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${que_id1}   ${resp.json()} 

     ${resp}=  JaldeeId Format   ${customerseries[1]}   ${EMPTY}   ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  ProviderLogout
     Should Be Equal As Strings  ${resp.status_code}  200

     ${CUSERPH0}=  Evaluate  ${CUSERPH}+100100344
     Set Suite Variable   ${CUSERPH0}
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH0}${\n}
     ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1012
     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${address}=  FakerLibrary.address
     ${dob}=  FakerLibrary.Date
     ${gender}    Random Element    ${Genderlist}
     ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Activation  ${CUSERPH0}  1
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Set Credential  ${CUSERPH0}  ${PASSWORD}  1
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${firstname5}=  FakerLibrary.first_name
     ${lastname5}=  FakerLibrary.last_name
     ${dob5}=  FakerLibrary.Date
     ${gender5}    Random Element    ${Genderlist}
     ${resp}=  AddFamilyMember  ${firstname5}  ${lastname5}  ${dob5}  ${gender5}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${mem_id}  ${resp.json()}

     ${cnote}=   FakerLibrary.word
     ${resp}=  Add To Waitlist Consumers  ${pid0}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${mem_id}  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200 
     
     ${wid}=  Get Dictionary Values  ${resp.json()}
     Set Test Variable  ${wid1}  ${wid[0]}
     ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable    ${cid}  ${resp.json()['consumer']['id']}
     
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER  personsAhead=0
     Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}  ${ser_id1}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeId']}  ${mem_id} 
     Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id1}
     Set Test Variable  ${cfid}   ${resp.json()['waitlistingFor'][0]['id']}

     ${resp}=  Consumer Logout
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Encrypted Provider Login  ${PUSERNAME231}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  GetCustomer  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
     # ${resp}=  ListFamilyMemberByProvider  ${cid}
     # Log  ${resp.content}
     # Should Be Equal As Strings  ${resp.status_code}  200
     # Verify Response List  ${resp}  0  user=${cfid}
     # Should Be Equal As Strings  ${resp.json()[0]['userProfile']['firstName']}  ${firstname5}
     # Should Be Equal As Strings  ${resp.json()[0]['userProfile']['lastName']}  ${lastname5}
     # Should Be Equal As Strings  ${resp.json()[0]['userProfile']['dob']}  ${dob5}
     # Should Be Equal As Strings  ${resp.json()[0]['userProfile']['gender']}  ${gender5}

 
JD-TC-AddCustomer-16

     [Documentation]    Add a same customer to three different providers and take waitlist then after consumer signup get waitlist details                 
     ...                (Here first  provider's online presence is false and jaldee integration is true 2nd provider's online presence and jaldee integration is true and 3rd providers jaldee integration is false)
     
     
     # [Documentation]    Add a same customer to three different providers and take waitlist then after consumer signup get waitlist details                 
     # ...                (Here first  provider's jaldee integration is true 2nd provider's  jaldee integration is true and 3rd providers jaldee integration is false)
     



     clear_queue      ${PUSERNAME257}
     clear_location   ${PUSERNAME257}
     clear_service    ${PUSERNAME257}
     clear waitlist   ${PUSERNAME257}

     clear_queue      ${PUSERNAME259}
     clear_location   ${PUSERNAME259}
     clear_service    ${PUSERNAME259}
     clear waitlist   ${PUSERNAME259}
     
     clear_queue      ${PUSERNAME213}
     clear_location   ${PUSERNAME213}
     clear_service    ${PUSERNAME213}
     clear waitlist   ${PUSERNAME213}
     
     ${resp}=  Encrypted Provider Login  ${PUSERNAME213}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
    
     ${resp}=   Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
          ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
          Should Be Equal As Strings  ${resp1.status_code}  200
     ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
          ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
          Should Be Equal As Strings  ${resp1.status_code}  200
     END
     
     ${resp}=  Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}


     ${firstname1}=  FakerLibrary.first_name
     ${lastname1}=  FakerLibrary.last_name
     ${phone}=  Evaluate  ${PUSERNAME162}+72003 
     Set Suite Variable    ${phone}     
     ${resp}=  AddCustomer  ${phone}   firstName=${firstname1}   lastName=${lastname1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${cid1}  ${resp.json()}

     ${resp}=  GetCustomer  phoneNo-eq=${phone}
     Log  ${resp.content}
     Should Be Equal As Strings      ${resp.status_code}  200
     Set Test Variable   ${jaldeeid1}    ${resp.json()[0]['jaldeeId']}
    

     ${pid0}=  get_acc_id  ${PUSERNAME213}

     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
     ${resp}=   Create Sample Location
     Set Test Variable    ${loc_id1}    ${resp}  
     ${resp}=   Get Location ById  ${loc_id1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 
     ${resp}=   Create Sample Service  ${SERVICE1}
     Set Test Variable    ${ser_id1}    ${resp}
     ${q_name}=    FakerLibrary.name
     ${list}=  Create List   1  2  3  4  5  6  7
     ${strt_time}=   add_timezone_time  ${tz}  3  00  
     ${end_time}=    add_timezone_time  ${tz}  3  30      
     ${parallel}=   Random Int  min=1   max=1
     ${capacity}=  Random Int   min=10   max=20
     ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${que_id1}   ${resp.json()} 
     ${desc}=   FakerLibrary.word
     ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     
     ${wid}=  Get Dictionary Values  ${resp.json()}
     Set Test Variable  ${wid1}  ${wid[0]}
     ${resp}=  Get Waitlist By Id  ${wid1} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}  personsAhead=0
     Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
     Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid1}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid1}

     ${resp}=  Encrypted Provider Login  ${PUSERNAME259}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     # clear_queue      ${PUSERNAME259}
     # clear_location   ${PUSERNAME259}
     # clear_service    ${PUSERNAME259}
     # clear waitlist   ${PUSERNAME259}

     ${resp}=   Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
          ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
          Should Be Equal As Strings  ${resp1.status_code}  200
     ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
          ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
          Should Be Equal As Strings  ${resp1.status_code}  200
     END
     
     ${resp}=  Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}


     ${firstname2}=  FakerLibrary.first_name
     ${lastname2}=  FakerLibrary.last_name 
     ${resp}=  AddCustomer  ${phone}   firstName=${firstname2}   lastName=${lastname2}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${cid2}  ${resp.json()}

     ${resp}=  GetCustomer  phoneNo-eq=${phone}
     Log  ${resp.content}
     Should Be Equal As Strings      ${resp.status_code}  200
     Set Test Variable   ${jaldeeid2}    ${resp.json()[0]['jaldeeId']}

     ${pid1}=  get_acc_id  ${PUSERNAME259}

     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
     ${resp}=   Create Sample Location
     Set Test Variable    ${loc_id2}    ${resp}  
     ${resp}=   Create Sample Service  ${SERVICE1}
     Set Test Variable    ${ser_id2}    ${resp}
     ${q_name}=    FakerLibrary.name
     ${list}=  Create List   1  2  3  4  5  6  7
     ${strt_time}=   add_timezone_time  ${tz}  3  00  
     ${end_time}=    add_timezone_time  ${tz}  3  30      
     ${parallel}=   Random Int  min=1   max=1
     ${capacity}=  Random Int   min=10   max=20
     ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id2}  ${ser_id2}  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${que_id2}   ${resp.json()} 
     ${desc}=   FakerLibrary.word
     ${resp}=  Add To Waitlist  ${cid2}  ${ser_id2}  ${que_id2}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid2} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     
     ${wid}=  Get Dictionary Values  ${resp.json()}
     Set Test Variable  ${wid2}  ${wid[0]}
     ${resp}=  Get Waitlist By Id  ${wid2} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}  personsAhead=0
     Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id2}
     Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid2}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid2}

     ${resp}=  Encrypted Provider Login  ${PUSERNAME257}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     # clear_queue      ${PUSERNAME257}
     # clear_location   ${PUSERNAME257}
     # clear_service    ${PUSERNAME257}
     # clear waitlist   ${PUSERNAME257}

     ${resp}=   Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[0]}

     ${firstname3}=  FakerLibrary.first_name
     ${lastname3}=  FakerLibrary.last_name   
     ${resp}=  AddCustomer  ${phone}   firstName=${firstname3}   lastName=${lastname3}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${cid3}  ${resp.json()}

     ${resp}=  GetCustomer  phoneNo-eq=${phone}
     Log  ${resp.content}
     Should Be Equal As Strings      ${resp.status_code}  200
     Set Test Variable   ${jaldeeid3}    ${resp.json()[0]['jaldeeId']}

     ${pid2}=  get_acc_id  ${PUSERNAME257}

     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
     ${resp}=   Create Sample Location
     Set Test Variable    ${loc_id3}    ${resp}  
     ${resp}=   Create Sample Service  ${SERVICE1}
     Set Test Variable    ${ser_id3}    ${resp}
     ${q_name}=    FakerLibrary.name
     ${list}=  Create List   1  2  3  4  5  6  7
     ${strt_time}=   add_timezone_time  ${tz}  3  00  
     ${end_time}=    add_timezone_time  ${tz}  3  30      
     ${parallel}=   Random Int  min=1   max=1
     ${capacity}=  Random Int   min=10   max=20
     ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id3}  ${ser_id3}  
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${que_id3}   ${resp.json()} 
     ${desc}=   FakerLibrary.word
     ${resp}=  Add To Waitlist  ${cid3}  ${ser_id3}  ${que_id3}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid3} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     
     ${wid}=  Get Dictionary Values  ${resp.json()}
     Set Test Variable  ${wid3}  ${wid[0]}
     ${resp}=  Get Waitlist By Id  ${wid3} 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}  personsAhead=0
     Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id3}
     Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid3}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid3}

     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${address}=  FakerLibrary.Address
     ${alternativeNo}=  Evaluate  ${PUSERNAME23}+73007
     ${dob}=  FakerLibrary.Date
     ${gender}=  Random Element    ${Genderlist}
     ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${phone}    ${alternativeNo}  ${dob}  ${gender}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Activation  ${phone}  1
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Set Credential  ${phone}  ${PASSWORD}  1
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Login   ${phone}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}   
     Log  ${resp.content}
     # Should Be Equal As Strings  ${resp.status_code}  200
     # Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"


     ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${pid1}   
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1     personsAhead=0
     Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}  ${ser_id2}
     Should Be Equal As Strings  ${resp.json()['consumer']['jaldeeId']}  ${jaldeeid2}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid2}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['firstName']}  ${firstname2}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['lastName']}  ${lastname2}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['phoneNo']}  ${phone}
     Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${que_id2}     


     ${resp}=  Get consumer Waitlist By Id   ${wid3}  ${pid2}   
     Log  ${resp.content}
     # Should Be Equal As Strings  ${resp.status_code}  200
     

     ${resp}=   Get Waitlist Consumer
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     
     Verify Response List  ${resp}  0   date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1    waitlistedBy=${waitlistedby[1]}    personsAhead=0
     Should Be Equal As Strings  ${resp.json()[0]['service']['name']}  ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()[0]['service']['id']}  ${ser_id2}
     Should Be Equal As Strings  ${resp.json()[0]['consumer']['id']}  ${cid2}
     Should Be Equal As Strings  ${resp.json()[0]['consumer']['jaldeeId']}  ${jaldeeid2}
     Should Be Equal As Strings  ${resp.json()[0]['waitlistingFor'][0]['id']}  ${cid3}
     Should Be Equal As Strings  ${resp.json()[0]['waitlistingFor'][0]['firstName']}  ${firstname2}
     Should Be Equal As Strings  ${resp.json()[0]['waitlistingFor'][0]['lastName']}  ${lastname2}
     Should Be Equal As Strings  ${resp.json()[0]['waitlistingFor'][0]['phoneNo']}  ${phone}
     Should Be Equal As Strings  ${resp.json()[0]['queue']['id']}  ${que_id2}     


     
JD-TC-AddCustomer-17

    [Documentation]    Add same customer to three different providers and take waitlist. After consumer signup get waitlist details                 
     ...                (Here first  provider's online presence is false and walkinConsumerBecomesJdCons is true, 2nd provider's online presence and walkinConsumerBecomesJdCons is true and 3rd providers walkinConsumerBecomesJdCons is false)
    ${resp}=  Encrypted Provider Login  ${PUSERNAME213}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid1}=  get_acc_id  ${PUSERNAME213}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME213}
    clear_location  ${PUSERNAME213}
    clear_customer   ${PUSERNAME213}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid1}=  Create Sample Location  
    clear_appt_schedule   ${PUSERNAME213}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id1}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${phone1}=  Evaluate  ${PUSERNAME162}+72004
    Set Suite Variable    ${phone1}   
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name 
    ${resp}=  AddCustomer  ${phone1}   firstName=${firstname1}   lastName=${lastname1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${phone1}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable   ${jaldeeid1}    ${resp.json()[0]['jaldeeId']}
    
    ${apptfor1}=  Create Dictionary  id=${cid1}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid1}  ${s_id1}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId1}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['jaldeeId']}   ${jaldeeid1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${firstname1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lastname1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id1}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${firstname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lastname1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid1}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME259}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid2}=  get_acc_id  ${PUSERNAME259}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME259}
    clear_location  ${PUSERNAME259}
    clear_customer   ${PUSERNAME259}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
          ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
          Should Be Equal As Strings  ${resp1.status_code}  200
     ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
          ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
          Should Be Equal As Strings  ${resp1.status_code}  200
     END
     
     ${resp}=  Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid2}=  Create Sample Location  
    clear_appt_schedule   ${PUSERNAME259}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id2}=  Create Sample Service  ${SERVICE2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid2}  ${duration}  ${bool1}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id2}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}

    ${firstname2}=  FakerLibrary.first_name
    ${lastname2}=  FakerLibrary.last_name 
    ${resp}=  AddCustomer  ${phone1}   firstName=${firstname2}   lastName=${lastname2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid2}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${phone1}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable   ${jaldeeid2}    ${resp.json()[0]['jaldeeId']}
    
    ${apptfor1}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id2}  ${sch_id2}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid2}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId2}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid2}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId2}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['jaldeeId']}   ${jaldeeid2}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${firstname2}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lastname2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id2}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${firstname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lastname2}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid2}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME257}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid3}=  get_acc_id  ${PUSERNAME257}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME257}
    clear_location  ${PUSERNAME257}
    clear_customer   ${PUSERNAME257}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[0]}

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid3}=  Create Sample Location  
    clear_appt_schedule   ${PUSERNAME257}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${s_id3}=  Create Sample Service  ${SERVICE2}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid3}  ${duration}  ${bool1}  ${s_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id3}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id3}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id3}  ${DAY1}  ${s_id3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id3}
    Set Test Variable   ${slot3}   ${resp.json()['availableSlots'][0]['time']}

    ${firstname3}=  FakerLibrary.first_name
    ${lastname3}=  FakerLibrary.last_name 
    ${resp}=  AddCustomer  ${phone1}   firstName=${firstname3}   lastName=${lastname3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid3}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${phone1}
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable   ${jaldeeid3}    ${resp.json()[0]['jaldeeId']}
    
    ${apptfor1}=  Create Dictionary  id=${cid3}   apptTime=${slot3}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid3}  ${s_id3}  ${sch_id3}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid3}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId3}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid3}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId3}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['jaldeeId']}   ${jaldeeid3}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${firstname3}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lastname3}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id3}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id3}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${firstname3}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lastname3}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot3}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot3}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid3}

     ${firstname}=  FakerLibrary.first_name
     ${lastname}=  FakerLibrary.last_name
     ${address}=  FakerLibrary.Address
     ${alternativeNo}=  Evaluate  ${PUSERNAME23}+73007
     ${dob}=  FakerLibrary.Date
     ${gender}=  Random Element    ${Genderlist}
     ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${phone1}    ${alternativeNo}  ${dob}  ${gender}  ${EMPTY}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Activation  ${phone1}  1
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Set Credential  ${phone1}  ${PASSWORD}  1
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Consumer Login   ${phone1}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=   Get consumer Appointment By Id   ${pid1}  ${apptid1}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  404
     Should Be Equal As Strings  "${resp.json()}"   "${YOU_CANNOT_VIEW_THE_APPT}"


     ${resp}=   Get consumer Appointment By Id   ${pid2}  ${apptid2}
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid2}
     Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId2}
     Should Be Equal As Strings  ${resp.json()['providerConsumer']['jaldeeId']}   ${jaldeeid2}
     Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${firstname2}
     Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lastname2}
     Should Be Equal As Strings  ${resp.json()['service']['id']}   ${s_id2}
     Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id2}
     Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${firstname2}
     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lastname2}
     Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
     Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
     Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot2}
     Should Be Equal As Strings  ${resp.json()['location']['id']}   ${lid2}

     ${resp}=   Get consumer Appointment By Id   ${pid3}  ${apptid3}
     Log  ${resp.content}
     # Should Be Equal As Strings  "${resp.json()}"   "${YOU_CANNOT_VIEW_THE_APPT}"


     ${resp}=  Get Consumer Appointments 
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()[0]['uid']}   ${apptid2}
     Should Be Equal As Strings  ${resp.json()[0]['appointmentEncId']}   ${encId2}
     Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['jaldeeId']}   ${jaldeeid2}
     Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['firstName']}   ${firstname2}
     Should Be Equal As Strings  ${resp.json()[0]['providerConsumer']['lastName']}   ${lastname2}
     Should Be Equal As Strings  ${resp.json()[0]['service']['id']}   ${s_id2}
     Should Be Equal As Strings  ${resp.json()[0]['schedule']['id']}   ${sch_id2}
     Should Be Equal As Strings  ${resp.json()[0]['apptStatus']}   ${apptStatus[1]}
     Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['firstName']}   ${firstname2}
     Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['lastName']}   ${lastname2}
     Should Be Equal As Strings  ${resp.json()[0]['appmtFor'][0]['apptTime']}   ${slot2}
     Should Be Equal As Strings  ${resp.json()[0]['appmtDate']}   ${DAY1}
     Should Be Equal As Strings  ${resp.json()[0]['appmtTime']}   ${slot2}
     Should Be Equal As Strings  ${resp.json()[0]['location']['id']}   ${lid2}
 

     ${resp}=  Encrypted Provider Login  ${PUSERNAME213}  ${PASSWORD}
     Log  ${resp.content}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=   Get jaldeeIntegration Settings
     Log  ${resp.content}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[0]}

