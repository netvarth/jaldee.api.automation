*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Order Settings
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
${Email}     email

*** Test Case ***
JD-TC-UpdateStoreContactinfo-1
    [Documentation]   Update Store_Contact_info after signup


    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH0}   AND  clear_service  ${PUSERPH0}  AND  clear_Item    ${PUSERPH0}  AND   clear_Coupon   ${PUSERPH0}   AND  clear_Discount  ${PUSERPH0}
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    Set Suite Variable   ${licid}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Suite Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    ${sdom}=  Random Int   min=0  max=${sdlen-1}
    Set Suite Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ['Male', 'Female']
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERPH0}  ${licid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.content}    "true"
    
    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Set Suite Variable  ${pid236}  ${resp.json()['id']}
    Set Suite Variable  ${P236_fName}  ${resp.json()['firstName']}
    Set Suite Variable  ${P236_lName}  ${resp.json()['lastName']}
    Set Suite Variable  ${Ph236}  ${resp.json()['primaryPhoneNumber']}

    ${accId236}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${accId236}

    ${resp}=  Get Order Settings Contact info
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['firstName']}    ${P236_fName}
    Should Be Equal As Strings  ${resp.json()['lastName']}     ${P236_lName}
    Should Be Equal As Strings  ${resp.json()['phone']}        ${Ph236}
    Should Not Contain    ${resp.json()}   ${Email}


    ${fName2}=    FakerLibrary.word
    Set Suite Variable  ${fName2}
    ${lName2}=    FakerLibrary.word
    Set Suite Variable  ${lName2}
    ${ph3}=  Evaluate  ${PUSERPH0}+1000000002
    Set Suite Variable  ${ph3}
    ${ph4}=  Evaluate  ${PUSERPH0}+2000000002
    Set Suite Variable  ${ph4}
    ${whatsappNo2}=  Evaluate  ${PUSERPH0}+3000000002
    Set Suite Variable  ${whatsappNo2}
    ${Email3}=   Set Variable  ${fName2}${ph3}.${test_mail}
    Set Suite Variable  ${Email3}
    ${Email4}=   Set Variable  ${fName2}${ph4}.${test_mail}
    Set Suite Variable  ${Email4}
    ${address2}=  get_address
    Set Suite Variable  ${address2}

    ${resp}=  Update Store Contact info  firstName=${fName2}  lastName=${lName2}  phone=${ph3}  alternatePhone=${ph4}  email=${Email3}  alternateEmail=${Email4}  address=${address2}  whatsappNo=${whatsappNo2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Settings Contact info
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['firstName']}        ${fName2}
    Should Be Equal As Strings  ${resp.json()['lastName']}         ${lName2}
    Should Be Equal As Strings  ${resp.json()['phone']}            ${ph3}
    Should Be Equal As Strings  ${resp.json()['alternatePhone']}   ${ph4}
    Should Be Equal As Strings  ${resp.json()['email']}            ${Email3}
    Should Be Equal As Strings  ${resp.json()['alternateEmail']}   ${Email4}
    Should Be Equal As Strings  ${resp.json()['address']}          ${address2}
    Should Be Equal As Strings  ${resp.json()['whatsappNo']}       ${whatsappNo2}



JD-TC-UpdateStoreContactinfo-UH1
    [Documentation]   Update Store_Contact_info Without using First_Name

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Update Store Contact info  lastName=${lName2}  phone=${ph3}  alternatePhone=${ph4}  email=${Email3}  alternateEmail=${Email4}  address=${address2}  whatsappNo=${whatsappNo2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CONTACT_FIRST_NAME}"



JD-TC-UpdateStoreContactinfo-2
    [Documentation]   Update Store_Contact_info Without using Last_Name

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Update Store Contact info  firstName=${fName2}  phone=${ph3}  email=${Email3}  address=${address2}  whatsappNo=${whatsappNo2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"  "${CONTACT_LAST_NAME}"
    ${resp}=  Get Order Settings Contact info
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-UpdateStoreContactinfo-UH2
    [Documentation]   Update Store_Contact_info Without using Phone_Number

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Update Store Contact info  firstName=${fName2}  lastName=${lName2}  email=${Email3}  address=${address2}  whatsappNo=${whatsappNo2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${PROVIDE_PRIMARY_PHONE}"



JD-TC-UpdateStoreContactinfo-3
    [Documentation]   Update Store_Contact_info Without using Email_id

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Update Store Contact info  firstName=${fName2}  lastName=${lName2}  phone=${ph3}  address=${address2}  whatsappNo=${whatsappNo2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  "${resp.json()}"  "${EMAIL_ID_REQUIRED}"



JD-TC-UpdateStoreContactinfo-4
    [Documentation]   Update Store_Contact_info Without using Address

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Update Store Contact info  firstName=${fName2}  lastName=${lName2}  phone=${ph3}  email=${Email3}   whatsappNo=${whatsappNo2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    


JD-TC-UpdateStoreContactinfo-5
    [Documentation]   Update Store_Contact_info Without using Whatsapp_Number

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Update Store Contact info  firstName=${fName2}  lastName=${lName2}  phone=${ph3}  email=${Email3}  address=${address2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-UpdateStoreContactinfo-UH3
    [Documentation]   Update Store_Contact_info Without login

    ${resp}=  Update Store Contact info  firstName=${fName2}  lastName=${lName2}  phone=${ph3}  email=${Email3}   whatsappNo=${whatsappNo2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


    
JD-TC-UpdateStoreContactinfo-UH4
    [Documentation]   Login as consumer and Update Store_Contact_info
    ${resp}=   Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Store Contact info  firstName=${fName2}  lastName=${lName2}  phone=${ph3}  email=${Email3}   whatsappNo=${whatsappNo2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 


JD-TC-UpdateStoreContactinfo-UH5
    [Documentation]   Update Store_Contact_info using Store_Contact_info as EMPTY

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Store Contact info 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CONTACT_FIRST_NAME}"




