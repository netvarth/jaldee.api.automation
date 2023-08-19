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
Suite Setup     Run Keyword     clear_Item  ${PUSERNAME20}


*** Variables ***

${item1}    ITEM1

*** Test Cases ***

JD-TC-Enable Item-UH3

    [Documentation]  Consumer try to Enable an Item
    ${resp}=  Consumer Login    ${CUSERNAME9}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

# JD-TC-Enable Item-UH1

#     [Documentation]   Provider Create item and try for Enable
#     clear_Item  ${PUSERNAME20}
#     ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${resp}=  ProviderLogin  ${PUSERNAME20}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     ${amount1}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
   
#     ${resp}=  Create Item   ${item1}  ${des}   ${description}  ${amount1}   ${bool[0]}    
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${id}  ${resp.json()}
    
#     ${resp}=   Get Item By Id  ${id} 
#     Verify Response  ${resp}  displayName=${item1}  displayDesc=${description}   shortDesc=${des}   status=ACTIVE  price=${amount1}    taxable=${bool[0]} 
#     ${resp}=  Enable Item  ${id}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${ITEM_ALREADY_ENABLED}"
#     ${resp}=  Get Item By Id  ${id}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     ${resp}=   Get Item By Id  ${id} 
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     Verify Response   ${resp}  displayName=${item1}   shortDesc=${des}   displayDesc=${description}   status=${status[0]}  price=${amount1}   taxable=${bool[0]} 

# JD-TC-Enable Item-UH2

#     [Documentation]  Enable item without login
#     ${resp}=  Enable Item  ${id}
#     Should Be Equal As Strings  ${resp.status_code}  419
#     Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}" 

# JD-TC-Enable Item-UH3

#     [Documentation]  Consumer try to Enable an Item
#     ${resp}=  Consumer Login    ${CUSERNAME9}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  Enable Item  ${id}
#     Should Be Equal As Strings  ${resp.status_code}  401
#     Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

# JD-TC-Enable Item-UH4

#     [Documentation]  try to enabled another providers item
#     ${resp}=  ProviderLogin  ${PUSERNAME3}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200
#      ${resp}=  Enable Item  ${id}
#     Should Be Equal As Strings  ${resp.status_code}  401
#     Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"