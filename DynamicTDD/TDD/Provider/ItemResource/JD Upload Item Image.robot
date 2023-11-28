*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords     Delete All Sessions
...               AND           Remove File  cookies.txt
Force Tags        Item Image
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
Library           /ebs/TDD/Imageupload.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Suite Setup     Run Keyword  clear_Item  ${PUSERNAME22}
*** Variables ***
${item1}  item1


*** Test Cases ***

JD-TC-Upload item Image-1

    [Documentation]   Provider check to upload item image
    ${resp}=  Encrypted Provider Login  ${PUSERNAME22}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

# JD-TC-Upload item Image-1

#     [Documentation]   Provider check to upload item image
#     ${des}=  FakerLibrary.Word
#     ${description}=  FakerLibrary.sentence
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME22}  ${PASSWORD}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${amount11}=   FakerLibrary.pyfloat  left_digits=2   right_digits=2    positive=True
   
#     ${resp}=  Create Item   ${item1}  ${des}   ${description}  ${amount11}   ${bool[1]}   
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${id}  ${resp.json()}
#     # ${resp}=  pyproviderlogin  ${PUSERNAME22}  ${PASSWORD}
#     # Should Be Equal As Strings  ${resp}  200 
#     ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME22}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=   uploadItemImages   ${id}   ${cookie}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     # Should Be Equal As Strings  ${resp[1]}  200
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME22}  ${PASSWORD}
#     ${resp}=   Get Item By Id   ${id}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Not Be Equal As Strings  ${resp.json()['picBig']}   ${EMPTY}  
#     Should Contain  ${resp.json()['picBig']}  /item/${id}/item 

# JD-TC-Upload item Image-UH1

#     [Documentation]  Provider check to upload item image with another provider itemid
#     # ${resp}=  pyproviderlogin  ${PUSERNAME3}  ${PASSWORD}
#     # Should Be Equal As Strings  ${resp}  200
#     ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME3}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=   uploadItemImages   ${id}  ${cookie}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  401
#     Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"
#     # Should Be Equal As Strings  ${resp[1]}  401
#     # Should Be Equal As Strings  ${resp[0]}  ${NO_PERMISSION}

# JD-TC-Upload item Image-UH2

#     [Documentation]  Provider check to upload item image with invalid itemid
#     # ${resp}=  pyproviderlogin  ${PUSERNAME3}  ${PASSWORD}
#     # Should Be Equal As Strings  ${resp}  200
#     ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME3}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=   uploadItemImages   0   ${cookie}
#     # Should Be Equal As Strings  ${resp[1]}  422
#     # Should Be Equal As Strings  ${resp[0]}   ${NO_ITEM_FOUND}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${NO_ITEM_FOUND}"

# JD-TC-Upload item Image-UH3

#     [Documentation]  Consumer check to upload item image  
#     # ${resp}=  pyconsumerlogin  ${CUSERNAME9}  ${PASSWORD}
#     # Log  ${resp}
#     # Should Be Equal As Strings  ${resp}  200
#     ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME9}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${resp}=  uploadItemImages    ${id}    ${cookie}
#     # Should Be Equal As Strings  ${resp[1]}  401
#     # Should Be Equal As Strings  ${resp[0]}   ${LOGIN_NO_ACCESS_FOR_URL} 
#     Should Be Equal As Strings  ${resp.status_code}  401
#     Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

# JD-TC-Upload item Image-UH4

#     [Documentation]  delete item upload without login 
#     ${empty_cookie}=  Create Dictionary
#     ${resp}=  uploadItemImages    ${id}  ${empty_cookie} 
#     Should Be Equal As Strings  ${resp.status_code}  419
#     Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"  
#     # Should Be Equal As Strings  ${resp[1]}  419
#     # Should Be Equal As Strings  ${resp[0]}   ${SESSION_EXPIRED}
 
 