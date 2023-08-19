*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords     Delete All Sessions
...               AND           Remove File  cookies.txt
Force Tags        ITEM
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           Process
Library           OperatingSystem
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***
${item1}   ITEM1
${item2}   ITEM2

*** Test Cases ***

JD-TC-Get Item By Id-UH1 
    [Documentation]    Consumer check to get Item By Id 
    ${resp}=  Consumer Login    ${CUSERNAME9}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

# JD-TC-Get Item By Id-1

#     [Documentation]  Provider check to get Item By Id
#     clear_Item  ${PUSERNAME29}
#     clear_Item  ${PUSERNAME251}
#     ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${resp}=  ProviderLogin  ${PUSERNAME29}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${amount1}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
    
#     ${resp}=  Create Item   ${item1}  ${des}   ${description}  ${amount1}   ${bool[0]}   
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${id}  ${resp.json()}
#     ${resp}=   Get Item By Id    ${id}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response   ${resp}   itemId=${id}    displayName=${item1}   shortDesc=${des}     displayDesc=${description}   price=${amount1}   taxable=${bool[0]}

# JD-TC-Get Item By Id-UH1 
#     [Documentation]    Consumer check to get Item By Id 
#     ${resp}=  Consumer Login    ${CUSERNAME9}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=   Get Item By Id   ${id}    
#     Should Be Equal As Strings  ${resp.status_code}  401
#     Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 

# JD-TC-Get Item By Id-UH2

#     [Documentation]  get Item By Id  without login
#     ${resp}=	Get Item By Id  ${id}  
#     Should Be Equal As Strings  ${resp.status_code}  419
#     Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"  

# JD-TC-Get Item By Id-UH3

#     [Documentation]  Provider check to create item with invalid get Item By Id
#     ${resp}=  ProviderLogin  ${PUSERNAME31}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=	Get Item By Id  0  
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${INCORRECT_ITEM_ID}"

# JD-TC-Get Item By Id-UH4

#     [Documentation]  provider2 using the get Item By Id of provider1
#     ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${resp}=  ProviderLogin  ${PUSERNAME251}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${amount2}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
    
#     ${resp}=  Create Item   ${item2}  ${des}   ${description}  ${amount2}   ${bool[0]} 
#     Log  ${resp.json()}  
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${id}  ${resp.json()}
    
#     ${resp}=   Get Item By Id  ${id} 
#     Verify Response  ${resp}  displayName=${item2}  displayDesc=${description}   shortDesc=${des}   status=${status[0]}   price=${amount2}    taxable=${bool[0]}
#     ${resp}=  ProviderLogin  ${PUSERNAME31}   ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${resp}=   Get Item By Id  ${id} 
#     Should Be Equal As Strings    ${resp.status_code}    401
#     Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"