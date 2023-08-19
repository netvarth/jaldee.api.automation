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
${item1}  item1
${item2}  item2
${item3}  item3


*** Test Cases ***


JD-TC-Get Items-UH1

    [Documentation]  consumer check to get items
    ${resp}=  Consumer Login    ${CUSERNAME9}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

# JD-TC-Get Items-1

#     [Documentation]   Provider check to get items
#     clear_Item  ${PUSERNAME240}
#     ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${resp}=  ProviderLogin  ${PUSERNAME240}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${amount1}=   FakerLibrary.pyfloat  left_digits=3   right_digits=2    positive=True
#     ${resp}=  Create Item   ${item1}  ${des}   ${description}  ${amount1}   ${bool[1]}   
    
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${id}  ${resp.json()}
#     ${amount2}=   FakerLibrary.pyfloat  left_digits=3   right_digits=2    positive=True
#     ${resp}=  Create Item   ${item2}   ${des}   ${description}  ${amount2}   ${bool[1]}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${id1}  ${resp.json()}
#     ${amount3}=   FakerLibrary.pyfloat  left_digits=3   right_digits=2    positive=True
#     ${resp}=  Create Item   ${item3}   ${des}   ${description}  ${amount3}   ${bool[1]} 
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${id1}  ${resp.json()}
    
#     ${resp}=   Get Items 
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200 
#     ${count}=  Get Length  ${resp.json()} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${count}  3
#     Verify Response List   ${resp}   0    displayName=${item1}   shortDesc=${des}     displayDesc=${description}   price=${amount1}  taxable=${bool[1]}  
#     Verify Response List   ${resp}   1    displayName=${item2}   shortDesc=${des}     displayDesc=${description}   price=${amount2}  taxable=${bool[1]}
#     Verify Response List   ${resp}   2    displayName=${item3}   shortDesc=${des}     displayDesc=${description}   price=${amount3}  taxable=${bool[1]}


# JD-TC-Get Items-UH1

#     [Documentation]  consumer check to get items
#     ${resp}=  Consumer Login    ${CUSERNAME9}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=   Get Items     
#     Should Be Equal As Strings  ${resp.status_code}  401
#     Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

# JD-TC-Get Items-UH2   

#     [Documentation]   get items without login
#     ${resp}=   Get Items     
#     Should Be Equal As Strings  ${resp.status_code}   419
#     Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"