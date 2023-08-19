*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Groups
Library           String
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Variables***
${self}                   0

***Test Cases***

JD-TC-CreateGroup-1
    [Documentation]  Create a customer group 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME87}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}   generateGrpMemId=${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

    ${resp}=  Get Customer Groups 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${groupid}  groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0


JD-TC-CreateGroup-2
    [Documentation]  Create more than one customer group

    ${resp}=  Encrypted Provider Login  ${PUSERNAME87}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME87}

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0


    ${groupName1}=   FakerLibrary.word
    ${desc1}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName1}  ${desc1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid1}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid1}   groupName=${groupName1}  
    ...   status=${grpstatus[0]}  description=${desc1}  consumerCount=0

    ${resp}=  Get Customer Groups 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2

    FOR  ${i}  IN RANGE   ${len}

        Run Keyword IF  '${resp.json()[${i}]['id']}' == '${groupid}'  
        ...    Verify Response List  ${resp}  ${i}  id=${groupid}  groupName=${groupName}  
        ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

        ...    ELSE IF     '${resp.json()[${i}]['id']}' == '${groupid1}'   
        ...    Verify Response List  ${resp}  ${i}  id=${groupid1}  groupName=${groupName1}  
        ...   status=${grpstatus[0]}  description=${desc1}  consumerCount=0   

    END


JD-TC-CreateGroup-3
    [Documentation]  Create a group without description

    ${resp}=  Encrypted Provider Login  ${PUSERNAME87}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME87}

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${EMPTY}  consumerCount=0

    ${resp}=  Get Customer Groups 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${groupid}  groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${EMPTY}  consumerCount=0


# JD-TC-CreateGroup-4
#     [Documentation]  Create a group without display name

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME87}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     clear_customer_groups  ${PUSERNAME87}

#     ${groupName}=   FakerLibrary.word
#     ${desc}=   FakerLibrary.sentence
#     ${resp}=  Create Customer Group   ${groupName}  ${desc}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${groupid}  ${resp.json()}

#     ${resp}=  Get Customer Group by id  ${groupid}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response  ${resp}  id=${groupid}   groupName=${groupName}
#     ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

#     ${resp}=  Get Customer Groups 
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response List  ${resp}  0  id=${groupid}  groupName=${groupName}
#     ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0


JD-TC-CreateGroup-5
    [Documentation]  Create a group, update its name, and create another group with 1st group's old name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME87}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME87}

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

    ${groupName_new}=   FakerLibrary.word
    ${resp}=  Update Customer Group   ${groupid}  ${groupName_new}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName_new}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid1}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid1}   groupName=${groupName}
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0
    

JD-TC-CreateGroup-UH1
    [Documentation]  Create 2 groups with same name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME87}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME87}

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

    # ${groupName1}=   FakerLibrary.word
    ${desc1}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${GROUP_NAME_ALREADY_EXIST}"

    ${resp}=  Get Customer Groups 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${groupid}  groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0


JD-TC-CreateGroup-UH2
    [Documentation]  Create group without login

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419 
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


JD-TC-CreateGroup-UH3
    [Documentation]  Consumer creates a group
    
    ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"     "${LOGIN_NO_ACCESS_FOR_URL}"


JD-TC-CreateGroup-UH4
    [Documentation]  Create a group without group name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME87}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME87}

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${EMPTY}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"     "${GROUP_NAME_MISSING}"


JD-TC-CreateGroup-UH5
    [Documentation]  Create a group, update its name, and create another group with this new name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME87}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME87}

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

    ${groupName_new}=   FakerLibrary.word
    ${resp}=  Update Customer Group   ${groupid}  ${groupName_new}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName_new}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

    ${resp}=  Create Customer Group   ${groupName_new}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-CreateGroup-6
    [Documentation]  Create a customer group with  generateGrpMemId true

    ${resp}=  Encrypted Provider Login  ${PUSERNAME87}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}   generateGrpMemId=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid12}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid12}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid12}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

   

JD-TC-CreateGroup-7
    [Documentation]  Create a group  generateGrpMemId false
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME87}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName12}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName12}  ${desc}    generateGrpMemId=${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName12}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

 
