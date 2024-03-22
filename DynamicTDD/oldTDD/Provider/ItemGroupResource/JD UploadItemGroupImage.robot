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
${pdffile}     /ebs/TDD/sample.pdf
${giffile}     /ebs/TDD/sample.gif
${jpegfile}     /ebs/TDD/large.jpeg
${bmpfile}     /ebs/TDD/first.bmp
${shfile}     /ebs/TDD/example.sh
${docfile}     /ebs/TDD/docsample.doc
${txtfile}     /ebs/TDD/textsample.txt


*** Test Cases ***


JD-TC-UploadItemGroupImage-1

    [Documentation]  Upload Item Group image with jpg format.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
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

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id1}  ${bool[1]}  ${jpgfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}                   ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}                     ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}                     ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][0]['type']}    jpg

JD-TC-UploadItemGroupImage-2

    [Documentation]  Upload Item Group image with png format.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName2}=    FakerLibrary.word
    Set Suite Variable    ${groupName2}
    ${groupDesc2}=    FakerLibrary.sentence
    Set Suite Variable    ${groupDesc2}
    ${resp}=  Create Item Group   ${groupName2}  ${groupDesc2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_group_id2}  ${resp.json()}

    ${resp}=  Get Item Group By Id  ${item_group_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupImages']}    []

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id2}  ${bool[1]}  ${pngfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Group By Id  ${item_group_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id2}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName2}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc2}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][0]['type']}    png


JD-TC-UploadItemGroupImage-3

    [Documentation]  Upload Item Group image with gif format.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName3}=    FakerLibrary.word
    Set Suite Variable    ${groupName3}
    ${groupDesc3}=    FakerLibrary.sentence
    Set Suite Variable    ${groupDesc3}
    ${resp}=  Create Item Group   ${groupName3}  ${groupDesc3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_group_id3}  ${resp.json()}

    ${resp}=  Get Item Group By Id  ${item_group_id3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupImages']}    []

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id3}  ${bool[1]}  ${giffile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Group By Id  ${item_group_id3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id3}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName3}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc3}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][0]['type']}    gif


JD-TC-UploadItemGroupImage-4

    [Documentation]  Upload Item Group image with jpeg format.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName4}=    FakerLibrary.word
    Set Suite Variable    ${groupName4}
    ${groupDesc4}=    FakerLibrary.sentence
    Set Suite Variable    ${groupDesc4}
    ${resp}=  Create Item Group   ${groupName4}  ${groupDesc4}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_group_id4}  ${resp.json()}

    ${resp}=  Get Item Group By Id  ${item_group_id4}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupImages']}    []

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id4}  ${bool[1]}  ${jpegfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Group By Id  ${item_group_id4}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id4}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName4}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc4}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][0]['type']}    jpeg


JD-TC-UploadItemGroupImage-5

    [Documentation]  verify all the uploaded images of a provider.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Group
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['itemGroupId']}                   ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()[0]['groupName']}                     ${groupName1}
    Should Be Equal As Strings  ${resp.json()[0]['groupDesc']}                     ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()[0]['itemGroupImages'][0]['type']}    jpg

    Should Be Equal As Strings  ${resp.json()[1]['itemGroupId']}                   ${item_group_id2}
    Should Be Equal As Strings  ${resp.json()[1]['groupName']}                     ${groupName2}
    Should Be Equal As Strings  ${resp.json()[1]['groupDesc']}                     ${groupDesc2}
    Should Be Equal As Strings  ${resp.json()[1]['itemGroupImages'][0]['type']}    png

    Should Be Equal As Strings  ${resp.json()[2]['itemGroupId']}                   ${item_group_id3}
    Should Be Equal As Strings  ${resp.json()[2]['groupName']}                     ${groupName3}
    Should Be Equal As Strings  ${resp.json()[2]['groupDesc']}                     ${groupDesc3}
    Should Be Equal As Strings  ${resp.json()[2]['itemGroupImages'][0]['type']}    gif

    Should Be Equal As Strings  ${resp.json()[3]['itemGroupId']}                   ${item_group_id4}
    Should Be Equal As Strings  ${resp.json()[3]['groupName']}                     ${groupName4}
    Should Be Equal As Strings  ${resp.json()[3]['groupDesc']}                     ${groupDesc4}
    Should Be Equal As Strings  ${resp.json()[3]['itemGroupImages'][0]['type']}    jpeg


JD-TC-UploadItemGroupImage-6

    [Documentation]  Upload Item Group image with txt format.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName}=    FakerLibrary.word
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_group_id}  ${resp.json()}

    ${resp}=  Get Item Group By Id  ${item_group_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupImages']}    []

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id}  ${bool[1]}  ${txtfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Group By Id  ${item_group_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][0]['type']}    txt


JD-TC-UploadItemGroupImage-7

    [Documentation]  Upload Item Group image with pdf format.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName}=    FakerLibrary.word
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_group_id}  ${resp.json()}

    ${resp}=  Get Item Group By Id  ${item_group_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupImages']}    []

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id}  ${bool[1]}  ${pdffile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Group By Id  ${item_group_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][0]['type']}    pdf


JD-TC-UploadItemGroupImage-8

    [Documentation]  Upload Item Group image with doc format.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName}=    FakerLibrary.word
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_group_id}  ${resp.json()}

    ${resp}=  Get Item Group By Id  ${item_group_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupImages']}    []

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id}  ${bool[1]}  ${docfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Group By Id  ${item_group_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][0]['type']}    doc


JD-TC-UploadItemGroupImage-9

    [Documentation]  Upload Item Group image with sh format.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName}=    FakerLibrary.word
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_group_id}  ${resp.json()}

    ${resp}=  Get Item Group By Id  ${item_group_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupImages']}    []

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id}  ${bool[1]}  ${shfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Group By Id  ${item_group_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][0]['type']}    sh


JD-TC-UploadItemGroupImage-10

    [Documentation]  Upload multiple images to the same Item Group with jpg format.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName}=    FakerLibrary.word
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_group_id}  ${resp.json()}

    ${resp}=  Get Item Group By Id  ${item_group_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupImages']}    []

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id}  ${bool[1]}  ${jpgfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id}  ${bool[1]}  ${jpgfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Group By Id  ${item_group_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][0]['type']}    jpg
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][1]['type']}    jpg


JD-TC-UploadItemGroupImage-11

    [Documentation]  Upload multiple images to the same Item Group with jpg and png format.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName}=    FakerLibrary.word
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_group_id}  ${resp.json()}

    ${resp}=  Get Item Group By Id  ${item_group_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupImages']}    []

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id}  ${bool[1]}  ${jpgfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id}  ${bool[1]}  ${pngfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Group By Id  ${item_group_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][0]['type']}    png
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][1]['type']}    jpg


JD-TC-UploadItemGroupImage-UH1

    [Documentation]  Upload Item Group image with another providers item group id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME68}  ${PASSWORD}
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

    ${groupName}=    FakerLibrary.word
    ${groupDesc}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName}  ${groupDesc}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_group_id}  ${resp.json()}

    ${resp}=  Get Item Group By Id  ${item_group_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupImages']}    []

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id}  ${bool[1]}  ${jpegfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${NO_ITEM_FOUND}"
    

*** Comments ***

# .....Not done from dev side(bmp format)

JD-TC-UploadItemGroupImage-5

    [Documentation]  Upload Item Group image with bmp format.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName5}=    FakerLibrary.word
    Set Suite Variable    ${groupName5}
    ${groupDesc5}=    FakerLibrary.sentence
    Set Suite Variable    ${groupDesc5}
    ${resp}=  Create Item Group   ${groupName5}  ${groupDesc5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${item_group_id5}  ${resp.json()}

    ${resp}=  Get Item Group By Id  ${item_group_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupImages']}    []

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id5}  ${bool[1]}  ${bmpfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Group By Id  ${item_group_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id5}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName5}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc5}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][0]['type']}    bmp

