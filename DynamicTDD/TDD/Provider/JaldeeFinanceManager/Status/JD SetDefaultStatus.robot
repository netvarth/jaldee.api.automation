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


JD-TC-Set Default status-1

    [Documentation]  Create statuses,get all status and verify default one .then change default status and Verified.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME104}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${userName}  ${resp.json()['userName']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

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
    
    ${resp}=  Create Finance Status   ${status[0]}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id0}   ${resp.json()}

    ${resp}=  Create Finance Status   ${status[1]}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id1}   ${resp.json()}

    ${resp}=  Create Finance Status   ${status[2]}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id2}   ${resp.json()}

    ${resp}=  Get default status    ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${status_id0}
    Should Be Equal As Strings  ${resp.json()['categoryType']}  ${categoryType[0]}
    Should Be Equal As Strings  ${resp.json()['name']}  ${status[0]}
    Should Be Equal As Strings  ${resp.json()['isDefault']}  ${bool[1]}

    ${resp}=  Set default status    ${status_id1}    ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get default status    ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${status_id1}
    Should Be Equal As Strings  ${resp.json()['categoryType']}  ${categoryType[0]}
    Should Be Equal As Strings  ${resp.json()['name']}  ${status[1]}
    Should Be Equal As Strings  ${resp.json()['isDefault']}  ${bool[1]}

JD-TC-Set Default status-2

    [Documentation]  try to set same status for default again.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME104}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Set default status    ${status_id1}    ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get default status    ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${status_id1}
    Should Be Equal As Strings  ${resp.json()['categoryType']}  ${categoryType[0]}
    Should Be Equal As Strings  ${resp.json()['name']}  ${status[1]}
    Should Be Equal As Strings  ${resp.json()['isDefault']}  ${bool[1]}
