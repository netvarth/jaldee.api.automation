*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Business Logo
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderPartnerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py


*** Variables ***

@{emptylist}

${jpgfile}      /ebs/TDD/uploadimage.jpg

${order}    0
${fileSize}  0.00458


*** Test Cases ***

JD-TC-Remove_Business_Logo-1
                                  
    [Documentation]               Remove Business Logo
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id1}  ${decrypted_data['id']}
    # Set Suite Variable  ${provider_id1}  ${resp.json()['id']}

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite variable    ${caption1}
    ${fileName}=    FakerLibrary.firstname
    Set Suite variable    ${fileName}

    ${resp}=    Add Business Logo    ${provider_id1}    ${fileName}    ${fileSize}    ${LoanAction[0]}    ${caption1}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Business Logo
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}              200
    Should Be Equal As Strings    ${resp.json()[0]['owner']}       ${provider_id1}
    Should Be Equal As Strings    ${resp.json()[0]['fileName']}    ${fileName}
    Should Be Equal As Strings    ${resp.json()[0]['fileSize']}    ${fileSize}
    Should Be Equal As Strings    ${resp.json()[0]['caption']}     ${caption1}
    Should Be Equal As Strings    ${resp.json()[0]['fileType']}    ${fileType1}
    Should Be Equal As Strings    ${resp.json()[0]['action']}      ${LoanAction[0]}

    ${resp}=    Remove Business Logo    ${provider_id1}    ${fileName}    ${fileSize}    ${LoanAction[1]}    ${caption1}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Business Logo
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.content}   ${emptylist}
    


JD-TC-Remove_Business_Logo-UH1
                                  
    [Documentation]               Remove Business Logo where provider id is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Add Business Logo    ${provider_id1}    ${fileName}    ${fileSize}    ${LoanAction[0]}    ${caption1}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Business Logo
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}              200
    Should Be Equal As Strings    ${resp.json()[0]['owner']}       ${provider_id1}
    Should Be Equal As Strings    ${resp.json()[0]['fileName']}    ${fileName}
    Should Be Equal As Strings    ${resp.json()[0]['fileSize']}    ${fileSize}
    Should Be Equal As Strings    ${resp.json()[0]['caption']}     ${caption1}
    Should Be Equal As Strings    ${resp.json()[0]['fileType']}    ${fileType1}
    Should Be Equal As Strings    ${resp.json()[0]['action']}      ${LoanAction[0]}

    ${invpid}=    FakerLibrary.Random Number

    ${resp}=    Remove Business Logo    ${invpid}    ${fileName}    ${fileSize}    ${LoanAction[1]}    ${caption1}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Run Keyword And Continue On Failure  Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Business Logo
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}              200
    Should Be Equal As Strings    ${resp.json()}       ${emptylist}
    # Should Be Equal As Strings    ${resp.json()[0]['owner']}       ${provider_id1}
    # Should Be Equal As Strings    ${resp.json()[0]['fileName']}    ${fileName}
    # Should Be Equal As Strings    ${resp.json()[0]['fileSize']}    ${fileSize}
    # Should Be Equal As Strings    ${resp.json()[0]['caption']}     ${caption1}
    # Should Be Equal As Strings    ${resp.json()[0]['fileType']}    ${fileType1}
    # Should Be Equal As Strings    ${resp.json()[0]['action']}      ${LoanAction[0]}


JD-TC-Remove_Business_Logo-UH2
                                  
    [Documentation]               Remove Business Logo with empty file name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Add Business Logo    ${provider_id1}    ${fileName}    ${fileSize}    ${LoanAction[0]}    ${caption1}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Business Logo
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}              200
    Should Be Equal As Strings    ${resp.json()[0]['owner']}       ${provider_id1}
    Should Be Equal As Strings    ${resp.json()[0]['fileName']}    ${fileName}
    Should Be Equal As Strings    ${resp.json()[0]['fileSize']}    ${fileSize}
    Should Be Equal As Strings    ${resp.json()[0]['caption']}     ${caption1}
    Should Be Equal As Strings    ${resp.json()[0]['fileType']}    ${fileType1}
    Should Be Equal As Strings    ${resp.json()[0]['action']}      ${LoanAction[0]}

    ${resp}=    Remove Business Logo    ${provider_id1}    ${empty}    ${fileSize}    ${LoanAction[1]}    ${caption1}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Run Keyword And Continue On Failure  Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Business Logo
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}              200
    Should Be Equal As Strings    ${resp.json()[0]['owner']}       ${provider_id1}
    Should Be Equal As Strings    ${resp.json()[0]['fileName']}    ${fileName}
    Should Be Equal As Strings    ${resp.json()[0]['fileSize']}    ${fileSize}
    Should Be Equal As Strings    ${resp.json()[0]['caption']}     ${caption1}
    Should Be Equal As Strings    ${resp.json()[0]['fileType']}    ${fileType1}
    Should Be Equal As Strings    ${resp.json()[0]['action']}      ${LoanAction[0]}


JD-TC-Remove_Business_Logo-UH3
                                  
    [Documentation]               Remove Business Logo with empty file size

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Add Business Logo    ${provider_id1}    ${fileName}    ${fileSize}    ${LoanAction[0]}    ${caption1}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Business Logo
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}              200
    Should Be Equal As Strings    ${resp.json()[0]['owner']}       ${provider_id1}
    Should Be Equal As Strings    ${resp.json()[0]['fileName']}    ${fileName}
    Should Be Equal As Strings    ${resp.json()[0]['fileSize']}    ${fileSize}
    Should Be Equal As Strings    ${resp.json()[0]['caption']}     ${caption1}
    Should Be Equal As Strings    ${resp.json()[0]['fileType']}    ${fileType1}
    Should Be Equal As Strings    ${resp.json()[0]['action']}      ${LoanAction[0]}

    ${resp}=    Remove Business Logo    ${provider_id1}    ${fileName}    ${empty}    ${LoanAction[1]}    ${caption1}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}  ${FILE_SIZE_ERROR}


JD-TC-Remove_Business_Logo-UH4
                                  
    [Documentation]               Remove Business Logo with empty action

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Add Business Logo    ${provider_id1}    ${fileName}    ${fileSize}    ${LoanAction[0]}    ${caption1}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Business Logo
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}              200
    Should Be Equal As Strings    ${resp.json()[0]['owner']}       ${provider_id1}
    Should Be Equal As Strings    ${resp.json()[0]['fileName']}    ${fileName}
    Should Be Equal As Strings    ${resp.json()[0]['fileSize']}    ${fileSize}
    Should Be Equal As Strings    ${resp.json()[0]['caption']}     ${caption1}
    Should Be Equal As Strings    ${resp.json()[0]['fileType']}    ${fileType1}
    Should Be Equal As Strings    ${resp.json()[0]['action']}      ${LoanAction[0]}

    ${resp}=    Remove Business Logo    ${provider_id1}    ${fileName}    ${fileSize}    ${empty}    ${caption1}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    500


JD-TC-Remove_Business_Logo-UH5
                                  
    [Documentation]               Remove Business Logo with action no change

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Add Business Logo    ${provider_id1}    ${fileName}    ${fileSize}    ${LoanAction[0]}    ${caption1}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Business Logo
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}              200
    Should Be Equal As Strings    ${resp.json()[0]['owner']}       ${provider_id1}
    Should Be Equal As Strings    ${resp.json()[0]['fileName']}    ${fileName}
    Should Be Equal As Strings    ${resp.json()[0]['fileSize']}    ${fileSize}
    Should Be Equal As Strings    ${resp.json()[0]['caption']}     ${caption1}
    Should Be Equal As Strings    ${resp.json()[0]['fileType']}    ${fileType1}
    Should Be Equal As Strings    ${resp.json()[0]['action']}      ${LoanAction[0]}

    ${resp}=    Remove Business Logo    ${provider_id1}    ${fileName}    ${fileSize}    ${LoanAction[2]}    ${caption1}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Business Logo
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}              200
    Should Be Equal As Strings    ${resp.json()[0]['owner']}       ${provider_id1}
    Should Be Equal As Strings    ${resp.json()[0]['fileName']}    ${fileName}
    Should Be Equal As Strings    ${resp.json()[0]['fileSize']}    ${fileSize}
    Should Be Equal As Strings    ${resp.json()[0]['caption']}     ${caption1}
    Should Be Equal As Strings    ${resp.json()[0]['fileType']}    ${fileType1}
    Should Be Equal As Strings    ${resp.json()[0]['action']}      ${LoanAction[0]}


JD-TC-Remove_Business_Logo-UH6
                                  
    [Documentation]               Remove Business Logo with empty caption

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Add Business Logo    ${provider_id1}    ${fileName}    ${fileSize}    ${LoanAction[0]}    ${caption1}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Business Logo
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}              200
    Should Be Equal As Strings    ${resp.json()[0]['owner']}       ${provider_id1}
    Should Be Equal As Strings    ${resp.json()[0]['fileName']}    ${fileName}
    Should Be Equal As Strings    ${resp.json()[0]['fileSize']}    ${fileSize}
    Should Be Equal As Strings    ${resp.json()[0]['caption']}     ${caption1}
    Should Be Equal As Strings    ${resp.json()[0]['fileType']}    ${fileType1}
    Should Be Equal As Strings    ${resp.json()[0]['action']}      ${LoanAction[0]}

    ${resp}=    Remove Business Logo    ${provider_id1}    ${fileName}    ${fileSize}    ${LoanAction[1]}    ${empty}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Business Logo
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}              200
    Should Be Equal As Strings    ${resp.content}   ${emptylist}


JD-TC-Remove_Business_Logo-UH7
                                  
    [Documentation]    Remove Business Logo with empty file type

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Add Business Logo    ${provider_id1}    ${fileName}    ${fileSize}    ${LoanAction[0]}    ${caption1}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Business Logo
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}              200
    Should Be Equal As Strings    ${resp.json()[0]['owner']}       ${provider_id1}
    Should Be Equal As Strings    ${resp.json()[0]['fileName']}    ${fileName}
    Should Be Equal As Strings    ${resp.json()[0]['fileSize']}    ${fileSize}
    Should Be Equal As Strings    ${resp.json()[0]['caption']}     ${caption1}
    Should Be Equal As Strings    ${resp.json()[0]['fileType']}    ${fileType1}
    Should Be Equal As Strings    ${resp.json()[0]['action']}      ${LoanAction[0]}

    ${resp}=    Remove Business Logo    ${provider_id1}    ${fileName}    ${fileSize}    ${LoanAction[1]}    ${caption1}    ${empty}    ${order}
    Log  ${resp.json()}
    Run Keyword And Continue On Failure  Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Business Logo
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}              200
    Should Be Equal As Strings    ${resp.json()[0]['owner']}       ${provider_id1}
    Should Be Equal As Strings    ${resp.json()[0]['fileName']}    ${fileName}
    Should Be Equal As Strings    ${resp.json()[0]['fileSize']}    ${fileSize}
    Should Be Equal As Strings    ${resp.json()[0]['caption']}     ${caption1}
    Should Be Equal As Strings    ${resp.json()[0]['fileType']}    ${fileType1}
    Should Be Equal As Strings    ${resp.json()[0]['action']}      ${LoanAction[0]}


JD-TC-Remove_Business_Logo-UH8
                                  
    [Documentation]               Remove Business Logo with empty order

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Add Business Logo    ${provider_id1}    ${fileName}    ${fileSize}    ${LoanAction[0]}    ${caption1}    ${fileType1}    ${order}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Business Logo
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}              200
    Should Be Equal As Strings    ${resp.json()[0]['owner']}       ${provider_id1}
    Should Be Equal As Strings    ${resp.json()[0]['fileName']}    ${fileName}
    Should Be Equal As Strings    ${resp.json()[0]['fileSize']}    ${fileSize}
    Should Be Equal As Strings    ${resp.json()[0]['caption']}     ${caption1}
    Should Be Equal As Strings    ${resp.json()[0]['fileType']}    ${fileType1}
    Should Be Equal As Strings    ${resp.json()[0]['action']}      ${LoanAction[0]}

    ${resp}=    Remove Business Logo    ${provider_id1}    ${fileName}    ${fileSize}    ${LoanAction[1]}    ${caption1}    ${fileType1}    ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Business Logo
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}              200
    Should Be Equal As Strings    ${resp.content}   ${emptylist}