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
${countryCode}   +91


*** Test Case ***

JD-TC-DisableOrderSettings-1
    [Documentation]   Disable Order Settings and verify

    ${resp}=  Encrypted Provider Login  ${PUSERNAME235}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid235}  ${resp.json()['id']}
    Set Suite Variable  ${P235_fName}  ${resp.json()['firstName']}
    Set Suite Variable  ${P235_lName}  ${resp.json()['lastName']}
    Set Suite Variable  ${Ph235}  ${resp.json()['primaryPhoneNumber']}

    ${accId235}=  get_acc_id  ${PUSERNAME235}
    Set Suite Variable  ${accId235}
     
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId235}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P235_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P235_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph235}

    # ${firstname2}=  FakerLibrary.first_name
    # Set Suite Variable  ${firstname2}
    # ${lastname2}=  FakerLibrary.last_name
    # Set Suite Variable  ${lastname2}

    ${provfname}  ${provlname}=  Split String  ${P235_fName}
    Set Suite Variable  ${email_id235}  ${provfname}.${provlname}.ynwtest@netvarth.com
    # Set Suite Variable  ${email_id235}  ${PUSERNAME235}${C_Email}.ynwtest@netvarth.com

    ${resp}=  Update Email   ${pid235}   ${P235_fName}   ${P235_lName}   ${email_id235}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId235}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P235_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P235_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph235}

    ${resp}=  Disable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  02s
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId235}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P235_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P235_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph235}



JD-TC-DisableOrderSettings-2
    [Documentation]   Enable order settings using Updation, after that Disable Order Settings

    ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${P28_fName}  ${resp.json()['firstName']}
    Set Suite Variable  ${P28_lName}  ${resp.json()['lastName']}
    Set Suite Variable  ${Ph28}  ${resp.json()['primaryPhoneNumber']}

    ${accId28}=  get_acc_id  ${PUSERNAME28}
    Set Suite Variable  ${accId28}
    
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId28}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P28_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P28_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph28}
     
    ${fName}=    FakerLibrary.word
    ${lName}=    FakerLibrary.word
    ${ph1}=  Evaluate  ${PUSERNAME28}+1000000000
    ${ph2}=  Evaluate  ${PUSERNAME28}+2000000000
    ${whatsappNo}=  Evaluate  ${PUSERNAME28}+3000000000
    ${Email1}=   Set Variable  ${fName}${ph1}.ynwtest@netvarth.com
    ${Email2}=   Set Variable  ${fName}${ph2}.ynwtest@netvarth.com
    ${address}=  get_address

    ${storeContactInfo}=  Create Dictionary  firstName=${fName}  lastName=${lName}  primCountryCode=+91  phone=${ph1}  secCountryCode=+91   alternatePhone=${ph2}  email=${Email1}  alternateEmail=${Email2}  address=${address}  whatsAppCountryCode=+91  whatsappNo=${whatsappNo} 
    ${resp}=  Update Order Settings  ${boolean[1]}  ${storeContactInfo}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId28}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}        ${fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}         ${lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}            ${ph1}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['alternatePhone']}   ${ph2}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}            ${Email1}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['alternateEmail']}   ${Email2}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['address']}          ${address}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['whatsappNo']}       ${whatsappNo}

    ${resp}=  Disable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId28}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}        ${fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}         ${lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}            ${ph1}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['alternatePhone']}   ${ph2}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}            ${Email1}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['alternateEmail']}   ${Email2}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['address']}          ${address}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['whatsappNo']}       ${whatsappNo}



JD-TC-DisableOrderSettings-UH1
    [Documentation]   Disable Order Settings without login

    ${resp}=  Disable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


JD-TC-DisableOrderSettings-UH2
    [Documentation]   Login as consumer and Disable Order Settings 

    ${resp}=   Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    ${resp}=  Disable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 


JD-TC-DisableOrderSettings-UH3
    [Documentation]   Disable Order Settings again

    ${resp}=  Encrypted Provider Login  ${PUSERNAME117}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${P117_fName}  ${resp.json()['firstName']}
    Set Suite Variable  ${P117_lName}  ${resp.json()['lastName']}
    Set Suite Variable  ${Ph117}  ${resp.json()['primaryPhoneNumber']}

    ${accId117}=  get_acc_id  ${PUSERNAME117}
    Set Suite Variable  ${accId117}

    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId117}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P117_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P117_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph117}

    ${resp}=  Disable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ORDER_SETTINGS_DISABLED}"

