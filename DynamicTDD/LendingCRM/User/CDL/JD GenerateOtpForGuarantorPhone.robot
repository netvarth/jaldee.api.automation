*** Settings ***

Suite Teardown    Delete All Sessions 
Test Teardown     Delete All Sessions
Force Tags        LOAN
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ProviderPartnerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Test Cases ***

JD-TC-GenerateOtpForGuarantorPhone-1

    [Documentation]  Login to a multi account provider,then create a guarantor.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PH_Number}    Random Number 	digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${Guarantor_no1}  555${PH_Number}
   
    ${resp}=  Generate Otp for Guarantor Phone  ${Guarantor_no1}  ${countryCodes[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-GenerateOtpForGuarantorPhone-2

    [Documentation]   Create Guarantor with already added phone number.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=  Generate Otp for Guarantor Phone  ${Guarantor_no1}  ${countryCodes[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GenerateOtpForGuarantorPhone-UH1

    [Documentation]   Create Guarantor with invalid phone number.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${invalid_number}    Random Number 	digits=5 
    ${resp}=  Generate Otp for Guarantor Phone  ${invalid_number}  ${countryCodes[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${INVALID_INPUT}" 


JD-TC-GenerateOtpForGuarantorPhone-UH2

    [Documentation]   Create Guarantor with empty phone number.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Generate Otp for Guarantor Phone  ${EMPTY}  ${countryCodes[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${INVALID_INPUT}" 


JD-TC-GenerateOtpForGuarantorPhone-UH3

    [Documentation]   Create Guarantor with another country code.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=  Generate Otp for Guarantor Phone  ${Guarantor_no1}  ${countryCodes[2]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GenerateOtpForGuarantorPhone-UH5

    [Documentation]   Create Guarantor without country code.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME132}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=  Generate Otp for Guarantor Phone  ${Guarantor_no1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GenerateOtpForGuarantorPhone-UH6

    [Documentation]   Create Guarantor without login.

    ${resp}=  Generate Otp for Guarantor Phone  ${Guarantor_no1}  ${countryCodes[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}" 


JD-TC-GenerateOtpForGuarantorPhone-UH7

    [Documentation]   Create Guarantor with consumer login.

    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Generate Otp for Guarantor Phone  ${Guarantor_no1}  ${countryCodes[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
     




    


