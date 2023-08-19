*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords     Delete All Sessions
...               AND           Remove File  cookies.txt
Force Tags        POC
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
Library           /ebs/TDD/Imageupload.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Suite Setup     Run Keyword  clear_Item  ${PUSERNAME19}

*** Variables ***
${item1}  ITEM1



*** Test Cases ***

JD-TC-Remove item Image-1

    [Documentation]  Provider check to remove item image
    ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


# JD-TC-Remove item Image-1

#     [Documentation]  Provider check to remove item image
#     ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME19}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${amount1}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
#     ${resp}=  Create Item   ${item1}  ${des}   ${description}  ${amount1}   ${bool[0]}    
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${id}  ${resp.json()} 
#     # ${resp}=  pyproviderlogin  ${PUSERNAME19}  ${PASSWORD}
#     # Should Be Equal As Strings  ${resp}  200
#     ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME19}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200   
#     ${resp}=  uploadItemImages   ${id}  ${cookie}
#     # Log  ${resp[0]}
#     Log  ${resp.json()}
#     # Should Be Equal As Strings  ${resp[1]}  200
#     Should Be Equal As Strings  ${resp.status_code}  200
#     # ${resp}=  pyproviderlogin  ${PUSERNAME19}  ${PASSWORD}
#     # Should Be Equal As Strings  ${resp}  200   
#     # ${resp}=  DeleteItemImage    ${id} 
#     # Log  ${resp[0]}
#     # Should Be Equal As Strings  ${resp[1]}  200
#     ${resp}=  DeleteItemImg    ${id}  ${cookie}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get Item By Id   ${id}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings  ${resp.json()['picBig']}   ${EMPTY}

# JD-TC-Remove item Image-UH1

#     [Documentation]  Provider check to remove item image with another provider itemid
#     ${resp}=  pyproviderlogin  ${PUSERNAME50}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp}  200
#     ${resp}=  DeleteItemImage    ${id} 
#     Should Be Equal As Strings  ${resp[1]}  401
#     Should Be Equal As Strings  ${resp[0]}  "${NO_PERMISSION}"

# JD-TC-Remove item Image-UH2

#     [Documentation]  Provider check to delete item with invalid itemid
#     ${resp}=  pyproviderlogin  ${PUSERNAME50}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp}  200
#     ${resp}=  DeleteItemImage    0   
#     Should Be Equal As Strings  ${resp[1]}  422
#     Should Be Equal As Strings  ${resp[0]}   "${NO_ITEM_FOUND}"

# JD-TC-Remove item Image-UH3

#     [Documentation]  Consumer check to remove item image 
#     ${resp}=  pyconsumerlogin  ${CUSERNAME9}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp}  200
#     ${resp}=  DeleteItemImage    ${id}   
#     Should Be Equal As Strings  ${resp[1]}  401
#     Should Be Equal As Strings  ${resp[0]}   "${LOGIN_NO_ACCESS_FOR_URL}"

# JD-TC-Remove item Image-UH4 

#     [Documentation]   Provider check to delete item image without login 
#     ${resp}=  DeleteItemImage    ${id}   
#     Should Be Equal As Strings  ${resp[1]}  419
#     Should Be Equal As Strings  ${resp[0]}   "${SESSION_EXPIRED}"