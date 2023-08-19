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

*** Test Case ***

JD-TC-GetOrderSettingsByAccountid-1
    [Documentation]   Get Order Settings after signup

    ${resp}=  ProviderLogin  ${PUSERNAME222}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid222}  ${resp.json()['id']}
    Set Suite Variable  ${P222_fName}  ${resp.json()['firstName']}
    Set Suite Variable  ${P222_lName}  ${resp.json()['lastName']}
    Set Suite Variable  ${Ph222}  ${resp.json()['primaryPhoneNumber']}

    ${accId222}=  get_acc_id  ${PUSERNAME222}
    Set Suite Variable  ${accId222}

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId222}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P222_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P222_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph222}
    Should Not Contain    ${resp.json()}   ${Email}



JD-TC-GetOrderSettingsByAccountid-2
    [Documentation]   Get Order Settings after Enable order settings

    ${resp}=  ProviderLogin  ${PUSERNAME222}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${firstname2}=  FakerLibrary.first_name
    # Set Suite Variable  ${firstname2}
    # ${lastname2}=  FakerLibrary.last_name
    # Set Suite Variable  ${lastname2}
    Set Suite Variable  ${email_id222}  ${PUSERNAME222}${C_Email}.${test_mail}


    ${resp}=  Update Email   ${pid222}   ${P222_fName}   ${P222_lName}   ${email_id222}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId222}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P222_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P222_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph222}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}        ${email_id222}



JD-TC-GetOrderSettingsByAccountid-3
    [Documentation]   Get Order Settings after Disable order settings

    ${resp}=  ProviderLogin  ${PUSERNAME222}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId222}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P222_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P222_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph222}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}        ${email_id222}


JD-TC-GetOrderSettingsByAccountid-4
    [Documentation]   Enable order settings through Updation, after that Get Order Settings

    ${resp}=  ProviderLogin  ${PUSERNAME222}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fName}=    FakerLibrary.word
    Set Suite Variable  ${fName}
    ${lName}=    FakerLibrary.word
    Set Suite Variable  ${lName}
    ${ph1}=  Evaluate  ${PUSERNAME222}+1000000000
    Set Suite Variable  ${ph1}
    ${ph2}=  Evaluate  ${PUSERNAME222}+2000000000
    Set Suite Variable  ${ph2}
    ${whatsappNo}=  Evaluate  ${PUSERNAME222}+3000000000
    Set Suite Variable  ${whatsappNo}
    ${Email1}=   Set Variable  ${fName}${ph1}.${test_mail}
    Set Suite Variable  ${Email1}
    ${Email2}=   Set Variable  ${fName}${ph2}.${test_mail}
    Set Suite Variable  ${Email2}
    ${address}=  get_address
    Set Suite Variable  ${address}

    ${storeContactInfo}=  Create Dictionary  firstName=${fName}  lastName=${lName}  primCountryCode=+91  phone=${ph1}  secCountryCode=+91   alternatePhone=${ph2}  email=${Email1}  alternateEmail=${Email2}  address=${address}  whatsAppCountryCode=+91  whatsappNo=${whatsappNo} 
    ${resp}=  Update Order Settings  ${boolean[1]}  ${storeContactInfo}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId222}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}        ${fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}         ${lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}            ${ph1}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['alternatePhone']}   ${ph2}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}            ${Email1}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['alternateEmail']}   ${Email2}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['address']}          ${address}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['whatsappNo']}       ${whatsappNo}



JD-TC-GetOrderSettingsByAccountid-5
    [Documentation]   Disable order settings through Updation, after that Get Order Settings

    ${resp}=  ProviderLogin  ${PUSERNAME222}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${fName2}=    FakerLibrary.word
    Set Suite Variable  ${fName2}
    ${lName2}=    FakerLibrary.word
    Set Suite Variable  ${lName2}
    ${ph3}=  Evaluate  ${PUSERNAME222}+1000000002
    Set Suite Variable  ${ph3}
    ${ph4}=  Evaluate  ${PUSERNAME222}+2000000002
    Set Suite Variable  ${ph4}
    ${whatsappNo2}=  Evaluate  ${PUSERNAME222}+3000000002
    Set Suite Variable  ${whatsappNo2}
    ${Email3}=   Set Variable  ${fName}${ph3}.${test_mail}
    Set Suite Variable  ${Email3}
    ${Email4}=   Set Variable  ${fName}${ph4}.${test_mail}
    Set Suite Variable  ${Email4}
    ${address2}=  get_address
    Set Suite Variable  ${address2}

    ${storeContactInfo2}=  Create Dictionary  firstName=${fName2}  lastName=${lName2}  primCountryCode=+91  phone=${ph3}  secCountryCode=+91   alternatePhone=${ph4}  email=${Email3}  alternateEmail=${Email4}  address=${address2}  whatsAppCountryCode=+91  whatsappNo=${whatsappNo2} 
    ${resp}=  Update Order Settings  ${boolean[0]}  ${storeContactInfo2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId222}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}        ${fName2}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}         ${lName2}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}            ${ph3}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['alternatePhone']}   ${ph4}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}            ${Email3}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['alternateEmail']}   ${Email4}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['address']}          ${address2}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['whatsappNo']}       ${whatsappNo2}



JD-TC-GetOrderSettingsByAccountid-6
    [Documentation]   Update Email again and Get Order Settings 

    ${resp}=  ProviderLogin  ${PUSERNAME32}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid32}  ${resp.json()['id']}
    Set Suite Variable  ${P32_fName}  ${resp.json()['firstName']}
    Set Suite Variable  ${P32_lName}  ${resp.json()['lastName']}
    Set Suite Variable  ${Ph32}  ${resp.json()['primaryPhoneNumber']}

    ${accId32}=  get_acc_id  ${PUSERNAME32}
    Set Suite Variable  ${accId32}
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId32}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P32_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P32_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph32}

    Set Suite Variable  ${email_id32}  ${PUSERNAME32}${C_Email}.${test_mail}
    ${resp}=  Update Email   ${pid32}   ${P32_fName}   ${P32_lName}   ${email_id32}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId32}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P32_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P32_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph32}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}        ${email_id32}


    Set Suite Variable  ${email_id2}  ${P32_lName}${PUSERNAME32}${C_Email}.${test_mail}
    ${resp}=  Update Email   ${pid32}   ${P32_fName}   ${P32_lName}   ${email_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
     

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId32}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P32_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P32_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph32}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}        ${email_id2}



JD-TC-GetOrderSettingsByAccountid-UH1
    [Documentation]   Get Order Settings without login

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


JD-TC-GetOrderSettingsByAccountid-UH2
    [Documentation]   Login as consumer and Get Order Settings 

    ${resp}=   Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 


