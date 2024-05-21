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

JD-TC-EnableOrderSettings-1
    [Documentation]   Enable Order Settings

    ${resp}=  Encrypted Provider Login  ${PUSERNAME71}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid71}  ${resp.json()['id']}
    Set Suite Variable  ${P71_fName}  ${resp.json()['firstName']}
    Set Suite Variable  ${P71_lName}  ${resp.json()['lastName']}
    Set Suite Variable  ${Ph71}  ${resp.json()['primaryPhoneNumber']}

    ${accId71}=  get_acc_id  ${PUSERNAME71}
    Set Suite Variable  ${accId71}

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId71}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P71_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P71_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph71}
    Should Not Contain    ${resp.json()}   ${Email}

    # ${firstname2}=  FakerLibrary.first_name
    # Set Suite Variable  ${firstname2}
    # ${lastname2}=  FakerLibrary.last_name
    # Set Suite Variable  ${lastname2}
    Set Suite Variable  ${email_id71}  ${PUSERNAME71}${C_Email}.${test_mail}

    ${resp}=  Update Email   ${pid71}   ${P71_fName}   ${P71_lName}   ${email_id71}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Update Email   ${pid71}   ${P71_fName}   ${P71_lName}   ${email_id71}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId71}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P71_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P71_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph71}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}        ${email_id71}


    ${resp}=  Enable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId71}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P71_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P71_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph71}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}        ${email_id71}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME71}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-EnableOrderSettings-2
    [Documentation]   Enable Order Settings after disable order settings

    ${resp}=  Encrypted Provider Login  ${PUSERNAME29}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid29}  ${resp.json()['id']}
    Set Suite Variable  ${P29_fName}  ${resp.json()['firstName']}
    Set Suite Variable  ${P29_lName}  ${resp.json()['lastName']}
    Set Suite Variable  ${Ph29}  ${resp.json()['primaryPhoneNumber']}

    ${accId29}=  get_acc_id  ${PUSERNAME29}
    Set Suite Variable  ${accId29}
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId29}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P29_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P29_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph29}
    Should Not Contain    ${resp.json()}   ${Email}

    Set Suite Variable  ${email_id29}  ${PUSERNAME29}${C_Email}.${test_mail}
    ${resp}=  Update Email   ${pid29}   ${P29_fName}   ${P29_lName}   ${email_id29}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
     
    ${resp}=  Enable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId29}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P29_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P29_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph29}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}        ${email_id29}


    ${resp}=  Disable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId29}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P29_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P29_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph29}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}        ${email_id29}


    ${resp}=  Enable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId29}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P29_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P29_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph29}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}        ${email_id29}



JD-TC-EnableOrderSettings-3
    [Documentation]   Disable order settings using Updation, after that Enable Order Settings

    ${resp}=  Encrypted Provider Login  ${PUSERNAME29}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId29}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P29_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P29_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph29}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}        ${email_id29}
     
    ${fName}=    FakerLibrary.word
    ${lName}=    FakerLibrary.word
    ${ph1}=  Evaluate  ${PUSERNAME29}+1000000000
    ${ph2}=  Evaluate  ${PUSERNAME29}+2000000000
    ${whatsappNo}=  Evaluate  ${PUSERNAME29}+3000000000
    ${Email1}=   Set Variable  ${fName}${ph1}.${test_mail}
    ${Email2}=   Set Variable  ${fName}${ph2}.${test_mail}
    ${address}=  get_address

    ${storeContactInfo}=  Create Dictionary  firstName=${fName}  lastName=${lName}  primCountryCode=+91  phone=${ph1}  secCountryCode=+91   alternatePhone=${ph2}  email=${Email1}  alternateEmail=${Email2}  address=${address}  whatsAppCountryCode=+91  whatsappNo=${whatsappNo} 
    ${resp}=  Update Order Settings  ${boolean[0]}  ${storeContactInfo}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId29}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}        ${fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}         ${lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}            ${ph1}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['alternatePhone']}   ${ph2}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}            ${Email1}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['alternateEmail']}   ${Email2}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['address']}          ${address}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['whatsappNo']}       ${whatsappNo}

    ${resp}=  Enable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId29}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}        ${fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}         ${lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}            ${ph1}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['alternatePhone']}   ${ph2}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}            ${Email1}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['alternateEmail']}   ${Email2}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['address']}          ${address}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['whatsappNo']}       ${whatsappNo}



JD-TC-EnableOrderSettings-4
    [Documentation]   Add Email using Updation, after that Enable Order Settings

    ${resp}=  Encrypted Provider Login  ${PUSERNAME79}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid34}  ${resp.json()['id']}
    Set Suite Variable  ${P34_fName}  ${resp.json()['firstName']}
    Set Suite Variable  ${P34_lName}  ${resp.json()['lastName']}
    Set Suite Variable  ${Ph34}  ${resp.json()['primaryPhoneNumber']}

    ${accId34}=  get_acc_id  ${PUSERNAME79}
    Set Suite Variable  ${accId34}
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId34}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P34_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P34_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph34}
    Should Not Contain    ${resp.json()}   ${Email}

   
    ${fName}=    FakerLibrary.word
    ${lName}=    FakerLibrary.word
    ${ph1}=  Evaluate  ${PUSERNAME79}+1000000000
    ${Email1}=   Set Variable  ${fName}${ph1}.${test_mail}
    ${address}=  get_address

    ${storeContactInfo}=  Create Dictionary  firstName=${fName}  lastName=${lName}  primCountryCode=+91  phone=${ph1}  email=${Email1}
    ${resp}=  Update Order Settings  ${boolean[0]}  ${storeContactInfo}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId34}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}        ${fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}         ${lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}            ${ph1}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}            ${Email1}


    ${resp}=  Enable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId34}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}        ${fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}         ${lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}            ${ph1}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}            ${Email1}



JD-TC-EnableOrderSettings-UH1
    [Documentation]   Enable Order Settings without login

    ${resp}=  Enable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


JD-TC-EnableOrderSettings-UH2
    [Documentation]   Login as consumer and Enable Order Settings 

    ${resp}=   Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    ${resp}=  Enable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 


JD-TC-EnableOrderSettings-UH3
    [Documentation]   Enable Order Settings again

    ${resp}=  Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid13}  ${resp.json()['id']}
    Set Suite Variable  ${P13_fName}  ${resp.json()['firstName']}
    Set Suite Variable  ${P13_lName}  ${resp.json()['lastName']}
    Set Suite Variable  ${Ph13}  ${resp.json()['primaryPhoneNumber']}

    ${accId13}=  get_acc_id  ${PUSERNAME13}
    Set Suite Variable  ${accId13}
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId13}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P13_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P13_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph13}
    Should Not Contain    ${resp.json()}   ${Email}

    Set Suite Variable  ${email_id13}  ${PUSERNAME13}${C_Email}.${test_mail}
    ${resp}=  Update Email   ${pid13}   ${P13_fName}   ${P13_lName}   ${email_id13}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
     
    ${resp}=  Enable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId13}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P13_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P13_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph13}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}        ${email_id13}

    ${resp}=  Enable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ORDER_SETTINGS_ENABLED}"



JD-TC-EnableOrderSettings-5
    [Documentation]   Enable Order Settings without adding Email

    ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid33}  ${resp.json()['id']}
    Set Suite Variable  ${P33_fName}  ${resp.json()['firstName']}
    Set Suite Variable  ${P33_lName}  ${resp.json()['lastName']}
    Set Suite Variable  ${Ph33}  ${resp.json()['primaryPhoneNumber']}

    ${accId33}=  get_acc_id  ${PUSERNAME11}
    Set Suite Variable  ${accId33}
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId33}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P33_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P33_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph33}
    Should Not Contain    ${resp.json()}   ${Email}

    ${resp}=  Enable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    # Should Be Equal As Strings  "${resp.json()}"  "${EMAIL_ID_REQUIRED}"
     

