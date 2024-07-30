*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        ITEM GROUP
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/providers.py


*** Variables ***

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}     /ebs/TDD/upload.png

*** Test Cases ***


JD-TC-DeleteItemGroupImage-1

    [Documentation]  delete item group image after uploading it..

    ${resp}=  Encrypted Provider Login  ${PUSERNAME87}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableItemGroup']}==${bool[0]}
        ${resp1}=  Enable Disable Item Group  ${Qstate[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableItemGroup']}  ${bool[1]}

    ${groupName1}=    FakerLibrary.word
    Set Suite Variable    ${groupName1}
    ${groupDesc1}=    FakerLibrary.sentence
    Set Suite Variable    ${groupDesc1}
    ${resp}=  Create Item Group   ${groupName1}  ${groupDesc1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_group_id1}  ${resp.json()}

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupImages']}    []

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME87}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id1}  ${bool[1]}  ${jpgfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME87}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}                   ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}                     ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}                     ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][0]['type']}    jpg
    Set Test Variable    ${imgname}   ${resp.json()['itemGroupImages'][0]['keyName']}       

    ${resp}=  Delete Item Group Image  ${item_group_id1}   ${imgname}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages']}    []


JD-TC-DeleteItemGroupImage-2

    [Documentation]  upload mutiple item images to the same group and then delete one of them.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME87}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME87}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id1}  ${bool[1]}  ${pngfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id1}  ${bool[1]}  ${jpgfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME87}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}                   ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}                     ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}                     ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][0]['type']}    jpg
    Set Suite Variable    ${imgname1}   ${resp.json()['itemGroupImages'][0]['keyName']}       
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][1]['type']}    png
    Set Suite Variable    ${imgname2}   ${resp.json()['itemGroupImages'][0]['keyName']}       

    ${resp}=  Delete Item Group Image  ${item_group_id1}   ${imgname1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][0]['type']}    png
    Should not contain    ${resp.json()}   jpg

JD-TC-DeleteItemGroupImage-UH1

    [Documentation]  delete already deleted item image.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME87}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Delete Item Group Image  ${item_group_id1}   ${imgname1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${IMAGE_NOT_FOUND_IN_ITEM_GROUP}"

JD-TC-DeleteItemGroupImage-UH2

    [Documentation]  delete using another providers item group id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableItemGroup']}==${bool[0]}
        ${resp1}=  Enable Disable Item Group  ${Qstate[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableItemGroup']}  ${bool[1]}

    ${groupName1}=    FakerLibrary.word
    ${groupDesc1}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName1}  ${groupDesc1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_group_id}  ${resp.json()}

    ${resp}=  Get Item Group By Id  ${item_group_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME87}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Delete Item Group Image  ${item_group_id}   ${imgname1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${NO_ITEM_GROUP_FOUND}"


JD-TC-DeleteItemGroupImage-UH3

    [Documentation]  delete item group image without login

    ${resp}=  Delete Item Group Image  ${item_group_id1}   ${imgname2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}" 

JD-TC-DeleteItemGroupImage-UH4

    [Documentation]  Consumer try to delete Item group image.

    ${resp}=  Consumer Login    ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Delete Item Group Image  ${item_group_id1}   ${imgname2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"


JD-TC-DeleteItemGroupImage-UH5

    [Documentation]  upload an image to an item group , then delete that item group and try to delete item image.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME87}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName1}=    FakerLibrary.word
    ${groupDesc1}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName1}  ${groupDesc1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_group_id}  ${resp.json()}

    ${resp}=  Get Item Group By Id  ${item_group_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME87}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id}  ${bool[1]}  ${pngfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME87}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Group By Id  ${item_group_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}                   ${item_group_id}
    Should Be Equal As Strings  ${resp.json()['groupName']}                     ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}                     ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][0]['type']}    png
    Set Test Variable    ${imgname1}   ${resp.json()['itemGroupImages'][0]['keyName']}       

    ${resp}=  Delete Item Group By Id  ${item_group_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Delete Item Group Image  ${item_group_id1}   ${imgname1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${IMAGE_NOT_FOUND_IN_ITEM_GROUP}"
