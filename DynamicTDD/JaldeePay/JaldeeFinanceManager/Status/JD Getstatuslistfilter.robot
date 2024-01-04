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
@{New_status}    Proceed     Unassign    Block     Delete    Remove    Assign


*** Test Cases ***


JD-TC-GetstatusListfilter-1

    [Documentation]  Create Status as New for Vendor then get with status list filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${userName}  ${resp.json()['userName']}

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
    
    ${resp}=  Create Finance Status   ${New_status[0]}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id1}   ${resp.json()}

    ${resp}=  Get status list filter   categoryType-eq=${categoryType[0]}    account-eq=${account_id1}   name-eq=${New_status[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['name']}     ${New_status[0]}

# *** comment ***

JD-TC-GetstatusListfilter-2

    [Documentation]  Create Two Status for Vendor then get with status list filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Create Finance Status   ${New_status[1]}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${status_id2}   ${resp.json()}

    ${resp}=  Get status list filter   categoryType-eq=${categoryType[0]}    account-eq=${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${status_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['name']}     ${New_status[1]}

JD-TC-GetstatusListfilter-3

    [Documentation]  Create Status as New and get with status list filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${userName}  ${resp.json()['userName']}


    ${resp}=  Create Finance Status   ${New_status[2]}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${status_id1}   ${resp.json()}

    ${resp}=  Get status list filter   categoryType-eq=${categoryType[0]}    account-eq=${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['name']}     ${New_status[2]}

JD-TC-GetstatusListfilter-4

    [Documentation]  Add new status for Vendor and get with status list filter.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Finance Status   ${New_status[3]}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${status_id2}   ${resp.json()}

    ${resp}=  Get status list filter   categoryType-eq=${categoryType[0]}    account-eq=${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${status_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['name']}     ${New_status[3]}

JD-TC-GetstatusListfilter-5

    [Documentation]  Update Vendor status and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Finance Status   ${New_status[4]}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${status_id2}   ${resp.json()}


    ${resp}=  Update Finance Status   ${New_status[5]}  ${categoryType[0]}   ${status_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get status list filter   categoryType-eq=${categoryType[0]}    account-eq=${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${status_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[0]}
    Should Be Equal As Strings  ${resp.json()[0]['name']}     ${New_status[5]}

JD-TC-GetstatusListfilter-6

    [Documentation]  Update Status With not created categoryType and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Finance Status   ${New_status[1]}  ${categoryType[2]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${status_id2}   ${resp.json()}


    ${resp}=  Update Finance Status   ${New_status[4]}  ${categoryType[2]}   ${status_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get status list filter   categoryType-eq=${categoryType[2]}    account-eq=${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${status_id2}
    Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[2]}
    Should Be Equal As Strings  ${resp.json()[0]['name']}     ${New_status[4]}

JD-TC-GetstatusListfilter-UH1

    [Documentation]   get with status list filter without login

     ${resp}=  Get status list filter   categoryType-eq=${categoryType[0]}    account-eq=${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-GetstatusListfilter-UH2

    [Documentation]   get with status list filter Using Consumer Login

    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get status list filter   categoryType-eq=${categoryType[0]}    account-eq=${account_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}






