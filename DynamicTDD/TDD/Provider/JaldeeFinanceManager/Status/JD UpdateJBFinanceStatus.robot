*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Finance Manager
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
${jpgfile2}      /ebs/TDD/small.jpg
${gif}      /ebs/TDD/sample.gif
${xlsx}      /ebs/TDD/qnr.xlsx

${order}    0
${fileSize}  0.00458

@{status}    New     Pending    Assigned     Approved    Rejected
@{New_status}    Proceed     Unassign    Block     Delete    Remove


*** Test Cases ***


JD-TC-UpdateStatus-1

    [Documentation]  Update Status as New and update it as Proceed.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME72}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}
    
    ${resp}=  Create Finance Status   ${status[0]}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id1}   ${resp.json()}

    ${resp}=  Update Finance Status   ${New_status[0]}  ${categoryType[0]}   ${status_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UpdateStatus-2

    [Documentation]  Update Status as Unassign.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME72}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Finance Status   ${New_status[1]}  ${categoryType[0]}   ${status_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UpdateStatus-3

    [Documentation]  Update Status as Block.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME72}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Update Finance Status   ${New_status[2]}  ${categoryType[0]}   ${status_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UpdateStatus-4

    [Documentation]  Update Status as Delete.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME72}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Finance Status   ${New_status[3]}  ${categoryType[0]}   ${status_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-UpdateStatus-5

    [Documentation]  Update Status as Remove.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME72}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Finance Status   ${New_status[4]}  ${categoryType[0]}   ${status_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-UpdateStatus-UH1

    [Documentation]   Update Category without login

    ${resp}=  Update Finance Status   ${New_status[4]}  ${categoryType[0]}   ${status_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-UpdateStatus-UH2

    [Documentation]   Update Category Using Consumer Login

    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Finance Status   ${New_status[4]}  ${categoryType[0]}   ${status_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-UpdateStatus-UH3

    [Documentation]  update Category with another providers status id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME95}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}
    
    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Category Id
    
    ${name}=   FakerLibrary.word
    ${resp}=  Update Finance Status   ${New_status[4]}  ${categoryType[0]}   ${status_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_FM_STATUS_ID}

JD-TC-UpdateStatus-UH4

    [Documentation]  Update Status With EMPTY Status .

    ${resp}=  Encrypted Provider Login  ${PUSERNAME72}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Finance Status   ${EMPTY}  ${categoryType[0]}   ${status_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${STATUS_BOARD_NAME_NOT_EMPTY}
    
JD-TC-UpdateStatus-6

    [Documentation]  Update Status With not created categoryType.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME72}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Finance Status   ${New_status[4]}  ${categoryType[2]}   ${status_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings   ${resp.json()}   ${STATUS_BOARD_NAME_NOT_EMPTY}

