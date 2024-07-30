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
${countryCode}   +91

*** Test Cases ***

JD-TC-GetOrderSettingsStoreContactinfo-1
    [Documentation]   Get Order Settings Store_Contact_info after signup

    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
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
    
    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERPH0}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid226}  ${decrypted_data['id']}
    Set Suite Variable  ${P226_fName}  ${decrypted_data['firstName']}
    Set Suite Variable  ${P226_lName}  ${decrypted_data['lastName']}
    Set Suite Variable  ${Ph226}  ${decrypted_data['primaryPhoneNumber']}

    # Set Suite Variable  ${pid226}  ${resp.json()['id']}
    # Set Suite Variable  ${P226_fName}  ${resp.json()['firstName']}
    # Set Suite Variable  ${P226_lName}  ${resp.json()['lastName']}
    # Set Suite Variable  ${Ph226}  ${resp.json()['primaryPhoneNumber']}

    ${accId226}=  get_acc_id  ${PUSERPH0}
    Set Suite Variable  ${accId226}

    ${resp}=  Get Order Settings Contact info
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['firstName']}    ${P226_fName}
    Should Be Equal As Strings  ${resp.json()['lastName']}     ${P226_lName}
    Should Be Equal As Strings  ${resp.json()['phone']}        ${Ph226}
    Should Not Contain    ${resp.json()}   ${Email}



JD-TC-GetOrderSettingsStoreContactinfo-2
    [Documentation]   Update order settings and get Store_Contact_info

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fName}=    FakerLibrary.name
    Set Suite Variable  ${fName}
    ${lName}=    FakerLibrary.word
    Set Suite Variable  ${lName}
    ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
    Set Suite Variable  ${ph1}
    ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
    Set Suite Variable  ${ph2}
    ${whatsappNo}=  Evaluate  ${PUSERPH0}+3000000000
    Set Suite Variable  ${whatsappNo}
    ${Email1}=   Set Variable  ${lName}${ph1}.${test_mail}
    Set Suite Variable  ${Email1}
    ${Email2}=   Set Variable  ${lName}${ph2}.${test_mail}
    Set Suite Variable  ${Email2}
    ${address}=  get_address
    Set Suite Variable  ${address}

    ${storeContactInfo}=  Create Dictionary  firstName=${fName}  lastName=${lName}  primCountryCode=+91   phone=${ph1}  secCountryCode=+91   alternatePhone=${ph2}  email=${Email1}  alternateEmail=${Email2}  address=${address}  whatsAppCountryCode=+91  whatsappNo=${whatsappNo} 
    ${resp}=  Update Order Settings  ${boolean[1]}  ${storeContactInfo}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Settings Contact info
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['firstName']}        ${fName}
    Should Be Equal As Strings  ${resp.json()['lastName']}         ${lName}
    Should Be Equal As Strings  ${resp.json()['phone']}            ${ph1}
    Should Be Equal As Strings  ${resp.json()['alternatePhone']}   ${ph2}
    Should Be Equal As Strings  ${resp.json()['email']}            ${Email1}
    Should Be Equal As Strings  ${resp.json()['alternateEmail']}   ${Email2}
    Should Be Equal As Strings  ${resp.json()['address']}          ${address}
    Should Be Equal As Strings  ${resp.json()['whatsappNo']}       ${whatsappNo}



JD-TC-GetOrderSettingsStoreContactinfo-3
    [Documentation]   Update Store_Contact_info and get Store_Contact_info

    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${fName2}=    FakerLibrary.name
    Set Suite Variable  ${fName2}
    ${lName2}=    FakerLibrary.word
    Set Suite Variable  ${lName2}
    ${ph3}=  Evaluate  ${PUSERPH0}+1000000002
    Set Suite Variable  ${ph3}
    ${ph4}=  Evaluate  ${PUSERPH0}+2000000002
    Set Suite Variable  ${ph4}
    ${whatsappNo2}=  Evaluate  ${PUSERPH0}+3000000002
    Set Suite Variable  ${whatsappNo2}
    ${Email3}=   Set Variable  ${lName}${ph3}.${test_mail}
    Set Suite Variable  ${Email3}
    ${Email4}=   Set Variable  ${lName}${ph4}.${test_mail}
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



JD-TC-GetOrderSettingsStoreContactinfo-4
    [Documentation]   Update Email again and Get Store_Contact_info 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME38}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid38}  ${decrypted_data['id']}
    Set Suite Variable  ${P38_fName}  ${decrypted_data['firstName']}
    Set Suite Variable  ${P38_lName}  ${decrypted_data['lastName']}
    Set Suite Variable  ${Ph38}  ${decrypted_data['primaryPhoneNumber']}

    # Set Suite Variable  ${pid38}  ${resp.json()['id']}
    # Set Suite Variable  ${P38_fName}  ${resp.json()['firstName']}
    # Set Suite Variable  ${P38_lName}  ${resp.json()['lastName']}
    # Set Suite Variable  ${Ph38}  ${resp.json()['primaryPhoneNumber']}

    ${accId38}=  get_acc_id  ${PUSERNAME38}
    Set Suite Variable  ${accId38}
    ${resp}=  Get Order Settings Contact info
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['firstName']}    ${P38_fName}
    Should Be Equal As Strings  ${resp.json()['lastName']}     ${P38_lName}
    Should Be Equal As Strings  ${resp.json()['phone']}        ${Ph38}

    Set Suite Variable  ${email_id38}  ${P38_lName}${PUSERNAME38}${C_Email}.${test_mail}
    ${resp}=  Update Email   ${pid38}   ${P38_fName}   ${P38_lName}   ${email_id38}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     

    ${resp}=  Get Order Settings Contact info
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['firstName']}    ${P38_fName}
    Should Be Equal As Strings  ${resp.json()['lastName']}     ${P38_lName}
    Should Be Equal As Strings  ${resp.json()['phone']}        ${Ph38}
    Should Be Equal As Strings  ${resp.json()['email']}        ${email_id38}

    ${fName3}=    FakerLibrary.name
    Set Suite Variable  ${fName3}
    ${lName3}=    FakerLibrary.word
    Set Suite Variable  ${lName3}
    Set Suite Variable  ${email_id2}  ${lName3}${PUSERNAME38}${C_Email}.${test_mail}
    ${resp}=  Update Email   ${pid38}   ${fName3}   ${lName2}   ${email_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
     

    ${resp}=  Get Order Settings Contact info
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['firstName']}    ${P38_fName}
    Should Be Equal As Strings  ${resp.json()['lastName']}     ${P38_lName}
    Should Be Equal As Strings  ${resp.json()['phone']}        ${Ph38}
    Should Be Equal As Strings  ${resp.json()['email']}        ${email_id2}



JD-TC-GetOrderSettingsStoreContactinfo-UH1
    [Documentation]   Get Order Settings without login

    ${resp}=  Get Order Settings Contact info
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


JD-TC-GetOrderSettingsStoreContactinfo-UH2
    [Documentation]   Login as consumer and Get Order Settings 

    ${resp}=   Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    ${resp}=  Get Order Settings Contact info
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 


