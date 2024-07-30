*** Settings ***

Suite Teardown    Run Keywords  Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Questionnaire
Library           Collections
Library           String
Library           json
Library           FakerLibrary
#Library           ExcellentLibrary
# Library           ExcelLibrary
Library           OperatingSystem
Library           robot.api.logger
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
${SERVICE1}   consultation
@{Datatypes}   plainText  list  bool  date  number  fileUpload  map
@{property}   plainTextPropertie   listPropertie  booleanProperties   dateProperties  numberPropertie   filePropertie


*** Test Cases ***

JD-TC-ChangeQuestionnaireStatus-1
    [Documentation]  change status of all questionnaire to Active
    ${account_id}=  db.get_acc_id  ${PUSERNAME4}

    # clear_service   ${PUSERNAME4}
    ${wb}=  readWorkbook  ${xlFile}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Log List  ${colnames}
    Log List  ${QnrChannel}
    Log List  ${QnrTransactionType}
    Set Suite Variable   ${colnames}
    ${servicenames}   getColumnValuesByName  ${sheet1}  ${colnames[6]}
    Log   ${servicenames}
    # Remove Values From List  ${servicenames}   ${NONE}
    # Log  ${servicenames}
    # ${unique_lnames}=    Remove Duplicates    ${servicenames}
    # Log  ${unique_lnames}
    # Set Suite Variable   ${unique_lnames}


#*** commnet ***
    # ${wb}=  readWorkbook  ${xlFile}
    # ${sheet1}  GetCurrentSheet   ${wb}
    # Set Suite Variable   ${sheet1}
    # ${colnames}=  getColumnHeaders  ${sheet1}
    # Set Suite Variable   ${colnames}
    # ${servicenames}   getColumnValuesByName  ${sheet1}  ${colnames[6]}
    # Log   ${servicenames}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

# *** Comments ***


    # ${resp}=   Get Service
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${s_len}=  Get Length  ${resp.json()}
    # @{snames}=  Create List
    # FOR  ${i}  IN RANGE   ${s_len}
    #     Append To List  ${snames}  ${resp.json()[${i}]['name']}
    # END

    # Remove Values From List  ${servicenames}   ${NONE}
    # Log  ${servicenames}
    # ${unique_snames}=    Remove Duplicates    ${servicenames}
    # Log  ${unique_snames}
    # ${snames_len}=  Get Length  ${unique_snames}
    # FOR  ${i}  IN RANGE   ${snames_len}
    #     ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${snames}  ${unique_snames[${i}]}
    #     Log Many  ${kwstatus} 	${value}
    #     Continue For Loop If  '${kwstatus}' == 'PASS'
    #     &{dict}=  Create Dictionary   ${colnames[6]}=${unique_snames[${i}]}
    #     ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
    #     Log  ${ttype}
    #     ${u_ttype}=    Remove Duplicates    ${ttype}
    #     Log  ${u_ttype}
    #     ${s_id}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[3]}' in @{u_ttype}  Create Sample Service  ${unique_snames[${i}]}
    #     ${d_id}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[0]}' in @{u_ttype}   Create Sample Donation  ${unique_snames[${i}]}
    # END

    # ${resp}=  Provider Logout
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    
    # ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${sa_resp}=  Get Questionnaire List   ${account_id}  
    # Log  ${sa_resp.content}
    # Should Be Equal As Strings  ${sa_resp.status_code}  200
    # ${len}=  Get Length  ${sa_resp.json()}

    # *** Comments ***

    ${resp}=   Get Service
    Log   ${resp.json()}
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
    Set Suite Variable   ${unique_snames}

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
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List   ${account_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${j}=  Evaluate  ${len}+1

    FOR  ${i}  IN RANGE   1  ${j}
        ${qns}   Get Questionnaire By Id  ${account_id}  ${i}  
        Log  ${qns.json()}
        Should Be Equal As Strings  ${qns.status_code}  200
        Should Be Equal As Strings   ${qns.json()['status']}  ${status[1]}
    END

    FOR  ${i}  IN RANGE   1  ${j}
        ${resp}=  Change Status of Questionnaire   ${account_id}  ${status[0]}  ${i}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${qns}   Get Questionnaire By Id  ${account_id}  ${i}  
        Log  ${qns.json()}
        Should Be Equal As Strings  ${qns.status_code}  200
        Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    END


JD-TC-ChangeQuestionnaireStatus-UH1
    [Documentation]  change status of all Active Questionnaire to Active
    ${account_id}=  db.get_acc_id  ${PUSERNAME4}

    # clear_service   ${PUSERNAME4}

    ${wb}=  readWorkbook  ${xlFile}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Set Suite Variable   ${colnames}
    ${servicenames}   getColumnValuesByName  ${sheet1}  ${colnames[7]}
    Log   ${servicenames}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=   Get Service
    Log   ${resp.json()}
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
        &{dict}=  Create Dictionary   ${colnames[7]}=${unique_snames[${i}]}
        ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[5]}  &{dict}  
        Log  ${ttype}
        ${u_ttype}=    Remove Duplicates    ${ttype}
        Log  ${u_ttype}
        ${s_id}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[3]}' in @{u_ttype}  Create Sample Service  ${unique_snames[${i}]}
        ${d_id}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[0]}' in @{u_ttype}   Create Sample Donation  ${unique_snames[${i}]}
    END

    # ${s_id}=  Create Sample Service  ${SERVICE1}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List   ${account_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${j}=  Evaluate  ${len}+1

    FOR  ${i}  IN RANGE   1  ${j}
        ${qns}   Get Questionnaire By Id  ${account_id}  ${i}  
        Log  ${qns.json()}
        Should Be Equal As Strings  ${qns.status_code}  200
        # Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
        ${resp1}=   Run Keyword If  '${qns.json()['status']}' == '${status[1]}'   Change Status of Questionnaire   ${account_id}  ${status[0]}  ${i}
        Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
        Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

        ${resp}=  Change Status of Questionnaire   ${account_id}  ${status[0]}  ${i}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings   ${resp.json()}  ${QUESTIONNAIRE_ALREADY_ENABLED}

        # ${qns}   Get Questionnaire By Id  ${account_id}  ${i}  
        # Log  ${qns.json()}
        # Should Be Equal As Strings  ${qns.status_code}  200
        # Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    END

    comment  change questionnaire status to inactive for next case.

    FOR  ${i}  IN RANGE   1  ${j}
        ${resp}=  Change Status of Questionnaire   ${account_id}  ${status[1]}  ${i}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${qns}   Get Questionnaire By Id  ${account_id}  ${i}  
        Log  ${qns.json()}
        Should Be Equal As Strings  ${qns.status_code}  200
        Should Be Equal As Strings   ${qns.json()['status']}  ${status[1]}
    END


JD-TC-ChangeQuestionnaireStatus-UH2
    [Documentation]  change status of all Inactive Questionnaire to Inactive
    ${account_id}=  db.get_acc_id  ${PUSERNAME4}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List   ${account_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${j}=  Evaluate  ${len}+1

    FOR  ${i}  IN RANGE   1  ${j}
        ${qns}   Get Questionnaire By Id  ${account_id}  ${i}  
        Log  ${qns.json()}
        Should Be Equal As Strings  ${qns.status_code}  200
        # Should Be Equal As Strings   ${qns.json()['status']}  ${status[1]}
        ${resp1}=   Run Keyword If  '${qns.json()['status']}' == '${status[0]}'   Change Status of Questionnaire   ${account_id}  ${status[1]}  ${i}
        Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
        Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

        ${resp}=  Change Status of Questionnaire   ${account_id}  ${status[1]}  ${i}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings   ${resp.json()}  ${QUESTIONNAIRE_ALREADY_DISABLED}

        ${qns}   Get Questionnaire By Id  ${account_id}  ${i}  
        Log  ${qns.json()}
        Should Be Equal As Strings  ${qns.status_code}  200
        Should Be Equal As Strings   ${qns.json()['status']}  ${status[1]}
    END


# JD-TC-ChangeQuestionnaireStatus-UH3
#     [Documentation]  change status of Questionnaire without account id

#     ${account_id}=  db.get_acc_id  ${PUSERNAME4}

#     ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Get Questionnaire List   ${account_id}  
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     ${len}=  Get Length  ${resp.json()}

#     ${j}=    Evaluate    random.randint(1, ${len})    random
#     # Evaluate    random.randint(0, sys.maxsize)    random

#     ${qns}   Get Questionnaire By Id  ${account_id}  ${j}  
#     Log  ${qns.json()}
#     Should Be Equal As Strings  ${qns.status_code}  200
#     Should Be Equal As Strings   ${qns.json()['status']}  ${status[1]}

#     ${resp}=  Change Status of Questionnaire   ${EMPTY}  ${status[1]}  ${j}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  404
#     # Should Be Equal As Strings   ${resp.json()}  "same staus already have"

#     ${qns}   Get Questionnaire By Id  ${account_id}  ${j}  
#     Log  ${qns.json()}
#     Should Be Equal As Strings  ${qns.status_code}  200
#     Should Be Equal As Strings   ${qns.json()['status']}  ${status[1]}


JD-TC-ChangeQuestionnaireStatus-UH4
    [Documentation]  change status of Questionnaire with non existant questionnaire id

    ${account_id}=  db.get_acc_id  ${PUSERNAME4}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List   ${account_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}

    ${invalid_qnsid}=  FakerLibrary.Numerify  %%%

    ${resp}=  Change Status of Questionnaire   ${account_id}  ${status[1]}  ${invalid_qnsid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}  ${QUESTIONNAIRE_NOT_EXIST}


JD-TC-ChangeQuestionnaireStatus-UH5
    [Documentation]  change status of Questionnaire for non existant provider

    ${account_id}=  db.get_acc_id  ${PUSERNAME4}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List   ${account_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    ${qnr_id_list}=  Create List
    FOR  ${i}  IN RANGE   ${len}
        Append To List   ${qnr_id_list}  ${resp.json()[${i}]['id']}
    END

    # ${j}=    Evaluate    random.randint(1, ${len})    random
    ${j}=    Evaluate    random.choice($qnr_id_list)  random

    ${invalid_account_id}=  FakerLibrary.Numerify  %%%%%%%%

    ${resp}=  Change Status of Questionnaire   ${invalid_account_id}  ${status[1]}  ${j}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}  ${QUESTIONNAIRE_NOT_EXIST}


JD-TC-ChangeQuestionnaireStatus-UH6
    [Documentation]  change status of Questionnaire for provider who doesn't have questionnaire

    ${account_id}=  db.get_acc_id  ${PUSERNAME141}

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Questionnaire List   ${account_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    # ${qnr_id_list}=  Create List
    # FOR  ${i}  IN RANGE   ${len}
    #     Append To List   ${qnr_id_list}  ${resp.json()[${i}]['id']}
    # END

    ${j}=    Evaluate    random.randint(1, 5)    random
    # ${j}=    Evaluate    random.sample(${qnr_id_list},1)   random

    ${resp}=  Change Status of Questionnaire   ${account_id}  ${status[1]}  ${j}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}  ${QUESTIONNAIRE_NOT_EXIST}


JD-TC-ChangeQuestionnaireStatus-UH7
    [Documentation]  change status of Questionnaire without SA login

    ${account_id}=  db.get_acc_id  ${PUSERNAME4}

    ${j}=    Evaluate    random.randint(1, 5)    random

    ${resp}=  Change Status of Questionnaire   ${account_id}  ${status[1]}  ${j} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}  ${SA_SESSION_EXPIRED}


JD-TC-ChangeQuestionnaireStatus-UH8
    [Documentation]  change status of Questionnaire by provider login

    ${account_id}=  db.get_acc_id  ${PUSERNAME4}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${j}=    Evaluate    random.randint(1, 5)    random

    ${resp}=  Change Status of Questionnaire   ${account_id}  ${status[1]}  ${j} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}  ${SA_SESSION_EXPIRED}


JD-TC-ChangeQuestionnaireStatus-UH9
    [Documentation]  change status of Questionnaire by consumer login

    ${account_id}=  get_acc_id  ${PUSERNAME4}

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${j}=    Evaluate    random.randint(1, 5)    random

    ${resp}=  Change Status of Questionnaire   ${account_id}  ${status[1]}  ${j} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}  ${SA_SESSION_EXPIRED}