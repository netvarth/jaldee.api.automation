*** Settings ***

Suite Teardown    Delete All Sessions
Force Tags        Consumer Signup
Library           Collections
Library           OperatingSystem
Library           String
Library           json
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Library           FakerLibrary

***Variables***
${CUSERPH}      ${CUSERNAME}


*** Test Cases ***
Clear Files
    Remove Files   ${EXECDIR}/TDD/varfiles/consumerlist.py  ${EXECDIR}/TDD/varfiles/consumermail.py
    Create File   ${EXECDIR}/TDD/varfiles/consumerlist.py   
    Create File   ${EXECDIR}/TDD/varfiles/consumermail.py


JD-TC-Consumer Signup-1
    [Documentation]   Signup Jaldee Consumers
    Remove File   ${EXECDIR}/TDD/varfiles/consumermail.py
    Create File   ${EXECDIR}/TDD/varfiles/consumermail.py
    Remove File   ${EXECDIR}/TDD/varfiles/consumerlist.py
    Create File   ${EXECDIR}/TDD/varfiles/consumerlist.py
    Set Global Variable  ${US}  0
    FOR  ${c_count}  IN RANGE  ${consumer_count} 
        ${CUSERNAME}=  Evaluate  ${CUSERNAME}+1
        ${CUSERNAME_SECOND}=  Evaluate  ${CUSERNAME}+1000
        Set Global Variable  ${CUSERNAME}
        ${firstname}=  FakerLibrary.name
        ${lastname}=  FakerLibrary.last_name
        ${address}=  FakerLibrary.address
        ${dob}=  FakerLibrary.Date
        # ${gender}    Random Element    ['Male', 'Female']
        ${gender}    Random Element    ${Genderlist}
        ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERNAME}  ${CUSERNAME_SECOND}  ${dob}  ${gender}   ${EMPTY}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Consumer Activation  ${CUSERNAME}  1
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Consumer Set Credential  ${CUSERNAME}  ${PASSWORD}  1
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Consumer Login  ${CUSERNAME}  ${PASSWORD} 
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Send Verify Login Consumer   ${C_Email}${CUSERNAME}.${test_mail}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Verify Login Consumer  ${C_Email}${CUSERNAME}.${test_mail}  5
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Append To File  ${EXECDIR}/TDD/varfiles/consumermail.py  CUSEREMAIL${US}="${C_Email}${CUSERNAME}.${test_mail}"${\n}
        Append To File  ${EXECDIR}/TDD/varfiles/consumerlist.py  CUSERNAME${US}=${CUSERNAME}${\n}
        Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERNAME}${\n}
        ${US} =  Evaluate  ${US}+1
        Set Global Variable  ${US}

        ${resp}=  Update Consumer Profile  ${firstname}  ${lastname}  ${address}  ${dob}  ${gender}   email=${C_Email}${CUSERNAME}.${test_mail}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    ${invalid}=  Evaluate  ${CUSERNAME}+10
    Append To File  ${EXECDIR}/TDD/varfiles/consumerlist.py   Invalid_CUSER=${invalid}${\n}   

    Log  \n${c_count} jaldee consumers signedup   console=yes                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     