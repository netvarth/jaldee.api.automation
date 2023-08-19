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
                                  
JD-TC-CreateprescriptionTemplate-1
                                  
    [Documentation]               Create prescription Template

    ${resp}=  Provider Login      ${PUSERNAME98}  ${PASSWORD}
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
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200

JD-TC-CreateprescriptionTemplate-2
                                  
    [Documentation]               Create prescription Template with multiple prescription

    ${resp}=  Provider Login      ${PUSERNAME98}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${id}   ${resp.json()['id']}
    ${templateName2}              FakerLibrary.sentence
    ${pre_list1}=                 Create Dictionary  medicine_name=${med_name1}  frequency=${frequency1}  instructions=${instrn1}  duration=${duration1}  dosage=${dosage1}
    ${pre_list2}=                 Create Dictionary  medicine_name=${med_name2}  frequency=${frequency2}  instructions=${instrn2}  duration=${duration2}  dosage=${dosage2}  imageSize=${imageSize2}

    ${resp}=                      Create Prescription Template  ${templateName2}  ${pre_list1}  ${pre_list2}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200

JD-TC-CreateprescriptionTemplate-3

    [Documentation]               Create prescription Template where template name as empty

    ${resp}=  Provider Login      ${PUSERNAME98}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${id}   ${resp.json()['id']}

    ${pre_list1}=                 Create Dictionary  medicine_name=${med_name1}  frequency=${frequency1}  instructions=${instrn1}  duration=${duration1}  dosage=${dosage1}

    ${resp}=                      Create Prescription Template  ${empty}  ${pre_list1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200

JD-TC-CreateprescriptionTemplate-4

    [Documentation]               Create prescription Template Where medicine name as empty

    ${resp}=  Provider Login      ${PUSERNAME98}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${id}   ${resp.json()['id']}
    ${templateName3}              FakerLibrary.sentence

    ${pre_list1}=                 Create Dictionary  medicine_name=${empty}  frequency=${frequency1}  instructions=${instrn1}  duration=${duration1}  dosage=${dosage1}

    ${resp}=                      Create Prescription Template  ${templateName3}  ${pre_list1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200

JD-TC-CreateprescriptionTemplate-5

    [Documentation]               Create prescription Template Where frequency as empty

    ${resp}=  Provider Login      ${PUSERNAME98}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${id}   ${resp.json()['id']}
    ${templateName4}              FakerLibrary.sentence

    ${pre_list1}=                 Create Dictionary  medicine_name=${med_name1}  frequency=${empty}  instructions=${instrn1}  duration=${duration1}  dosage=${dosage1}

    ${resp}=                      Create Prescription Template  ${templateName4}  ${pre_list1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200

JD-TC-CreateprescriptionTemplate-6

    [Documentation]               Create prescription Template Where instructions as empty

    ${resp}=  Provider Login      ${PUSERNAME98}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${id}   ${resp.json()['id']}
    ${templateName5}              FakerLibrary.sentence

    ${pre_list1}=                 Create Dictionary  medicine_name=${med_name1}  frequency=${frequency1}  instructions=${empty}  duration=${duration1}  dosage=${dosage1}

    ${resp}=                      Create Prescription Template  ${templateName5}  ${pre_list1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200

JD-TC-CreateprescriptionTemplate-7

    [Documentation]               Create prescription Template Where duration as empty

    ${resp}=  Provider Login      ${PUSERNAME98}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${id}   ${resp.json()['id']}
    ${templateName6}              FakerLibrary.sentence

    ${pre_list1}=                 Create Dictionary  medicine_name=${med_name1}  frequency=${frequency1}  instructions=${instrn1}  duration=${empty}  dosage=${dosage1}

    ${resp}=                      Create Prescription Template  ${templateName6}  ${pre_list1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200

JD-TC-CreateprescriptionTemplate-8

    [Documentation]               Create prescription Template Where dosage as empty

    ${resp}=  Provider Login      ${PUSERNAME98}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${id}   ${resp.json()['id']}
    ${templateName7}              FakerLibrary.sentence

    ${pre_list1}=                 Create Dictionary  medicine_name=${med_name1}  frequency=${frequency1}  instructions=${instrn1}  duration=${duration1}  dosage=${empty}

    ${resp}=                      Create Prescription Template  ${templateName7}  ${pre_list1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200

JD-TC-CreateprescriptionTemplate-9

    [Documentation]               Create prescription Template Where everything is empty

    ${resp}=  Provider Login      ${PUSERNAME98}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${id}   ${resp.json()['id']}
    ${templateName8}              FakerLibrary.sentence

    ${pre_list1}=                 Create Dictionary  medicine_name=${empty}  frequency=${empty}  instructions=${empty}  duration=${empty}  dosage=${empty}

    ${resp}=                      Create Prescription Template  ${templateName8}  ${pre_list1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  200

JD-TC-CreateprescriptionTemplate-UH1
                                  
    [Documentation]               Create prescription Template with existing Template Name

    ${resp}=  Provider Login      ${PUSERNAME98}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable    ${id}   ${resp.json()['id']}
    ${templateName2}              FakerLibrary.sentence
    ${pre_list1}=                 Create Dictionary  medicine_name=${med_name1}  frequency=${frequency1}  instructions=${instrn1}  duration=${duration1}  dosage=${dosage1}

    ${resp}=                      Create Prescription Template  ${templateName1}  ${pre_list1}
    Log                           ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}   ${TEMPLATE_NAME_ALREADY_EXISTS}