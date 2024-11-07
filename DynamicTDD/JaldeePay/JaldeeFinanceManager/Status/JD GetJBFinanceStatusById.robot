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
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
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


JD-TC-Get status-1

    [Documentation]  Create Status as New and get status byid.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
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
    Should Be Equal As Strings  ${resp.json()['id']}  ${status_id1} 
    Should Be Equal As Strings  ${resp.json()['categoryType']}  ${categoryType[1]} 
    Should Be Equal As Strings  ${resp.json()['name']}  ${New_status[0]} 
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id1} 
    Should Be Equal As Strings  ${resp.json()['isEnabled']}  ${toggle[0]} 
    Should Be Equal As Strings  ${resp.json()['isDefault']}  ${bool[0]} 

JD-TC-Get status-2

    [Documentation]  Add new status for Vendor and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Finance Status   ${New_status[1]}  ${categoryType[1]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${status_id2}   ${resp.json()}

    ${resp}=  Get Finance Status By Id   ${status_id2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${status_id2} 
    Should Be Equal As Strings  ${resp.json()['categoryType']}  ${categoryType[1]} 
    Should Be Equal As Strings  ${resp.json()['name']}  ${New_status[1]} 
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id1} 
    Should Be Equal As Strings  ${resp.json()['isEnabled']}  ${toggle[0]} 
    Should Be Equal As Strings  ${resp.json()['isDefault']}  ${bool[0]} 

JD-TC-Get status-3

    [Documentation]  Update Vendor status and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Finance Status   ${New_status[3]}  ${categoryType[1]}   ${status_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Finance Status By Id   ${status_id2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${status_id2} 
    Should Be Equal As Strings  ${resp.json()['categoryType']}  ${categoryType[1]} 
    Should Be Equal As Strings  ${resp.json()['name']}  ${New_status[3]} 
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id1} 
    Should Be Equal As Strings  ${resp.json()['isEnabled']}  ${toggle[0]} 
    Should Be Equal As Strings  ${resp.json()['isDefault']}  ${bool[0]} 

JD-TC-Get status-4

    [Documentation]  Update Status With not created categoryType and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Update Finance Status   ${New_status[4]}  ${categoryType[2]}   ${status_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Finance Status By Id   ${status_id2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${status_id2} 
    Should Be Equal As Strings  ${resp.json()['categoryType']}  ${categoryType[2]} 
    Should Be Equal As Strings  ${resp.json()['name']}  ${New_status[4]} 
    Should Be Equal As Strings  ${resp.json()['accountId']}  ${account_id1} 
    Should Be Equal As Strings  ${resp.json()['isEnabled']}  ${toggle[0]} 
    Should Be Equal As Strings  ${resp.json()['isDefault']}  ${bool[0]} 

JD-TC-Get status-UH1

    [Documentation]   Get Category By Id without login

    ${resp}=  Get Finance Status By Id   ${status_id2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JJD-TC-Get status-UH2

    [Documentation]   Get Category by Id Using Consumer Login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


    #............provider consumer creation..........

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    Set Suite Variable  ${fname}
    ${lastname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  countryCode=${countryCodes[1]} 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${account_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Finance Status By Id   ${status_id2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}


JJD-TC-Get status-UH3

    [Documentation]   Get Category by Id Using another provisders status id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME12}  ${PASSWORD}
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

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   Category Id
    
    ${resp}=  Get Finance Status By Id   ${status_id2}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${INVALID_FM_STATUS_ID}
