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

*** Keywords ***

Get Finance Status By categorytype

    [Arguments]   ${categoryType}  
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /provider/jp/finance/status/type/${categoryType}    expected_status=any
    [Return]  ${resp}

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


JD-TC-GetstatusListByCategoryId-1

    [Documentation]  Create Status as New for Vendor then get with catagory Id.

    ${resp}=  Provider Login  ${PUSERNAME95}  ${PASSWORD}
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
    Set Suite Variable   ${status_id1}   ${resp.json()}

    ${resp}=  Get Finance Status By categorytype    ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${status_id1} 
    Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${status[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id1} 
    Should Be Equal As Strings  ${resp.json()[0]['isEnabled']}  ${toggle[0]} 

JD-TC-GetstatusListByCategoryId-2

    [Documentation]  Create Two Status for Vendor then get with catagory Id.

    ${resp}=  Provider Login  ${PUSERNAME95}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Create Finance Status   ${status[1]}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id2}   ${resp.json()}

    ${resp}=  Get Finance Status By categorytype    ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${status_id1} 
    Should Be Equal As Strings  ${resp.json()[0]['categoryType']}  ${categoryType[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${status[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}  ${account_id1} 
    Should Be Equal As Strings  ${resp.json()[0]['isEnabled']}  ${toggle[0]} 
    Should Be Equal As Strings  ${resp.json()[0]['isDefault']}  ${bool[1]} 

    Should Be Equal As Strings  ${resp.json()[1]['id']}  ${status_id2} 
    Should Be Equal As Strings  ${resp.json()[1]['categoryType']}  ${categoryType[0]} 
    Should Be Equal As Strings  ${resp.json()[1]['name']}  ${status[1]} 
    Should Be Equal As Strings  ${resp.json()[1]['accountId']}  ${account_id1} 
    Should Be Equal As Strings  ${resp.json()[1]['isEnabled']}  ${toggle[0]} 
    Should Be Equal As Strings  ${resp.json()[1]['isDefault']}  ${bool[0]} 

    ${resp}=  Get Finance Status By categorytype    ${categoryType[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
