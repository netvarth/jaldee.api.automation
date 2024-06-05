*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           random
Library           /ebs/TDD/db.py
Library           /ebs/TDD/Keywordspy.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot


*** Test Cases ***
JD-TC-Take Appointment in Different Timezone-2
    ${resp}=  db.validatePhoneNumber  91  9595362548
    ${Number}=  random_phone_num_generator
    Log  ${Number}
    ${CountryCode}=  Set Variable  ${Number[0]}
    ${primaryMobileNo}=  Set Variable  ${Number[1]}
    Set Test Variable  ${email}  ${C_Email}${primaryMobileNo}.${test_mail}
    
    ${resp}=    Send Otp For Login    ${primaryMobileNo}    2   countryCode=${CountryCode}  alternateLoginId=${email}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200