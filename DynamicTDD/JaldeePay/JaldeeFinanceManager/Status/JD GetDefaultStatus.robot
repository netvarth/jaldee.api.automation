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

@{status}    New     Pending    Assigned     Approved    Rejected
@{New_status}    Proceed     Unassign    Block     Delete    Remove


*** Test Cases ***

JD-TC-get Default status-1

    [Documentation]  Create statuses,get all status and verify default one .

    ${resp}=  Provider Login  ${PUSERNAME4}  ${PASSWORD}
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
    
    ${resp}=  Create Finance Status   ${New_status[0]}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id0}   ${resp.json()}

    ${resp}=  Create Finance Status   ${New_status[1]}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id1}   ${resp.json()}

    ${resp}=  Create Finance Status   ${New_status[2]}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id2}   ${resp.json()}

    ${resp}=  Set default status    ${status_id0}    ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get default status    ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${status_id0}
    Should Be Equal As Strings  ${resp.json()['categoryType']}  ${categoryType[0]}
    Should Be Equal As Strings  ${resp.json()['name']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()['isDefault']}  ${bool[1]}


JD-TC-get Default status-2

    [Documentation]  Create Status as Proceed and Get default status .

    ${resp}=  Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${userName}  ${resp.json()['userName']}}
    
    ${resp}=  Create Finance Status   ${New_status[0]}  ${categoryType[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${status_id1}   ${resp.json()}


    ${resp}=  Set default status    ${status_id1}    ${categoryType[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get default status    ${categoryType[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${status_id1}
    Should Be Equal As Strings  ${resp.json()['categoryType']}  ${categoryType[1]}
    Should Be Equal As Strings  ${resp.json()['name']}  ${New_status[0]}
    Should Be Equal As Strings  ${resp.json()['isDefault']}  ${bool[1]}


JD-TC-get Default status-3

    [Documentation]  Create Status as  Unassign   and Get default status  ..

    ${resp}=  Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Finance Status   ${New_status[1]}  ${categoryType[2]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${status_id2}   ${resp.json()}

    ${resp}=  Set default status    ${status_id2}    ${categoryType[2]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get default status    ${categoryType[2]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${status_id2}
    Should Be Equal As Strings  ${resp.json()['categoryType']}  ${categoryType[2]}
    Should Be Equal As Strings  ${resp.json()['name']}  ${New_status[1]}
    Should Be Equal As Strings  ${resp.json()['isDefault']}  ${bool[1]}


JD-TC-get Default status-4

    [Documentation]  Create Status as  Block  and Get default status  ..

    ${resp}=  Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Finance Status   ${New_status[2]}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${status_id2}   ${resp.json()}

    ${resp}=  Set default status    ${status_id2}    ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get default status    ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${status_id2}
    Should Be Equal As Strings  ${resp.json()['categoryType']}  ${categoryType[3]}
    Should Be Equal As Strings  ${resp.json()['name']}  ${New_status[2]}
    Should Be Equal As Strings  ${resp.json()['isDefault']}  ${bool[1]}

JD-TC-get Default status-5

    [Documentation]  Create Status as  Remove and Get default status  ..

    ${resp}=  Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Finance Status   ${New_status[4]}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${status_id2}   ${resp.json()}

    ${resp}=  Set default status    ${status_id2}    ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get default status    ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${status_id2}
    Should Be Equal As Strings  ${resp.json()['categoryType']}  ${categoryType[3]}
    Should Be Equal As Strings  ${resp.json()['name']}  ${New_status[4]}
    Should Be Equal As Strings  ${resp.json()['isDefault']}  ${bool[1]}

JD-TC-get Default status-6

    [Documentation]  Create Status as Remove and Get default status  ..

    ${resp}=  Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Finance Status   ${New_status[4]}  ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${status_id2}   ${resp.json()}

    ${resp}=  Set default status    ${status_id2}    ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get default status    ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${status_id2}
    Should Be Equal As Strings  ${resp.json()['categoryType']}  ${categoryType[0]}
    Should Be Equal As Strings  ${resp.json()['name']}  ${New_status[4]}
    Should Be Equal As Strings  ${resp.json()['isDefault']}  ${bool[1]}

JD-TC-get Default status-UH1

    [Documentation]    Get default status without login

   ${resp}=  Get default status    ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-get Default status-UH2

    [Documentation]   Get default status Using Consumer Login

    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get default status    ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}




JD-TC-get Default status-UH4

    [Documentation]  Get default status without enable jaldee finance.

    ${resp}=  Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[1]}
        ${resp1}=    Enable Disable Jaldee Finance  ${toggle[1]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[0]}
    
    ${FIELD_DISABLED}=  format String   ${FIELD_DISABLED}   Jaldee Finance
    
    ${resp}=  Get default status   ${categoryType[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${FIELD_DISABLED}