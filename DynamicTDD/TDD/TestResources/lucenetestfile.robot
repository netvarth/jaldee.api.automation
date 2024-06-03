***Settings***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Search
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***
# ${fname}    Mohammed
# ${lname}    Hisham
${count}       ${9}


*** Test Cases ***
JD-TC-Create Lucene Search Documentation-1
    [Documentation]   Create Lucene Search Documentation by provider login .

    ${resp}=  Encrypted Provider Login  ${PUSERNAME58}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${pid}  ${resp.json()['id']}

*** Comments ***

    ${PH_Number}=  Generate Random Phone Number
    ${Cons_num}=  Convert To Integer    ${PH_Number}

    FOR   ${a}  IN RANGE   ${count}

        ${CUSERPH}=  Evaluate  ${Cons_num}+${a}  
        Set Test Variable  ${CUSERPH${a}}   ${CUSERPH}  
        ${fname}=  FakerLibrary.first_name
        ${lname}=  FakerLibrary.last_name                   
        ${resp}=  AddCustomer  ${CUSERPH${a}}  firstName=${fname}  lastName=${lname}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

    END

    FOR   ${b}  IN RANGE   ${count}

        ${resp}=  Get Consumer  primaryMobileNo-eq=${CUSERNAME${b}}   
        Log  ${resp.content}   
        Should Be Equal As Strings  ${resp.status_code}  200  

        ${resp}=  AddCustomer  ${CUSERNAME${b}}  # firstName=${fname}  lastName=${lname}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${jccid${a}}   ${resp.json()}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${b}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${jccid${a}}
        
    END

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Create Lucene Search    ${pid}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lucene Search    ${pid}    name=M*
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200