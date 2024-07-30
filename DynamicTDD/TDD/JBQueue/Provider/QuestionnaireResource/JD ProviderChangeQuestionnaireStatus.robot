*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        Questionnaire
Library           Collections
Library           String
Library           json
Library           FakerLibrary
#Library           ExcellentLibrary
Library           OperatingSystem
Library           /ebs/TDD/Imageupload.py
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
${xlFile}      ${EXECDIR}/TDD/sampleqnr.xlsx    # DataSheet
${xlFile2}      ${EXECDIR}/TDD/qnr.xlsx    # DataSheet 2
@{emptylist}

*** Test Cases ***

JD-TC-ChangeQuestionnaireStatusByProvider-1
    [Documentation]  change status of all questionnaire to Active
    ${account_id}=  db.get_acc_id  ${PUSERNAME5}

    # clear_service   ${PUSERNAME5}

    ${wb}=  readWorkbook  ${xlFile}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Set Suite Variable   ${colnames}
    ${servicenames}   getColumnValuesByName  ${sheet1}  ${colnames[6]}
    Log   ${servicenames}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    @{snames}=  Create List
    # Set Test Variable   ${s_name}   ${resp.json()[0]['name']}
    FOR  ${i}  IN RANGE   ${s_len}
        Append To List  ${snames}  ${resp.json()[${i}]['name']}
    END

    Remove Values From List  ${servicenames}   ${NONE}
    Log  ${servicenames}
    ${unique_snames}=    Remove Duplicates    ${servicenames}
    Log  ${unique_snames}
    ${snames_len}=  Get Length  ${unique_snames}
    FOR  ${i}  IN RANGE   ${snames_len}
        ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${snames}  ${unique_snames[${i}]}
        Log Many  ${kwstatus} 	${value}
        Continue For Loop If  '${kwstatus}' == 'PASS'
        &{dict}=  Create Dictionary   ${colnames[6]}=${unique_snames[${i}]}
        ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
        Log  ${ttype}
        ${u_ttype}=    Remove Duplicates    ${ttype}
        Log  ${u_ttype}
        ${s_id}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[3]}' in @{u_ttype}  Create Sample Service  ${unique_snames[${i}]}
        ${d_id}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[0]}' in @{u_ttype}   Create Sample Donation  ${unique_snames[${i}]}
    END

    # ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}    ${xlFile}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=  Get Questionnaire List By Provider  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    @{ids}=  Create List
    FOR  ${i}  IN RANGE   ${len}
        Append To List  ${ids}   ${resp.json()[${i}]['id']} 
    END

    ${j}=  Evaluate  ${len}+1

    FOR  ${id}  IN   @{ids}
        ${qns}   Get Provider Questionnaire By Id   ${id}  
        Log  ${qns.content}
        Should Be Equal As Strings  ${qns.status_code}  200
        Should Be Equal As Strings   ${qns.json()['status']}  ${status[1]}
    END

    # FOR  ${i}  IN RANGE   1  ${j}
    #     ${qns}   Get Provider Questionnaire By Id   ${i}  
    #     Log  ${qns.content}
    #     Should Be Equal As Strings  ${qns.status_code}  200
    #     Should Be Equal As Strings   ${qns.json()['status']}  ${status[1]}
    # END

    FOR  ${id}  IN   @{ids}
        ${resp}=  Provider Change Questionnaire Status  ${id}  ${status[0]}  
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${qns}   Get Provider Questionnaire By Id   ${id}  
        Log  ${qns.content}
        Should Be Equal As Strings  ${qns.status_code}  200
        Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    END


JD-TC-ChangeQuestionnaireStatusByProvider-UH1
    [Documentation]  change status of all Active Questionnaire to Active
    comment  Also check status when the same file is uploaded again.
    ${account_id}=  db.get_acc_id  ${PUSERNAME5}

    # clear_service   ${PUSERNAME5}

    ${wb}=  readWorkbook  ${xlFile}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Set Suite Variable   ${colnames}
    ${servicenames}   getColumnValuesByName  ${sheet1}  ${colnames[6]}
    Log   ${servicenames}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    @{snames}=  Create List
    # Set Test Variable   ${s_name}   ${resp.json()[0]['name']}
    FOR  ${i}  IN RANGE   ${s_len}
        Append To List  ${snames}  ${resp.json()[${i}]['name']}
    END

    Remove Values From List  ${servicenames}   ${NONE}
    Log  ${servicenames}
    ${unique_snames}=    Remove Duplicates    ${servicenames}
    Log  ${unique_snames}
    ${snames_len}=  Get Length  ${unique_snames}
    FOR  ${i}  IN RANGE   ${snames_len}
        ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${snames}  ${unique_snames[${i}]}
        Log Many  ${kwstatus} 	${value}
        Continue For Loop If  '${kwstatus}' == 'PASS'
        &{dict}=  Create Dictionary   ${colnames[6]}=${unique_snames[${i}]}
        ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
        Log  ${ttype}
        ${u_ttype}=    Remove Duplicates    ${ttype}
        Log  ${u_ttype}
        ${s_id}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[3]}' in @{u_ttype}  Create Sample Service  ${unique_snames[${i}]}
        ${d_id}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[0]}' in @{u_ttype}   Create Sample Donation  ${unique_snames[${i}]}
    END

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}    ${xlFile} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=  Get Questionnaire List By Provider  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    @{ids}=  Create List
    FOR  ${i}  IN RANGE   ${len}
        Append To List  ${ids}   ${resp.json()[${i}]['id']} 
    END

    # ${j}=  Evaluate  ${len}+1

    FOR  ${id}  IN   @{ids}
        ${qns}   Get Provider Questionnaire By Id   ${id}  
        Log  ${qns.content}
        Should Be Equal As Strings  ${qns.status_code}  200
        # Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
        ${resp1}=   Run Keyword If  '${qns.json()['status']}' == '${status[1]}'   Provider Change Questionnaire Status  ${id}  ${status[0]}
        Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
        Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

        ${resp}=  Provider Change Questionnaire Status  ${id}  ${status[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings   ${resp.json()}  ${QUESTIONNAIRE_ALREADY_ENABLED}

    END

    comment  change questionnaire status to inactive for next case.

    FOR  ${id}  IN   @{ids}
        ${resp}=  Provider Change Questionnaire Status  ${id}  ${status[1]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${qns}   Get Provider Questionnaire By Id   ${id}  
        Log  ${qns.content}
        Should Be Equal As Strings  ${qns.status_code}  200
        Should Be Equal As Strings   ${qns.json()['status']}  ${status[1]}
    END


JD-TC-ChangeQuestionnaireStatusByProvider-UH2
    [Documentation]  change status of all Inactive Questionnaire to Inactive
    ${account_id}=  db.get_acc_id  ${PUSERNAME5}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=  Get Questionnaire List By Provider  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    @{ids}=  Create List
    FOR  ${i}  IN RANGE   ${len}
        Append To List  ${ids}   ${resp.json()[${i}]['id']} 
    END

    # ${j}=  Evaluate  ${len}+1

    FOR  ${id}  IN   @{ids}
        ${qns}   Get Provider Questionnaire By Id   ${id}  
        Log  ${qns.content}
        Should Be Equal As Strings  ${qns.status_code}  200
        # Should Be Equal As Strings   ${qns.json()['status']}  ${status[1]}
        ${resp1}=   Run Keyword If  '${qns.json()['status']}' == '${status[0]}'   Provider Change Questionnaire Status  ${id}  ${status[1]}
        Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
        Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

        ${resp}=  Provider Change Questionnaire Status  ${id}  ${status[1]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings   ${resp.json()}  ${QUESTIONNAIRE_ALREADY_DISABLED}

        ${qns}   Get Provider Questionnaire By Id   ${id}  
        Log  ${qns.content}
        Should Be Equal As Strings  ${qns.status_code}  200
        Should Be Equal As Strings   ${qns.json()['status']}  ${status[1]}
    END


JD-TC-ChangeQuestionnaireStatusByProvider-UH4
    [Documentation]  change status of Questionnaire with non existant questionnaire id

    # ${account_id}=  db.get_acc_id  ${PUSERNAME5}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=  Get Questionnaire List By Provider  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${invalid_qnsid}=  FakerLibrary.Numerify  %%%

    ${resp}=  Provider Change Questionnaire Status  ${invalid_qnsid}  ${status[1]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}  ${QUESTIONNAIRE_NOT_EXIST}


JD-TC-ChangeQuestionnaireStatusByProvider-UH6
    [Documentation]  change status of Questionnaire for provider who doesn't have questionnaire

    # ${account_id}=  db.get_acc_id  ${PUSERNAME141}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME141}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=  Get Questionnaire List By Provider  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${j}=    Evaluate    random.randint(1, 5)    random

    ${resp}=  Provider Change Questionnaire Status  ${j}  ${status[1]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}  ${QUESTIONNAIRE_NOT_EXIST}


JD-TC-ChangeQuestionnaireStatusByProvider-UH7
    [Documentation]  change status of Questionnaire without provider login

    ${j}=    Evaluate    random.randint(1, 5)    random

    ${resp}=  Provider Change Questionnaire Status  ${j}  ${status[1]}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}  ${SESSION_EXPIRED}


JD-TC-ChangeQuestionnaireStatusByProvider-UH8
    [Documentation]  change status of Questionnaire by SA login

    ${resp}=   SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${j}=    Evaluate    random.randint(1, 5)    random

    ${resp}=  Provider Change Questionnaire Status  ${j}  ${status[1]}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}  ${SESSION_EXPIRED}


JD-TC-ChangeQuestionnaireStatusByProvider-UH9
    [Documentation]  change status of Questionnaire by consumer login

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${j}=    Evaluate    random.randint(1, 5)    random

    ${resp}=  Provider Change Questionnaire Status  ${j}  ${status[1]} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}  ${LOGIN_NO_ACCESS_FOR_URL}