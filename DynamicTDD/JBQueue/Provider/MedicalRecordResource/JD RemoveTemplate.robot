*** Settings ***
Suite Teardown                    Delete All Sessions 
Test Teardown                     Delete All Sessions
Force Tags                        MR
Library                           Collections
Library                           String
Library                           json
Library                           FakerLibrary
Library                           /ebs/TDD/db.py
Resource                          /ebs/TDD/ProviderKeywords.robot
Resource                          /ebs/TDD/ConsumerKeywords.robot
Variables                         /ebs/TDD/varfiles/providers.py
Variables                         /ebs/TDD/varfiles/consumerlist.py 
Variables                         /ebs/TDD/varfiles/consumermail.py
                                  
*** Variables ***      

                                  
*** Test Cases ***  

JD-TC-RemovePrescriptionTemplate-1

   [Documentation]                Remove prescription Template with id where created only one template

    ${resp}=  Encrypted Provider Login      ${PUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${id}  ${decrypted_data['id']}
    # Set Suite Variable    ${id}   ${resp.json()['id']}
    ${med_name1}                  FakerLibrary.name
    ${frequency1}                 FakerLibrary.word
    ${duration1}                  FakerLibrary.sentence
    ${instrn1}                    FakerLibrary.sentence
    ${dosage1}                    FakerLibrary.sentence
    ${med_name2}                  FakerLibrary.name
    ${frequency2}                 FakerLibrary.word
    ${duration2}                  FakerLibrary.sentence
    ${instrn2}                    FakerLibrary.sentence
    ${dosage2}                    FakerLibrary.sentence
    ${imageSize2}                 FakerLibrary.Random Number
    Set Suite Variable            ${med_name1}
    Set Suite Variable            ${frequency1}
    Set Suite Variable            ${duration1}
    Set Suite Variable            ${instrn1}
    Set Suite Variable            ${dosage1}
    Set Suite Variable            ${med_name2}
    Set Suite Variable            ${frequency2}
    Set Suite Variable            ${duration2}
    Set Suite Variable            ${instrn2}
    Set Suite Variable            ${dosage2}
    Set Suite Variable            ${imageSize2}
    
    ${templateName1}              FakerLibrary.sentence
    Set Suite Variable            ${templateName1}
    ${pre_list1}=                 Create Dictionary  medicine_name=${med_name1}  frequency=${frequency1}  instructions=${instrn1}  duration=${duration1}  dosage=${dosage1}

    ${resp}=                      Create Prescription Template  ${templateName1}  ${pre_list1}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200 
    Set Suite Variable            ${p1id1}    ${resp.json()}

    ${resp}=                      Get Prescription Template
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200

    ${resp}=                      Remove Template     ${p1id1}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200

    ${resp}=                      Get Prescription Template
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200

JD-TC-RemovePrescriptionTemplate-2
                                  
    [Documentation]               Remove prescription Template with id where created multiple template

    ${resp}=  Encrypted Provider Login      ${PUSERNAME38}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${id}  ${decrypted_data['id']}
    # Set Suite Variable    ${id}   ${resp.json()['id']}
    
    ${templateName2}              FakerLibrary.sentence
    ${pre_list1}=                 Create Dictionary  medicine_name=${med_name1}  frequency=${frequency1}  instructions=${instrn1}  duration=${duration1}  dosage=${dosage1}
    ${pre_list2}=                 Create Dictionary  medicine_name=${med_name2}  frequency=${frequency2}  instructions=${instrn2}  duration=${duration2}  dosage=${dosage2}  imageSize=${imageSize2}
    
    Set Suite Variable            ${templateName2}

    ${resp}=                      Create Prescription Template  ${templateName2}  ${pre_list1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200
    Set Suite Variable            ${p1id}    ${resp.json()}

    ${templateName3}              FakerLibrary.sentence
    Set Suite Variable            ${templateName3}

    ${resp}=                      Create Prescription Template  ${templateName3}  ${pre_list1}  ${pre_list2}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200
    Set Suite Variable            ${p2id}    ${resp.json()}

    ${resp}=                      Get Prescription Template
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200

    ${resp}=                      Remove Template     ${p2id}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200

    ${resp}=                      Get Prescription Template
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()[0]['templateName']}                            ${templateName2}
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionDto'][0]['medicine_name']}     ${med_name1}
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionDto'][0]['frequency']}         ${frequency1}
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionDto'][0]['instructions']}      ${instrn1}
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionDto'][0]['duration']}          ${duration1}
    Should Be Equal As Strings    ${resp.json()[0]['prescriptionDto'][0]['dosage']}            ${dosage1}

JD-TC-RemovePrescriptionTemplate-3

   [Documentation]               Remove prescription Template with invalid template id

    ${resp}=  Encrypted Provider Login      ${PUSERNAME38}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${id}  ${decrypted_data['id']}
    # Set Suite Variable    ${id}   ${resp.json()['id']}

    ${templateName3}              FakerLibrary.sentence
    Set Suite Variable            ${templateName3}
    ${pre_list1}=                 Create Dictionary  medicine_name=${med_name1}  frequency=${frequency1}  instructions=${instrn1}  duration=${duration1}  dosage=${dosage1}

    ${resp}=                      Create Prescription Template  ${templateName3}  ${pre_list1}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200 
    Set Suite Variable            ${p1id1}    ${resp.json()}

    ${resp}=                      Get Prescription Template
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200

    ${tempid}=                    FakerLibrary.Random Number

    ${resp}=                      Remove Template     ${tempid}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200

JD-TC-RemovePrescriptionTemplate-4

   [Documentation]               Remove prescription Template where prescription template is not created

    ${resp}=  Encrypted Provider Login      ${PUSERNAME40}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${id}   ${resp.json()['id']}

    ${tempid}=                    FakerLibrary.Random Number

    ${resp}=                      Remove Template     ${tempid}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200

JD-TC-RemovePrescriptionTemplate-UH1

   [Documentation]               Remove prescription Template without Provider Login

    ${tempid}=                    FakerLibrary.Random Number

    ${resp}=                      Remove Template     ${tempid}
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  419    
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}