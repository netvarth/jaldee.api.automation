***Settings***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Customers
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/providers.py
#Force Tags        ProviderCommunication

***Variables***
${self}   0


@{Views}  self  all  customersOnly
${CUSERPH}      ${CUSERNAME}
${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}     /ebs/TDD/upload.png

*** Test Cases ***
JD-TC-Get Consumer-1
    [Documentation]   Get Consumer by provider login using account.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME53}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Get Consumer  primaryMobileNo-eq=${CUSERNAME17}   
    Log  ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Get Consumer-2
    [Documentation]   Get Consumer by provider login provider add a customer.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME53}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${ph2}=  Evaluate  ${PUSERNAME230}+71010
    ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}   ${gender}  ${dob}  ${ph2}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph2}${\n}

    ${resp}=  Get Consumer  primaryMobileNo-eq=${ph2}   
    Log  ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Get Consumer-3
    [Documentation]   Get Consumer by Consumer login .

    ${resp}=  Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    IF  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Consumer  primaryMobileNo-eq=${CUSERNAME17}   
    Log  ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}    ${NO_ACCESS_TO_URL}

JD-TC-Get Consumer-UH2
    [Documentation]  Get Consumer without login 

    ${resp}=  Get Consumer   
    Should Be Equal As Strings  ${resp.status_code}  419  
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"  