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
${item10}  item10
${item1}  item1
${item2}  item2
${item3}  item3
${item4}  item4
${item5}  item5
${item6}  item6
${item7}  item7
*** Test Cases ***

JD-TC-Update Item-1 

    [Documentation]  Provider check to update item 
    ${resp}=  ProviderLogin  ${PUSERNAME21}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

# JD-TC-Update Item-1 

#     [Documentation]  Provider check to update item 
#     clear_Item  ${PUSERNAME21}
#     clear_Item   ${PUSERNAME35}
#     ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${resp}=  ProviderLogin  ${PUSERNAME21}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${amount1}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     ${resp}=  Create Item   ${item1}  ${des}   ${description}  ${amount1}  ${bool[1]}   
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${id}  ${resp.json()}
#     ${resp}=   Get Item By Id   ${id}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Verify Response  ${resp}    displayName=${item1}   shortDesc=${des}     displayDesc=${description}   price=${amount1}   taxable=${bool[1]}
#     ${amount2}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     ${resp}=  Update Item  ${id}   ${item2}    ${des}   ${description}   ${amount2}   ${bool[0]}   
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=   Get Item By Id   ${id}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Verify Response  ${resp}    displayName=${item2}   shortDesc=${des}     displayDesc=${description}   price=${amount2}    taxable=${bool[0]}

# JD-TC-Update Item-2 

#     [Documentation]  Provider check to update item with same item name 
#     ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${resp}=  ProviderLogin  ${PUSERNAME35}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${amount10}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     ${resp}=  Create Item   ${item10}  ${des}   ${description}  ${amount10}   ${bool[1]}   
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${id}  ${resp.json()}
    
#     ${resp}=   Get Item By Id   ${id}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Verify Response  ${resp}    displayName=${item10}   shortDesc=${des}     displayDesc=${description}   price=${amount10}   taxable=${bool[1]}
#     ${amount11}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     ${resp}=  Update Item  ${id}   ${item10}    ${des}   ${description}   ${amount11}   ${bool[0]} 
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=   Get Item By Id   ${id}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Verify Response  ${resp}    displayName=${item10}   shortDesc=${des}     displayDesc=${description}   price=${amount11}   taxable=${bool[0]}

# JD-TC-Update Item-UH1

#     [Documentation]  consumer check to update item 
#     ${resp}=  Consumer Login    ${CUSERNAME9}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${amount}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${resp}=   Update Item     ${id}   ${item3}   ${des}   ${description}    ${amount}   ${bool[0]} 
#     Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 

# JD-TC-Update Item-UH2

#     [Documentation]  update item of an account without login
    
#     ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${amount}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     ${resp}=   Update Item    ${id}   ${item4}   ${des}   ${description}   ${amount}   ${bool[0]} 
#     Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

# JD-TC-Update Item-UH3

#     [Documentation]   Provider check to update an item with invalid item id 
#     ${resp}=  ProviderLogin   ${PUSERNAME35}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}   200
#     ${item1}=  FakerLibrary.Word
#     ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${amount}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     ${resp}=  Update Item   0   ${item1}   ${des}   ${description}   ${amount}   ${bool[0]}
#     Should Be Equal As Strings  ${resp.status_code}  404
#     Should Be Equal As Strings  "${resp.json()}"  "${NO_ITEM_FOUND}"

# JD-TC-Update Item -UH4

#     [Documentation]  Provider check to update an item with another provider's item id
#     ${resp}=  ProviderLogin  ${PUSERNAME21}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${amount4}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${resp}=  Create Item   ${item5}  ${des}   ${description}  ${amount4}  ${bool[1]}   
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${id}  ${resp.json()}
#     ${resp}=  ProviderLogin  ${PUSERNAME29}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${amount6}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     ${resp}=   Update Item    ${id}   ${item5}   ${des}   ${description}    ${amount6}   ${bool[0]}
#     Should Be Equal As Strings  ${resp.status_code}  401
#     Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"




# JD-TC-Update Item -UH5 

#     [Documentation]   Provider create 2 item and 1st item is updated as 2nd item's  name
#     ${resp}=  ProviderLogin  ${PUSERNAME21}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
    
#     ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${amount3}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     ${resp}=  Create Item   ${item6}  ${des}   ${description}  ${amount3}   ${bool[0]}   
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${id}  ${resp.json()}
#     ${amount6}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     ${resp}=  Create Item   ${item7}  ${des}   ${description}  ${amount6}  ${bool[0]}   
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${id1}  ${resp.json()}
   
#     ${resp}=   Get Item By Id   ${id}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response   ${resp}   displayName=${item6}   shortDesc=${des}      displayDesc=${description}   price=${amount3}   taxable=${bool[0]}
#     ${resp}=   Get Item By Id   ${id1}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Verify Response   ${resp}   displayName=${item7}   shortDesc=${des}      displayDesc=${description}   price=${amount6}    taxable=${bool[0]}
#     ${amount8}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     ${resp}=   Update Item    ${id1}   ${item6}   ${des}   ${description}   ${amount8}   ${bool[0]}
#     Should Be Equal As Strings  ${resp.status_code}  422    
#     Should Be Equal As Strings  "${resp.json()}"  "${ITEM_NAME_SHOULD_BE_UNIQUE}" 