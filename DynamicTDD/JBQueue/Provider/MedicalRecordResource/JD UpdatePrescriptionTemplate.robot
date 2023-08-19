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

JD-TC-UpdatePrescriptionTemplate-1

   [Documentation]                Update prescription Template with id where created only one template

    ${resp}=  Provider Login      ${PUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${id}   ${resp.json()['id']}
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

    ${med_name0}                  FakerLibrary.name
    ${frequency0}                 FakerLibrary.word
    ${duration0}                  FakerLibrary.sentence
    ${instrn0}                    FakerLibrary.sentence
    ${dosage0}                    FakerLibrary.sentence
    Set Suite Variable            ${med_name0}
    Set Suite Variable            ${frequency0}
    Set Suite Variable            ${duration0}
    Set Suite Variable            ${instrn0}
    Set Suite Variable            ${dosage0}

    ${templateName2}              FakerLibrary.sentence
    Set Suite Variable            ${templateName2}

    ${pre_list2}=                 Create Dictionary  medicine_name=${med_name2}  frequency=${frequency1}  instructions=${instrn1}  duration=${duration1}  dosage=${dosage1}

    ${resp}=                      Update Prescription Template    ${p1id1}  ${templateName2}  ${pre_list2}  
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200

    ${resp}=                      Get Prescription Template
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200

JD-TC-UpdatePrescriptionTemplate-UH1

   [Documentation]                Update prescription Template where template is not created

    ${resp}=  Provider Login      ${PUSERNAME38}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${id}   ${resp.json()['id']}
    
    ${templateName2}              FakerLibrary.sentence
    ${pre_list1}=                 Create Dictionary  medicine_name=${med_name1}  frequency=${frequency1}  instructions=${instrn1}  duration=${duration1}  dosage=${dosage1}
    
    Set Suite Variable            ${templateName2}

    ${resp}=                      Get Prescription Template
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200

    ${presid}=                    FakerLibrary.Random Number

    ${resp}=                      Update Prescription Template    ${presid}  ${templateName2}  ${pre_list1}  
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}   ${INVALID_INPUT}

JD-TC-UpdatePrescriptionTemplate-2

    [Documentation]                Update Prescription Template with same data

    ${resp}=  Provider Login      ${PUSERNAME23}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${id}   ${resp.json()['id']}
    
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

    ${templateName2}              FakerLibrary.sentence
    Set Suite Variable            ${templateName2}

    ${resp}=                      Update Prescription Template    ${p1id1}  ${templateName2}  ${pre_list1}  
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200

    ${resp}=                      Get Prescription Template
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200

JD-TC-UpdatePrescriptionTemplate-3

    [Documentation]                Update Prescription Template with same templatename

    ${resp}=  Provider Login      ${PUSERNAME23}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${id}   ${resp.json()['id']}
    
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

    ${resp}=                      Update Prescription Template    ${p1id1}  ${templateName1}  ${pre_list1}  
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200

    ${resp}=                      Get Prescription Template
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200

JD-TC-UpdatePrescriptionTemplate-4

    [Documentation]                Update Prescription Template without login

    ${pre_list1}=                 Create Dictionary  medicine_name=${med_name1}  frequency=${frequency1}  instructions=${instrn1}  duration=${duration1}  dosage=${dosage1}
    ${p1id1}=                     FakerLibrary.Random Number
    ${resp}=                      Update Prescription Template    ${p1id1}  ${templateName1}  ${pre_list1}  
    Log                           ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  419
    Should Be Equal As Strings    ${resp.json()}   ${SESSION_EXPIRED}
