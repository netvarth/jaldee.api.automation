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

JD-TC-UpdateOrderSettings-1
    [Documentation]   Enable order settings using Updation

    ${resp}=  ProviderLogin  ${PUSERNAME22}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${P110_fName}  ${resp.json()['firstName']}
    Set Suite Variable  ${P110_lName}  ${resp.json()['lastName']}
    Set Suite Variable  ${Ph110}  ${resp.json()['primaryPhoneNumber']}

    ${accId110}=  get_acc_id  ${PUSERNAME22}
    Set Suite Variable  ${accId110}
    
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId110}
    # Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P110_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P110_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph110}
     
    ${fName}=    FakerLibrary.word
    Set Suite Variable  ${fName}
    ${lName}=    FakerLibrary.word
    Set Suite Variable  ${lName}
    ${ph1}=  Evaluate  ${PUSERNAME110}+1000000000
    Set Suite Variable  ${ph1}
    ${ph2}=  Evaluate  ${PUSERNAME110}+2000000000
    Set Suite Variable  ${ph2}
    ${whatsappNo}=  Evaluate  ${PUSERNAME110}+3000000000
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
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId110}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}        ${fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}         ${lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}            ${ph1}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['alternatePhone']}   ${ph2}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}            ${Email1}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['alternateEmail']}   ${Email2}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['address']}          ${address}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['whatsappNo']}       ${whatsappNo}



JD-TC-UpdateOrderSettings-2
    [Documentation]   Disable order settings using Updation

    ${resp}=  ProviderLogin  ${PUSERNAME22}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId110}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}        ${fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}         ${lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}            ${ph1}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['alternatePhone']}   ${ph2}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}            ${Email1}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['alternateEmail']}   ${Email2}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['address']}          ${address}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['whatsappNo']}       ${whatsappNo}

    ${storeContactInfo2}=  Create Dictionary  firstName=${P110_fName}  lastName=${P110_lName}  primCountryCode=+91   phone=${ph1}  email=${Email1}    address=${address}  whatsAppCountryCode=+91  whatsappNo=${whatsappNo} 
    Set Suite Variable  ${storeContactInfo2}
    ${resp}=  Update Order Settings  ${boolean[0]}  ${storeContactInfo2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId110}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}        ${P110_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}         ${P110_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}            ${ph1}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['email']}            ${Email1}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['address']}          ${address}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['whatsappNo']}       ${whatsappNo}



JD-TC-UpdateOrderSettings-UH1
    [Documentation]   Update Order Settings without login

    ${resp}=  Update Order Settings  ${boolean[0]}  ${storeContactInfo2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


JD-TC-UpdateOrderSettings-UH2
    [Documentation]   Login as consumer and Update Order Settings 

    ${resp}=   Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     
    ${resp}=  Update Order Settings  ${boolean[0]}  ${storeContactInfo2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 



JD-TC-UpdateOrderSettings-UH3
    [Documentation]   Update order settings when firstname is EMPTY

    ${resp}=  ProviderLogin  ${PUSERNAME120}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${P120_fName}  ${resp.json()['firstName']}
    Set Suite Variable  ${P120_lName}  ${resp.json()['lastName']}
    Set Suite Variable  ${Ph120}  ${resp.json()['primaryPhoneNumber']}

    ${accId120}=  get_acc_id  ${PUSERNAME120}
    Set Suite Variable  ${accId120}
    
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId120}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P120_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P120_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph120}
     

    ${storeContactInfo}=  Create Dictionary  firstName=${EMPTY}  lastName=${P120_lName}  primCountryCode=+91   phone=${Ph120}
    ${resp}=  Update Order Settings  ${boolean[1]}  ${storeContactInfo}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CONTACT_FIRST_NAME}"



JD-TC-UpdateOrderSettings-UH4
    [Documentation]   Update order settings when lastname is EMPTY

    ${resp}=  ProviderLogin  ${PUSERNAME120}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${P120_fName}  ${resp.json()['firstName']}
    Set Suite Variable  ${P120_lName}  ${resp.json()['lastName']}
    Set Suite Variable  ${Ph120}  ${resp.json()['primaryPhoneNumber']}

    ${accId120}=  get_acc_id  ${PUSERNAME120}
    Set Suite Variable  ${accId120}
    
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId120}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P120_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P120_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph120}
     

    ${storeContactInfo}=  Create Dictionary  firstName=${P120_fName}  lastName=${EMPTY}  primCountryCode=+91   phone=${Ph120}
    ${resp}=  Update Order Settings  ${boolean[1]}  ${storeContactInfo}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-UpdateOrderSettings-UH5
    [Documentation]   Update order settings when Phone number is EMPTY

    ${resp}=  ProviderLogin  ${PUSERNAME120}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${P120_fName}  ${resp.json()['firstName']}
    Set Suite Variable  ${P120_lName}  ${resp.json()['lastName']}
    Set Suite Variable  ${Ph120}  ${resp.json()['primaryPhoneNumber']}

    ${accId120}=  get_acc_id  ${PUSERNAME120}
    Set Suite Variable  ${accId120}
    
    # ${resp}=  Get Order Settings by account id
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['account']}         ${accId120}
    # Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    # Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P120_fName}
    # Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P120_lName}
    # Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph120}
     

    ${storeContactInfo}=  Create Dictionary  firstName=${P120_fName}  lastName=${P120_lName}  primCountryCode=+91   phone=${EMPTY}
    ${resp}=  Update Order Settings  ${boolean[1]}  ${storeContactInfo}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${PROVIDE_PRIMARY_PHONE}"



# JD-TC-UpdateOrderSettings-UH6
#     [Documentation]   Update order settings when Store_Contact_Info is EMPTY

#     ${resp}=  ProviderLogin  ${PUSERNAME120}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${P120_fName}  ${resp.json()['firstName']}
#     Set Suite Variable  ${P120_lName}  ${resp.json()['lastName']}
#     Set Suite Variable  ${Ph120}  ${resp.json()['primaryPhoneNumber']}

#     ${accId120}=  get_acc_id  ${PUSERNAME120}
#     Set Suite Variable  ${accId120}
    
#     ${resp}=  Get Order Settings by account id
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()['account']}         ${accId120}
#     Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
#     Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P120_fName}
#     Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P120_lName}
#     Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Ph120}
     

#     ${resp}=  Update Order Settings  ${boolean[1]}  ${EMPTY}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${STORE_CONTACT_INFO}"



JD-TC-UpdateOrderSettings-UH7
    [Documentation]   Update order settings using invalid phone number

    ${resp}=  ProviderLogin  ${PUSERNAME118}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${P118_fName}  ${resp.json()['firstName']}
    Set Suite Variable  ${P118_lName}  ${resp.json()['lastName']}
    Set Suite Variable  ${Phone118}  ${resp.json()['primaryPhoneNumber']}

    ${accId118}=  get_acc_id  ${PUSERNAME118}
    Set Suite Variable  ${accId118}
    
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId118}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P118_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P118_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Phone118}
     
    ${fName118}=    FakerLibrary.word
    Set Suite Variable  ${fName118}
    ${lName118}=    FakerLibrary.word
    Set Suite Variable  ${lName118}
    ${ph118}=  Evaluate  ${PUSERNAME118}+1000000000
    Set Suite Variable  ${ph118}
    
    ${whatsappNo118}=  Evaluate  ${PUSERNAME118}+3000000000
    Set Suite Variable  ${whatsappNo118}
    ${Email118}=   Set Variable  ${fName}${ph118}.ynwtest@netvarth.com
    Set Suite Variable  ${Email118}
    
    ${address118}=  get_address
    Set Suite Variable  ${address118}

    ${INVALID}=    FakerLibrary.word

    ${storeContactInfo}=  Create Dictionary  firstName=${fName118}  lastName=${lName118}  primCountryCode=+91   phone=${INVALID}  secCountryCode=+91   alternatePhone=${ph118}  email=${Email118}  alternateEmail=${Email118}  address=${address118}  whatsAppCountryCode=+91  whatsappNo=${whatsappNo118} 
    ${resp}=  Update Order Settings  ${boolean[1]}  ${storeContactInfo}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_PRIMARY_PHONE}"

    ${storeContactInfo}=  Create Dictionary  firstName=${fName118}  lastName=${lName118}  primCountryCode=+91   phone=${ph118}  secCountryCode=+91   alternatePhone=${INVALID}  email=${Email118}  alternateEmail=${Email118}  address=${address118}  whatsAppCountryCode=+91  whatsappNo=${whatsappNo118} 
    ${resp}=  Update Order Settings  ${boolean[1]}  ${storeContactInfo}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SECONDARY_PHONE}"

    ${storeContactInfo}=  Create Dictionary  firstName=${fName118}  lastName=${lName118}  primCountryCode=+91   phone=${INVALID}  secCountryCode=+91   alternatePhone=${INVALID}  email=${Email118}  alternateEmail=${Email118}  address=${address118}  whatsAppCountryCode=+91  whatsappNo=${whatsappNo118} 
    ${resp}=  Update Order Settings  ${boolean[1]}  ${storeContactInfo}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_PRIMARY_PHONE}"  200



JD-TC-UpdateOrderSettings-UH8
    [Documentation]   Update order settings using invalid Email_id

    ${resp}=  ProviderLogin  ${PUSERNAME118}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId118}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P118_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P118_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Phone118}
     
    ${INVALID}=    FakerLibrary.word
    ${storeContactInfo}=  Create Dictionary  firstName=${fName118}  lastName=${lName118}  primCountryCode=+91   phone=${ph118}  secCountryCode=+91   alternatePhone=${ph118}  email=${INVALID}  alternateEmail=${Email118}  address=${address118}  whatsAppCountryCode=+91  whatsappNo=${whatsappNo118} 
    ${resp}=  Update Order Settings  ${boolean[1]}  ${storeContactInfo}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_PRIMARY_EMAIL}"

    ${storeContactInfo}=  Create Dictionary  firstName=${fName118}  lastName=${lName118}  primCountryCode=+91   phone=${ph118}  secCountryCode=+91   alternatePhone=${ph118}  email=${Email118}  alternateEmail=${INVALID}  address=${address118}  whatsAppCountryCode=+91  whatsappNo=${whatsappNo118} 
    ${resp}=  Update Order Settings  ${boolean[1]}  ${storeContactInfo}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SECONDARY_EMAIL}"

    ${storeContactInfo}=  Create Dictionary  firstName=${fName118}  lastName=${lName118}  primCountryCode=+91   phone=${ph118}  secCountryCode=+91   alternatePhone=${ph118}  email=${INVALID}  alternateEmail=${INVALID}  address=${address118}  whatsAppCountryCode=+91  whatsappNo=${whatsappNo118} 
    ${resp}=  Update Order Settings  ${boolean[1]}  ${storeContactInfo}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_PRIMARY_EMAIL}"



JD-TC-UpdateOrderSettings-UH9
    [Documentation]   Update order settings using invalid Whasapp number

    ${resp}=  ProviderLogin  ${PUSERNAME118}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['account']}         ${accId118}
    Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${P118_fName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${P118_lName}
    Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${Phone118}
     
    ${INVALID}=    FakerLibrary.word
    ${storeContactInfo}=  Create Dictionary  firstName=${fName118}  lastName=${lName118}  primCountryCode=+91   phone=${ph118}  secCountryCode=+91   alternatePhone=${ph118}  email=${Email118}  alternateEmail=${Email118}  address=${address118}  whatsAppCountryCode=+91  whatsappNo=${INVALID} 
    ${resp}=  Update Order Settings  ${boolean[1]}  ${storeContactInfo}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_WHATSAPP_NO}"

    

