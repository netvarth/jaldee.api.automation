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

@{service_names}

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

    

JD-TC-EnableDisableFinanceManagerStatus-1

    [Documentation]  Create one status and Disable that status.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${userName}    ${decrypted_data['userName']}
    Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}

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

    ${resp}=  Create Finance Status   ${New_status[0]}  ${categoryType[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id1}   ${resp.json()}

    ${resp}=  Get Finance Status By Id   ${status_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Enable Disable Jaldee Finance Status   ${status_id1}      ${toggle[1]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Finance Status By Id   ${status_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-EnableDisableFinanceManagerStatus-2

    [Documentation]   Disable that status again.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${STATUS_ALREADY_DISABLED}=  format String   ${STATUS_ALREADY_DISABLED}   ${New_status[0]}

    ${resp}=  Enable Disable Jaldee Finance Status   ${status_id1}      ${toggle[1]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${STATUS_ALREADY_DISABLED}

JD-TC-EnableDisableFinanceManagerStatus-3

    [Documentation]   update the disabled status  then status change to enabled.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Disable Jaldee Finance Status   ${status_id1}      ${toggle[1]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422

    ${resp}=  Update Finance Status   ${New_status[3]}  ${categoryType[1]}   ${status_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Jaldee Finance Status   ${status_id1}      ${toggle[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Finance Status By Id   ${status_id1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-EnableDisableFinanceManagerStatus-4

    [Documentation]   Create new status and disable all.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Finance Status   ${New_status[0]}  ${categoryType[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id2}   ${resp.json()}

    ${resp}=  Get Finance Status By Id   ${status_id2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Finance Status   ${New_status[3]}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id3}   ${resp.json()}

    ${resp}=  Get Finance Status By Id   ${status_id3}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Jaldee Finance Status   ${status_id2}      ${toggle[1]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Finance Status By Id   ${status_id2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Enable Disable Jaldee Finance Status   ${status_id3}      ${toggle[1]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Finance Status By Id   ${status_id3}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

