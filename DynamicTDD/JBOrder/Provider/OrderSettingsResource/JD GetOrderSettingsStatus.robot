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
${firstName}   firstName
${lastName}    lastName
${Email}       email
${countryCode}   +91

*** Test Case ***
JD-TC-GetOrderSettingsStatus-1
    [Documentation]   Get Order Settings Status after signup

    ${resp}=  Encrypted Provider Login  ${PUSERNAME225}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid225}  ${decrypted_data['id']}
    Set Suite Variable  ${P225_fName}  ${decrypted_data['firstName']}
    Set Suite Variable  ${P225_lName}  ${decrypted_data['lastName']}
    Set Suite Variable  ${Ph225}  ${decrypted_data['primaryPhoneNumber']}

    # Set Suite Variable  ${pid225}  ${resp.json()['id']}
    # Set Suite Variable  ${P225_fName}  ${resp.json()['firstName']}
    # Set Suite Variable  ${P225_lName}  ${resp.json()['lastName']}
    # Set Suite Variable  ${Ph225}  ${resp.json()['primaryPhoneNumber']}

    ${accId225}=  get_acc_id  ${PUSERNAME225}
    Set Suite Variable  ${accId225}

    ${resp}=  Get Order Settings Status
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${bool[0]}



JD-TC-GetOrderSettingsStatus-2
    [Documentation]   Get Order Settings Status after Enable order settings

    ${resp}=  Encrypted Provider Login  ${PUSERNAME225}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${firstname2}=  FakerLibrary.first_name
    # Set Suite Variable  ${firstname2}
    # ${lastname2}=  FakerLibrary.last_name
    # Set Suite Variable  ${lastname2}
    Set Suite Variable  ${email_id225}  ${PUSERNAME225}${C_Email}.ynwtest@netvarth.com


    ${resp}=  Update Email   ${pid225}   ${P225_fName}   ${P225_lName}   ${email_id225}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Settings Status
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${bool[1]}



JD-TC-GetOrderSettingsStatus-3
    [Documentation]   Get Order Settings Status after Disable order settings

    ${resp}=  Encrypted Provider Login  ${PUSERNAME225}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Disable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Order Settings Status
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  ${bool[0]}



JD-TC-GetOrderSettingsStatus-4
    [Documentation]   Enable order settings through Updation, after that Get Order Settings

    ${resp}=  Encrypted Provider Login  ${PUSERNAME225}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fName}=    FakerLibrary.word
    Set Suite Variable  ${fName}
    ${lName}=    FakerLibrary.word
    Set Suite Variable  ${lName}
    ${ph1}=  Evaluate  ${PUSERNAME225}+1000000000
    Set Suite Variable  ${ph1}
    ${ph2}=  Evaluate  ${PUSERNAME225}+2000000000
    Set Suite Variable  ${ph2}
    ${whatsappNo}=  Evaluate  ${PUSERNAME225}+3000000000
    Set Suite Variable  ${whatsappNo}
    ${Email1}=   Set Variable  ${fName}${ph1}.ynwtest@netvarth.com
    Set Suite Variable  ${Email1}
    ${Email2}=   Set Variable  ${fName}${ph2}.ynwtest@netvarth.com
    Set Suite Variable  ${Email2}
    ${address}=  get_address
    Set Suite Variable  ${address}

    ${storeContactInfo}=  Create Dictionary  firstName=${fName}  lastName=${lName}  primCountryCode=+91   phone=${ph1}  secCountryCode=+91   alternatePhone=${ph2}  email=${Email1}  alternateEmail=${Email2}  address=${address}  whatsAppCountryCode=+91  whatsappNo=${whatsappNo} 
    ${resp}=  Update Order Settings  ${boolean[1]}  ${storeContactInfo}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Settings Status
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${bool[1]}



JD-TC-GetOrderSettingsStatus-5
    [Documentation]   Disable order settings through Updation, after that Get Order Settings

    ${resp}=  Encrypted Provider Login  ${PUSERNAME225}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${fName2}=    FakerLibrary.word
    Set Suite Variable  ${fName2}
    ${lName2}=    FakerLibrary.word
    Set Suite Variable  ${lName2}
    ${ph3}=  Evaluate  ${PUSERNAME225}+1000000002
    Set Suite Variable  ${ph3}
    ${ph4}=  Evaluate  ${PUSERNAME225}+2000000002
    Set Suite Variable  ${ph4}
    ${whatsappNo2}=  Evaluate  ${PUSERNAME225}+3000000002
    Set Suite Variable  ${whatsappNo2}
    ${Email3}=   Set Variable  ${fName}${ph3}.ynwtest@netvarth.com
    Set Suite Variable  ${Email3}
    ${Email4}=   Set Variable  ${fName}${ph4}.ynwtest@netvarth.com
    Set Suite Variable  ${Email4}
    ${address2}=  get_address
    Set Suite Variable  ${address2}

    ${storeContactInfo2}=  Create Dictionary  firstName=${fName2}  lastName=${lName2}  primCountryCode=+91   phone=${ph3}  secCountryCode=+91   alternatePhone=${ph4}  email=${Email3}  alternateEmail=${Email4}  address=${address2}  whatsAppCountryCode=+91  whatsappNo=${whatsappNo2} 
    ${resp}=  Update Order Settings  ${boolean[0]}  ${storeContactInfo2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Settings Status
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${bool[0]}



JD-TC-GetOrderSettingsStatus-UH1
    [Documentation]   Get Order Settings without login

    ${resp}=  Get Order Settings Status
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


JD-TC-GetOrderSettingsStatus-UH2
    [Documentation]   Login as consumer and Get Order Settings 

    ${resp}=   Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    ${resp}=  Get Order Settings Status
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 


