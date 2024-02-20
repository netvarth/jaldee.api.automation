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
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


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
@{emptylist}

*** Test Cases ***


JD-TC-UploadItemGroupImageforUser-1

    [Documentation]  Upload Item Group image with jpg format.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME67}  ${PASSWORD}
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

    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id1}  ${bool[1]}  ${jpgfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}                   ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}                     ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}                     ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][0]['type']}    jpg

JD-TC-UploadItemGroupImageforUser-2

    [Documentation]  Upload Item Group image with png format.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME67}  ${PASSWORD}
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

    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id2}  ${bool[1]}  ${pngfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Group By Id  ${item_group_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id2}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName2}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc2}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][0]['type']}    png


JD-TC-UploadItemGroupImageforUser-3

    [Documentation]  Upload Item Group image with gif format.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME67}  ${PASSWORD}
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

    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id3}  ${bool[1]}  ${giffile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Group By Id  ${item_group_id3}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id3}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName3}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc3}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][0]['type']}    gif


JD-TC-UploadItemGroupImageforUser-4

    [Documentation]  Upload Item Group image with jpeg format.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME67}  ${PASSWORD}
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

    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id4}  ${bool[1]}  ${jpegfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Group By Id  ${item_group_id4}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id4}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName4}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc4}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][0]['type']}    jpeg


JD-TC-UploadItemGroupImageforUser-5

    [Documentation]  verify all the uploaded images of a provider.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME67}  ${PASSWORD}
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


JD-TC-UploadItemGroupImageforUser-6

    [Documentation]  Upload Item Group image with txt format.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME67}  ${PASSWORD}
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

    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id}  ${bool[1]}  ${txtfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Group By Id  ${item_group_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][0]['type']}    txt


JD-TC-UploadItemGroupImageforUser-7

    [Documentation]  Upload Item Group image with pdf format.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME67}  ${PASSWORD}
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

    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id}  ${bool[1]}  ${pdffile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Group By Id  ${item_group_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][0]['type']}    pdf


JD-TC-UploadItemGroupImageforUser-8

    [Documentation]  Upload Item Group image with doc format.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME67}  ${PASSWORD}
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

    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id}  ${bool[1]}  ${docfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Group By Id  ${item_group_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][0]['type']}    doc


JD-TC-UploadItemGroupImageforUser-9

    [Documentation]  Upload Item Group image with sh format.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME67}  ${PASSWORD}
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

    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id}  ${bool[1]}  ${shfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}   ${IMAGE_TYPE_NOT_SUPPORTED}


JD-TC-UploadItemGroupImageforUser-10

    [Documentation]  Upload multiple images to the same Item Group with jpg format.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME67}  ${PASSWORD}
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

    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id}  ${bool[1]}  ${jpgfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id}  ${bool[1]}  ${jpgfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME67}  ${PASSWORD}
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


JD-TC-UploadItemGroupImageforUser-11

    [Documentation]  Upload multiple images to the same Item Group with jpg and png format.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME67}  ${PASSWORD}
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

    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id}  ${bool[1]}  ${jpgfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id}  ${bool[1]}  ${pngfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME67}  ${PASSWORD}
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


JD-TC-UploadItemGroupImageforUser-12

    [Documentation]  upload item group image by user.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME149}  ${PASSWORD}
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

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
    END
    FOR   ${i}  IN RANGE   0   ${len}
        Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
        IF   not '${user_phone}' == '${MUSERNAME149}'
            clear_users  ${user_phone}
        END
    END

    ${u_id}=  Create Sample User  admin=${bool[0]}
    Set Test Variable  ${u_id}

    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SendProviderResetMail   ${BUSER_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${groupName1}=    FakerLibrary.word
    ${groupDesc1}=    FakerLibrary.sentence
    ${resp}=  Create Item Group   ${groupName1}  ${groupDesc1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_group_id1}  ${resp.json()}

    ${resp}=  Get Item Group By Id   ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc1}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${BUSER_U1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id1}  ${bool[1]}  ${jpgfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}                   ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}                     ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}                     ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][0]['type']}    jpg


JD-TC-UploadItemGroupImageforUser-UH1

    [Documentation]  Upload Item Group image with another providers item group id.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME68}  ${PASSWORD}
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

    ${resp}=  Encrypted Provider Login  ${MUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id}  ${bool[1]}  ${jpegfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${NO_ITEM_FOUND}"
    

*** Comments ***

# .....Not done from dev side(bmp format)

JD-TC-UploadItemGroupImageforUser-5

    [Documentation]  Upload Item Group image with bmp format.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME67}  ${PASSWORD}
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

    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME67}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadItemGroupImages   ${item_group_id5}  ${bool[1]}  ${bmpfile}  ${cookie}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME67}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Item Group By Id  ${item_group_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id5}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName5}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc5}
    Should Be Equal As Strings  ${resp.json()['itemGroupImages'][0]['type']}    bmp

